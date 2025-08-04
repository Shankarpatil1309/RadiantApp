import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/faculty_model.dart';
import '../models/announcement_model.dart';
import '../services/faculty_service.dart';
import '../services/class_session_service.dart';
import '../services/announcement_service.dart';
import '../services/user_service.dart';
import 'auth_controller.dart';

final facultyServiceProvider =
    Provider<FacultyService>((ref) => FacultyService());
final classSessionServiceProvider =
    Provider<ClassSessionService>((ref) => ClassSessionService());
final announcementServiceProvider =
    Provider<AnnouncementService>((ref) => AnnouncementService());
final userServiceProvider = Provider<UserService>((ref) => UserService());

final facultyDataProvider = FutureProvider.autoDispose<Faculty?>((ref) async {
  final authState = ref.watch(authControllerProvider);

  return authState.when(
    data: (user) async {
      if (user == null) return null;

      final facultyService = ref.read(facultyServiceProvider);

      try {
        final faculty = await facultyService.getFaculty("EMP2024011");
        return faculty;
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
  final faculty = await ref.watch(facultyDataProvider.future);
  if (faculty == null) return [];

  final classSessionService = ref.read(classSessionServiceProvider);

  try {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final classSessions = await classSessionService.getClassSessionsByDateRange(
      faculty.employeeId, 
      startOfDay, 
      endOfDay
    );

    List<Map<String, dynamic>> todayClasses = classSessions.map((session) {
      return {
        'id': session.id,
        'subject': session.subjectCode,
        'time': '${_formatTime(session.startTime)} - ${_formatTime(session.endTime)}',
        'duration': _calculateDuration(session.startTime, session.endTime),
        'room': session.room,
        'studentCount': 0, // This would come from student service
        'section': session.section,
        'semester': session.semester,
        'attendanceMarked': false, // This would come from attendance service
        'classSessionId': session.id,
      };
    }).toList();

    // Sort by time
    todayClasses.sort((a, b) {
      final timeA = _parseTimeFromDateTime(a['time']);
      final timeB = _parseTimeFromDateTime(b['time']);
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
  final faculty = await ref.watch(facultyDataProvider.future);
  if (faculty == null) return [];

  final announcementService = ref.read(announcementServiceProvider);

  try {
    final announcements = await announcementService.listenAnnouncements().first;

    // Filter announcements for this faculty's department or general announcements
    final filteredAnnouncements = announcements.where((announcement) {
      return announcement.departments.contains('All') ||
          announcement.departments.contains(faculty.department);
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
  final faculty = await ref.watch(facultyDataProvider.future);
  if (faculty == null) return {};

  final classSessionService = ref.read(classSessionServiceProvider);

  try {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));

    final classSessions = await classSessionService.getClassSessionsByDateRange(
      faculty.employeeId, 
      startOfWeek, 
      endOfWeek
    );

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

    for (final session in classSessions) {
      final dayOfWeek = _getDayOfWeek(session.startTime.weekday);
      
      weeklySchedule[dayOfWeek]?.add({
        'id': session.id,
        'subject': session.subjectCode,
        'time': '${_formatTime(session.startTime)} - ${_formatTime(session.endTime)}',
        'duration': _calculateDuration(session.startTime, session.endTime),
        'room': session.room,
        'section': session.section,
        'semester': session.semester,
        'classSessionId': session.id,
        'startTime': session.startTime,
        'endTime': session.endTime,
      });
    }

    // Sort each day's classes by time
    for (final day in weeklySchedule.keys) {
      weeklySchedule[day]?.sort((a, b) {
        final timeA = (a['startTime'] as DateTime).hour * 60 + (a['startTime'] as DateTime).minute;
        final timeB = (b['startTime'] as DateTime).hour * 60 + (b['startTime'] as DateTime).minute;
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

String _formatTime(DateTime dateTime) {
  final hour = dateTime.hour;
  final minute = dateTime.minute;
  final period = hour >= 12 ? 'PM' : 'AM';
  final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
  
  return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
}

String _calculateDuration(DateTime startTime, DateTime endTime) {
  final duration = endTime.difference(startTime);
  final hours = duration.inHours;
  final minutes = duration.inMinutes % 60;
  
  if (hours > 0 && minutes > 0) {
    return '${hours}hr ${minutes}min';
  } else if (hours > 0) {
    return '${hours}hr';
  } else {
    return '${minutes}min';
  }
}

int _parseTimeFromDateTime(String timeStr) {
  try {
    // Extract time from "HH:MM AM/PM - HH:MM AM/PM" format
    final parts = timeStr.split(' - ')[0].trim();
    final cleanTime = parts.toLowerCase().replaceAll(' ', '');
    final isAM = cleanTime.contains('am');
    final isPM = cleanTime.contains('pm');

    final timeOnly = cleanTime.replaceAll('am', '').replaceAll('pm', '');
    final timeParts = timeOnly.split(':');

    int hour = int.parse(timeParts[0]);
    int minute = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;

    if (isPM && hour != 12) hour += 12;
    if (isAM && hour == 12) hour = 0;

    return hour * 60 + minute;
  } catch (e) {
    print('Error parsing time: $timeStr');
    return 0;
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
