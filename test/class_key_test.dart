import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/logic/class_key.dart';

String key(String u, String b, String s, String sec) =>
    classMatchKey(university: u, branch: b, semester: s, section: sec);

void main() {
  test('agriculture branch variants collapse to one key', () {
    final variants = [
      key('REVA University', 'Agricultural Engineering', '4', 'A'),
      key('REVA UNIVERSITY', 'Agriculture Engineering', '4', 'a'),
      key('reva', 'Agri', 'Sem 4', 'Sec A'),
      key('Reva University', 'Ag Engineering', '4th', 'A'),
      key('REVA University', 'Department of Agricultural Engineering', '4', 'A'),
      key('REVA University', 'Dept. of Agriculture', '4', 'A'),
    ];
    expect(variants.toSet().length, 1,
        reason: 'all agriculture variants should map to the same key: $variants');
    expect(variants.first, 'reva|agriculture|4|a');
  });

  test('common branch abbreviations normalize', () {
    expect(normalizeBranch('CSE'), 'cse');
    expect(normalizeBranch('Computer Science'), 'cse');
    expect(normalizeBranch('Computer Science Engineering'), 'cse');
    expect(normalizeBranch('B.E. Computer Science'), 'cse');
    expect(normalizeBranch('ECE'), 'ece');
    expect(normalizeBranch('Electronics and Communication'), 'ece');
    expect(normalizeBranch('EEE'), 'eee');
    expect(normalizeBranch('Electrical'), 'eee');
    expect(normalizeBranch('Mechanical Engineering'), 'mechanical');
    expect(normalizeBranch('ISE'), 'ise');
    expect(normalizeBranch('Information Science'), 'ise');
    expect(normalizeBranch('Information Technology'), 'it');
    expect(normalizeBranch('AIML'), 'aiml');
    expect(normalizeBranch('Artificial Intelligence'), 'aiml');
  });

  test('distinct branches stay distinct', () {
    expect(normalizeBranch('CSE') == normalizeBranch('ECE'), isFalse);
    expect(normalizeBranch('Agriculture') == normalizeBranch('Civil'), isFalse);
    expect(normalizeBranch('ISE') == normalizeBranch('IT'), isFalse);
  });

  test('unknown branch still normalizes consistently', () {
    expect(normalizeBranch('Marine Engineering'), normalizeBranch('marine  engg'));
  });

  test('semester and section normalization', () {
    expect(normalizeSemester('4'), '4');
    expect(normalizeSemester('4th'), '4');
    expect(normalizeSemester('Sem 4'), '4');
    expect(normalizeSemester('Semester 6'), '6');
    expect(normalizeSection('A'), 'a');
    expect(normalizeSection('Sec A'), 'a');
    expect(normalizeSection('section-b'), 'b');
  });

  test('university drops the generic "University" word', () {
    expect(normalizeUniversity('REVA University'), normalizeUniversity('REVA'));
    expect(normalizeUniversity('PES University'), 'pes');
  });
}
