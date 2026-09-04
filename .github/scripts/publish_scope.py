#!/usr/bin/env python3
"""Resolve the publish schedule for a MonoChange release tag.

The publish workflow (`.github/workflows/publish.yml`) publishes MonoChange
release records to their trusted publishing sources (pub.dev via OIDC, npm
via provenance). pub.dev Trusted Publishing only accepts a workflow run whose
triggering ref equals the per-package tag pattern resolved with the version
being published, so a monorepo release cannot publish mixed versions from a
single run. Instead, one release tag per version group drives publishing:

- primary group targets tag as `v{{version}}` (for example `v0.9.1`) and
  their run acts as the release orchestrator;
- namespaced targets tag as `<id>/v{{version}}` (for example
  `solana_kit_token/v0.8.1`) and are published by child runs that the
  orchestrator dispatches with `workflow_dispatch` on that tag.

This script reads the release record (`monochange step release-record`) and
the workspace package graph (`monochange step discover`) and emits a JSON
schedule:

- `role: orchestrator` runs own the primary tag. Their batches publish the
  primary packages and dispatch/await a child run for every other release
  target, in topological dependency order, so a package is only published
  after the versions it depends on are on pub.dev.
- `role: contributor` runs own one namespaced tag. Their batches publish that
  tag's packages once the sibling versions they depend on are visible on
  pub.dev (which the orchestrator guarantees by dispatch order).
- Runs whose tag owns no release-plan publications report `status: skip`.

Batch shape:
  {"publish": [...package names...], "dispatch": [{"tag": ..., "packages": [...]}],
   "wait_for": [{"package": ..., "version": ...}]}

Orchestrator batches rely on sequential execution (each batch's dispatches
are awaited before the next batch starts), so they carry no `wait_for`.
Contributor batches poll `wait_for` versions on pub.dev before publishing,
which also makes manual single-tag retries safe to run at any time.

Usage:
  publish_scope.py --record <record.json> --discover <discover.json> \
    --tag <release tag> --output <scope.json>
"""

from __future__ import annotations

import argparse
import json
import sys

GITHUB_ERROR_PREFIX = "::error::"


def fail(message: str) -> None:
    """Report a workflow error annotation and exit nonzero."""
    print(f"{GITHUB_ERROR_PREFIX}{message}", file=sys.stderr)
    raise SystemExit(1)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Resolve the publish schedule for a MonoChange release tag.",
    )
    parser.add_argument(
        "--record",
        required=True,
        help="Path to `monochange step release-record --format json` output.",
    )
    parser.add_argument(
        "--discover",
        required=True,
        help="Path to `monochange step discover --format json` output.",
    )
    parser.add_argument("--tag", required=True, help="Release tag being published.")
    parser.add_argument(
        "--output",
        required=True,
        help="Path where the resolved publish scope JSON is written.",
    )
    return parser.parse_args()


def load_json(path: str, label: str) -> dict:
    try:
        with open(path, encoding="utf-8") as handle:
            return json.load(handle)
    except FileNotFoundError:
        fail(f"{label} not found at {path}.")
    except json.JSONDecodeError as error:
        fail(f"{label} at {path} is not valid JSON: {error}")
    raise AssertionError("unreachable")


def resolve_target(targets: list, tag: str) -> dict:
    matching = [target for target in targets if target.get("tag_name") == tag]
    if len(matching) == 0:
        known = ", ".join(
            str(target.get("tag_name", "<untagged>")) for target in targets
        )
        fail(
            f"Tag '{tag}' does not match any MonoChange release target. "
            "Publishing is only allowed from release tags created by "
            f"monochange. Known release tags: {known}."
        )
    if len(matching) > 1:
        fail(f"Tag '{tag}' unexpectedly matches multiple release targets.")
    return matching[0]


def release_owner_tag(targets: list) -> str | None:
    """Pick the single tag whose run orchestrates the whole release.

    The primary-version group target (for example `main` tagging `v0.9.1`)
    orchestrates. When the record has no primary group target, the first
    tagged target orchestrates so scoped-only releases still publish.
    """
    for target in targets:
        if (
            target.get("kind") == "group"
            and target.get("version_format") == "primary"
            and target.get("tag_name")
        ):
            return target["tag_name"]
    for target in targets:
        if target.get("tag_name"):
            return target["tag_name"]
    return None


def dart_package_metadata(discover: dict) -> tuple[dict[str, str], set[str]]:
    """Return (id -> dart package name, set of private package names)."""
    name_by_id: dict[str, str] = {}
    private: set[str] = set()
    for package in discover.get("packages", []):
        if package.get("ecosystem") != "dart" or not package.get("name"):
            continue
        name_by_id[package["id"]] = package["name"]
        if package.get("publish_state") == "private":
            private.add(package["name"])
    return name_by_id, private


def build_dependency_graph(
    discover: dict, name_by_id: dict[str, str]
) -> dict[str, set[str]]:
    """Map workspace package name -> set of direct workspace dependency names."""
    dependencies: dict[str, set[str]] = {}
    for edge in discover.get("dependencies", []):
        source = name_by_id.get(edge.get("from"))
        target = name_by_id.get(edge.get("to"))
        if source and target:
            dependencies.setdefault(source, set()).add(target)
    return dependencies


def topological_order(names: set[str], dependencies: dict[str, set[str]]) -> list[str]:
    """Order `names` so every member precedes members that depend on it.

    Dependencies outside `names` are ignored; cross-target dependencies are
    handled by the scheduler and (for contributors) registry polling.
    """
    remaining = {
        name: {dep for dep in dependencies.get(name, set()) if dep in names}
        for name in names
    }
    order: list[str] = []
    resolved: set[str] = set()
    while remaining:
        ready = sorted(
            name for name, deps in remaining.items() if deps <= resolved
        )
        if not ready:
            cycle = ", ".join(sorted(remaining))
            fail(
                "Dependency cycle detected between release packages: "
                f"{cycle}. Cannot derive a publish order."
            )
        for name in ready:
            order.append(name)
            resolved.add(name)
            del remaining[name]
    return order


def build_orchestrator_batches(
    order: list[str],
    dependencies: dict[str, set[str]],
    plan_packages: set[str],
    own_members: set[str],
    target_of_package: dict[str, str],
    tag_of_target: dict[str, str],
) -> list[dict]:
    """Batch the whole release into a sequential, dependency-safe schedule.

    Each round collects every package whose in-release dependencies were
    scheduled by earlier rounds. Own (primary) packages are published by the
    orchestrator itself; a foreign release target is dispatched as one child
    run once all of its in-release members are eligible.
    """
    scheduled: set[str] = set()
    remaining = list(order)
    batches: list[dict] = []

    while remaining:
        eligible = [
            package
            for package in remaining
            if all(
                dependency in scheduled or dependency not in plan_packages
                for dependency in dependencies.get(package, set())
            )
        ]
        publish_now = [
            package for package in eligible if package in own_members
        ]
        dispatch_targets = sorted(
            {
                target_of_package[package]
                for package in eligible
                if package not in own_members
            }
        )
        dispatch_now = []
        dispatched_members: set[str] = set()
        for target_id in dispatch_targets:
            members = [
                package
                for package in remaining
                if target_of_package.get(package) == target_id
            ]
            # A target dispatches once every member's dependencies that live
            # OUTSIDE the target are scheduled. Dependencies between members
            # of the same target are handled by the child run itself, which
            # publishes its members in topological order.
            externally_ready = all(
                dependency in scheduled
                or dependency not in plan_packages
                or target_of_package.get(dependency) == target_id
                for member in members
                for dependency in dependencies.get(member, set())
            )
            if externally_ready:
                dispatch_now.append(
                    {
                        "tag": tag_of_target[target_id],
                        "packages": sorted(members),
                    }
                )
                dispatched_members.update(members)

        if not publish_now and not dispatch_now:
            blocked = ", ".join(sorted(remaining))
            fail(
                "Publish schedule stalled: no package became eligible. "
                f"Blocked packages: {blocked}."
            )

        batches.append(
            {
                "publish": publish_now,
                "dispatch": dispatch_now,
                "wait_for": [],
            }
        )
        scheduled.update(publish_now)
        scheduled.update(dispatched_members)
        remaining = [package for package in remaining if package not in scheduled]

    return batches


def build_contributor_batches(
    order: list[str],
    dependencies: dict[str, set[str]],
    plan_versions: dict[str, str],
    own_members: set[str],
) -> list[dict]:
    """Batch a contributor's own packages, waiting for sibling versions.

    A contributor publishes its own tag only. Each batch lists the sibling
    release versions its packages depend on; the run polls pub.dev until
    those versions are visible before publishing. This keeps manual single
    tag retries safe whenever they are dispatched.
    """
    batches: list[dict] = []
    batch: list[str] = []
    batch_waits: dict[str, str] = {}

    def flush() -> None:
        if not batch:
            return
        batches.append(
            {
                "publish": list(batch),
                "dispatch": [],
                "wait_for": [
                    {"package": name, "version": version}
                    for name, version in sorted(batch_waits.items())
                ],
            }
        )
        batch.clear()
        batch_waits.clear()

    for name in order:
        waits = {
            dependency: plan_versions[dependency]
            for dependency in sorted(dependencies.get(name, set()))
            if dependency in plan_versions and dependency not in own_members
        }
        if waits and batch:
            flush()
        batch.append(name)
        batch_waits.update(waits)
    flush()
    return batches


def main() -> None:
    args = parse_args()

    record = load_json(args.record, "release record")
    record_data = record.get("record")
    if not isinstance(record_data, dict):
        fail(
            f"Release record from {args.record} contains no release record "
            "payload. Run from a release tag or release commit."
        )

    targets = record_data.get("release_targets") or []
    plan = record_data.get("package_publications") or []
    versions = record_data.get("versions") or {}

    target = resolve_target(targets, args.tag)
    members = set(target.get("members") or [])
    owner_tag = release_owner_tag(targets)
    role = "orchestrator" if target.get("tag_name") == owner_tag else "contributor"

    discover = load_json(args.discover, "package discovery")
    name_by_id, private_names = dart_package_metadata(discover)
    dependencies = build_dependency_graph(discover, name_by_id)

    plan_versions = {
        publication["package"]: publication["version"]
        for publication in plan
        if publication.get("package") not in private_names
    }

    own_publications = [
        publication
        for publication in plan
        if publication.get("package") in members
        and publication.get("package") not in private_names
    ]

    for publication in own_publications:
        name = publication["package"]
        expected = versions.get(name)
        if expected is not None and publication["version"] != expected:
            fail(
                f"Release record is inconsistent for {name}: the publish "
                f"plan targets version {publication['version']} but the "
                f"record lists version {expected}."
            )

    own_names = {publication["package"] for publication in own_publications}
    plan_packages = set(plan_versions)

    if role == "orchestrator":
        target_of_package: dict[str, str] = {}
        tag_of_target: dict[str, str] = {}
        for entry in targets:
            tag_name = entry.get("tag_name")
            if not tag_name:
                continue
            tag_of_target[entry["id"]] = tag_name
            for member in entry.get("members") or []:
                target_of_package.setdefault(member, entry["id"])
        missing_tags = sorted(
            package
            for package in plan_packages
            if package not in own_names
            and target_of_package.get(package) not in tag_of_target
        )
        if missing_tags:
            fail(
                "Release plan contains packages without a tagged release "
                f"target: {', '.join(missing_tags)}. Cannot dispatch child "
                "publish runs for them."
            )
        order = topological_order(plan_packages, dependencies)
        batches = build_orchestrator_batches(
            order,
            dependencies,
            plan_packages,
            own_names,
            target_of_package,
            tag_of_target,
        )
    else:
        order = topological_order(own_names, dependencies)
        batches = build_contributor_batches(
            order, dependencies, plan_versions, own_names
        )

    scope = {
        "tag": args.tag,
        "role": role,
        "is_release_owner": target.get("tag_name") == owner_tag,
        "status": "publish" if own_publications else "skip",
        "target": {
            "id": target.get("id"),
            "kind": target.get("kind"),
            "version": target.get("version"),
            "tag_name": target.get("tag_name"),
        },
        "packages": [
            {
                "name": publication["package"],
                "version": publication["version"],
                "ecosystem": publication.get("ecosystem"),
                "registry": publication.get("registry"),
            }
            for publication in own_publications
        ],
        "has_npm": any(
            publication.get("ecosystem") == "npm"
            for publication in own_publications
        ),
        "batches": batches,
    }

    with open(args.output, "w", encoding="utf-8") as handle:
        json.dump(scope, handle, indent=2)
        handle.write("\n")

    print(
        f"Release tag {args.tag} -> target {target.get('id')} "
        f"({target.get('kind')}), role={role}, status={scope['status']}, "
        f"packages={len(own_publications)}, batches={len(batches)}, "
        f"release_owner={scope['is_release_owner']}"
    )
    for index, batch in enumerate(batches, start=1):
        parts = []
        if batch["publish"]:
            parts.append(f"publish {', '.join(batch['publish'])}")
        for dispatch in batch["dispatch"]:
            parts.append(
                f"dispatch {dispatch['tag']} ({', '.join(dispatch['packages'])})"
            )
        waits = [
            f"{entry['package']}@{entry['version']}"
            for entry in batch["wait_for"]
        ]
        if waits:
            parts.append(f"after {', '.join(waits)}")
        print(f"  batch {index}: {'; '.join(parts)}")


if __name__ == "__main__":
    main()