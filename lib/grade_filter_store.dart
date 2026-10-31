/// Remembers the chosen grade for the rest of this browser tab, so coming
/// back from a game keeps the filter. A new visit (closed tab) starts clean.
library;

export 'grade_filter_store_stub.dart'
    if (dart.library.js_interop) 'grade_filter_store_web.dart';
