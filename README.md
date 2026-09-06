# Bannerworks — Godot prototype 0.1

A personal 2D medieval automation game. Build the town, route its materials, and train its residents into soldiers with combinable skills.

**Target device:** iPhone 15 Pro, portrait, 60 fps target. **Engine:** Godot 4.5.2 Standard (GDScript), Compatibility renderer. No paid assets or runtime dependencies.

## Status

This is a first implementation for playtesting, not yet an iPhone installation package. It contains the Godot project, an interactive scene, a simulation regression suite, and a GitHub workflow for checking the game and exporting a Windows build.

On 6 September 2026, GitHub Actions compiled the project with Godot 4.5.2, passed all 49 simulation assertions, opened the main scene headlessly, and produced the Windows executable artifact. Static project/data checks also pass. **Visual inspection, hands-on Windows playtesting, native iPhone testing and physical-device performance profiling are still pending.**

## Open it on Windows

1. Download **Godot 4.5.2 Standard** from the [official archive](https://godotengine.org/download/archive/4.5.2-stable/). The .NET edition is unnecessary.
2. Extract this project ZIP and Godot's ZIP.
3. Start Godot, choose **Import**, and select this folder's `project.godot`.
4. Open the project and press **F6** with `main.tscn` open, or **F5** to run the project.

The successful GitHub workflow's `Bannerworks-Windows-…` artifact provides an executable instead. Extract the artifact before running it.

## What is implemented

- A 36 × 36 overhead grid with forest edges, a river, an iron deposit, original code-drawn building art and visible carts/residents.
- Nine building types: Town Hall, Farm, Lumber Camp, Iron Mine, Charcoal Kiln, Smithy, Warehouse Barn, Sword School and Shield School.
- Placement ghosts, quarter-turn gate rotation, overlap checks, road drawing and safe road removal.
- **Separate local inventories in every building.** A barn is storage, not a shared global supply.
- A **12-slot backpack**. Building and road construction spend only the materials it holds. Drag stacks between building/backpack columns, or tap to transfer 1, 10 or up to 50 items.
- Routes with explicit source, destination and cargo filter. Carts carry four items, move one tile/second, and return empty. Distance affects throughput. A full destination holds cargo on the cart.
- Timber → charcoal; ore + charcoal → iron bars; bars + timber → swords or shields. Each smithy runs one chosen recipe.
- Town Hall recruits peasants from local rations. Residents walk on roads to schools, retain their identities and keep their equipped weapons.
- Sword training, Shield training and the **Man-at-Arms** combination. A small three-swordsman milestone unlocks Shield School.
- Pause, autosave, previous-save recovery, manual save and safe construction refunds with overflow pickup crates.

The renderer updates independently of the 10 Hz simulation, with interpolated travel positions. Actual frame rate and touch quality must be measured on the phone.

## First ten minutes

The opening town has a working Farm → Town Hall delivery, three peasants, a lumber camp, an iron mine, and a backpack of founding supplies. The game is deliberately generous while testing the controls.

1. Tap **Lumber Camp**, then tap its Timber stack to move timber to your backpack. The two inventory columns also accept drag and drop. The transfer selector changes the quantity.
2. Choose **Build → Charcoal Kiln**. Drag the footprint to open ground, rotate if needed, then tap **Place building**. No materials are spent until placement succeeds.
3. Build **two Smithies**. Keep one on Iron bars and set the other to Swords in its inspector.
4. Choose **Roads → Draw roads**. Draw continuous paths from each gold gate to the existing road. Each new tile costs one backpack timber. One gate is used for all traffic in this first prototype.
5. Tap the Lumber Camp and choose **Create delivery from here**. Select Timber, then tap the Kiln. Repeat for Mine → bar Smithy (ore), Kiln → bar Smithy (charcoal), bar Smithy → sword Smithy (bars), and Lumber Camp → sword Smithy (timber).
6. Build **Sword School**, connect its gate, and configure sword Smithy → school (swords) and Farm → school (rations).
7. Open the school and tap **Enroll next eligible resident**. The resident walks there, then training starts when one sword and two rations are present. Repeat for three residents. You can also use Army → Send to a building.
8. Open **Army** and complete **Border Patrol**. Build a Shield School, produce shields, supply rations and send a swordsman there to train a Man-at-Arms.

To test training immediately, carry equipment manually from a workshop to a school through your backpack. Sustained supply is the roads' job.

## Controls

| Action | iPhone | Windows |
| --- | --- | --- |
| Select building | Tap | Click |
| Pan map | One-finger drag in inspect mode | Left drag in inspect mode; right drag in any tool |
| Zoom / pan while building | Two-finger pinch / drag | Mouse wheel / right drag |
| Position a building | Drag footprint, then Place | Move pointer, then Place |
| Draw roads | Drag in Draw roads mode | Left drag in Draw roads mode |
| Transfer stack | Drag to other column, or tap | Drag to other column, or click |
| Stop current tool | Open another toolbar tool | Same |

Production continues while inventory panels are open. Pause if you want to plan without the town advancing. Leaving the app freezes simulation; there is no offline catch-up.

## Continuous checks and Windows build

The project lives at [github.com/jarmokungla/bannerworks](https://github.com/jarmokungla/bannerworks). The included workflow:

1. Downloads pinned Godot 4.5.2 on a GitHub Linux runner.
2. Imports/compiles the project, runs simulation regression tests, and opens the main scene headlessly.
3. Downloads matching export templates and builds a Windows test executable.
4. Uploads that executable as a private repository Actions artifact.

It runs on pushes, pull requests and manual dispatch. Engine errors fail the job even if Godot returns a zero exit code. No Apple credentials are required for this workflow. It does not publish releases or deploy a website. The first fully successful run was build #3 on commit `b2150ed`.

## Getting it onto your iPhone

GitHub hosts the source and can coordinate builds, but it does not replace Apple's signing process. A native Godot iOS export requires **macOS with Xcode**; a hosted Mac can do that work, so owning a Mac is optional. See [Godot's iOS export requirements](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_ios.html).

After the first engine checks pass:

1. Choose an Apple development team and a unique bundle identifier.
2. Configure the iOS export on a Mac or hosted macOS runner, including the Apple Team ID and signing setup.
3. Build a signed app and distribute it for device testing, typically through TestFlight for this remote workflow.
4. Install on the iPhone 15 Pro and check touch input, safe areas, scrolling, saves, frame time and battery/heat on a busy map.

There is intentionally no dummy iOS signing preset or nonfunctional TestFlight workflow. We will add the real configuration once the Apple team and repository are available. Apple account access and signing credentials should be configured in the relevant account/secrets interface, not pasted into chat or committed.

## Tests

Static checks, with Python 3:

```sh
python tools/check_project.py
```

Real engine checks, with Godot installed:

```sh
python tools/run_checks.py --godot /absolute/path/to/godot
```

On Windows, pass the Godot console executable path (for example `Godot_v4.5.2-stable_win64_console.exe`). The test runner checks import, regressions and main-scene startup. It does not replace visual/touch QA.

The regression suite covers transfer conservation, full inventories, failed construction charges, invalid terrain, in-flight cargo, congestion at destination storage, route removal, citizen identity, equipment retention, hybrid training, distinct mission participants, pause, save/backup recovery and dismantle refunds.

## Architecture

| File | Responsibility |
| --- | --- |
| `data.json` | Items, recipes, costs, capacity and building definitions |
| `scripts/simulation.gd` | Authoritative inventories, production, grid rules, routes, people and progression |
| `scripts/save_store.gd` | Schema checks, checksum, temporary-file commit and previous-save backup |
| `scripts/game.gd` | UI, player commands, fixed-step driver and lifecycle |
| `scripts/world_view.gd` | Map drawing, placement/road gestures, camera and interpolated travel |
| `scripts/stack_button.gd`, `inventory_panel.gd` | Native Godot inventory drag/drop |
| `tests/test_simulation.gd` | Engine-run simulation regression tests |

Local saves live in Godot's `user://` directory. No network service is used by the game. Save schema is version 1; incompatible or corrupt saves are not silently overwritten. **New town** explicitly resets them.

## Deliberate first-slice limits

This implementation tests the economic loop and interface. The full design remains in `docs/Game_Design_v0.3.md`.

- Original vector placeholder art; no final sprites, audio, effects or animation polish yet.
- Workshops run without civilian staffing. Mining/smithing certificates, instructors and labor allocation are a later milestone.
- One shared gate per building, one cart per configured route, no traffic collision, split ratios, priority rules or road bridges yet.
- Students can be enrolled individually; automated standing training orders are not implemented yet.
- Twelve residents, one small map, seven material types and two combat skills. Archery, cavalry, magic, expanded housing and the larger campaign come later.
- Border Patrol is a requirements/unlock milestone, not a battle simulation. Soldiers are retained; no wounds or expedition timer yet.
- Touch drag/drop inside scrolling panels, notch/home-indicator spacing and 60 fps are implemented targets, **not device-verified claims**.

The next useful milestone is hands-on playtesting followed by a native phone test. Those results should guide interface changes before expanding the economy.
