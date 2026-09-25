import { execFileSync, execSync } from "node:child_process";

/**
 * Format Dart code using `dart format`.
 * Falls back to returning the unformatted code if Dart is not available.
 */
export function formatDartCode(code: string): string {
  try {
    const result = execSync("dart format --output=show", {
      input: code,
      encoding: "utf-8",
      timeout: 30_000,
      stdio: ["pipe", "pipe", "pipe"],
    });
    return result;
  } catch {
    // If dart format is not available, return as-is
    return code;
  }
}

/**
 * Format all Dart files in a directory using `dart format`.
 */
export function formatDartDirectory(dir: string): void {
  execFileSync("dart", ["format", "--", dir], {
    encoding: "utf-8",
    timeout: 60_000,
    stdio: ["pipe", "pipe", "pipe"],
  });
}
