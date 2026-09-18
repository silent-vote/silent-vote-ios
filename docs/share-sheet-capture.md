# Share-sheet capture — take a screenshot yourself, share it in

One-press flow: **user takes their own screenshot → shares it to Silent Vote → the app opens on the capture screen with that image.**

This complements the Action Button flow (`docs/quick-capture-action-button.md`): the Shortcut path silently grabs the *current* screen; the share path lets the user bring any image that already exists — a screenshot from the Photos app, or an image from Files, Mail, Notes, Safari. No user setup is needed beyond installing the app: the **ShareCapture** extension ships inside the app bundle and registers itself in the share sheet.

## How it works

1. The share sheet shows **Silent Vote** (the `ShareCapture` extension) whenever the selected content includes at least one image (up to 10).
2. The extension takes the **first** image attachment and writes it into the **`CaptureInbox`** — a folder inside the shared App Group container (`group.autos.vibration.silentvote`). Extra images in the same share are ignored.
3. It then foregrounds Silent Vote via the `silentvote://capture` URL and dismisses itself.
4. The app drains the inbox (on launch, on foreground, on the URL open — whichever arrives first): the newest item is displayed through the **same capture screen** as the Action Button flow, and the inbox is emptied. A handoff whose foregrounding failed is therefore not lost: the capture shows on the next app launch instead.
5. **Done** deletes the image, exactly like the Shortcut flow.

In-app rules shared with the Shortcut channel: a new capture **replaces** one that is currently on screen; the image never leaves the device.

## Edge cases (by design)

- Non-image content (text, URLs, video-only): Silent Vote does not appear in the sheet at all.
- Live Photo shared: comes as an image + video pair; the image is taken.
- The image payload can't be read (provider failure): the extension cancels; the sheet just collapses and the app stays closed.
- Older unconsumed files left in the inbox: discarded when the newest one is displayed ("show newest, delete the rest").

## Requirements

- iPhone on iOS 26.4+, SilentVote installed. Nothing to configure.

## Verify

1. Open **Photos** → pick any screenshot → **Share** (⬆︎) → the app row should include **Silent Vote** (if hidden, tap **More** ⋯ and find it there).
2. Tap it → the share sheet collapses and Silent Vote opens showing the capture screen with your image and *"Got it. Purchase insights are coming soon."*
3. **Done** returns to the main UI; the temporary file is deleted.
4. Select multiple photos → the app opens with only the first one.
5. Kill Silent Vote, repeat a share, and force-quit the app while the share sheet is still closing → reopening the app shows the capture (missed-handoff survival).

## Notes

- The foregrounding in step 3 uses the documented-by-practice technique of reaching the process's `UIApplication` through the extension's responder chain and calling the public `open()` API. If it ever breaks on a future iOS, the design degrades to rule 4's next-launch pickup rather than losing the capture.
- Testing on the Simulator is limited: simulator builds without code signing have no App Group container, so the extension→app handoff cannot fully run there. Test the flow on a real device from Xcode (automatic signing provisions both App Group entitlements on first run).
- Both targets carry the App Groups capability. If it is ever missing (entitlement not provisioned), the handoff **fails closed**: the extension can't write and cancels, rather than depositing the image where no reader could find it.
