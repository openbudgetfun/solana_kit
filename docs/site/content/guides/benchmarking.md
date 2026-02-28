---
title: Benchmarking
description: Measure performance, enforce baselines, and prevent regressions.
---

## Why Benchmarking Is Critical

In Solana workloads, tight loops around encoding, message compilation, and parsing directly affect user latency and infrastructure cost.

## Step 1: Pick Stable Benchmarks

Target deterministic, high-frequency paths:

- address validation and encode/decode
- transaction message compilation
- key derivation/signing hot paths
- RPC payload parsing and transformation

Reason: stable microbenchmarks produce actionable trend lines.

## Step 2: Freeze Input Fixtures

- commit representative fixture inputs.
- avoid network-dependent benchmark inputs.

Reason: fixture drift makes regression data unreliable.

## Step 3: Define Regression Policy

- set thresholds by operation class.
- require justification for regressions beyond threshold.

Reason: performance budgets should be explicit engineering policy.

## Step 4: Track Baseline and Prior Versions

- compare current branch vs baseline.
- compare current branch vs previous release tags.

Reason: catches both accidental slowdowns and long-term drift.

## Step 5: Report Meaningful Metrics

- median and p95 runtime
- throughput where relevant
- absolute delta and percent delta

Reason: single-number summaries hide variance and tail behavior.

## Step 6: Automate in CI

- run benchmark checks on PRs.
- upload machine-readable result artifacts.

Reason: manual-only benchmarking does not scale.
