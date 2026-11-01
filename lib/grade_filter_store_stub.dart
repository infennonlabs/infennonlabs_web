String? _saved;

/// The saved grade label, or null.
String? readSavedGradeLabel() => _saved;

/// Saves [label]; null clears it.
void saveGradeLabel(String? label) => _saved = label;

String? _savedSubject;

/// The saved subject label, or null.
String? readSavedSubjectLabel() => _savedSubject;

/// Saves [label]; null clears it.
void saveSubjectLabel(String? label) => _savedSubject = label;
