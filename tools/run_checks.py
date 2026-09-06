#!/usr/bin/env python3
"""Run real engine checks; fail on Godot errors even when its exit code is zero."""
import argparse
import os
import pathlib
import re
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument("--godot", default=os.environ.get("GODOT_BIN", "godot"))
args = parser.parse_args()

subprocess.run([sys.executable, str(ROOT / "tools/check_project.py")], check=True)
steps = [
    ("Import and compile", ["--headless", "--editor", "--path", str(ROOT), "--import", "--quit"]),
    ("Simulation regression tests", ["--headless", "--path", str(ROOT), "--script", "res://tests/test_simulation.gd"]),
    ("Main scene smoke test", ["--headless", "--path", str(ROOT), "--", "--smoke-test"]),
]
for title, flags in steps:
    print(f"\n{title}", flush=True)
    try:
        result = subprocess.run([args.godot, *flags], cwd=ROOT, text=True, stdout=subprocess.PIPE,
                                stderr=subprocess.STDOUT, timeout=120)
    except (OSError, subprocess.TimeoutExpired) as error:
        sys.exit(str(error))
    print(result.stdout)
    if result.returncode or re.search(r"SCRIPT ERROR|Parse Error|TEST FAILED|^ERROR:", result.stdout, re.M):
        sys.exit(f"Failed: {title}")
print("All engine checks passed. Physical-device touch and performance tests remain separate.")
