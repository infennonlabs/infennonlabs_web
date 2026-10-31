import 'package:web/web.dart' as web;

const String _key = 'home-grade-filter';

/// The saved grade label, or null. Storage can be blocked, so failures read
/// as "nothing saved".
String? readSavedGradeLabel() {
  try {
    return web.window.sessionStorage.getItem(_key);
  } catch (_) {
    return null;
  }
}

/// Saves [label]; null clears it.
void saveGradeLabel(String? label) {
  try {
    if (label == null) {
      web.window.sessionStorage.removeItem(_key);
    } else {
      web.window.sessionStorage.setItem(_key, label);
    }
  } catch (_) {
    // Private mode or blocked storage: the filter just won't be remembered.
  }
}
