import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AssignmentDetailBottomSheetWidget extends StatelessWidget {
  final Map<String, dynamic> assignment;
  final VoidCallback onEditAssignment;
  final VoidCallback onExtendDeadline;
  final VoidCallback onDownloadSubmissions;
  final VoidCallback onSendReminders;
  final VoidCallback onClose;

  const AssignmentDetailBottomSheetWidget({
    Key? key,
    required this.assignment,
    required this.onEditAssignment,
    required this.onExtendDeadline,
    required this.onDownloadSubmissions,
    required this.onSendReminders,
    required this.onClose,
  }) : super(key: key);

  bool _isOverdue() {
    final deadline = assignment['deadline'] as DateTime;
    return deadline.isBefore(DateTime.now()) &&
        assignment['status'] == 'active';
  }

  Color _getSubmissionStatusColor() {
    final submissionRate = (assignment['submissionCount'] as int) /
        (assignment['totalStudents'] as int);

    if (submissionRate >= 0.8) {
      return AppTheme.getStatusColor('success');
    } else if (submissionRate >= 0.5) {
      return AppTheme.getStatusColor('warning');
    } else {
      return AppTheme.getStatusColor('error');
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue = _isOverdue();
    final submissionStatusColor = _getSubmissionStatusColor();
    final submissionRate = (assignment['submissionCount'] as int) /
        (assignment['totalStudents'] as int);

    return Container(
      height: 90.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle Bar
          Container(
            width: 12.w,
            height: 0.5.h,
            margin: EdgeInsets.symmetric(vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              children: [
                IconButton(
                  onPressed: onClose,
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 24,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Assignment Details',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      color: AppTheme.getRoleColor('faculty'),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Status Badge
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
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
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
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
          ),

          Divider(height: 1),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Assignment Title
                  Text(
                    assignment['title'],
                    style:
                        AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),

                  SizedBox(height: 1.h),

                  // Course Info
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.getRoleColor('faculty')
                          .withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.getRoleColor('faculty')
                            .withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'school',
                          color: AppTheme.getRoleColor('faculty'),
                          size: 20,
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            '${assignment['subject']} • ${assignment['department']} • ${assignment['semester']}',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme.getRoleColor('faculty'),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Statistics Cards
                  Row(
                    children: [
                      // Submissions Card
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: submissionStatusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              CustomIconWidget(
                                iconName: 'people',
                                color: submissionStatusColor,
                                size: 32,
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                '${assignment['submissionCount']}/${assignment['totalStudents']}',
                                style: AppTheme
                                    .lightTheme.textTheme.headlineSmall
                                    ?.copyWith(
                                  color: submissionStatusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Submissions',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: submissionStatusColor,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              LinearProgressIndicator(
                                value: submissionRate,
                                backgroundColor: submissionStatusColor
                                    .withValues(alpha: 0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    submissionStatusColor),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(width: 4.w),

                      // Deadline Card
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: isOverdue
                                ? AppTheme.getStatusColor('error')
                                    .withValues(alpha: 0.1)
                                : AppTheme.lightTheme.colorScheme
                                    .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              CustomIconWidget(
                                iconName: 'schedule',
                                color: isOverdue
                                    ? AppTheme.getStatusColor('error')
                                    : AppTheme.lightTheme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                size: 32,
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                '${assignment['deadline'].day}/${assignment['deadline'].month}',
                                style: AppTheme
                                    .lightTheme.textTheme.headlineSmall
                                    ?.copyWith(
                                  color: isOverdue
                                      ? AppTheme.getStatusColor('error')
                                      : AppTheme
                                          .lightTheme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                isOverdue ? 'Overdue' : 'Deadline',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: isOverdue
                                      ? AppTheme.getStatusColor('error')
                                      : AppTheme
                                          .lightTheme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 3.h),

                  // Description Section
                  Text(
                    'Description',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme
                          .lightTheme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      assignment['description'],
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Timeline Section
                  Text(
                    'Timeline',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),

                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'upload',
                        color: AppTheme.getStatusColor('success'),
                        size: 20,
                      ),
                      SizedBox(width: 3.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Uploaded',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _formatDateTime(assignment['uploadDate']),
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 2.h),

                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'schedule',
                        color: isOverdue
                            ? AppTheme.getStatusColor('error')
                            : AppTheme.getRoleColor('faculty'),
                        size: 20,
                      ),
                      SizedBox(width: 3.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Deadline',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _formatDateTime(assignment['deadline']),
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: isOverdue
                                  ? AppTheme.getStatusColor('error')
                                  : AppTheme.lightTheme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  if (assignment['hasAttachments']) ...[
                    SizedBox(height: 3.h),

                    // Attachments Section
                    Text(
                      'Attachments (${assignment['attachmentCount']})',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),

                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: AppTheme.getRoleColor('faculty')
                            .withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.getRoleColor('faculty')
                              .withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'attach_file',
                            color: AppTheme.getRoleColor('faculty'),
                            size: 20,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            '${assignment['attachmentCount']} files attached',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme.getRoleColor('faculty'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),

          // Action Buttons
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEditAssignment,
                        icon: CustomIconWidget(
                          iconName: 'edit',
                          color: AppTheme.getRoleColor('faculty'),
                          size: 20,
                        ),
                        label: Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.getRoleColor('faculty'),
                          side: BorderSide(
                              color: AppTheme.getRoleColor('faculty')),
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onExtendDeadline,
                        icon: CustomIconWidget(
                          iconName: 'schedule',
                          color: AppTheme.getStatusColor('warning'),
                          size: 20,
                        ),
                        label: Text('Extend'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.getStatusColor('warning'),
                          side: BorderSide(
                              color: AppTheme.getStatusColor('warning')),
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onDownloadSubmissions,
                        icon: CustomIconWidget(
                          iconName: 'download',
                          color: Colors.white,
                          size: 20,
                        ),
                        label: Text('Download Submissions'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.getRoleColor('faculty'),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onSendReminders,
                        icon: CustomIconWidget(
                          iconName: 'notifications',
                          color: Colors.white,
                          size: 20,
                        ),
                        label: Text('Send Reminders'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.getStatusColor('warning'),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
