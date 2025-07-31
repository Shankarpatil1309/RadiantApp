import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/faculty_model.dart';
import '../models/announcement_model.dart';
import '../services/faculty_service.dart';
import '../services/schedule_service.dart';
import '../services/announcement_service.dart';
import '../services/user_service.dart';
import 'auth_controller.dart';

final facultyServiceProvider =
    Provider<FacultyService>((ref) => FacultyService());
final scheduleServiceProvider =
    Provider<ScheduleService>((ref) => ScheduleService());
final announcementServiceProvider =
    Provider<AnnouncementService>((ref) => AnnouncementService());
final userServiceProvider = Provider<UserService>((ref) => UserService());

final facultyDataProvider =
    FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final authState = ref.watch(authControllerProvider);

  return authState.when(
    data: (user) async {
      if (user == null) return null;

      final userService = ref.read(userServiceProvider);
      final facultyService = ref.read(facultyServiceProvider);

      try {
        final appUser = await userService.getUser(user.uid);
        final faculty = await facultyService.getFaculty("EMP2024011");

        if (faculty != null) {
          return {
            'user': appUser,
            'faculty': faculty,
            'name': faculty.name,
            'email': faculty.email,
            'mobile': faculty.mobile,
            'imageUrl': user.photoURL, // Use Firebase Auth photo URL
            'employeeId': faculty.employeeId,
            'department': faculty.department,
            'designation': faculty.designation,
            'joiningDate': faculty.joiningDate,
            'gender': faculty.gender,
            'dateOfBirth': faculty.dateOfBirth,
            'salary': faculty.salary,
            'address': faculty.address,
            'qualification': faculty.qualification,
            'experience': faculty.experience,
            'specializedSubjects': faculty.specializedSubjects,
            'emergencyContact': faculty.emergencyContact,
            'isActive': faculty.isActive,
            'userRole': appUser?.role.name ?? 'FACULTY',
            'lastLoginAt': appUser?.lastLoginAt,
          };
        }
      } catch (e) {
        print('Error fetching faculty data: $e');
      }
      return null;
    },
    loading: () => null,
    error: (error, stack) => null,
  );
});

final facultyTodayClassesProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final facultyData = await ref.watch(facultyDataProvider.future);
  if (facultyData == null) return [];

  final scheduleService = ref.read(scheduleServiceProvider);
  final faculty = facultyData['faculty'] as Faculty;

  try {
    final now = DateTime.now();
    final dayOfWeek = _getDayOfWeek(now.weekday);

    final schedules = await scheduleService.listenSchedules().first;

    List<Map<String, dynamic>> todayClasses = [];

    for (final schedule in schedules) {
      if (schedule.department == faculty.department &&
          schedule.dayOfWeek == dayOfWeek) {
        for (final subject in schedule.subjects) {
          if (subject['facultyId'] == faculty.employeeId) {
            todayClasses.add({
              'id': '${schedule.id}_${subject['subject']}',
              'subject': subject['subject'],
              'time': subject['time'],
              'duration': subject['duration'] ?? '1hr 30min',
              'room': subject['room'],
              'studentCount': subject['studentCount'] ?? 0,
              'section': schedule.section,
              'semester': schedule.semester,
              'attendanceMarked':
                  false, // This would come from attendance service
              'scheduleId': schedule.id,
            });
          }
        }
      }
    }

    // Sort by time
    todayClasses.sort((a, b) {
      final timeA = _parseTime(a['time']);
      final timeB = _parseTime(b['time']);
      return timeA.compareTo(timeB);
    });

    return todayClasses;
  } catch (e) {
    print('Error fetching today classes: $e');
    return [];
  }
});

final facultyAnnouncementsProvider =
    FutureProvider.autoDispose<List<Announcement>>((ref) async {
  final facultyData = await ref.watch(facultyDataProvider.future);
  if (facultyData == null) return [];

  final announcementService = ref.read(announcementServiceProvider);
  final faculty = facultyData['faculty'] as Faculty;

  try {
    final announcements = await announcementService.listenAnnouncements().first;

    // Filter announcements for this faculty's department or general announcements
    final filteredAnnouncements = announcements.where((announcement) {
      return announcement.department == null ||
          announcement.department == faculty.department ||
          announcement.department == 'All';
    }).toList();

    // Sort by creation date (newest first) and take only 3
    filteredAnnouncements.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filteredAnnouncements.take(3).toList();
  } catch (e) {
    print('Error fetching announcements: $e');
    return [];
  }
});

final facultyNextClassProvider =
    FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final todayClasses = await ref.watch(facultyTodayClassesProvider.future);
  if (todayClasses.isEmpty) return null;

  final now = DateTime.now();
  final currentTime = now.hour * 60 + now.minute;

  for (final classData in todayClasses) {
    final classTime = _parseTime(classData['time']);
    if (classTime > currentTime) {
      return classData;
    }
  }

  return null; // No more classes today
});

final facultyWeeklyScheduleProvider =
    FutureProvider.autoDispose<Map<String, List<Map<String, dynamic>>>>(
        (ref) async {
  final facultyData = await ref.watch(facultyDataProvider.future);
  if (facultyData == null) return {};

  final scheduleService = ref.read(scheduleServiceProvider);
  final faculty = facultyData['faculty'] as Faculty;

  try {
    final schedules = await scheduleService.listenSchedules().first;

    Map<String, List<Map<String, dynamic>>> weeklySchedule = {};
    final daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];

    for (final day in daysOfWeek) {
      weeklySchedule[day] = [];
    }

    for (final schedule in schedules) {
      if (schedule.department == faculty.department) {
        for (final subject in schedule.subjects) {
          if (subject['facultyId'] == faculty.employeeId) {
            weeklySchedule[schedule.dayOfWeek]?.add({
              'id': '${schedule.id}_${subject['subject']}',
              'subject': subject['subject'],
              'time': subject['time'],
              'duration': subject['duration'] ?? '1hr 30min',
              'room': subject['room'],
              'section': schedule.section,
              'semester': schedule.semester,
              'scheduleId': schedule.id,
            });
          }
        }
      }
    }

    // Sort each day's classes by time
    for (final day in weeklySchedule.keys) {
      weeklySchedule[day]?.sort((a, b) {
        final timeA = _parseTime(a['time']);
        final timeB = _parseTime(b['time']);
        return timeA.compareTo(timeB);
      });
    }

    return weeklySchedule;
  } catch (e) {
    print('Error fetching weekly schedule: $e');
    return {};
  }
});

String _getDayOfWeek(int weekday) {
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

int _parseTime(String timeStr) {
  try {
    final cleanTime = timeStr.toLowerCase().replaceAll(' ', '');
    final isAM = cleanTime.contains('am');
    final isPM = cleanTime.contains('pm');

    final timeOnly = cleanTime.replaceAll('am', '').replaceAll('pm', '');
    final parts = timeOnly.split(':');

    int hour = int.parse(parts[0]);
    int minute = parts.length > 1 ? int.parse(parts[1]) : 0;

    if (isPM && hour != 12) hour += 12;
    if (isAM && hour == 12) hour = 0;

    return hour * 60 + minute;
  } catch (e) {
    print('Error parsing time: $timeStr');
    return 0;
  }
}
