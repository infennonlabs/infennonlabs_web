# Legal change triggers

The Privacy Policy (`/privacy`) and Terms of Service (`/terms`) are published from this repo. Both describe what the products do today. When a product changes in one of the ways below, update the policy or terms in the same change set, before release.

Owner: InfennonLabs LLC. Contact in the documents: privacy@infennonlabs.com. Not legal advice; have counsel review before each major change.

## Triggers

| Change | Update required |
|---|---|
| Ads are added back (the AdSense script was removed 2026-11-04; `web/ads.txt` is kept) | Privacy: the "no advertising" statements in sections 4 and 5 become false. Replace them with the ad partners, cookies/identifiers, and opt-outs. Child-directed use means non-personalized ads only. See "If ads return" below. |
| AppsFlyer ships (planned for the second launcher release) | Privacy: the text says "uses, or will use". Confirm it against the real network capture and the App Store / Google Play labels (`lgl_launcher/PRIVACY_AND_TRACKING_REVIEW.md` P11, P12). Settings stated: Strict SDK (iOS), no IDFA/AAID, no ATT prompt, partner sharing blocked, `anonymizeUser(true)`. If any setting changes, change the text. |
| Firebase added | Privacy: name the exact products (Crashlytics, Analytics, Performance) and what each collects. The text currently says "may use" and promises an update. |
| Any new SDK, analytics event, or network call | Needs the review in `lgl_launcher/CLAUDE_HANDOFF.md`, then a policy update. |
| Nunito bundled in the website (no more runtime Google Fonts requests) | **Done 2026-11-04.** Fonts come from `brand_fonts_shared`; the "Fonts" bullet and the Google table row are removed from the Privacy Policy. Any new `google_fonts` use, CDN script, or hosted-font link reopens this. |
| Web builds use the Flutter CDN again (`--no-web-resources-cdn` dropped) | Privacy: the site would request CanvasKit from `www.gstatic.com` and a fallback font from `fonts.gstatic.com`, so the "no Google requests" claim fails. `build_learning.sh` fails the build if `flutter_bootstrap.js` lacks `"useLocalCanvasKit":true`. |
| Any game starts saving scores or progress, or stores/sends new data | Privacy: update the "stored on your device" paragraph (today: sound, audio support and difficulty preferences in five apps, plus saved game state in `farm_kids`; re-run a search for `SharedPreferences` / `localStorage` across all apps before each release). |
| Accounts, purchases, subscriptions, or user content | Large change to both documents (data collected, deletion flow, payment terms). Terms: liability cap becomes the greater of the amount paid in the prior six months or US$20. |
| Address, email, or legal entity changes | Update the contact blocks in both documents. |

## Every change

1. Update the effective date in the edited document.
2. Add a row to the log below.
3. For material changes, give a more visible notice, as the policy promises.

## Log

| Date | Document | Change |
|---|---|---|
| 2026-10-17 | Privacy, Terms | First version drafted. Liability cap US$20. |
| 2026-10-21 | Privacy, Terms | Contact address changed to 519 W 22nd St Ste 300 PMB 550709, Sioux Falls, SD 57105-1745 (was 514 Americas Way PMB 18751, Box Elder, SD 57719). Effective date left at October 17, 2026 (owner decision). PDFs in `infennonlabs_legal_text/` still need regenerating. |

## Wording held back until each SDK ships

The first Privacy Policy describes only what is live (Cloudflare). The AppsFlyer and Firebase wording below was drafted from `lgl_launcher/APPSFLYER_PLAN.md` and the compliance docs and removed on 2026-10-17. Re-check it against the real network capture and store labels before restoring it.

**Section 1 bullet, AppsFlyer:** "Install measurement (AppsFlyer). Our mobile app uses AppsFlyer to count app installs and to see, in aggregate, how the app is used: when the app is opened, which game is opened, and roughly how long a game is played (in ranges such as under 1 minute, 1 to 5 minutes, 5 to 15 minutes, and over 15 minutes). These counts are not tied to a child, a name, an account, or any profile. We configure it for children's apps: we do not collect or use the iOS advertising identifier (IDFA) or the Android advertising ID, we do not show an App Tracking Transparency prompt, we block sharing of data with advertising partners, and we turn on AppsFlyer's anonymization setting. AppsFlyer may still receive technical information such as your IP address (which may be masked or hashed), device model and operating system version, language and region, screen size, mobile carrier codes, app version, and a random install identifier that AppsFlyer generates. (Counsel to confirm this wording against `lgl_launcher/COUNSEL_BRIEF_APPSFLYER.md`.)"

**Section 1 bullet, Firebase:** "App stability and basic usage (Firebase). We use Google Firebase for crash reports, performance, and anonymous, app-level usage counts. We do not send names, emails, or other personal details to it. Firebase may process technical information such as device model, operating system, and an app-instance identifier." (Name only the products actually enabled.)

**Also restore when AppsFlyer ships:**
- Section 2 purpose: "To understand how many people install and use the app, so we can improve it."
- Section 3 table rows: AppsFlyer (app install measurement); Google (Firebase) if used.
- Section 6: add AppsFlyer to "Data held by ... follows their retention practices."
- Section 7: "or to ask us to make a request to AppsFlyer to delete install data tied to your device" (the OpenDSR route, `PRIVACY_AND_TRACKING_REVIEW.md` P11).

## Claims register (every statement in the policies must be validated)

Standard (owner, 2026-10-17): a claim in the Privacy Policy, Terms, or store labels is published only if it is validated against the code and the real behavior of the build. "Verified" means checked and dated here. "Code read" means read in source but not observed running. Anything else is "unverified" and must be fixed, softened, or checked before release. Re-run this table before each release and before any SDK ships (AppsFlyer, Firebase/Crashlytics, AdSense, others), and compare against the App Store privacy labels and the Google Play Data safety / Families answers.

| Claim in the policy | How to validate | Status (2026-10-17) |
|---|---|---|
| "We do not have accounts; we do not ask for names, emails, ages, locations" | Search all apps for sign-in, text-entry of personal data, `mailto` only | Not yet searched across all apps |
| "The Services do not show advertising; the website loads no ad-network code" (Privacy s.4, s.5) | Search every `web/index.html`, `lib`, and Worker for ad/analytics scripts; proxy capture of page load | AdSense meta tag and loader removed from `infennon_labs_home/web/index.html` 2026-11-04. Code read; local-serve capture of the built site showed no ad host. Live capture pending. |
| "Cloudflare processes your IP address and request details" | Architecture (Worker + assets); confirm in Cloudflare dashboard which features are on (analytics, bot management) | Code read; dashboard not checked |
| "The website makes no requests to Google servers" (implied by removing the Google Fonts and AdSense text) | Proxy/Chrome capture of a page load of the deployed site; build output check | Release build with `--no-web-resources-cdn`: `flutter_bootstrap.js` has `"useLocalCanvasKit":true`, Roboto fallback font served from `assets/fonts/fallback/`; headless Chrome load of the built site requested only its own host (2026-11-04). Live capture pending. Browser speech voices are the visitor's browser, not our site (owner accepted 2026-11-04). |
| "Games save preferences/game state on your device; not sent to us" | Search all apps for `SharedPreferences`/storage; check no upload code; inspect browser Local Storage on a live game | Code read: prefs in 5 apps, game state in `farm_kids`. Not observed in a browser. |
| Cookies | DevTools, Application, Cookies on the live site | Owner chose to defer; policy is silent on cookies |
| "We do not sell personal information; we do not build profiles" | Code read for no data export; no SDKs present | Code read: no analytics/ad/DB packages in app pubspecs |
| "Designed to comply with COPPA"; no advertising identifiers | Counsel review; store Kids/Families rules | Counsel review pending |
| (Held back) AppsFlyer events: only app_open, game_opened(game_id), session_time(game_id, bucket); no identifiers | `lgl_launcher/tool/privacy_audit.sh` (allowlist, code) and `tool/privacy_traffic_check.py` on a real-key device capture | Code read and unit-tested; observed live on Android 2026-10-31 (debug build, SDK request log, `lgl_launcher/tool/android_smoke.sh`; owner confirmed the AppsFlyer dashboard). Release-build proxy capture on a real phone and iOS not yet run |
| (Held back) AppsFlyer settings: Strict SDK, no IDFA/AAID, no ATT, sharing blocked, anonymize | `lgl_launcher/PRIVACY_AND_TRACKING_REVIEW.md` P1 to P7: binary/manifest checks with a negative control, network capture, dashboard | Integrated on `lgl_launcher` main 2026-10-31; static audit passes; Android run confirmed the flags on the wire (ad IDs disabled, partner sharing blocked). Carrier codes and a device profile are still sent (see `lgl_launcher/COUNSEL_BRIEF_APPSFLYER.md`); real-phone release capture and iOS still open |
| (Held back) Firebase/Crashlytics collection | Check the exact products enabled, data fields in a capture, Play Data safety / App Store labels | Not installed |

Release rule: no policy sentence ships that is "unverified", and no SDK ships until its held-back wording has its row verified.

## AdSense (removed 2026-11-04)

The AdSense loader script and `google-adsense-account` meta tag were removed from `infennon_labs_home/web/index.html`. `web/ads.txt` is kept on purpose (static file, no visitor request to Google). History kept for a future return:

- Site was flagged child-directed in Search Console (domain property `infennonlabs.com`) by the owner on 2026-10-17, with a matching Cloudflare DNS record; auto ads were disabled. Both remain set outside the code.
- No ad request was ever observed in our checks; we have no record of ads serving.

## If ads return

- Use manual ad units (`<ins>` per page) with `data-tag-for-age-treatment="1"` (and optionally `data-restrict-data-processing="1"`); auto ads give no way to set the child attribute.
- Verify the child-directed flag in a real ad request (child age treatment, no ad IDs; `&rdp=1` if RDP is used) and log it in the Claims register before changing the policy wording.
- Decide on the EEA/UK/Switzerland consent message (Google-certified CMP) or limit ads in those regions.
- Rewrite Privacy sections 1, 3, 4, 5 and 6 (ad provider, data handling) and get counsel review of the children's advertising language.
