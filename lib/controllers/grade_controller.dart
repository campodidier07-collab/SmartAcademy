import 'package:flutter/material.dart';
import '../models/models.dart';
import '../database/database_helper.dart';

class GradeController extends ChangeNotifier {
  List<Grade> _grades = [];
  List<Grade> get grades => _grades;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadGrades(int cursoId) async {
    _isLoading = true;
    notifyListeners();

    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'notas',
      where: 'curso_id = ?',
      whereArgs: [cursoId],
    );
    
    _grades = maps.map((map) => Grade.fromMap(map)).toList();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveGrade(Grade grade) async {
    final db = await DatabaseHelper.instance.database;
    
    double def = 0;
    int count = 0;
    if (grade.parcial1 != null) { def += grade.parcial1!; count++; }
    if (grade.parcial2 != null) { def += grade.parcial2!; count++; }
    if (grade.parcial3 != null) { def += grade.parcial3!; count++; }
    if (grade.trabajoFinal != null) { def += grade.trabajoFinal!; count++; }
    
    double finalGrade = count > 0 ? def / count : 0;
    
    Grade gradeToSave = Grade(
      id: grade.id,
      estudianteId: grade.estudianteId,
      cursoId: grade.cursoId,
      parcial1: grade.parcial1,
      parcial2: grade.parcial2,
      parcial3: grade.parcial3,
      trabajoFinal: grade.trabajoFinal,
      definitiva: finalGrade,
    );

    if (gradeToSave.id == null) {
      await db.insert('notas', gradeToSave.toMap());
    } else {
      await db.update(
        'notas',
        gradeToSave.toMap(),
        where: 'id = ?',
        whereArgs: [gradeToSave.id],
      );
    }
    await loadGrades(gradeToSave.cursoId);
  }
}
