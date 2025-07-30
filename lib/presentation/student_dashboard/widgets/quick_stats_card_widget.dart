import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickStatsCardWidget extends StatelessWidget {
  final double attendancePercentage;
  final List<Map<String, dynamic>> recentMarks;
  final VoidCallback onAttendanceTap;
  final VoidCallback onMarksTap;

  const QuickStatsCardWidget({
    super.key,
    required this.attendancePercentage,
    required this.recentMarks,
    required this.onAttendanceTap,
    required this.onMarksTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(4.w),
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
                Expanded(
                  child: Text(
                    'Quick Stats',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: _buildAttendanceCard(),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: _buildRecentMarksCard(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceCard() {
    Color attendanceColor;
    String attendanceStatus;

    if (attendancePercentage >= 85) {
      attendanceColor = AppTheme.getStatusColor('success');
      attendanceStatus = 'Excellent';
    } else if (attendancePercentage >= 75) {
      attendanceColor = AppTheme.getStatusColor('warning');
      attendanceStatus = 'Good';
    } else {
      attendanceColor = AppTheme.getStatusColor('error');
      attendanceStatus = 'Low';
    }

    return InkWell(
      onTap: onAttendanceTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: attendanceColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: attendanceColor.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'how_to_reg',
                  color: attendanceColor,
                  size: 20,
                ),
                const Spacer(),
                CustomIconWidget(
                  iconName: 'arrow_forward_ios',
                  color: attendanceColor.withValues(alpha: 0.6),
                  size: 14,
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              '${attendancePercentage.toStringAsFixed(1)}%',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                color: attendanceColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              'Attendance',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 0.5.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.2.h),
              decoration: BoxDecoration(
                color: attendanceColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                attendanceStatus,
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentMarksCard() {
    final hasMarks = recentMarks.isNotEmpty;
    final averageMarks = hasMarks
        ? recentMarks
                .map((mark) => mark['marks'] as double)
                .reduce((a, b) => a + b) /
            recentMarks.length
        : 0.0;

    Color marksColor;
    String marksStatus;

    if (averageMarks >= 85) {
      marksColor = AppTheme.getStatusColor('success');
      marksStatus = 'Excellent';
    } else if (averageMarks >= 70) {
      marksColor = AppTheme.getStatusColor('warning');
      marksStatus = 'Good';
    } else if (averageMarks >= 50) {
      marksColor = AppTheme.lightTheme.primaryColor;
      marksStatus = 'Average';
    } else {
      marksColor = AppTheme.getStatusColor('error');
      marksStatus = 'Needs Improvement';
    }

    return InkWell(
      onTap: onMarksTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: hasMarks
              ? marksColor.withValues(alpha: 0.1)
              : AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasMarks
                ? marksColor.withValues(alpha: 0.3)
                : AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'grade',
                  color: hasMarks
                      ? marksColor
                      : AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                  size: 20,
                ),
                const Spacer(),
                CustomIconWidget(
                  iconName: 'arrow_forward_ios',
                  color: hasMarks
                      ? marksColor.withValues(alpha: 0.6)
                      : AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.4),
                  size: 14,
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              hasMarks ? '${averageMarks.toStringAsFixed(1)}%' : 'N/A',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                color: hasMarks
                    ? marksColor
                    : AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              'Recent Marks',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 0.5.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.2.h),
              decoration: BoxDecoration(
                color: hasMarks
                    ? marksColor
                    : AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                hasMarks ? marksStatus : 'No Data',
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
