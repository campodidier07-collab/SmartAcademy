import 'package:flutter/material.dart';
import '../models/models.dart';
import '../database/database_helper.dart';

class ScheduleController extends ChangeNotifier {
  List<Schedule> _schedules = [];
  List<Schedule> get schedules => _schedules;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadSchedules(int cursoId) async {
    _isLoading = true;
    notifyListeners();

    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'horarios',
      where: 'curso_id = ?',
      whereArgs: [cursoId],
    );
    
    _schedules = maps.map((map) => Schedule.fromMap(map)).toList();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveSchedule(Schedule schedule) async {
    final db = await DatabaseHelper.instance.database;
    
    if (schedule.id == null) {
      await db.insert('horarios', schedule.toMap());
    } else {
      await db.update(
        'horarios',
        schedule.toMap(),
        where: 'id = ?',
        whereArgs: [schedule.id],
      );
    }
    await loadSchedules(schedule.cursoId);
  }
}
