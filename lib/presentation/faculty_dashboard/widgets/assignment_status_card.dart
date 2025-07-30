import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AssignmentStatusCard extends StatelessWidget {
  final Map<String, dynamic> assignmentStats;
  final Function() onViewAssignments;

  const AssignmentStatusCard({
    Key? key,
    required this.assignmentStats,
    required this.onViewAssignments,
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
                  iconName: 'assignment',
                  color: AppTheme.getRoleColor('faculty'),
                  size: 24,
                ),
                SizedBox(width: 2.w),
                Text(
                  "Assignment Status",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getRoleColor('faculty'),
                      ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onViewAssignments,
                  child: Text(
                    "View All",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.getRoleColor('faculty'),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    "Total Assignments",
                    assignmentStats["total"].toString(),
                    'assignment_turned_in',
                    AppTheme.getRoleColor('faculty'),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: _buildStatItem(
                    context,
                    "Pending Review",
                    assignmentStats["pendingReview"].toString(),
                    'rate_review',
                    AppTheme.warningLight,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    "Submissions",
                    assignmentStats["submissions"].toString(),
                    'upload_file',
                    AppTheme.getStatusColor('success'),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: _buildStatItem(
                    context,
                    "Overdue",
                    assignmentStats["overdue"].toString(),
                    'schedule',
                    AppTheme.getStatusColor('error'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            _buildProgressIndicator(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value,
      String iconName, Color color) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: iconName,
                color: color,
                size: 20,
              ),
              const Spacer(),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    final int total = assignmentStats["total"] as int;
    final int reviewed = assignmentStats["reviewed"] as int;
    final double progress = total > 0 ? reviewed / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Review Progress",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            Text(
              "${(progress * 100).toInt()}%",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getRoleColor('faculty'),
                  ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        LinearProgressIndicator(
          value: progress,
          backgroundColor:
              Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          valueColor:
              AlwaysStoppedAnimation<Color>(AppTheme.getRoleColor('faculty')),
          minHeight: 6,
        ),
        SizedBox(height: 0.5.h),
        Text(
          "$reviewed of $total assignments reviewed",
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
        ),
      ],
    );
  }
}
