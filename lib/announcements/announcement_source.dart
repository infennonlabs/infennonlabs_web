/// Fetches the deploy's announcements-feed.json from the same host as the page.
/// Anything that goes wrong reads as "no feed" (the ticker then shows tips only).
library;

export 'announcement_source_stub.dart'
    if (dart.library.js_interop) 'announcement_source_web.dart';
