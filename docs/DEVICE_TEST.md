# First iPhone 15 Pro test

Run this after a signed native build is installed. These checks are currently **pending**, not passed.

Record build commit, Godot version, iOS version and whether Low Power Mode is enabled.

1. **Comfort:** top buttons clear the Dynamic Island; bottom controls clear the home indicator. Labels are legible and buttons easy to hit in portrait.
2. **Map:** one-finger pan starts without jumping; pinch keeps the point between the fingers stable. Releasing one finger after a pinch must not place a building or commit a road.
3. **Placement:** preview matches final footprint and rotation. Invalid placement and cancellation cost nothing. Map panning remains possible with a placement preview active.
4. **Roads:** a fast stroke fills continuous orthogonal tiles. An invalid stroke or insufficient backpack stock builds nothing. Connecting gates creates a route; nearby disconnected buildings receive nothing.
5. **Inventory:** drag exactly 1/10/50 items between columns. Dragging inside a scrolling panel must be distinguishable from scrolling. Tap transfer remains usable. Full target slots prevent duplication or loss.
6. **Training:** a recruit visibly walks to school, consumes local equipment/rations and retains their name and sword after later shield training.
7. **Persistence:** background the app mid-delivery, wait, reopen; no offline simulation occurred. Force-close after a save, relaunch and inspect cargo, backpack, trained people and unlocks.
8. **Performance:** pan/zoom during active deliveries for several minutes. Measure frame times on the physical device; target 60 fps, roughly 16.7 ms per frame. Check a larger manually built town too. Watch for sustained heat and excessive battery use.

Capture a short screen recording and note the first three uncomfortable interactions. Fix those before adding more schools.
