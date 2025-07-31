import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radiant_app/models/class_session_model.dart';
import 'package:radiant_app/services/class_session_service.dart';

final classSessionServiceProvider = Provider<ClassSessionService>((ref) => ClassSessionService());

final scheduleControllerProvider = StateNotifierProvider<ScheduleController, ScheduleState>((ref) {
  final classSessionService = ref.watch(classSessionServiceProvider);
  return ScheduleController(classSessionService);
});

final weeklyScheduleProvider = StateNotifierProvider<WeeklyScheduleNotifier, AsyncValue<Map<String, List<ClassSession>>>>((ref) {
  final classSessionService = ref.watch(classSessionServiceProvider);
  return WeeklyScheduleNotifier(classSessionService);
});

class ScheduleState {
  final DateTime currentWeek;
  final Map<String, List<ClassSession>> weeklySchedule;
  final bool isLoading;
  final String? error;
  final String selectedFacultyId;
  final String selectedDepartment;
  final String selectedSection;

  ScheduleState({
    DateTime? currentWeek,
    this.weeklySchedule = const {},
    this.isLoading = false,
    this.error,
    this.selectedFacultyId = 'EMP2024011', // TODO: Get from auth
    this.selectedDepartment = 'CSE',
    this.selectedSection = 'A',
  }) : currentWeek = currentWeek ?? _getStartOfWeek(DateTime.now());

  static DateTime _getStartOfWeek(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }

  ScheduleState copyWith({
    DateTime? currentWeek,
    Map<String, List<ClassSession>>? weeklySchedule,
    bool? isLoading,
    String? error,
    String? selectedFacultyId,
    String? selectedDepartment,
    String? selectedSection,
  }) {
    return ScheduleState(
      currentWeek: currentWeek ?? this.currentWeek,
      weeklySchedule: weeklySchedule ?? this.weeklySchedule,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedFacultyId: selectedFacultyId ?? this.selectedFacultyId,
      selectedDepartment: selectedDepartment ?? this.selectedDepartment,
      selectedSection: selectedSection ?? this.selectedSection,
    );
  }
}

class ScheduleController extends StateNotifier<ScheduleState> {
  final ClassSessionService _classSessionService;

  ScheduleController(this._classSessionService) : super(ScheduleState()) {
    loadWeeklySchedule();
  }

  Future<void> loadWeeklySchedule() async {
    print('📅 Loading weekly schedule for week: ${state.currentWeek}');
    print('📅 Faculty ID: ${state.selectedFacultyId}');
    
    state = state.copyWith(isLoading: true, error: null);

    try {
      final startOfWeek = state.currentWeek;
      final endOfWeek = startOfWeek.add(Duration(days: 6));
      
      print('📅 Date range: $startOfWeek to $endOfWeek');

      final sessions = await _classSessionService.getClassSessionsByDateRange(
        state.selectedFacultyId,
        startOfWeek,
        endOfWeek,
      );

      print('📅 Found ${sessions.length} sessions in date range');

      final weeklySchedule = _groupSessionsByDay(sessions);
      
      state = state.copyWith(
        weeklySchedule: weeklySchedule,
        isLoading: false,
      );

      print('📅 Weekly schedule loaded with ${weeklySchedule.length} days');
      for (final entry in weeklySchedule.entries) {
        print('  ${entry.key}: ${entry.value.length} sessions');
      }
    } catch (e) {
      print('❌ Error loading weekly schedule: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Map<String, List<ClassSession>> _groupSessionsByDay(List<ClassSession> sessions) {
    final Map<String, List<ClassSession>> grouped = {
      'Monday': <ClassSession>[],
      'Tuesday': <ClassSession>[],
      'Wednesday': <ClassSession>[],
      'Thursday': <ClassSession>[],
      'Friday': <ClassSession>[],
      'Saturday': <ClassSession>[],
    };

    for (final session in sessions) {
      final dayName = _getDayName(session.startTime.weekday);
      if (grouped.containsKey(dayName)) {
        grouped[dayName]!.add(session);
      }
    }

    // Sort each day's sessions by start time
    for (final dayList in grouped.values) {
      dayList.sort((a, b) => a.startTime.compareTo(b.startTime));
    }

    return grouped;
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return 'Monday';
    }
  }

  void goToPreviousWeek() {
    print('📅 Going to previous week');
    final previousWeek = state.currentWeek.subtract(Duration(days: 7));
    state = state.copyWith(currentWeek: previousWeek);
    loadWeeklySchedule();
  }

  void goToNextWeek() {
    print('📅 Going to next week');
    final nextWeek = state.currentWeek.add(Duration(days: 7));
    state = state.copyWith(currentWeek: nextWeek);
    loadWeeklySchedule();
  }

  void goToCurrentWeek() {
    print('📅 Going to current week');
    final currentWeek = ScheduleState._getStartOfWeek(DateTime.now());
    state = state.copyWith(currentWeek: currentWeek);
    loadWeeklySchedule();
  }

  void updateFilters({
    String? facultyId,
    String? department,
    String? section,
  }) {
    print('📅 Updating filters - Faculty: $facultyId, Dept: $department, Section: $section');
    state = state.copyWith(
      selectedFacultyId: facultyId,
      selectedDepartment: department,
      selectedSection: section,
    );
    loadWeeklySchedule();
  }

  Future<void> addClassSession(ClassSession session) async {
    print('📅 Adding new class session: ${session.title}');
    try {
      await _classSessionService.createClassSession(session);
      await loadWeeklySchedule(); // Refresh the schedule
    } catch (e) {
      print('❌ Error adding class session: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateClassSession(String sessionId, Map<String, dynamic> updates) async {
    print('📅 Updating class session: $sessionId');
    try {
      await _classSessionService.updateClassSession(sessionId, updates);
      await loadWeeklySchedule(); // Refresh the schedule
    } catch (e) {
      print('❌ Error updating class session: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteClassSession(String sessionId) async {
    print('📅 Deleting class session: $sessionId');
    try {
      await _classSessionService.deleteClassSession(sessionId);
      await loadWeeklySchedule(); // Refresh the schedule
    } catch (e) {
      print('❌ Error deleting class session: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  // Helper methods
  String get weekRangeText {
    final endOfWeek = state.currentWeek.add(Duration(days: 6));
    final startMonth = _getMonthName(state.currentWeek.month);
    final endMonth = _getMonthName(endOfWeek.month);
    
    if (state.currentWeek.month == endOfWeek.month) {
      return '$startMonth ${state.currentWeek.day}-${endOfWeek.day}, ${state.currentWeek.year}';
    } else {
      return '$startMonth ${state.currentWeek.day} - $endMonth ${endOfWeek.day}, ${state.currentWeek.year}';
    }
  }

  String _getMonthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }

  bool get isCurrentWeek {
    final now = DateTime.now();
    final currentWeekStart = ScheduleState._getStartOfWeek(now);
    return state.currentWeek.isAtSameMomentAs(currentWeekStart);
  }
}

class WeeklyScheduleNotifier extends StateNotifier<AsyncValue<Map<String, List<ClassSession>>>> {
  final ClassSessionService _classSessionService;

  WeeklyScheduleNotifier(this._classSessionService) : super(const AsyncValue.loading());

  Future<void> loadWeeklySchedule(String facultyId, DateTime weekStart) async {
    state = const AsyncValue.loading();
    try {
      final endOfWeek = weekStart.add(Duration(days: 6));
      final sessions = await _classSessionService.getClassSessionsByDateRange(
        facultyId,
        weekStart,
        endOfWeek,
      );

      final weeklySchedule = _groupSessionsByDay(sessions);
      state = AsyncValue.data(weeklySchedule);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Map<String, List<ClassSession>> _groupSessionsByDay(List<ClassSession> sessions) {
    final Map<String, List<ClassSession>> grouped = {
      'Monday': <ClassSession>[],
      'Tuesday': <ClassSession>[],
      'Wednesday': <ClassSession>[],
      'Thursday': <ClassSession>[],
      'Friday': <ClassSession>[],
      'Saturday': <ClassSession>[],
    };

    for (final session in sessions) {
      final dayName = _getDayName(session.startTime.weekday);
      if (grouped.containsKey(dayName)) {
        grouped[dayName]!.add(session);
      }
    }

    // Sort each day's sessions by start time
    for (final dayList in grouped.values) {
      dayList.sort((a, b) => a.startTime.compareTo(b.startTime));
    }

    return grouped;
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return 'Monday';
    }
  }
}