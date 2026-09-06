#!/usr/bin/env python3
"""Static package checks. These do NOT compile or run GDScript."""
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
errors = []

def require(condition, message):
    if not condition:
        errors.append(message)

data = json.loads((ROOT / "data.json").read_text())
for key, item in data["items"].items():
    require(item["stack"] > 0, f"Invalid stack size: {key}")
    require(bool(re.fullmatch(r"[0-9a-fA-F]{6}", item["color"])), f"Invalid color: {key}")
for key, building in data["buildings"].items():
    require(building["size"] in (2, 3), f"Invalid footprint: {key}")
    require(building["slots"] > 0, f"Invalid capacity: {key}")
    require(set(building["cost"]) <= set(data["items"]), f"Unknown construction item: {key}")
    for recipe in building.get("recipes", []):
        require(recipe in data["recipes"], f"Unknown recipe: {recipe}")
    if "skill" in building:
        require(building["equipment"] in data["items"], f"Unknown equipment: {key}")
for key, recipe in data["recipes"].items():
    require(recipe["seconds"] > 0, f"Invalid recipe duration: {key}")
    for side in ("in", "out"):
        require(set(recipe[side]) <= set(data["items"]), f"Unknown recipe item: {key}")
        require(all(isinstance(v, int) and v > 0 for v in recipe[side].values()), f"Invalid quantity: {key}")
    require(key in data["items"], f"Recipe label requires corresponding item: {key}")

scripts = sorted(ROOT.rglob("*.gd"))
for path in scripts:
    text = path.read_text()
    for ref in re.findall(r'"res://([^"\n]+)"', text):
        require((ROOT / ref).exists(), f"Missing resource {ref} in {path.name}")
    functions = re.findall(r"^(?:static )?func (\w+)\(", text, re.M)
    require(len(functions) == len(set(functions)), f"Duplicate function in {path.name}")
    for n, line in enumerate(text.splitlines(), 1):
        require(not re.match(r"\t* +\S", line), f"Space indentation in {path.name}:{n}")
    # Strip strings/comments, then check structural delimiter pairs.
    stripped = re.sub(r'"(?:\\.|[^"\\])*"|\'([^\'\\]|\\.)*\'|#[^\n]*', "", text)
    stack = []
    for char in stripped:
        if char in "([{":
            stack.append(char)
        elif char in ")]}":
            expected = dict(zip(")]}", "([{"))[char]
            require(bool(stack) and stack[-1] == expected, f"Unbalanced delimiter: {path.name}")
            if stack:
                stack.pop()
    require(not stack, f"Unclosed delimiter: {path.name}")

for path in (ROOT / "project.godot", ROOT / "main.tscn"):
    for ref in re.findall(r'"res://([^"\n]+)"', path.read_text()):
        require((ROOT / ref).exists(), f"Missing resource: {ref}")
require("gl_compatibility" in (ROOT / "project.godot").read_text(), "Expected Compatibility renderer")
require("emulate_mouse_from_touch=true" in (ROOT / "project.godot").read_text(), "UI touch emulation required")
if errors:
    print("\n".join(errors), file=sys.stderr)
    sys.exit(1)
print(f"Static checks passed: {len(scripts)} scripts, {len(data['buildings'])} buildings, {len(data['recipes'])} recipes.")
print("GDScript compilation, runtime tests, visual QA and iPhone profiling still require Godot.")
