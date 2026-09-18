# Quick Capture — Action Button setup

One-press flow: **hold the Action Button → the screen is captured → SilentVote opens with that screenshot.**

The capture is done by the Shortcuts app (a third-party app cannot snapshot another app's screen); SilentVote receives it through its **Silent Vote Quick Capture** app intent. The setup is done once, by hand.

## Requirements

- iPhone with an Action Button (15 Pro or later) on iOS 26.4+.
- SilentVote installed.
- The Shortcuts app.

## 1. Build the Shortcut

Open the **Shortcuts** app → **＋** (new shortcut). Name it `Silent Vote Quick Capture`. Then add the capture action — pick the variant for your device:

### Variant A — Apple Intelligence available (any region where "Get Screen" exists)

1. **Add Action** → search **Get Screen** (under Controls/Screen). It silently captures the current screen and outputs it as a variable.
2. **Add Action** → under the **SilentVote** app, add **Silent Vote Quick Capture**. Its *Screenshot* input should already be auto-connected to the capture; if not, tap the *Screenshot* placeholder and pick the variable from the previous action.

### Variant B — China region / Apple Intelligence off ("Get Screen" is hidden)

Use **Take Screenshot** instead:

1. **Add Action** → search **Take Screenshot**. Turn **off** "Show Markup Interface" and "Show Preview" (where offered) so it captures silently. Note: this route always keeps a copy in your Camera Roll (Screenshots album) — unavoidable without Get Screen.
2. **Add Action** → **Silent Vote Quick Capture** (under SilentVote). The intent declares its *Screenshot* parameter as `IntentFile` with image content types and `connectToPreviousIntentResult`, so adding it directly after the capture action **auto-wires** the screenshot — the action token should show the connected variable without you picking anything.

If it shows a Files browser instead of connecting (old app build before the parameter fix): reinstall the app, then remove and re-add the Silent Vote Quick Capture action.

Finally, for both variants: long-press the shortcut card in the library → shortcut details → turn **Show When Run** off, so the running-Shortcut HUD does not cover the captured screen.

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
