import 'package:flutter/material.dart';
import 'package:radiant_app/presentation/login_screen/login_screen2.dart';
import 'package:radiant_app/presentation/splash_screen/splash_screen.dart';
import '../presentation/assignments_screen/assignments_screen.dart';
import '../presentation/weekly_schedule_screen/weekly_schedule_screen.dart';
import '../presentation/faculty_dashboard/faculty_dashboard.dart';
import '../presentation/admin_dashboard/admin_dashboard.dart';
import '../presentation/student_dashboard/student_dashboard.dart';
import '../presentation/attendance_screen/attendance_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splashScreen = '/splash-screen';
  static const String loginScreen = '/login-screen';
  static const String assignmentsScreen = '/assignments-screen';
  static const String weeklyScheduleScreen = '/weekly-schedule-screen';
  static const String facultyDashboard = '/faculty-dashboard';
  static const String adminDashboard = '/admin-dashboard';
  static const String studentDashboard = '/student-dashboard';
  static const String attendanceScreen = '/attendance-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splashScreen: (context) => const SplashScreen(),
    loginScreen: (context) => const LoginScreen(),
    assignmentsScreen: (context) => AssignmentsScreen(),
    weeklyScheduleScreen: (context) => WeeklyScheduleScreen(),
    facultyDashboard: (context) => FacultyDashboard(),
    adminDashboard: (context) => AdminDashboard(),
    studentDashboard: (context) => StudentDashboard(),
    attendanceScreen: (context) => AttendanceScreen(),
    // TODO: Add your other routes here
  };
}
