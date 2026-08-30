#!/usr/bin/env python3
"""V2: Solana x Dart logo candidates — no text anywhere.

Usage (secrets injected by monosecret):
    monosecret -f ~/monosecret.toml --reason "..." run -- python3 generate_logos_v2.py

Writes square JPEGs into ./candidates-v2/ (relative to this script).
"""

from concurrent.futures import ThreadPoolExecutor
import json
import os
import sys
import urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
OUT_DIR = os.path.join(HERE, "candidates-v2")
os.makedirs(OUT_DIR, exist_ok=True)

TOKEN = os.environ.get("HUGGING_FACE_TOKEN", "")
if not TOKEN:
    sys.exit("HUGGING_FACE_TOKEN not available; run inside `monosecret run --`")

MODEL = "stabilityai/stable-diffusion-3-medium-diffusers"
URL = f"https://router.huggingface.co/hf-inference/models/{MODEL}"

BASE = (
    "flat vector logo icon, minimal geometric design, delicate but elegant Solana "
    "brand gradient from magenta #9945FF through violet and teal to bright green "
    "#14F195, very dark navy background #0a0e18 like a night sky, centered "
    "composition, crisp clean edges, premium developer-tool brand identity mark, "
    "no text, no letters, no words, no numbers, no typography, no watermark, "
    "square app icon"
)

NEG = (
    "text, letters, words, numbers, typography, font, writing, label, logo text, "
    "watermark, signature, photo, photograph, realistic, blurry, jpeg artifacts, "
    "busy, cluttered, frame, gradient background"
)

# (n, slug, subject)
CONCEPTS = [
    (1,  "s-flight",       "a dart's curved flight path drawn as one smooth S-shaped gradient ribbon, ending in a minimal dart arrowhead, three small glowing dots trailing behind"),
    (2,  "taper-bars",     "three stacked parallelogram gradient bars aligned like the Solana logo, the middle bar tapering into a sharp dart point"),
    (3,  "dotted-arc",     "a thin dotted arc sweeping across the icon like a thrown dart's trajectory, ending in a small sharp arrowhead"),
    (4,  "dart-pierce",    "a minimal sleek throwing dart piercing through three stacked skewed gradient bars, viewed straight on"),
    (5,  "dart-feather",   "a single minimal throwing dart seen from the side, its body a gradient bar and its rear flight made of three small skewed gradient slats"),
    (6,  "arrowhead-bars", "three gradient bars converging and fusing into one sharp upward arrowhead"),
    (7,  "flight-fin",     "close-up of a stylized dart flight fin composed of three curved skewed gradient planes facing right"),
    (8,  "twin-wings",     "two symmetrical abstract wings each made of three layered skewed gradient bars, rising like fluttering motion"),
    (9,  "flutter-spark",  "abstract symmetrical wing spread of six thin gradient shards crossing at the center, small glowing dot where they meet"),
    (10, "feather",        "one minimal elegant feather built from three clean overlapping gradient shapes, tilted diagonally"),
    (11, "dart-trail",     "a small sharp dart diving downward leaving a curved trail of three fading gradient bars behind it"),
    (12, "trefoil-dart",   "the rear flight of a dart from the front view, three blades arranged in rotational symmetry like a trefoil"),
    (13, "kite-facets",    "one geometric kite made of four triangular gradient facets, with two small tail dots below"),
    (14, "arrow-ring",     "a minimal dart arrowhead centered inside one thin gradient ring, the ring tilted at a slight diagonal"),
    (15, "bar-arrow-up",   "three stacked skewed gradient bars, the top bar bent upward into an arrow shape at its end"),
    (16, "swoosh-dart",    "a wide dynamic swoosh gradient stroke curving through the icon, starting thick and ending in a dart point"),
    (17, "streak-dart",    "one sharp dart flying upward and to the right, with two parallel gradient speed streaks trailing from it"),
    (18, "compass-dart",   "a slim dart rotated forty-five degrees pointing to the upper right corner like the Solana logo tilt, three small square pixels fading behind its tail"),
    (19, "shard-shard",    "an arrowhead assembled from three separate parallelogram shards of gradient color with small gaps between them"),
    (20, "orbit-dart",     "one tiny dart moving along a thin elliptical orbit, echoing a planet with its moon, centered dot glowing inside the path"),
]


def generate(concept):
    n, slug, subject = concept
    prompt = BASE + ", " + subject
    payload = {
        "inputs": prompt,
        "parameters": {
            "width": 1024,
            "height": 1024,
            "num_inference_steps": 28,
            "guidance_scale": 4.5,
            "seed": 130000 + n * 7919,
            "negative_prompt": NEG,
        },
    }
    out_path = os.path.join(OUT_DIR, f"{n:02d}-{slug}.jpg")
    if os.path.exists(out_path) and os.path.getsize(out_path) > 10000:
        return f"skip {n:02d}-{slug} (exists)"
    req = urllib.request.Request(
        URL,
        data=json.dumps(payload).encode(),
        headers={"Authorization": f"Bearer {TOKEN}", "Content-Type": "application/json"},
        method="POST",
    )
    attempts = 3
    for attempt in range(attempts):
        try:
            with urllib.request.urlopen(req, timeout=180) as resp:
                data = resp.read()
            if len(data) < 5000 or data[:3] != b"\xff\xd8\xff":
                raise RuntimeError(f"unexpected payload ({len(data)} bytes)")
            with open(out_path, "wb") as fh:
                fh.write(data)
            return f"ok   {n:02d}-{slug} ({len(data)//1024} KiB)"
        except Exception as exc:  # noqa: BLE001
            err = str(exc)[:120]
            if attempt == attempts - 1:
                return f"FAIL {n:02d}-{slug}: {err}"
    return f"FAIL {n:02d}-{slug}: unreachable"


def main():
    workers = min(4, os.cpu_count() or 2)
    with ThreadPoolExecutor(max_workers=workers) as pool:
        for line in pool.map(generate, CONCEPTS):
            print(line, flush=True)


if __name__ == "__main__":
    main()