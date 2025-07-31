import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radiant_app/models/student_model.dart';
import 'package:radiant_app/models/class_session_model.dart';
import 'package:radiant_app/services/student_service.dart';
import 'package:radiant_app/services/attendance_service.dart';
import 'package:radiant_app/services/class_session_service.dart';

final studentServiceProvider = Provider<StudentService>((ref) => StudentService());
final attendanceServiceProvider = Provider<AttendanceService>((ref) => AttendanceService());
final classSessionServiceProvider = Provider<ClassSessionService>((ref) => ClassSessionService());

final attendanceControllerProvider = StateNotifierProvider<AttendanceController, AttendanceState>((ref) {
  final studentService = ref.watch(studentServiceProvider);
  final attendanceService = ref.watch(attendanceServiceProvider);
  final classSessionService = ref.watch(classSessionServiceProvider);
  return AttendanceController(studentService, attendanceService, classSessionService);
});

final studentsProvider = StateNotifierProvider<StudentsNotifier, AsyncValue<List<Student>>>((ref) {
  final studentService = ref.watch(studentServiceProvider);
  return StudentsNotifier(studentService);
});

final todayClassesProvider = StateNotifierProvider<TodayClassesNotifier, AsyncValue<List<ClassSession>>>((ref) {
  final classSessionService = ref.watch(classSessionServiceProvider);
  return TodayClassesNotifier(classSessionService);
});

class AttendanceState {
  final List<Student> students;
  final Map<String, bool> attendance;
  final bool isLoading;
  final String? error;
  final String? selectedDepartment;
  final String? selectedSection;
  final String? selectedSessionId;
  final bool isMarkingMode;

  AttendanceState({
    this.students = const [],
    this.attendance = const {},
    this.isLoading = false,
    this.error,
    this.selectedDepartment,
    this.selectedSection,
    this.selectedSessionId,
    this.isMarkingMode = false,
  });

  AttendanceState copyWith({
    List<Student>? students,
    Map<String, bool>? attendance,
    bool? isLoading,
    String? error,
    String? selectedDepartment,
    String? selectedSection,
    String? selectedSessionId,
    bool? isMarkingMode,
  }) {
    return AttendanceState(
      students: students ?? this.students,
      attendance: attendance ?? this.attendance,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedDepartment: selectedDepartment ?? this.selectedDepartment,
      selectedSection: selectedSection ?? this.selectedSection,
      selectedSessionId: selectedSessionId ?? this.selectedSessionId,
      isMarkingMode: isMarkingMode ?? this.isMarkingMode,
    );
  }
}

class AttendanceController extends StateNotifier<AttendanceState> {
  final StudentService _studentService;
  final AttendanceService _attendanceService;
  final ClassSessionService _classSessionService;

  AttendanceController(this._studentService, this._attendanceService, this._classSessionService)
      : super(AttendanceState());

  Future<void> loadStudentsBySection(String department, String section) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      selectedDepartment: department,
      selectedSection: section,
    );

    try {
      final students = await _studentService.getStudentsBySection(department, section);
      final initialAttendance = <String, bool>{};
      for (final student in students) {
        initialAttendance[student.id] = false;
      }

      state = state.copyWith(
        students: students,
        attendance: initialAttendance,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void toggleAttendance(String studentId, bool isPresent) {
    final updatedAttendance = Map<String, bool>.from(state.attendance);
    updatedAttendance[studentId] = isPresent;
    state = state.copyWith(attendance: updatedAttendance);
  }

  void startMarkingMode(String sessionId) {
    state = state.copyWith(
      isMarkingMode: true,
      selectedSessionId: sessionId,
    );
  }

  void exitMarkingMode() {
    state = state.copyWith(
      isMarkingMode: false,
      selectedSessionId: null,
    );
  }

  Future<bool> saveAttendance(String facultyId, String subject) async {
    if (state.selectedSessionId == null || 
        state.selectedDepartment == null || 
        state.selectedSection == null) {
      state = state.copyWith(error: 'Missing required session information');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final presentStudents = <String>[];
      final absentStudents = <String>[];

      for (final entry in state.attendance.entries) {
        if (entry.value) {
          presentStudents.add(entry.key);
        } else {
          absentStudents.add(entry.key);
        }
      }

      await _attendanceService.markAttendanceForSession(
        state.selectedSessionId!,
        state.selectedDepartment!,
        state.selectedSection!,
        1, // Default semester, should be made dynamic
        subject,
        facultyId,
        presentStudents,
        absentStudents,
      );

      // Update class session status
      await _classSessionService.markAttendance(state.selectedSessionId!, presentStudents);

      state = state.copyWith(
        isLoading: false,
        isMarkingMode: false,
        selectedSessionId: null,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

class StudentsNotifier extends StateNotifier<AsyncValue<List<Student>>> {
  final StudentService _studentService;

  StudentsNotifier(this._studentService) : super(const AsyncValue.loading());

  Future<void> loadStudentsBySection(String department, String section) async {
    state = const AsyncValue.loading();
    try {
      final students = await _studentService.getStudentsBySection(department, section);
      state = AsyncValue.data(students);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

class TodayClassesNotifier extends StateNotifier<AsyncValue<List<ClassSession>>> {
  final ClassSessionService _classSessionService;

  TodayClassesNotifier(this._classSessionService) : super(const AsyncValue.loading());

  Future<void> loadTodayClasses(String facultyId) async {
    state = const AsyncValue.loading();
    try {
      final classes = await _classSessionService.getTodayClassesByFaculty(facultyId);
      state = AsyncValue.data(classes);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}