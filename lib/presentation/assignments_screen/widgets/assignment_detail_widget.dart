import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AssignmentDetailWidget extends StatelessWidget {
  final Map<String, dynamic> assignment;
  final VoidCallback onDownloadAttachment;
  final VoidCallback onSubmit;
  final VoidCallback onClose;

  const AssignmentDetailWidget({
    Key? key,
    required this.assignment,
    required this.onDownloadAttachment,
    required this.onSubmit,
    required this.onClose,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85.h,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Assignment Details',
                  style: AppTheme.lightTheme.textTheme.titleLarge,
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: CustomIconWidget(
                  iconName: 'close',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 24,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Status
                  Text(
                    assignment['title'] as String,
                    style: AppTheme.lightTheme.textTheme.headlineSmall,
                  ),
                  SizedBox(height: 2.h),

                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: _getDueDateColor().withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName: 'schedule',
                              color: _getDueDateColor(),
                              size: 16,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              'Due: ${assignment['dueDate'].toString().split(' ')[0]}',
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                color: _getDueDateColor(),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.primaryColor
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          assignment['subject'] as String,
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),

                  // Description
                  Text(
                    'Description',
                    style: AppTheme.lightTheme.textTheme.titleMedium,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    assignment['description'] as String,
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                  SizedBox(height: 3.h),

                  // Attachments
                  if (assignment['hasAttachments'] == true) ...[
                    Text(
                      'Attachments',
                      style: AppTheme.lightTheme.textTheme.titleMedium,
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'attach_file',
                            color: AppTheme.lightTheme.primaryColor,
                            size: 24,
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Assignment_Materials.pdf',
                                  style: AppTheme
                                      .lightTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '2.5 MB',
                                  style:
                                      AppTheme.lightTheme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          TextButton.icon(
                            onPressed: onDownloadAttachment,
                            icon: CustomIconWidget(
                              iconName: 'download',
                              color: AppTheme.lightTheme.primaryColor,
                              size: 20,
                            ),
                            label: Text('Download'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 3.h),
                  ],

                  // Submission Status
                  if (assignment['submissionStatus'] != null) ...[
                    Text(
                      'Submission Status',
                      style: AppTheme.lightTheme.textTheme.titleMedium,
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: assignment['submissionStatus'] == 'submitted'
                            ? AppTheme.getStatusColor('success')
                                .withValues(alpha: 0.1)
                            : AppTheme.getStatusColor('warning')
                                .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName:
                                assignment['submissionStatus'] == 'submitted'
                                    ? 'check_circle'
                                    : 'pending',
                            color: assignment['submissionStatus'] == 'submitted'
                                ? AppTheme.getStatusColor('success')
                                : AppTheme.getStatusColor('warning'),
                            size: 24,
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              assignment['submissionStatus'] == 'submitted'
                                  ? 'Assignment submitted successfully'
                                  : 'Submission pending',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: assignment['submissionStatus'] ==
                                        'submitted'
                                    ? AppTheme.getStatusColor('success')
                                    : AppTheme.getStatusColor('warning'),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 3.h),
                  ],

                  // Grade (if available)
                  if (assignment['grade'] != null) ...[
                    Text(
                      'Grade',
                      style: AppTheme.lightTheme.textTheme.titleMedium,
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: AppTheme.getStatusColor('success')
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'grade',
                            color: AppTheme.getStatusColor('success'),
                            size: 24,
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            '${assignment['grade']}/100',
                            style: AppTheme.lightTheme.textTheme.titleLarge
                                ?.copyWith(
                              color: AppTheme.getStatusColor('success'),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          if (assignment['feedback'] != null)
                            Expanded(
                              child: Text(
                                assignment['feedback'] as String,
                                style: AppTheme.lightTheme.textTheme.bodySmall,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Submit Button (if not submitted)
          if (assignment['submissionStatus'] != 'submitted')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onSubmit,
                icon: CustomIconWidget(
                  iconName: 'upload',
                  color: Colors.white,
                  size: 20,
                ),
                label: Text('Submit Assignment'),
              ),
            ),
        ],
      ),
    );
  }
}
