import 'dart:io';

void main() {
  // Fix pantalla_escaner.dart
  final f1 = File('c:/src/academia/lib/screens/pantalla_escaner.dart');
  var c1 = f1.readAsStringSync();
  c1 = c1.replaceAll("import '../database/database_helper.dart';", "import 'package:supabase_flutter/supabase_flutter.dart' as supa;");
  
  final target1 = '''          final db = await DatabaseHelper.instance.database;
          
          // Buscar estudiante por documento
          final maps = await db.query(
            'estudiantes',
            where: 'documento = ?',
            whereArgs: [documento],
          );''';
  final repl1 = '''          final client = supa.Supabase.instance.client;
          
          final maps = await client.from('estudiantes').select().eq('documento', documento);''';
          
  final target1b = '''            // Registrar asistencia (simulamos curso_id = 1 por ahora)
            await db.insert('asistencias', {
              'estudiante_id': estudianteId,
              'curso_id': 1,
              'fecha': DateTime.now().toIso8601String(),
              'estado': 'Presente',
            });''';
            
  final repl1b = '''            await client.from('asistencias').insert({
              'estudiante_id': estudianteId,
              'curso_id': 1,
              'fecha': DateTime.now().toIso8601String(),
              'estado': 'Presente',
            });''';

  c1 = c1.replaceAll(target1, repl1);
  c1 = c1.replaceAll(target1b, repl1b);
  f1.writeAsStringSync(c1);

  // Fix pantalla_calificaciones.dart
  final f2 = File('c:/src/academia/lib/screens/pantalla_calificaciones.dart');
  var c2 = f2.readAsStringSync();
  c2 = c2.replaceAll("import '../database/database_helper.dart';", "import 'package:supabase_flutter/supabase_flutter.dart' as supa;");
  
  final target2 = '''      final db = await DatabaseHelper.instance.database;
      final courseMaps = await db.query('cursos', where: 'id = ?', whereArgs: [widget.cursoId]);''';
      
  final repl2 = '''      final client = supa.Supabase.instance.client;
      final courseMaps = await client.from('cursos').select().eq('id', widget.cursoId);''';
      
  c2 = c2.replaceAll(target2, repl2);
  f2.writeAsStringSync(c2);
  
  print('Done fixing escaner and calificaciones');
}
