import { execSync } from "node:child_process";

/**
 * Format Dart code using `dart format`.
 * Falls back to returning the unformatted code if dart is not available.
 */
export function formatDartCode(code: string): string {
  try {
    const result = execSync("dart format --fix -", {
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
  try {
    execSync(`dart format --fix "${dir}"`, {
      encoding: "utf-8",
      timeout: 60_000,
      stdio: ["pipe", "pipe", "pipe"],
    });
  } catch {
    // Silently ignore if dart format is not available
  }
}
