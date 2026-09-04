#!/usr/bin/env python3
"""Generate logo candidates for Solana Kit via Hugging Face Inference Providers.

Usage (secrets injected by monosecret):
    monosecret -f ~/monosecret.toml --reason "..." run -- python3 generate_logos.py

Writes square JPEGs into ../candidates/ (relative to this script).
"""

from concurrent.futures import ThreadPoolExecutor
import json
import os
import sys
import urllib.error
import urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
OUT_DIR = os.path.join(HERE, "candidates")
os.makedirs(OUT_DIR, exist_ok=True)

TOKEN = os.environ.get("HUGGING_FACE_TOKEN", "")
if not TOKEN:
    sys.exit("HUGGING_FACE_TOKEN not available; run inside `monosecret run --`")

MODEL = "stabilityai/stable-diffusion-3-medium-diffusers"
URL = f"https://router.huggingface.co/hf-inference/models/{MODEL}"

BASE = (
    "professional flat vector logo design, minimal geometric icon, "
    "Solana brand style smooth diagonal gradient from magenta #9945FF "
    "through violet to bright green #14F195, deep dark navy background #0A0E18, "
    "centered composition, crisp sharp edges, clean silhouette, premium "
    "developer-tool brand identity, high quality, "
)

NO_POS = {
    True: 'geometric interlocked monogram letters "SK", bold rounded sans-serif letterforms',
    False: "no text, no letters, no words, no watermark",
}

CONCEPTS = [
    (1, "bars-s", False, "three parallel skewed gradient bars stacked in offset rows, homage to the Solana logo, bars varying in width"),
    (2, "glow-dot", False, "a single glowing gradient sphere centered above three small skewed gradient bars underneath"),
    (3, "dart-chevron", False, "three gradient bars converging into a sharp upward chevron arrowhead"),
    (4, "toolbox-slats", False, "abstract geometric toolbox silhouette with open lid formed by gradient slats"),
    (5, "bars-s-mark", False, "a stylized letter S shape assembled from three skewed parallelogram bars"),
    (6, "crate-beams", False, "isometric open crate emitting beams of gradient light upward"),
    (7, "target-dart", False, "a dart arrow hitting the center of concentric gradient target rings"),
    (8, "stack-dot", False, "three stacked glowing gradient layers forming an abstract stack, small sphere floating above"),
    (9, "k-dot", False, "bold letter K built from two clean geometric strokes with a glowing gradient dot"),
    (10, "wrench", False, "a minimal geometric wrench crossed with a gradient bar inside a rounded square"),
    (11, "hex-cartridge", False, "a hexagonal container holding three parallel gradient bars like a code cartridge"),
    (12, "rising-arrow", False, "three gradient bars morphing into one rising arrow with a glowing dot at its tip"),
    (13, "sk-monogram", True, "")  # text handled specially
    ,
    (14, "terminal", False, "a rounded terminal window shape with a gradient prompt cursor dot, bars radiating inside"),
    (15, "gem", False, "a faceted geometric gemstone assembled from triangular gradient facets"),
    (16, "orbit", False, "a gradient sphere with a thin elliptical orbit ring passing behind it"),
    (17, "slab-box", False, "three vertical gradient slabs forming the walls of an abstract open box, one corner cut"),
    (18, "wing-mark", False, "two gradient bars sweeping upward like wind wings with a small glowing dot between them"),
    (19, "shield", False, "a minimal rounded shield outline filled with three horizontal skewed gradient bars"),
    (20, "node-graph", False, "five connected circular nodes forming a simple constellation, all gradient colored, outer nodes smaller"),
]


def build_prompt(idx, slug, allow_text, extra):
    if allow_text:
        # SD3 short-text friendly, still conservative
        return (
            "professional flat vector app-icon logo on deep dark navy background "
            "#0A0E18, geometric interlocked monogram of the letters S and K, bold "
            "rounded sans-serif letterforms filled with a smooth Solana-branded "
            "diagonal gradient from magenta #9945FF to bright green #14F195, "
            "centered, crisp edges, premium developer-tool brand identity, "
            "minimal, high quality, no extra text, no watermark"
        )
    return BASE + extra + ", " + NO_POS[False]


def generate(item):
    idx, slug, allow_text, extra = item
    prompt = build_prompt(*item)
    payload = {
        "inputs": prompt,
        "parameters": {
            "width": 1024,
            "height": 1024,
            "num_inference_steps": 28,
            "guidance_scale": 4.5,
            "seed": 1000 + idx * 7919,
            "negative_prompt": "photo, photograph, realistic, blurry, jpeg artifacts, watermark, signature, frame, border pattern, busy, clutter",
        },
    }
    out_path = os.path.join(OUT_DIR, f"{idx:02d}-{slug}.jpg")
    if os.path.exists(out_path) and os.path.getsize(out_path) > 10000:
        return f"skip {idx:02d}-{slug} (exists)"
    req = urllib.request.Request(
        URL,
        data=json.dumps(payload).encode(),
        headers={
            "Authorization": f"Bearer {TOKEN}",
            "Content-Type": "application/json",
        },
        method="POST",
    )
    for attempt in range(3):
        try:
            with urllib.request.urlopen(req, timeout=180) as resp:
                data = resp.read()
            if len(data) < 5000 or not data[:3] == b"\xff\xd8\xff":
                raise RuntimeError(f"unexpected payload ({len(data)} bytes)")
            with open(out_path, "wb") as fh:
                fh.write(data)
            return f"ok   {idx:02d}-{slug} ({len(data)//1024} KiB)"
        except Exception as exc:  # noqa: BLE001
            err = str(exc)[:120]
            if attempt == 2:
                return f"FAIL {idx:02d}-{slug}: {err}"
    return f"FAIL {idx:02d}-{slug}: unreachable"


def main():
    workers = min(4, os.cpu_count() or 2)
    with ThreadPoolExecutor(max_workers=workers) as pool:
        for line in pool.map(generate, CONCEPTS):
            print(line, flush=True)


if __name__ == "__main__":
    main()