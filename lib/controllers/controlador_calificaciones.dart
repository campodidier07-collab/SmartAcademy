import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../models/models.dart';

class GradeController extends ChangeNotifier {
  List<Grade> _grades = [];
  List<Grade> get grades => _grades;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int? _activeCursoFilter;
  int? get activeCursoFilter => _activeCursoFilter;

  final client = supa.Supabase.instance.client;

  Future<void> loadGrades([int? cursoId]) async {
    _activeCursoFilter = cursoId;
    _isLoading = true;
    notifyListeners();

    try {
      final response = cursoId != null
          ? await client.from('notas').select().eq('curso_id', cursoId).order('id', ascending: false)
          : await client.from('notas').select().order('id', ascending: false);
      _grades = (response as List).map((map) => Grade.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error loading grades: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> saveGrade(Grade grade) async {
    try {
      double def = 0;
      int count = 0;
      if (grade.parcial1 != null) { def += grade.parcial1!; count++; }
      if (grade.parcial2 != null) { def += grade.parcial2!; count++; }
      if (grade.parcial3 != null) { def += grade.parcial3!; count++; }
      if (grade.trabajoFinal != null) { def += grade.trabajoFinal!; count++; }

      double finalGrade = count > 0 ? (def / count) : 0;
      // Round to 2 decimals
      finalGrade = double.parse(finalGrade.toStringAsFixed(2));

      int? targetId = grade.id;

      // If id is null, verify if this student already has a record in this course to avoid duplicate insertion errors
      if (targetId == null) {
        final existing = await client
            .from('notas')
            .select('id')
            .eq('estudiante_id', grade.estudianteId)
            .eq('curso_id', grade.cursoId)
            .maybeSingle();
        if (existing != null && existing['id'] != null) {
          targetId = existing['id'] as int;
        }
      }

      final gradeToSave = Grade(
        id: targetId,
        estudianteId: grade.estudianteId,
        cursoId: grade.cursoId,
        parcial1: grade.parcial1,
        parcial2: grade.parcial2,
        parcial3: grade.parcial3,
        trabajoFinal: grade.trabajoFinal,
        definitiva: finalGrade,
      );

      final map = gradeToSave.toMap();
      if (targetId == null) {
        map.remove('id');
        await client.from('notas').insert(map);
      } else {
        map.remove('id');
        await client.from('notas').update(map).eq('id', targetId);
      }

      await loadGrades(_activeCursoFilter);
      return true;
    } catch (e) {
      debugPrint('Error saving grade: $e');
      return false;
    }
  }

  Future<bool> deleteGrade(int id) async {
    try {
      await client.from('notas').delete().eq('id', id);
      await loadGrades(_activeCursoFilter);
      return true;
    } catch (e) {
      debugPrint('Error deleting grade: $e');
      return false;
    }
  }
}
