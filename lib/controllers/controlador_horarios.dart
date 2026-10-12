import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../models/models.dart';

class ScheduleController extends ChangeNotifier {
  List<Schedule> _schedules = [];
  List<Schedule> get schedules => _schedules;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final client = supa.Supabase.instance.client;

  Future<void> loadSchedules(int cursoId) async {
    _isLoading = true;
    notifyListeners();

    final response = await client.from('horarios').select().eq('curso_id', cursoId);
    _schedules = response.map((map) => Schedule.fromMap(map)).toList();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveSchedule(Schedule schedule) async {
    final map = schedule.toMap();
    
    if (schedule.id == null) {
      map.remove('id');
      await client.from('horarios').insert(map);
    } else {
      map.remove('id');
      await client.from('horarios').update(map).eq('id', schedule.id!);
    }
    await loadSchedules(schedule.cursoId);
  }
}
