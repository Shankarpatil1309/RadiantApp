import 'package:flutter/material.dart';
import 'package:radiant_app/presentation/faculty_assignment_management_screen/faculty_assignment_management_screen.dart';
import 'package:radiant_app/presentation/login_screen/login_screen2.dart';
import 'package:radiant_app/presentation/splash_screen/splash_screen.dart';
import '../presentation/assignments_screen/assignments_screen.dart';
import '../presentation/weekly_schedule_screen/weekly_schedule_screen.dart';
import '../presentation/faculty_dashboard/faculty_dashboard.dart';
import '../presentation/admin_dashboard/admin_dashboard.dart';
import '../presentation/admin_dashboard/add_student_screen.dart';
import '../presentation/admin_dashboard/add_faculty_screen.dart';
import '../presentation/student_dashboard/student_dashboard.dart';
import '../presentation/attendance_screen/student_attendance_screen.dart';
import '../presentation/attendance_screen/faculty_attendance_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splashScreen = '/splash-screen';
  static const String loginScreen = '/login-screen';
  static const String studentAssignmentsScreen = '/student-assignments-screen';
  static const String facultyAssignmentsScreen = '/faculty-assignments-screen';
  static const String weeklyScheduleScreen = '/weekly-schedule-screen';
  static const String facultyDashboard = '/faculty-dashboard';
  static const String adminDashboard = '/admin-dashboard';
  static const String studentDashboard = '/student-dashboard';
  static const String attendanceScreen = '/attendance-screen';
  static const String studentAttendanceScreen = '/student-attendance-screen';
  static const String facultyAttendanceScreen = '/faculty-attendance-screen';
  static const String addStudentScreen = '/add-student';
  static const String addFacultyScreen = '/add-faculty';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splashScreen: (context) => const SplashScreen(),
    loginScreen: (context) => const LoginScreen(),
    studentAssignmentsScreen: (context) => AssignmentsScreen(),
    weeklyScheduleScreen: (context) => WeeklyScheduleScreen(),
    facultyDashboard: (context) => FacultyDashboard(),
    adminDashboard: (context) => AdminDashboard(),
    studentDashboard: (context) => StudentDashboard(),
    studentAttendanceScreen: (context) => StudentAttendanceScreen(),
    facultyAttendanceScreen: (context) => FacultyAttendanceScreen(),
    facultyAssignmentsScreen: (context) => FacultyAssignmentManagementScreen(),
    addStudentScreen: (context) => AddStudentScreen(),
    addFacultyScreen: (context) => AddFacultyScreen(),

    // TODO: Add your other routes here
  };
}
