import 'package:flutter/material.dart';
import '../models/models.dart';
import '../database/database_helper.dart';

class AttendanceController extends ChangeNotifier {
  List<Attendance> _attendances = [];
  List<Attendance> get attendances => _attendances;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadAttendances(int cursoId) async {
    _isLoading = true;
    notifyListeners();

    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'asistencias',
      where: 'curso_id = ?',
      whereArgs: [cursoId],
    );
    
    _attendances = maps.map((map) => Attendance.fromMap(map)).toList();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveAttendance(Attendance attendance) async {
    final db = await DatabaseHelper.instance.database;
    
    if (attendance.id == null) {
      await db.insert('asistencias', attendance.toMap());
    } else {
      await db.update(
        'asistencias',
        attendance.toMap(),
        where: 'id = ?',
        whereArgs: [attendance.id],
      );
    }
    await loadAttendances(attendance.cursoId);
  }

  double calculateAttendancePercentage(int studentId, int cursoId) {
    if (_attendances.isEmpty) return 0.0;
    
    final studentAttendances = _attendances.where((a) => a.estudianteId == studentId && a.cursoId == cursoId).toList();
    if (studentAttendances.isEmpty) return 0.0;
    
    int presentCount = studentAttendances.where((a) => a.estado == 'Presente').length;
    // Tarde podría contar como presente o parcial, asumimos presente para el cálculo total de asistencia a clase
    int lateCount = studentAttendances.where((a) => a.estado == 'Tarde').length; 
    
    return ((presentCount + lateCount) / studentAttendances.length) * 100;
  }
}
