import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../models/models.dart';

class AttendanceController extends ChangeNotifier {
  List<Attendance> _attendances = [];
  List<Attendance> get attendances => _attendances;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final client = supa.Supabase.instance.client;

  Future<void> loadAttendances([int? cursoId]) async {
    _isLoading = true;
    notifyListeners();

    try {
      final query = client.from('asistencias').select();
      final response = cursoId != null 
          ? await query.eq('curso_id', cursoId).order('fecha', ascending: false)
          : await query.order('fecha', ascending: false);

      _attendances = (response as List).map((map) => Attendance.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error loading attendances: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveAttendance(Attendance attendance) async {
    final map = attendance.toMap();
    
    if (attendance.id == null) {
      map.remove('id');
      await client.from('asistencias').insert(map);
    } else {
      map.remove('id');
      await client.from('asistencias').update(map).eq('id', attendance.id!);
    }
    await loadAttendances(attendance.cursoId);
  }

  Future<void> recordScanAttendance({
    required int estudianteId,
    required int cursoId,
    String estado = 'Presente',
  }) async {
    await client.from('asistencias').insert({
      'estudiante_id': estudianteId,
      'curso_id': cursoId,
      'fecha': DateTime.now().toIso8601String(),
      'estado': estado,
    });
    await loadAttendances(cursoId);
  }

  double calculateAttendancePercentage(int studentId, int cursoId) {
    if (_attendances.isEmpty) return 0.0;
    
    final studentAttendances = _attendances.where((a) => a.estudianteId == studentId && a.cursoId == cursoId).toList();
    if (studentAttendances.isEmpty) return 0.0;
    
    int presentCount = studentAttendances.where((a) => a.estado == 'Presente').length;
    int lateCount = studentAttendances.where((a) => a.estado == 'Retardo' || a.estado == 'Tarde').length; 
    
    return ((presentCount + lateCount) / studentAttendances.length) * 100;
  }
}
