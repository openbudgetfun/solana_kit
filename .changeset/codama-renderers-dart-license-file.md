---
"codama-renderers-dart": patch
---

# Add the MIT LICENSE file to the renderer package

`packages/codama-renderers-dart` declared `"license": "MIT"` in its `package.json` but never shipped the license text itself. The file now matches the MIT LICENSE used by every other package in the workspace, satisfying the repo-wide package rule and making the license discoverable from a plain clone of the npm package.
