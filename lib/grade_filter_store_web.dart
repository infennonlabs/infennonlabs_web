import 'package:web/web.dart' as web;

const String _gradeKey = 'home-grade-filter';
const String _subjectKey = 'home-subject-filter';

/// The saved grade label, or null. Storage can be blocked, so failures read
/// as "nothing saved".
String? readSavedGradeLabel() => _read(_gradeKey);

/// Saves [label]; null clears it.
void saveGradeLabel(String? label) => _write(_gradeKey, label);

/// The saved subject label, or null.
String? readSavedSubjectLabel() => _read(_subjectKey);

/// Saves [label]; null clears it.
void saveSubjectLabel(String? label) => _write(_subjectKey, label);

String? _read(String key) {
  try {
    return web.window.sessionStorage.getItem(key);
  } catch (_) {
    return null;
  }
}

void _write(String key, String? value) {
  try {
    if (value == null) {
      web.window.sessionStorage.removeItem(key);
    } else {
      web.window.sessionStorage.setItem(key, value);
    }
  } catch (_) {
    // Private mode or blocked storage: the filter just won't be remembered.
  }
}
