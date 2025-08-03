import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FacultyAssignmentCardWidget extends StatelessWidget {
  final Map<String, dynamic> assignment;
  final VoidCallback onTap;

  const FacultyAssignmentCardWidget({
    Key? key,
    required this.assignment,
    required this.onTap,
  }) : super(key: key);

  // Color _getSubmissionStatusColor() {
  //   final submissionRate = (assignment['submissionCount'] as int) /
  //       (assignment['totalStudents'] as int);

  //   if (submissionRate >= 0.8) {
  //     return AppTheme.getStatusColor('success');
  //   } else if (submissionRate >= 0.5) {
  //     return AppTheme.getStatusColor('warning');
  //   } else {
  //     return AppTheme.getStatusColor('error');
  //   }
  // }

  // String _getSubmissionStatusText() {
  //   final submissionRate = (assignment['submissionCount'] as int) /
  //       (assignment['totalStudents'] as int);

  //   if (submissionRate >= 0.8) {
  //     return 'High';
  //   } else if (submissionRate >= 0.5) {
  //     return 'Moderate';
  //   } else {
  //     return 'Low';
  //   }
  // }

  bool _isOverdue() {
    final deadline = assignment['deadline'] as DateTime;
    return deadline.isBefore(DateTime.now()) &&
        assignment['status'] == 'active';
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'Due in ${difference.inMinutes} min';
      }
      return 'Due in ${difference.inHours}h';
    } else if (difference.inDays > 0) {
      return 'Due in ${difference.inDays} days';
    } else {
      return 'Overdue by ${difference.inDays.abs()} days';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue = _isOverdue();
    // final submissionStatusColor = _getSubmissionStatusColor();
    // final submissionStatusText = _getSubmissionStatusText();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0),
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            assignment['title'],
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.lightTheme.colorScheme.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.5.h),
                          Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'school',
                                size: 16,
                                color: AppTheme.lightTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                '${assignment['department']} • ${assignment['semester']}',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Status Badge
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 3.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: isOverdue
                            ? AppTheme.getStatusColor('error')
                                .withValues(alpha: 0.1)
                            : assignment['status'] == 'closed'
                                ? AppTheme.getStatusColor('success')
                                    .withValues(alpha: 0.1)
                                : AppTheme.getRoleColor('faculty')
                                    .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        isOverdue
                            ? 'Overdue'
                            : assignment['status'] == 'closed'
                                ? 'Closed'
                                : 'Active',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: isOverdue
                              ? AppTheme.getStatusColor('error')
                              : assignment['status'] == 'closed'
                                  ? AppTheme.getStatusColor('success')
                                  : AppTheme.getRoleColor('faculty'),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 2.h),

                // Description
                Text(
                  assignment['description'],
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 2.h),

                // Statistics Row
                Row(
                  children: [
                    // Submission Count
                    // Expanded(
                    //   flex: 2,
                    //   child: Container(
                    //     padding: EdgeInsets.all(3.w),
                    //     decoration: BoxDecoration(
                    //       color: submissionStatusColor.withValues(alpha: 0.1),
                    //       borderRadius: BorderRadius.circular(8),
                    //     ),
                    //     child: Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         Row(
                    //           children: [
                    //             CustomIconWidget(
                    //               iconName: 'people',
                    //               size: 16,
                    //               color: submissionStatusColor,
                    //             ),
                    //             SizedBox(width: 1.w),
                    //             Text(
                    //               'Submissions',
                    //               style: AppTheme.lightTheme.textTheme.bodySmall
                    //                   ?.copyWith(
                    //                 color: submissionStatusColor,
                    //                 fontWeight: FontWeight.w500,
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //         SizedBox(height: 1.h),
                    //         Text(
                    //           '${assignment['submissionCount']}/${assignment['totalStudents']}',
                    //           style: AppTheme.lightTheme.textTheme.titleMedium
                    //               ?.copyWith(
                    //             color: submissionStatusColor,
                    //             fontWeight: FontWeight.w600,
                    //           ),
                    //         ),
                    //         Text(
                    //           '$submissionStatusText Rate',
                    //           style: AppTheme.lightTheme.textTheme.bodySmall
                    //               ?.copyWith(
                    //             color: submissionStatusColor,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),

                    // SizedBox(width: 3.w),

                    // Deadline Info
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: isOverdue
                              ? AppTheme.getStatusColor('error')
                                  .withValues(alpha: 0.1)
                              : AppTheme.lightTheme.colorScheme
                                  .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'schedule',
                                  size: 16,
                                  color: isOverdue
                                      ? AppTheme.getStatusColor('error')
                                      : AppTheme
                                          .lightTheme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  'Deadline',
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: isOverdue
                                        ? AppTheme.getStatusColor('error')
                                        : AppTheme
                                            .lightTheme.colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              _formatDateTime(assignment['deadline']),
                              style: AppTheme.lightTheme.textTheme.titleSmall
                                  ?.copyWith(
                                color: isOverdue
                                    ? AppTheme.getStatusColor('error')
                                    : AppTheme.lightTheme.colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(width: 3.w),

                    // Attachments
                    if (assignment['hasAttachments']) ...[
                      Column(
                        children: [
                          CustomIconWidget(
                            iconName: 'attach_file',
                            size: 20,
                            color: AppTheme.getRoleColor('faculty'),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            '${assignment['attachmentCount']}',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.getRoleColor('faculty'),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
