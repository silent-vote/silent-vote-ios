# Quick Capture — Action Button setup

One-press flow: **hold the Action Button → the screen is captured → SilentVote opens with that screenshot.**

The capture is done by the Shortcuts app ("Get Screen" is the only way to snapshot another app's screen); SilentVote receives it through its **Silent Vote Quick Capture** app intent. The setup is done once, by hand.

## Requirements

- iPhone with an Action Button (15 Pro or later) on iOS 26.4+.
- SilentVote installed.
- The Shortcuts app.

## 1. Build the Shortcut

1. Open the **Shortcuts** app → **＋** (new shortcut). Name it `Silent Vote Quick Capture`.
2. Tap **Add Action**, search for **Get Screen** (under Controls/Screen) and add it. It outputs the current screen as a photo.
3. Tap **Add Action** again, search under the **SilentVote** app for **Silent Vote Quick Capture** and add it.
4. In that action's **Screenshot** input, tap the variable placeholder and choose **Screenshot** (the output of "Get Screen").
5. (Optional but recommended) Long-press the shortcut card in the library → shortcut details → turn **Show When Run** off, so the running-Shortcut HUD does not cover the captured screen.

## 2. Assign it to the Action Button

1. **Settings → Action Button** (under Screen Pressure / Sounds... on your device: the dedicated Action Button pane).
2. Swipe/scroll to **Shortcut**, tap **Choose a Shortcut**, pick **Silent Vote Quick Capture**.

## 3. Verify

1. Open any app, **press and hold the Action Button** → SilentVote should cold-launch straight to the capture screen showing your screenshot with *"Got it. Purchase insights are coming soon."*
2. Press **Done** to return to the main UI; the temporary image file is deleted on leaving.
3. Already-open app: holding the button replaces the current view with the new capture.
4. Misconfigured shortcut (intent wired without the Get Screen input) → the capture screen shows *"No screenshot received — check the Shortcut includes Get Screen."*

## Notes

- The screenshot never leaves the device; it lives in the system temp directory only while the capture screen is visible.
- Recognition ("what does the user want to purchase") is a planned follow-up; this slice ends at receiving + display.
- Dev testing without the Action Button: run the shortcut from the Shortcuts app's ▶, or invoke the intent from Xcode; the simulator has no Action Button and no real "Get Screen".
