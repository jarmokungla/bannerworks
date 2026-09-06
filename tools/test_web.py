#!/usr/bin/env python3
"""Exercise the real exported Godot canvas, served without special headers."""
import functools
import http.server
import json
import pathlib
import threading

from playwright.sync_api import sync_playwright

ROOT = pathlib.Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "build" / "web-qa"


def main():
    OUTPUT.mkdir(parents=True, exist_ok=True)
    handler = functools.partial(http.server.SimpleHTTPRequestHandler, directory=str(ROOT / "build/web"))
    server = http.server.ThreadingHTTPServer(("127.0.0.1", 0), handler)
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    errors = []
    try:
        with sync_playwright() as playwright:
            browser = playwright.chromium.launch(args=["--enable-webgl", "--use-angle=swiftshader", "--enable-unsafe-swiftshader"])
            context = browser.new_context(viewport={"width":402, "height":874}, device_scale_factor=1, has_touch=True, is_mobile=True)
            page = context.new_page()
            page.on("pageerror", lambda error: errors.append(str(error)))
            page.on("console", lambda message: errors.append(message.text) if message.type == "error" else None)
            page.goto(f"http://127.0.0.1:{server.server_port}/index.html", wait_until="networkidle")
            page.get_by_role("button", name="Enter your town").click()
            page.wait_for_function("document.body.dataset.gameReady === 'true'", timeout=90000)
            page.wait_for_selector("#loader", state="hidden", timeout=90000)
            page.wait_for_timeout(2500)
            page.screenshot(path=str(OUTPUT / "town.png"))
            # Open the bottom-right game menu using real canvas input.
            page.mouse.click(350, 838)
            page.wait_for_timeout(500)
            page.screenshot(path=str(OUTPUT / "menu.png"))
            assert page.locator('link[rel="manifest"]').count() == 1, "PWA manifest is missing"
            page.wait_for_function("navigator.serviceWorker.controller !== null", timeout=30000)
            # The menu screenshot establishes this button's canvas coordinates.
            with page.expect_download() as download_info:
                page.mouse.click(195, 684)
            backup = json.loads(pathlib.Path(download_info.value.path()).read_text())
            assert "payload" in backup, "Downloaded file is not a save envelope"
            # A fresh navigation must start the real engine with no network.
            context.set_offline(True)
            page.reload(wait_until="load")
            page.get_by_role("button", name="Enter your town").click()
            page.wait_for_function("document.body.dataset.gameReady === 'true'", timeout=90000)
            page.wait_for_selector("#loader", state="hidden", timeout=90000)
            page.screenshot(path=str(OUTPUT / "offline-town.png"))
            assert not errors, "Browser errors:\n" + "\n".join(errors)
            context.close()
            browser.close()
    finally:
        server.shutdown()
        server.server_close()
    print("Web startup, menu input, save download, and offline game restart checks passed.")
    print("Physical iPhone gestures, performance and save-file picker still need device testing.")


if __name__ == "__main__":
    main()
