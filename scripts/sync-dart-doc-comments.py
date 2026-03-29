#!/usr/bin/env python3
from __future__ import annotations

import argparse
import difflib
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Tuple, Union


PROVIDER_START_RE = re.compile(r"<!--\s*\{@([A-Za-z0-9_]+)(?::[^}]*)?\}\s*-->")
PROVIDER_END_RE = re.compile(r"<!--\s*\{/([A-Za-z0-9_]+)\}\s*-->")
CONSUMER_START_RE = re.compile(
    r"^(?P<indent>\s*)///\s*<!--\s*\{=(?P<name>[A-Za-z0-9_]+)(?P<transforms>[^}]*)\}\s*-->\s*$"
)
CONSUMER_END_RE = re.compile(
    r"^(?P<indent>\s*)///\s*<!--\s*\{/(?P<name>[A-Za-z0-9_]+)\}\s*-->\s*$"
)
SUPPORTED_TRANSFORMS = {"replace", "trim", "trimStart", "trimEnd"}


@dataclass(frozen=True)
class ReplaceTransform:
    old: str
    new: str


Transform = Union[Tuple[str], Tuple[str, ReplaceTransform]]


@dataclass(frozen=True)
class ConsumerBlock:
    path: Path
    name: str
    start_index: int
    end_index: int
    transforms: tuple[Transform, ...]


class ParseError(RuntimeError):
    pass


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Synchronize Dart /// doc comment consumers from markdown template "
            "provider blocks."
        )
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="Validate that Dart doc comment consumers are up to date.",
    )
    parser.add_argument(
        "--write",
        action="store_true",
        help="Rewrite stale Dart doc comment consumers (default).",
    )
    return parser.parse_args()


def decode_quoted(text: str, index: int) -> tuple[str, int]:
    if index >= len(text) or text[index] != '"':
        raise ParseError(f'Expected quoted string at offset {index}: {text!r}')

    index += 1
    value_chars: list[str] = []
    while index < len(text):
        char = text[index]
        if char == '\\':
            index += 1
            if index >= len(text):
                raise ParseError(f'Invalid trailing escape in transform: {text!r}')
            escape = text[index]
            escapes = {
                '"': '"',
                '\\': '\\',
                'n': '\n',
                'r': '\r',
                't': '\t',
            }
            value_chars.append(escapes.get(escape, escape))
            index += 1
            continue
        if char == '"':
            return ''.join(value_chars), index + 1
        value_chars.append(char)
        index += 1

    raise ParseError(f'Unterminated quoted string in transform: {text!r}')


def parse_transforms(raw: str) -> tuple[Transform, ...]:
    text = raw.strip()
    if not text:
        return ()

    index = 0
    transforms: list[Transform] = []
    while index < len(text):
        if text[index] != '|':
            raise ParseError(f'Expected `|` in transform list: {text!r}')
        index += 1

        name_start = index
        while index < len(text) and text[index] not in ':|':
            index += 1
        name = text[name_start:index].strip()
        if name not in SUPPORTED_TRANSFORMS:
            raise ParseError(f'Unsupported transform `{name}` in {text!r}')

        if name == 'replace':
            if index >= len(text) or text[index] != ':':
                raise ParseError(f'`replace` requires two quoted arguments: {text!r}')
            index += 1
            old, index = decode_quoted(text, index)
            if index >= len(text) or text[index] != ':':
                raise ParseError(f'`replace` requires two quoted arguments: {text!r}')
            index += 1
            new, index = decode_quoted(text, index)
            transforms.append((name, ReplaceTransform(old=old, new=new)))
        else:
            transforms.append((name,))

    return tuple(transforms)


def apply_transforms(content: str, transforms: Iterable[Transform]) -> str:
    rendered = content
    for transform in transforms:
        kind = transform[0]
        if kind == 'replace':
            replacement = transform[1]
            assert isinstance(replacement, ReplaceTransform)
            rendered = rendered.replace(replacement.old, replacement.new)
        elif kind == 'trim':
            rendered = rendered.strip()
        elif kind == 'trimStart':
            rendered = rendered.lstrip()
        elif kind == 'trimEnd':
            rendered = rendered.rstrip()
        else:
            raise ParseError(f'Unsupported transform {kind!r}')
    return rendered


def parse_providers(repo_root: Path) -> dict[str, str]:
    providers: dict[str, str] = {}
    for template_path in sorted(repo_root.glob('*.t.md')):
        lines = template_path.read_text().splitlines()
        index = 0
        while index < len(lines):
            start_match = PROVIDER_START_RE.search(lines[index])
            if not start_match:
                index += 1
                continue

            name = start_match.group(1)
            end_index = index + 1
            while end_index < len(lines):
                end_match = PROVIDER_END_RE.search(lines[end_index])
                if end_match and end_match.group(1) == name:
                    break
                end_index += 1
            else:
                raise ParseError(
                    f'Missing provider end tag for `{name}` in {template_path}'
                )

            if name in providers:
                raise ParseError(
                    f'Duplicate provider `{name}` found in {template_path} '
                    f'and another template file.'
                )
            providers[name] = '\n'.join(lines[index + 1 : end_index])
            index = end_index + 1
    return providers


def iter_consumer_blocks(path: Path) -> list[ConsumerBlock]:
    lines = path.read_text().splitlines()
    blocks: list[ConsumerBlock] = []
    index = 0
    while index < len(lines):
        start_match = CONSUMER_START_RE.match(lines[index])
        if not start_match:
            index += 1
            continue

        name = start_match.group('name')
        transforms = parse_transforms(start_match.group('transforms'))
        end_index = index + 1
        while end_index < len(lines):
            end_match = CONSUMER_END_RE.match(lines[end_index])
            if end_match and end_match.group('name') == name:
                break
            end_index += 1
        else:
            raise ParseError(f'Missing consumer end tag for `{name}` in {path}')

        blocks.append(
            ConsumerBlock(
                path=path,
                name=name,
                start_index=index,
                end_index=end_index,
                transforms=transforms,
            )
        )
        index = end_index + 1
    return blocks


def render_doc_comment(content: str) -> list[str]:
    lines = content.split('\n')
    if lines == ['']:
        return ['///']

    rendered: list[str] = []
    for line in lines:
        if line:
            rendered.append(f'/// {line}')
        else:
            rendered.append('///')
    return rendered


def update_file(path: Path, providers: dict[str, str], write: bool) -> tuple[bool, str]:
    original_text = path.read_text()
    lines = original_text.splitlines()
    blocks = iter_consumer_blocks(path)
    if not blocks:
        return False, ''

    updated_lines = list(lines)
    delta = 0
    changed = False

    for block in blocks:
        if block.name not in providers:
            raise ParseError(f'No provider found for consumer `{block.name}` in {path}')

        rendered = apply_transforms(providers[block.name], block.transforms)
        replacement = render_doc_comment(rendered)

        start = block.start_index + 1 + delta
        end = block.end_index + delta
        current = updated_lines[start:end]
        if current != replacement:
            updated_lines[start:end] = replacement
            delta += len(replacement) - len(current)
            changed = True

    if not changed:
        return False, ''

    new_text = '\n'.join(updated_lines)
    if original_text.endswith('\n'):
        new_text += '\n'

    diff = ''.join(
        difflib.unified_diff(
            original_text.splitlines(keepends=True),
            new_text.splitlines(keepends=True),
            fromfile=str(path),
            tofile=str(path),
        )
    )

    if write:
        path.write_text(new_text)

    return True, diff


def main() -> int:
    args = parse_args()
    write = not args.check or args.write

    repo_root = Path(__file__).resolve().parent.parent
    providers = parse_providers(repo_root)
    dart_files = sorted(repo_root.glob('packages/*/lib/**/*.dart'))

    changed_paths: list[Path] = []
    diffs: list[str] = []
    consumer_count = 0

    for path in dart_files:
        blocks = iter_consumer_blocks(path)
        if not blocks:
            continue
        consumer_count += len(blocks)
        changed, diff = update_file(path, providers, write=write)
        if changed:
            changed_paths.append(path)
            diffs.append(diff)

    mode = 'Updated' if write else 'Checked'
    if not changed_paths:
        print(
            f'{mode} {consumer_count} Dart doc comment consumer block(s); '
            'all are up to date.'
        )
        return 0

    if write:
        print(
            f'Updated {len(changed_paths)} file(s) across {consumer_count} '
            'Dart doc comment consumer block(s).'
        )
        return 0

    print(
        f'{len(changed_paths)} file(s) have stale Dart doc comment consumers '
        f'across {consumer_count} block(s).',
        file=sys.stderr,
    )
    for diff in diffs:
        print(diff, file=sys.stderr, end='')
    return 1


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except ParseError as error:
        print(f'error: {error}', file=sys.stderr)
        raise SystemExit(2)
