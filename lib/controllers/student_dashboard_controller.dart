import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/student_model.dart';
import '../models/announcement_model.dart';
import '../models/class_session_model.dart';
import '../models/assignment_model.dart';
import '../services/student_service.dart';
import '../services/class_session_service.dart';
import '../services/announcement_service.dart';
import '../services/assignment_service.dart';
import '../services/user_service.dart';
import 'auth_controller.dart';

final studentServiceProvider =
    Provider<StudentService>((ref) => StudentService());
final studentClassSessionServiceProvider =
    Provider<ClassSessionService>((ref) => ClassSessionService());
final studentAnnouncementServiceProvider =
    Provider<AnnouncementService>((ref) => AnnouncementService());
final studentAssignmentServiceProvider =
    Provider<AssignmentService>((ref) => AssignmentService());
final studentUserServiceProvider =
    Provider<UserService>((ref) => UserService());

final studentDataProvider =
    FutureProvider.autoDispose<Student?>((ref) async {
  final authState = ref.watch(authControllerProvider);

  return authState.when(
    data: (user) async {
      if (user == null) return null;

      final studentService = ref.read(studentServiceProvider);

      try {
        // For demo purposes, using a hardcoded student ID
        // In production, this would come from the user's profile
        final student = await studentService.getStudent("twrVVSHeWoUpTNLSJ48N");
        return student;
      } catch (e) {
        print('Error fetching student data: $e');
      }
      return null;
    },
    loading: () => null,
    error: (error, stack) => null,
  );
});

final studentTodayClassesProvider =
    FutureProvider.autoDispose<List<ClassSession>>((ref) async {
  final student = await ref.watch(studentDataProvider.future);
  if (student == null) return [];

  final classSessionService = ref.read(studentClassSessionServiceProvider);

  try {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(Duration(days: 1));

    // Get today's classes for the student's department and section
    final sessions =
        await classSessionService.getClassSessionsByDateRangeForStudent(
      student.department,
      student.section,
      student.semester,
      startOfDay,
      endOfDay,
    );

    // Sort by start time
    sessions.sort((a, b) => a.startTime.compareTo(b.startTime));

    return sessions;
  } catch (e) {
    print('Error fetching today classes: $e');
    return [];
  }
});

final studentAnnouncementsProvider =
    FutureProvider.autoDispose<List<Announcement>>((ref) async {
  final student = await ref.watch(studentDataProvider.future);
  if (student == null) return [];

  final announcementService = ref.read(studentAnnouncementServiceProvider);

  try {
    final announcements = await announcementService.listenAnnouncements().first;

    // Filter announcements for this student's department or general announcements
    final filteredAnnouncements = announcements.where((announcement) {
      return announcement.departments.contains('All') ||
          announcement.departments.contains(student.department);
    }).toList();

    // Sort by creation date (newest first) and take only recent ones
    filteredAnnouncements.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filteredAnnouncements.take(5).toList();
  } catch (e) {
    print('Error fetching announcements: $e');
    return [];
  }
});

final studentAssignmentsProvider =
    FutureProvider.autoDispose<List<Assignment>>((ref) async {
  final student = await ref.watch(studentDataProvider.future);
  if (student == null) return [];

  final assignmentService = ref.read(studentAssignmentServiceProvider);

  try {
    final assignments = await assignmentService.getActiveAssignmentsForStudent(
      student.department,
      student.section,
      student.semester,
    );

    return assignments;
  } catch (e) {
    print('Error fetching assignments: $e');
    return [];
  }
});

final studentNextClassProvider =
    FutureProvider.autoDispose<ClassSession?>((ref) async {
  final todayClasses = await ref.watch(studentTodayClassesProvider.future);
  if (todayClasses.isEmpty) return null;

  final now = DateTime.now();

  for (final classSession in todayClasses) {
    if (classSession.startTime.isAfter(now)) {
      return classSession;
    }
  }

  return null; // No more classes today
});

final studentWeeklyScheduleProvider =
    FutureProvider.autoDispose<Map<String, List<ClassSession>>>((ref) async {
  final student = await ref.watch(studentDataProvider.future);
  if (student == null) return {};

  final classSessionService = ref.read(studentClassSessionServiceProvider);

  try {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));

    final sessions =
        await classSessionService.getClassSessionsByDateRangeForStudent(
      student.department,
      student.section,
      student.semester,
      startOfWeek,
      endOfWeek,
    );

    // Group by day of week
    final Map<String, List<ClassSession>> weeklySchedule = {
      'Monday': <ClassSession>[],
      'Tuesday': <ClassSession>[],
      'Wednesday': <ClassSession>[],
      'Thursday': <ClassSession>[],
      'Friday': <ClassSession>[],
      'Saturday': <ClassSession>[],
    };

    for (final session in sessions) {
      final dayName = _getDayName(session.startTime.weekday);
      if (weeklySchedule.containsKey(dayName)) {
        weeklySchedule[dayName]!.add(session);
      }
    }

    // Sort each day's sessions by start time
    for (final dayList in weeklySchedule.values) {
      dayList.sort((a, b) => a.startTime.compareTo(b.startTime));
    }

    return weeklySchedule;
  } catch (e) {
    print('Error fetching weekly schedule: $e');
    return {};
  }
});

String _getDayName(int weekday) {
  switch (weekday) {
    case 1:
      return 'Monday';
    case 2:
      return 'Tuesday';
    case 3:
      return 'Wednesday';
    case 4:
      return 'Thursday';
    case 5:
      return 'Friday';
    case 6:
      return 'Saturday';
    case 7:
      return 'Sunday';
    default:
      return 'Monday';
  }
}
