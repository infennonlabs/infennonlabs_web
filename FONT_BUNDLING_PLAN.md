# Plan: bundle fonts, stop runtime Google Fonts requests

Status: PLAN ONLY. No files changed. Needs owner OK before any edit.

## Why
`google_fonts` downloads font files from Google at runtime unless they are bundled. Every visitor of infennonlabs.com and every launcher user then sends their IP address to Google. For a children's product that is avoidable. The Privacy Policy currently discloses it (section 1, "Fonts"); bundling lets us delete that line. Source: `lgl_launcher/PRIVACY_AND_TRACKING_REVIEW.md` P13.1.

## Scope (verified by search on 2026-10-17)
| App | Use | Fonts |
|---|---|---|
| `infennon_labs_home` | `lib/main.dart:49-50` text theme, `:240` heading | Nunito, Fredoka |
| `lgl_launcher` | `lib/main.dart:46` text theme | Nunito |
| `learning` | out of scope (owner decision, 2026-10-17) | n/a |

No shared package uses `google_fonts`. Other game apps do not depend on it.

## Licensing (compliance check)
- Nunito and Fredoka are published on Google Fonts under the SIL Open Font License 1.1. OFL allows bundling and redistribution in websites and apps, commercial or not, with no fee. This is my general knowledge; confirm against the `OFL.txt` that comes with each download before shipping.
- Obligations: ship the OFL text and copyright notice with the files; do not sell the fonts alone; do not rename a modified version (we will not modify them).
- Check each font's own copyright line in its `OFL.txt` and copy it verbatim.

## Steps
1. **Baseline (no code change).** Load the current site and the launcher on a simulator through a proxy; confirm requests to `fonts.googleapis.com` / `fonts.gstatic.com`. Save the host list as evidence.
2. **Get files.** Download Nunito and Fredoka from Google Fonts with their `OFL.txt`. Use only the weights the code uses (check `fontWeight` values; variable font file preferred if the package accepts it, otherwise the static weights). Save under `assets/google_fonts/` in each app, license files beside them (`assets/google_fonts/OFL-Nunito.txt`, etc.). Fonts must keep the file names `google_fonts` expects (e.g. `Nunito-Regular.ttf`, `Nunito-Bold.ttf`) so the package finds them as assets.
3. **Register.** Add the asset folder under `flutter: assets:` in `pubspec.yaml`. Set `GoogleFonts.config.allowRuntimeFetching = false` at the start of `main()` so a missing file fails loudly in debug instead of silently fetching.
4. **Register the licenses** with `LicenseRegistry.addLicense` so they show on the app's licenses page.
5. **Verify.** `flutter analyze` and `flutter test` in each touched app. Test: widget test renders the home page with fetching disabled and does not throw. Repeat the proxy run from step 1: no Google font hosts. Check the web build output includes the font files and the total size change (note it).
6. **Policy.** Remove the "Fonts" bullet from the Privacy Policy section 1 and add a row to the log in `LEGAL_CHANGE_TRIGGERS.md`. Tick P13.1 in the launcher review with the evidence.
7. **Deploy** separately from the legal pages, using the normal deploy gate.

## Pass if
- No requests to Google font hosts in the proxy capture, on web and in the launcher.
- Text renders in Nunito / Fredoka on a fresh install with the network off.
- `OFL.txt` files are in the repos and in the licenses page.
- Analyze and tests pass; policy and change log updated in the same change.

## Risks
- Web font weight mismatches if a weight is used but not bundled (the browser fakes bold). Mitigate by listing used weights in step 2.
- Bundle size grows by the font files (tens to a few hundred KB each); record the before/after.
- Offline first-launch behavior now works, which is a side benefit.

## Open questions
- Keep Fredoka, or switch the one heading to Nunito to bundle only one family?
