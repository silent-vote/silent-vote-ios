# Action Button → Shortcut → "Get Screen" → cold-launch app with image — platform research

Date: 2026-09-17. Target: iOS app, deployment target iOS 26.4, iPhone with Action Button.
Sources: iOS 26.4 SDK `.swiftinterface` (Xcode 26.4, 17E192), developer.apple.com documentation JSON, support.apple.com user guides. Search engines were unreachable from the research network, so anything not backed by a fetched source is marked **[knowledge]** or **[uncertain]**.

Legend: ✅ verified against primary source · 🔶 high-confidence knowledge, no primary citation fetched · ❓ uncertain, must test on device.

## 1. Image as an AppIntent parameter

✅ `@Parameter` (type `IntentParameter`) is the way to declare intent parameters: <https://developer.apple.com/documentation/AppIntents/IntentParameter>.

✅ Parameter types must conform to the value-type protocol (`_IntentValue`, publicly via `AppValue` / `AppEntity` / `AppEnum`). Full built-in conformance set in the iOS 26.4 SDK:
`String, Int, Double, Bool, Date, DateComponents, AttributedString, URL, Measurement, CLPlacemark, IntentCurrencyAmount, IntentPaymentMethod, IntentPerson, IntentFile, EntityIdentifier, Calendar.RecurrenceRule, Optional/Array/Set of the above, AppEntity, AppEnum`, plus custom `AppValue` types and iOS 18 `@UnionValue` types.
Source: `iPhoneOS26.4.sdk/…/AppIntents.swiftmodule/arm64e-apple-ios.swiftinterface` (grep of `_IntentValue` conformances).

✅ **No `Image`, `CGImage`, `Data`, or arbitrary `Transferable` as a `@Parameter` type in iOS 26.4.** `Transferable` is used for *sharing* entities (AppEntity: Transferable, iOS 18) and — only from the "June 2026" wave — `IntentValueRepresentation` bridges entities to system values; `IntentValueRepresentation`, `AppUnionValue`, `RunSystemShortcutIntent`, `LongRunningIntent`, `EntityCollection`, `IntentExecutionTargets` are **not present in the 26.4 SDK** (iOS 27-era). Marking: those are unavailable on a 26.4 deployment target.

✅ The image parameter type that **is** available: `IntentFile` (iOS 16.0+): data/filename/fileURL/`type: UTType?`/`removedOnCompletion` — "An interface for providing an app entity that represents an on-disk file or file-based resource". <https://developer.apple.com/documentation/AppIntents/IntentFile>. `removedOnCompletion` defaults true → copy bytes to your container during `perform()` or set it false.

✅ Apple's iOS 18 changelog states the Shortcuts bridge explicitly: "Receive content other apps make available with app intents by using `IntentFile` for your app intent parameters." <https://developer.apple.com/documentation/Updates/AppIntents>

✅ App Shortcuts can be embedded as actions in custom shortcuts: "you can also include these app shortcuts as an action in your own custom shortcuts." <https://support.apple.com/guide/shortcuts/run-app-shortcuts-apd43295406d/ios> 🔶 Wiring the "Get Screen" output variable into the intent action's `IntentFile` parameter works on iOS 17+ (Shortcuts "File" ↔ IntentFile). ❓ exact editor behavior — verify on device.

✅ Cold launch with payload: `openAppWhenRun` (iOS 16; deprecated in iOS 26.0 → "Use supportedModes instead") runs the intent **inside the main app** ("Setting this property to `true` generates an error if the app intent runs in an app extension"). <https://developer.apple.com/documentation/appintents/appintent/openappwhenrun>
✅ iOS 26.0 `supportedModes: IntentModes` with `.foreground(.immediate)` = "bring the app to the foreground **before** the action runs"; `[.background, .foreground(.deferred/.dynamic)]` variants exist; consult `IntentSystemContext.currentMode`. Availability `@available(iOS 26.0)` verified in the 26.4 SDK and <https://developer.apple.com/documentation/appintents/appintent/supportedmodes>. So yes: invoking such an intent from a Shortcut cold-launches the app and `perform()` receives the resolved `IntentFile`.

## 2. Alternative handoff channels

### a) Photos album + PhotoKit
- ✅ `PHAccessLevel` has only `addOnly` and `readWrite` (iOS 14+), `PHPhotoLibrary.requestAuthorizationForAccessLevel` — Headers/PHPhotoLibrary.h in 26.4 SDK. There is **no public `.readOnly`**; auto-fetching the newest asset needs `.readWrite` (Full Access; the limited picker grants read-only of a subset — bad for "newest screenshot").
- PHPickerViewController: no permission but only user-picked items — useless for hands-off **[knowledge]**.
- 🔶 "Add to Photo Album" (Shortcuts action) creates/uses a normal user album; user albums persist across OS updates and are fetchable by title via `PHAssetCollection`. ❓ whether the action auto-creates a missing album: believed yes — test.
- Cons: permission prompt, race vs. other screenshots (any screenshot/camera roll write beats you to "newest"), no launch signal without a URL-scheme/open-app step anyway.

### b) Files
- ✅ `UIFileSharingEnabled` = "A Boolean value indicating whether the app shares files" <https://developer.apple.com/documentation/bundleresources/information-property-list/uifilesharingenabled>; enables the app's Documents folder in the Files app ("On My iPhone/AppName").
- 🔶 No File Provider extension required — the Shortcuts "Save File" destination picker exposes Files locations including On My iPhone app folders (community-documented; not cited in the Shortcuts guide fetched). ❓ verify destination pinning on device.
- ✅ App Intents' "Save to Files" sibling: guide confirms Shortcuts' file-ish actions exist but "Open In … sends a copy to another app that supports documents" <https://support.apple.com/guide/shortcuts/share-actions-apdaf74d75a5/ios>. "Open In" into your own app is an alternative (opens app with file, but no deep route).
- Pros: zero extra permissions, file lands in your sandbox. Cons: stale-file ambiguity, no wake signal.

### c) App Groups
- ✅/🔶 Shortcuts has no action that can read or write another app's App Group container; App Groups scope to your app+extensions under your team ID. Confident negative (no public API/action exists).

### d) Open App / URL schemes
- ✅ "Open App" action exists (share actions list) and takes just the app — no payload channel. <https://support.apple.com/guide/shortcuts/share-actions-apdaf74d75a5/ios>
- ✅ "Open URLs … also supports URL schemes provided by other apps you've installed" <https://support.apple.com/guide/shortcuts/use-another-apps-url-scheme-apd68802640c/ios> — so custom-scheme launch with query text is possible; image only as base64 in the URL.
- ❓ max URL length for custom schemes is not documented by Apple; a screenshot base64 is ≥1 MB of characters — fragile/slow at best. Not viable at full resolution **[knowledge]**.
- ✅ Reverse direction documented: `shortcuts://run-shortcut?name=…&input=clipboard` (Shortcuts URL scheme; input is text or clipboard) <https://support.apple.com/guide/shortcuts/run-a-shortcut-from-a-url-apd624386f42/ios>. Clipboard handoff to the app is possible in theory but reading UIPasteboard unprompted shows paste confirmations — poor UX **[knowledge]**.

### e) Newer (iOS 18–26)
- ✅ iOS 18: `@UnionValue` multi-type parameters; IntentFile content sharing; Transferable app entities ("Content sharing" section, <https://developer.apple.com/documentation/Updates/AppIntents>).
- ✅ iOS 26: `supportedModes`/`IntentModes` (above); `SnippetIntent`; `IntentValueQuery` for Visual Intelligence (screen-content → your entities); `NSUserActivity.appEntityIdentifier` (same page).
- ❗ June-2026 (iOS 27) items — `IntentValueRepresentation`, `RunSystemShortcutIntent`, `LongRunningIntent`, `allowedExecutionTargets`, `EntityCollection`, `AppUnionValue` — verified **absent** from the iOS 26.4 SDK; do not plan on them.
- 🔶 Visual Intelligence via Action Button (iPhone 15 Pro+, Apple Intelligence required) is a camera/screen-analysis flow that shows its own results UI and only opens your app via cards — not a cold-launch-with-your-UI channel **[knowledge]**.

## 3. Action Button specifics

- ✅ Supported models (Apple Support, "Models with an Action button"): iPhone 15 Pro, 15 Pro Max, 16, 16 Plus, 16 Pro, 16 Pro Max, 16e, 17, 17 Pro, 17 Pro Max, Air, 17e, 18 Pro, 18 Pro Max (list as of the iOS 27 guide) <https://support.apple.com/guide/iphone/aside/iph44c8b4227/27/ios/27>. No Action Button on iPhone 15/15 Plus or earlier.
- ✅ Arbitrary shortcut assignment: "On supported models (iPhone 15 Pro or later)… including running a shortcut. Go to Settings > Action Button… Swipe to Shortcut, tap Choose a Shortcut, then select a shortcut." <https://support.apple.com/guide/shortcuts/run-shortcuts-with-the-action-button-apdfea15680b/ios> ✅ Trigger is press-and-hold (identical text in iOS 18 and iOS 26 versions of the guide): <https://support.apple.com/guide/iphone/use-and-customize-the-action-button-iphe89d61d66/ios>
  ❗ "iOS 15.4" in the question is wrong for this hardware; the Action Button debuted with iPhone 15 Pro (iOS 17). (Back Tap has run shortcuts since iPhone era 11+ **[knowledge]**.)
- ❓ What "Get Screen" captures during an Action-Button run: the shortcut runs while the previous foreground UI is on screen; iOS shows a transient "Running shortcut" HUD/banner and (per reports) it can persist during the run — whether it appears in the capture is timing-dependent. Apple's guide doesn't document "Get Screen" per-action; treat "banner in capture?", "shutter flash/sound?", "thumbnail popup?" as ❓ needs on-device matrix testing. 🔶 Community consensus: Get Screen is silent, no editing thumbnail, and behaves like a screenshot capture; the per-shortcut "Show When Run" detail toggles the HUD **[knowledge]**.
- 🔶 Reliability caveats: data-protected APIs (Photos/Files/Location) unavailable before first unlock → a locked press can capture the Lock Screen or fail; cold App Intents execution adds ~launch latency; the capture happens *before* your app opens (that is the desired "previous screen") **[knowledge/uncertain]**.

## 4. Easing setup from the app

- ❌ No public API to suggest/preconfigure the Action Button in Settings. The 26.4 SDK contains no `SuggestionManager`/suggestion classes (Intents donation-era APIs gone; `SUG*` never public). ✅ Nearest: `IntentDonationManager` (iOS 16) — donations "can then proactively suggest actions on the Lock Screen, in the Siri Suggestions widget, in Search, and in other system interfaces" — *not* Settings > Action Button. <https://developer.apple.com/documentation/appintents/intentdonationmanager>
- 🔶 App Shortcuts (AppShortcutsProvider) appear in the Action Button "Choose a Shortcut" picker — so shipping intents minimizes user work **[knowledge]**.
- ✅ Setup-surfacing UI: `ShortcutsLink` — "A button that brings users to the current app's App Shortcuts page in the Shortcuts app" (iOS 16); `ShortcutsUIButton` — "A button that opens the current app's page in the Shortcuts app" (iOS 16); `SiriTipView` — shows the invocation phrase (iOS 16). <https://developer.apple.com/documentation/appintents/shortcutslink>
- ✅ Sharing/installing a prebuilt shortcut: iCloud links `https://www.icloud.com/shortcuts/<id>` → recipient taps "Get Shortcut"; or share an exported shortcut file ("Anyone" → "Apple will receive a copy of your shortcut for validation"; "People Who Know Me"), or "Export File" (.shortcut) — recipient taps Add Shortcut. No App-Store API for an app to install a shortcut silently; opening the icloud.com link (user gesture) is the standard install flow. <https://support.apple.com/guide/shortcuts/share-shortcuts-apdf01f8c054/ios>

## 5. Verdict

**Most robust for cold-launch-with-image on iOS 26.4:**
App Intents: custom `AppIntent` with `@Parameter file: IntentFile`, `static let supportedModes: IntentModes = [.foreground(.immediate)]` (+ legacy `openAppWhenRun = true` for compatibility), defined in the **main app** (not an extension). Shortcut: `Get Screen` → your app's intent action with the screenshot wired into the parameter. The system cold-launches the app, `perform()` receives the PNG in-process; copy `file.data`/`fileURL` into the app container (or set `removedOnCompletion = false`), push it into SwiftUI state, navigate to the screen. Single user setup step: assign that shortcut to the Action Button.

**Runner-up (Photos-album handoff) failure modes:** `.readWrite` permission prompt; "newest asset" race with unrelated screenshots/camera; album title lookup breakage if user renames/deletes; no wake signal (still needs Open URL/Open App as a second hop); Shortcuts' own Photos access state; iCloud Photo Library quirks when album syncs. Save-File variant failure modes: manual destination pinning, stale-file ambiguity, no wake signal; it does avoid all permissions.
