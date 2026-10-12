import 'dart:io';

void main() {
  final file = File('c:/src/academia/lib/screens/pantalla_estudiantes.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll(
    'await PdfGenerator.generateStudentReport(student, grades);',
    "final courseMaps = await db.query('cursos');\n                final courses = courseMaps.map((map) => Course.fromMap(map)).toList();\n                await PdfGenerator.generateStudentReport(student, grades, courses);"
  );
  file.writeAsStringSync(content);
  print('Done pantalla_estudiantes.dart');
}
