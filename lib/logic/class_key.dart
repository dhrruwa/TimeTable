/// Canonicalises a class identity (university / branch / semester / section) so
/// students who enter the same class slightly differently — "Agri" vs
/// "Agriculture Engineering" vs "Dept. of Agricultural Engineering" — still
/// resolve to the SAME community timetable. Drives [TimetableMeta.matchKey].
///
/// The goal is tolerance for the common cases, not perfection: unknown branches
/// fall back to a filler-stripped form, which is still far more forgiving than a
/// raw case-sensitive compare.

/// Lowercase, replace any run of non-alphanumerics with a single space, trim.
String _squish(String s) => s
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
    .trim()
    .replaceAll(RegExp(r'\s+'), ' ');

/// Structural words that add no identity to a branch name.
const _branchFiller = <String>{
  'department', 'dept', 'of', 'the', 'branch', 'engineering', 'engg', 'eng',
  'and', 'in', 'semester', 'sem', 'tech', 'technology', 'btech', 'be',
  'bachelor', 'b', 'e', 'stream', 'specialization', 'specialisation', 'hons',
  'honours',
};

/// Canonical branch → the cleaned (filler-stripped) aliases that map to it.
const _branchCanon = <String, List<String>>{
  'agriculture': ['agri', 'ag', 'agriculture', 'agricultural'],
  'cse': ['cse', 'cs', 'computer', 'computers', 'computer science',
    'computer sciences'],
  'ise': ['ise', 'information science', 'info science'],
  'it': ['it', 'information'],
  'ece': ['ece', 'electronics', 'electronics communication',
    'electronics communications'],
  'eee': ['eee', 'electrical', 'electrical electronics'],
  'mechanical': ['mech', 'mechanical'],
  'civil': ['civil'],
  'aiml': ['aiml', 'ai ml', 'ai', 'artificial intelligence',
    'artificial intelligence machine learning', 'artificial intelligence ml'],
  'ds': ['ds', 'data science'],
  'chemical': ['chem', 'chemical'],
  'biotech': ['biotech', 'biotechnology', 'bt'],
  'aerospace': ['aero', 'aeronautical', 'aerospace'],
};

/// A canonical branch token (e.g. every agriculture variant → `agriculture`).
String normalizeBranch(String raw) {
  final cleaned = _squish(raw)
      .split(' ')
      .where((w) => w.isNotEmpty && !_branchFiller.contains(w))
      .join(' ')
      .trim();
  final phrase = cleaned.isEmpty ? _squish(raw) : cleaned;
  for (final entry in _branchCanon.entries) {
    if (entry.value.contains(phrase)) return entry.key;
  }
  return phrase;
}

/// University name with the generic "University" word and punctuation removed,
/// so "REVA University" and "REVA" collapse together.
String normalizeUniversity(String raw) {
  const uniFiller = {'university', 'univ', 'the'};
  final cleaned = _squish(raw)
      .split(' ')
      .where((w) => w.isNotEmpty && !uniFiller.contains(w))
      .join(' ')
      .trim();
  return cleaned.isEmpty ? _squish(raw) : cleaned;
}

/// The numeric semester if present ("Sem 4", "4th" → "4"); else the squished
/// form.
String normalizeSemester(String raw) {
  final m = RegExp(r'\d+').firstMatch(raw);
  return m?.group(0) ?? _squish(raw);
}

/// Section letter/number with any "section"/"sec" prefix and spaces removed
/// ("Sec A", "section-a" → "a").
String normalizeSection(String raw) {
  final cleaned = _squish(raw).replaceAll(RegExp(r'\b(section|sec)\b'), '');
  return cleaned.replaceAll(' ', '').trim();
}

/// The canonical `university|branch|semester|section` key used to match a class
/// across community publishes and searches.
String classMatchKey({
  required String university,
  required String branch,
  required String semester,
  required String section,
}) =>
    '${normalizeUniversity(university)}|${normalizeBranch(branch)}'
    '|${normalizeSemester(semester)}|${normalizeSection(section)}';
