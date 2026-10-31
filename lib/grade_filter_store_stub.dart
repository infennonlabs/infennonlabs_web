String? _saved;

/// The saved grade label, or null.
String? readSavedGradeLabel() => _saved;

/// Saves [label]; null clears it.
void saveGradeLabel(String? label) => _saved = label;
