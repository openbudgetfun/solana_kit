#!/usr/bin/env python3
from __future__ import annotations

import json
import re
import shutil
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
CONFIG_PATH = REPO_ROOT / 'config' / 'coverage-risk-tier-thresholds.json'


def parse_lcov(lcov_path: Path) -> tuple[int, int]:
    text = lcov_path.read_text()
    total_found = 0
    total_hit = 0
    for block in text.split('end_of_record'):
      found_match = re.search(r'LF:(\d+)', block)
      hit_match = re.search(r'LH:(\d+)', block)
      if found_match and hit_match:
          total_found += int(found_match.group(1))
          total_hit += int(hit_match.group(1))
    return total_hit, total_found


def main() -> int:
    config = json.loads(CONFIG_PATH.read_text())
    packages: list[dict[str, object]] = config['packages']
    failures: list[str] = []

    print('Running risk-tier package coverage checks...')
    for package_config in packages:
        package_name = str(package_config['package'])
        risk = str(package_config['risk'])
        minimum = float(package_config['minimumLineCoverage'])
        package_dir = REPO_ROOT / 'packages' / package_name
        coverage_dir = package_dir / 'coverage'
        lcov_path = coverage_dir / 'lcov.info'

        print(f'\n[{risk}] {package_name} (min {minimum:.0f}%)')
        shutil.rmtree(coverage_dir, ignore_errors=True)
        subprocess.run(
            ['dart', 'run', 'coverage:test_with_coverage', 'test'],
            cwd=package_dir,
            check=True,
        )

        if not lcov_path.exists():
            failures.append(f'{package_name}: missing coverage/lcov.info output')
            continue

        lines_hit, lines_found = parse_lcov(lcov_path)
        percentage = 100.0 if lines_found == 0 else (lines_hit / lines_found) * 100.0
        print(f'  line coverage: {lines_hit}/{lines_found} ({percentage:.2f}%)')

        if percentage < minimum:
            failures.append(
                f'{package_name}: {percentage:.2f}% < required {minimum:.0f}%'
            )

    if failures:
        print('\nCoverage threshold failures:')
        for failure in failures:
            print(f'  - {failure}')
        return 1

    print('\nAll risk-tier package coverage floors passed.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
