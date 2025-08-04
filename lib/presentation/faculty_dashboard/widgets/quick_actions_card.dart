import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickActionsCard extends StatelessWidget {
  final Function() onMarkAttendance;
  final Function() onPostAnnouncement;
  final Function() onViewSchedule;
  final Function() onManageAssignments;
  final Function() onCreateAssignment;
  final Function() onScheduleClass;

  const QuickActionsCard({
    Key? key,
    required this.onMarkAttendance,
    required this.onPostAnnouncement,
    required this.onViewSchedule,
    required this.onManageAssignments,
    required this.onCreateAssignment,
    required this.onScheduleClass,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'flash_on',
                  color: AppTheme.getRoleColor('faculty'),
                  size: 24,
                ),
                SizedBox(width: 2.w),
                Text(
                  "Quick Actions",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getRoleColor('faculty'),
                      ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    "Mark Attendance",
                    'how_to_reg',
                    AppTheme.getRoleColor('faculty'),
                    onMarkAttendance,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: _buildActionButton(
                    context,
                    "Post Announcement",
                    'campaign',
                    AppTheme.warningLight,
                    onPostAnnouncement,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    "View Schedule",
                    'calendar_today',
                    AppTheme.getRoleColor('student'),
                    onViewSchedule,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: _buildActionButton(
                    context,
                    "Manage Assignments",
                    'assignment',
                    AppTheme.getStatusColor('success'),
                    onManageAssignments,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    "Create Assignment",
                    'assignment_add',
                    AppTheme.getStatusColor('info'),
                    onCreateAssignment,
                  ),
                ),
                // SizedBox(width: 3.w),
                // Expanded(
                //   child: _buildActionButton(
                //     context,
                //     "Schedule Class",
                //     'schedule',
                //     AppTheme.getStatusColor('warning'),
                //     onScheduleClass,
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    String iconName,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 2.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomIconWidget(
                iconName: iconName,
                color: Colors.white,
                size: 24,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
