import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AttendanceStatsWidget extends StatelessWidget {
  final Map<String, dynamic> attendanceData;
  final String userRole;

  const AttendanceStatsWidget({
    Key? key,
    required this.attendanceData,
    required this.userRole,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (userRole == 'student') {
      return _buildStudentStats(context);
    } else {
      return _buildFacultyStats(context);
    }
  }

  Widget _buildStudentStats(BuildContext context) {
    final overallPercentage =
        (attendanceData['overallPercentage'] as num).toDouble();
    final subjects = attendanceData['subjects'] as List;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'analytics',
                color: AppTheme.lightTheme.primaryColor,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Text(
                'Attendance Overview',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildOverallProgress(context, overallPercentage),
          SizedBox(height: 3.h),
          Text(
            'Subject-wise Attendance',
            style: AppTheme.lightTheme.textTheme.titleSmall,
          ),
          SizedBox(height: 2.h),
          ...subjects
              .map((subject) => _buildSubjectProgress(
                    context,
                    subject['name'] as String,
                    (subject['percentage'] as num).toDouble(),
                    subject['present'] as int,
                    subject['total'] as int,
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildFacultyStats(BuildContext context) {
    final todayClasses = attendanceData['todayClasses'] as List;
    final pendingSessions = attendanceData['pendingSessions'] as int;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'school',
                color: AppTheme.getRoleColor('faculty'),
                size: 24,
              ),
              SizedBox(width: 3.w),
              Text(
                'Today\'s Classes',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          if (pendingSessions > 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color:
                    AppTheme.getStatusColor('warning').withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'warning',
                    color: AppTheme.getStatusColor('warning'),
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    '$pendingSessions pending sessions',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.getStatusColor('warning'),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 2.h),
          ...todayClasses
              .map((classData) => _buildClassCard(context, classData))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildOverallProgress(BuildContext context, double percentage) {
    Color progressColor = AppTheme.getStatusColor('success');
    if (percentage < 75) {
      progressColor = AppTheme.getStatusColor('error');
    } else if (percentage < 85) {
      progressColor = AppTheme.getStatusColor('warning');
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: progressColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overall Attendance',
                style: AppTheme.lightTheme.textTheme.titleSmall,
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: progressColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: progressColor.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectProgress(BuildContext context, String subject,
      double percentage, int present, int total) {
    Color progressColor = AppTheme.getStatusColor('success');
    if (percentage < 75) {
      progressColor = AppTheme.getStatusColor('error');
    } else if (percentage < 85) {
      progressColor = AppTheme.getStatusColor('warning');
    }

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  subject,
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '$present/$total (${percentage.toStringAsFixed(1)}%)',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: progressColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: progressColor.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, Map<String, dynamic> classData) {
    final isCompleted = classData['isCompleted'] as bool;
    final className = classData['className'] as String;
    final time = classData['time'] as String;
    final studentsPresent = classData['studentsPresent'] as int;
    final totalStudents = classData['totalStudents'] as int;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppTheme.getStatusColor('success').withValues(alpha: 0.1)
            : AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCompleted
              ? AppTheme.getStatusColor('success').withValues(alpha: 0.3)
              : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: isCompleted ? 'check_circle' : 'schedule',
            color: isCompleted
                ? AppTheme.getStatusColor('success')
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  className,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  time,
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (isCompleted)
            Text(
              '$studentsPresent/$totalStudents',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.getStatusColor('success'),
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}
