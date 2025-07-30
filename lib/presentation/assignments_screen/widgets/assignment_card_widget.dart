import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AssignmentCardWidget extends StatelessWidget {
  final Map<String, dynamic> assignment;
  final VoidCallback onTap;
  final VoidCallback onDownload;
  final VoidCallback onReminder;
  final VoidCallback onPriority;

  const AssignmentCardWidget({
    Key? key,
    required this.assignment,
    required this.onTap,
    required this.onDownload,
    required this.onReminder,
    required this.onPriority,
  }) : super(key: key);

  Color _getDueDateColor() {
    final dueDate = assignment['dueDate'] as DateTime;
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;

    if (difference < 0) {
      return AppTheme.getStatusColor('error');
    } else if (difference <= 2) {
      return AppTheme.getStatusColor('warning');
    } else {
      return AppTheme.getStatusColor('success');
    }
  }

  String _getStatusText() {
    final dueDate = assignment['dueDate'] as DateTime;
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;

    if (difference < 0) {
      return 'Overdue';
    } else if (difference == 0) {
      return 'Due Today';
    } else if (difference <= 2) {
      return 'Due Soon';
    } else {
      return 'Upcoming';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(assignment['id'].toString()),
      direction: DismissDirection.startToEnd,
      background: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SizedBox(width: 6.w),
            CustomIconWidget(
              iconName: 'download',
              color: AppTheme.lightTheme.primaryColor,
              size: 24,
            ),
            SizedBox(width: 4.w),
            CustomIconWidget(
              iconName: 'notifications',
              color: AppTheme.lightTheme.primaryColor,
              size: 24,
            ),
            SizedBox(width: 4.w),
            CustomIconWidget(
              iconName: 'star',
              color: AppTheme.lightTheme.primaryColor,
              size: 24,
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        // Handle quick actions
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        assignment['title'] as String,
                        style: AppTheme.lightTheme.textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: _getDueDateColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getStatusText(),
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: _getDueDateColor(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'book',
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      assignment['subject'] as String,
                      style: AppTheme.lightTheme.textTheme.bodySmall,
                    ),
                    SizedBox(width: 6.w),
                    CustomIconWidget(
                      iconName: 'schedule',
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Due: ${assignment['dueDate'].toString().split(' ')[0]}',
                      style: AppTheme.lightTheme.textTheme.bodySmall,
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    if (assignment['hasAttachments'] == true) ...[
                      CustomIconWidget(
                        iconName: 'attach_file',
                        color: AppTheme.lightTheme.primaryColor,
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '${assignment['attachmentCount']} files',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.primaryColor,
                        ),
                      ),
                      SizedBox(width: 4.w),
                    ],
                    if (assignment['submissionStatus'] != null) ...[
                      CustomIconWidget(
                        iconName: assignment['submissionStatus'] == 'submitted'
                            ? 'check_circle'
                            : 'pending',
                        color: assignment['submissionStatus'] == 'submitted'
                            ? AppTheme.getStatusColor('success')
                            : AppTheme.getStatusColor('warning'),
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        assignment['submissionStatus'] == 'submitted'
                            ? 'Submitted'
                            : 'Pending',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: assignment['submissionStatus'] == 'submitted'
                              ? AppTheme.getStatusColor('success')
                              : AppTheme.getStatusColor('warning'),
                        ),
                      ),
                    ],
                    if (assignment['grade'] != null) ...[
                      SizedBox(width: 4.w),
                      CustomIconWidget(
                        iconName: 'grade',
                        color: AppTheme.getStatusColor('success'),
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'Grade: ${assignment['grade']}',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.getStatusColor('success'),
                          fontWeight: FontWeight.w500,
                        ),
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
