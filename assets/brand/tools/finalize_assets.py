#!/usr/bin/env python3
"""Build the final Solana Kit logo set from the winning Gen-2 candidate (#7 Flight Fin).

Run with the venv: /tmp/logovenv/bin/python finalize_assets.py
Outputs land in ../assets/ and ../../docs/site/web/.
"""

from pathlib import Path
from PIL import Image
import vtracer

HERE = Path(__file__).resolve().parent
WT = HERE.parent  # worktree root
ASSETS = WT / "assets"
BRAND = ASSETS / "brand"
REFS = HERE / "candidates-v2"
SITE_WEB = WT / "docs" / "site" / "web"

WINNER = REFS / "07-flight-fin.jpg"
BACKUP = REFS / "02-taper-bars.jpg"

# --- archive originals: winner + designated backup, committed for reuse ---
(BRAND / "reference").mkdir(parents=True, exist_ok=True)

# --- 1) trace winner to SVG ---
svg_tmp = HERE / "traced.svg"
vtracer.convert_image_to_svg_py(
    str(WINNER),
    str(svg_tmp),
    colormode="color",
    hierarchical="stacked",
    mode="spline",
    filter_speckle=8,
    color_precision=7,
    layer_difference=24,
    corner_threshold=45,
    length_threshold=6.0,
    max_iterations=12,
    splice_threshold=45,
    path_precision=2,
)

svg = svg_tmp.read_text()
svg = svg.replace("<svg", '<svg role="img" preserveAspectRatio="xMidYMid meet"', 1)
if 'viewBox' not in svg:
    svg = svg.replace("<svg", '<svg viewBox="0 0 1024 1024"', 1)
svg = svg.replace(
    ">",
    ">\n  <title>Solana Kit</title>",
    1,
)
path_count = svg.count("<path")
svg_size = len(svg.encode())
print(f"traced svg: {path_count} paths, {svg_size/1024:.1f} KiB")

# --- 2) write assets ---
(ASSETS / "solana-kit-icon.svg").write_text(svg)

img = Image.open(WINNER).convert("RGB")
img.save(ASSETS / "solana-kit-icon.png", optimize=True)
print(f"assets/solana-kit-icon.png: {img.size}")

for ref in (WINNER, BACKUP):
    ref_path = BRAND / "reference" / ref.name
    ref_path.write_bytes(ref.read_bytes())
    print(f"archived {ref_path.relative_to(WT)}")

# --- 3) docs site favicon + logo ---
favicon_src = img.convert("RGBA")
(IMAGE_PATH := SITE_WEB / "images" / "logo.svg").write_text(svg)
(SITE_WEB / "favicon.svg").write_text(svg)
favicon_src.save(
    SITE_WEB / "favicon.ico",
    format="ICO",
    sizes=[(16, 16), (32, 32), (48, 48)],
)
print("site: logo.svg, favicon.svg, favicon.ico written")

# favicon sanity
ico = Image.open(SITE_WEB / "favicon.ico")
print(f"favicon.ico layer: {ico.size}, frames: {getattr(ico, 'n_frames', 1) + 1}")