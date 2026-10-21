# Legal change triggers

The Privacy Policy (`/privacy`) and Terms of Service (`/terms`) are published from this repo. Both describe what the products do today. When a product changes in one of the ways below, update the policy or terms in the same change set, before release.

Owner: InfennonLabs LLC. Contact in the documents: privacy@infennonlabs.com. Not legal advice; have counsel review before each major change.

## Triggers

| Change | Update required |
|---|---|
| Google AdSense or any ads go live (`web/ads.txt` is already present) | Privacy: replace the "no advertising" section with the ad partners, cookies/identifiers, and opt-outs. Child-directed use means non-personalized ads only. Re-check the "we do not share for advertising" statements. |
| AppsFlyer ships (planned for the second launcher release) | Privacy: the text says "uses, or will use". Confirm it against the real network capture and the App Store / Google Play labels (`lgl_launcher/PRIVACY_AND_TRACKING_REVIEW.md` P11, P12). Settings stated: Strict SDK (iOS), no IDFA/AAID, no ATT prompt, partner sharing blocked, `anonymizeUser(true)`. If any setting changes, change the text. |
| Firebase added | Privacy: name the exact products (Crashlytics, Analytics, Performance) and what each collects. The text currently says "may use" and promises an update. |
| Any new SDK, analytics event, or network call | Needs the review in `lgl_launcher/CLAUDE_HANDOFF.md`, then a policy update. |
| Nunito bundled in the website (no more runtime Google Fonts requests) | Privacy: remove the "Fonts" bullet in section 1. Today `google_fonts` fetches the typeface from Google at runtime (see `lgl_launcher/PRIVACY_AND_TRACKING_REVIEW.md` P13.1). Plan and license check: [FONT_BUNDLING_PLAN.md](FONT_BUNDLING_PLAN.md). |
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

The first Privacy Policy describes only what is live (Cloudflare, Google Fonts). The AppsFlyer and Firebase wording below was drafted from `lgl_launcher/APPSFLYER_PLAN.md` and the compliance docs and removed on 2026-10-17. Re-check it against the real network capture and store labels before restoring it.

**Section 1 bullet, AppsFlyer:** "Install measurement (AppsFlyer). Our mobile app uses AppsFlyer to count app installs. We configure it for children's apps: we do not collect or use the iOS advertising identifier (IDFA) or the Android advertising ID, we do not show an App Tracking Transparency prompt, we block sharing of data with advertising partners, and we turn on AppsFlyer's anonymization setting. AppsFlyer may still receive technical information such as your IP address (which may be masked or hashed), device type, operating system version, app version, and a random install identifier that AppsFlyer generates."

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
| "The Services do not include advertising partners" (Privacy s.4) | Search every `web/index.html`, `lib`, and Worker for ad/analytics scripts; proxy capture of page load | **FAILS for the home site.** `infennon_labs_home/web/index.html:41-44` loads Google's AdSense script (`adsbygoogle.js`, client `ca-pub-8017542409324420`). Fix the policy or remove the script before publishing. |
| "Cloudflare processes your IP address and request details" | Architecture (Worker + assets); confirm in Cloudflare dashboard which features are on (analytics, bot management) | Code read; dashboard not checked |
| "Our website loads its typeface from Google Fonts" | Proxy capture; `GoogleFonts.*` calls with fetching enabled | Code read; capture pending (P13.1) |
| "Games save preferences/game state on your device; not sent to us" | Search all apps for `SharedPreferences`/storage; check no upload code; inspect browser Local Storage on a live game | Code read: prefs in 5 apps, game state in `farm_kids`. Not observed in a browser. |
| Cookies | DevTools, Application, Cookies on the live site | Owner chose to defer; policy is silent on cookies |
| "We do not sell personal information; we do not build profiles" | Code read for no data export; no SDKs present | Code read: no analytics/ad/DB packages in app pubspecs |
| "Designed to comply with COPPA"; no advertising identifiers | Counsel review; store Kids/Families rules | Counsel review pending |
| (Held back) AppsFlyer settings: Strict SDK, no IDFA/AAID, no ATT, sharing blocked, anonymize | `lgl_launcher/PRIVACY_AND_TRACKING_REVIEW.md` P1 to P7: binary/manifest checks with a negative control, network capture, dashboard | Not installed, not testable yet |
| (Held back) Firebase/Crashlytics collection | Check the exact products enabled, data fields in a capture, Play Data safety / App Store labels | Not installed |

Release rule: no policy sentence ships that is "unverified", and no SDK ships until its held-back wording has its row verified.

## AdSense and children: status

Source: Google AdSense help pages on child-directed treatment, TFAT, restricted data processing, and the EU User Consent Policy (read 2026-10-17 via summaries; Search Console steps not yet read).

| Item | Status |
|---|---|
| Site flagged as child-directed in Search Console (domain property `infennonlabs.com`) | Done by owner 2026-10-17. Google says it may take time to apply. Not yet confirmed to affect ad requests. |
| Cloudflare DNS setting added by owner for the above | Done by owner (record type/value not noted here; add it) |
| Auto ads | Disabled by owner 2026-10-17. Revisit with manual ad units (`<ins>` per page) carrying `data-tag-for-age-treatment="1"` (and optionally `data-restrict-data-processing="1"`). The AdSense loader script is still in `web/index.html`. |
| Restricted data processing (RDP) in AdSense UI | Not yet confirmed |
| EEA/UK/Switzerland consent message (certified CMP) or regional ad limit | Not done |
| Does child treatment apply to Auto ads? | Unknown. Per-request attribute `data-tag-for-age-treatment="1"` needs an `<ins>` element, which Auto ads does not give us. |
| Observed in a real ad request (child treatment, `rdp=1`, no ad IDs) | Not done; do this when ads first serve, and log it in the Claims register |
| Privacy Policy section 4 wording (non-personalized ads for children) | Draft only; stays unverified until the row above is done |
| Counsel review of children's advertising language | Pending |

## Open before ads go live (owner decisions 2026-10-17)

- Verify the child-directed flag in a real ad request once AdSense approves the site and ads serve (child age treatment, no ad IDs; `&rdp=1` if RDP is used). Log the result in the Claims register. Until then, Privacy s.5 says only that we "make every effort to limit and block personalized advertising".
- Decide on the EEA/UK/Switzerland consent message (Google-certified CMP) or limiting ads in those regions. A missing CMP is not a Do Not Track signal; per Google, traffic without a certified CMP can only receive non-personalized or limited ads, and consent may still be required for cookies.
- Do Not Track sentence removed from the policy (owner, 2026-10-17); counsel to confirm no disclosure is required.
- Links to Cloudflare and Google privacy policies are in the Privacy s.3 table; keep them current.
