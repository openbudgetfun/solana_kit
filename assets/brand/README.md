# Solana Kit brand assets

The pub.dev-safe, GitHub-safe logo references live one level up:

- `../solana-kit-icon.svg` — primary vector mark (full-bleed square, 1024×1024 viewBox)
- `../solana-kit-icon.png` — raster render used by `readme.md` (absolute URL so it renders on pub.dev too)

## Reference rasters (`reference/`)

Archived originals from the logo design exploration (Hugging Face Inference Providers, Stability AI SD3-medium, 1024×1024). The SVG is a vtracer color trace of the winning raster, cleaned up for production use.

- `07-flight-fin.jpg` — **winner**: Gen-2 "Flight Fin" dart, Solana gradient. Source of the current mark.
- `02-taper-bars.jpg` — **designated backup**: Gen-2 "Taper Bars" (Solana bars with a dart point). Kept as the fallback if the mark is ever redesigned.

Both are reproducible: see `tools/generate_logos_v2.py` (candidate generation via Hugging Face Inference Providers) and `tools/finalize_assets.py` (trace + favicon pipeline).
