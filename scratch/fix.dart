import 'dart:io';

void main() {
  final file = File('c:/src/academia/lib/screens/pantalla_estudiantes.dart');
  var content = file.readAsStringSync();

  content = content.replaceAll(
      "import '../database/database_helper.dart';", 
      "import 'package:supabase_flutter/supabase_flutter.dart' as supa;");

  final target = '''                final db = await DatabaseHelper.instance.database;
                final gradeMaps = await db.query(
                  'notas',
                  where: 'estudiante_id = ?',
                  whereArgs: [student.id],
                );
                final grades = gradeMaps.map((map) => Grade.fromMap(map)).toList();
                final courseMaps = await db.query('cursos');
                final courses = courseMaps.map((map) => Course.fromMap(map)).toList();''';

  final replacement = '''                final client = supa.Supabase.instance.client;
                final gradeMaps = await client.from('notas').select().eq('estudiante_id', student.id!);
                final grades = gradeMaps.map((map) => Grade.fromMap(map)).toList();
                final courseMaps = await client.from('cursos').select();
                final courses = courseMaps.map((map) => Course.fromMap(map)).toList();''';

  content = content.replaceAll(target, replacement);
  file.writeAsStringSync(content);
  print('Done pantalla_estudiantes.dart');
}
