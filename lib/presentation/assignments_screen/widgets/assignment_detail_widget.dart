import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../models/assignment_model.dart';

class AssignmentDetailWidget extends StatelessWidget {
  final Assignment assignment;
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
    final now = DateTime.now();
    final difference = assignment.dueDate.difference(now).inDays;

    if (difference < 0) {
      return AppTheme.getStatusColor('error');
    } else if (difference <= 2) {
      return AppTheme.getStatusColor('warning');
    } else {
      return AppTheme.getStatusColor('success');
    }
  }

  String _getSubmissionStatus() {
    if (!assignment.isActive) {
      return 'submitted';
    }
    if (assignment.dueDate.isBefore(DateTime.now())) {
      return 'overdue';
    }
    return 'pending';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
                    assignment.title,
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
                              'Due: ${_formatDate(assignment.dueDate)}',
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
                          assignment.subject,
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
                    assignment.description,
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                  SizedBox(height: 3.h),

                  // Attachments
                  if (assignment.hasFile) ...[
                    Text(
                      'Attachments',
                      style: AppTheme.lightTheme.textTheme.titleMedium,
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: AppTheme
                            .lightTheme.colorScheme.surfaceContainerHighest,
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
                                  assignment.fileName.isNotEmpty
                                      ? assignment.fileName
                                      : 'Assignment File',
                                  style: AppTheme
                                      .lightTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  assignment.fileExtension.isNotEmpty
                                      ? assignment.fileExtension.toUpperCase()
                                      : 'File',
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
                  Container(
                    margin: EdgeInsets.only(bottom: 3.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Submission Status',
                          style: AppTheme.lightTheme.textTheme.titleMedium,
                        ),
                        SizedBox(height: 1.h),
                        Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: _getSubmissionStatus() == 'submitted'
                                ? AppTheme.getStatusColor('success')
                                    .withValues(alpha: 0.1)
                                : _getSubmissionStatus() == 'overdue'
                                    ? AppTheme.getStatusColor('error')
                                        .withValues(alpha: 0.1)
                                    : AppTheme.getStatusColor('warning')
                                        .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              CustomIconWidget(
                                iconName: _getSubmissionStatus() == 'submitted'
                                    ? 'check_circle'
                                    : _getSubmissionStatus() == 'overdue'
                                        ? 'warning'
                                        : 'pending',
                                color: _getSubmissionStatus() == 'submitted'
                                    ? AppTheme.getStatusColor('success')
                                    : _getSubmissionStatus() == 'overdue'
                                        ? AppTheme.getStatusColor('error')
                                        : AppTheme.getStatusColor('warning'),
                                size: 24,
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Text(
                                  _getSubmissionStatus() == 'submitted'
                                      ? 'Assignment submitted successfully'
                                      : _getSubmissionStatus() == 'overdue'
                                          ? 'Assignment is overdue'
                                          : 'Submission pending',
                                  style: AppTheme
                                      .lightTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                    color: _getSubmissionStatus() == 'submitted'
                                        ? AppTheme.getStatusColor('success')
                                        : _getSubmissionStatus() == 'overdue'
                                            ? AppTheme.getStatusColor('error')
                                            : AppTheme.getStatusColor(
                                                'warning'),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Assignment Details
                  Container(
                    margin: EdgeInsets.only(bottom: 3.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assignment Details',
                          style: AppTheme.lightTheme.textTheme.titleMedium,
                        ),
                        SizedBox(height: 1.h),
                        Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: AppTheme
                                .lightTheme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'person',
                                    color: AppTheme.lightTheme.primaryColor,
                                    size: 20,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    'Faculty: ${assignment.facultyName}',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              SizedBox(height: 1.h),
                              Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'grading',
                                    color: AppTheme.lightTheme.primaryColor,
                                    size: 20,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    'Max Marks: ${assignment.maxMarks}',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              SizedBox(height: 1.h),
                              Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'category',
                                    color: AppTheme.lightTheme.primaryColor,
                                    size: 20,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    'Type: ${assignment.type.toUpperCase()}',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              if (assignment.instructions != null &&
                                  assignment.instructions!.isNotEmpty) ...[
                                SizedBox(height: 1.h),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomIconWidget(
                                      iconName: 'info',
                                      color: AppTheme.lightTheme.primaryColor,
                                      size: 20,
                                    ),
                                    SizedBox(width: 2.w),
                                    Expanded(
                                      child: Text(
                                        'Instructions: ${assignment.instructions}',
                                        style: AppTheme
                                            .lightTheme.textTheme.bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Submit Button (if not submitted)
          // TODO: Implement submission logic
          // if (_getSubmissionStatus() != 'submitted')
          //   SizedBox(
          //     width: double.infinity,
          //     child: ElevatedButton.icon(
          //       onPressed: onSubmit,
          //       icon: CustomIconWidget(
          //         iconName: 'upload',
          //         color: Colors.white,
          //         size: 20,
          //       ),
          //       label: Text('Submit Assignment'),
          //     ),
          //   ),
        ],
      ),
    );
  }
}
