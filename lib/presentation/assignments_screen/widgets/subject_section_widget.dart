import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './assignment_card_widget.dart';

class SubjectSectionWidget extends StatefulWidget {
  final String subject;
  final List<Map<String, dynamic>> assignments;
  final Function(Map<String, dynamic>) onAssignmentTap;
  final Function(Map<String, dynamic>) onDownload;
  final Function(Map<String, dynamic>) onReminder;
  final Function(Map<String, dynamic>) onPriority;

  const SubjectSectionWidget({
    Key? key,
    required this.subject,
    required this.assignments,
    required this.onAssignmentTap,
    required this.onDownload,
    required this.onReminder,
    required this.onPriority,
  }) : super(key: key);

  @override
  State<SubjectSectionWidget> createState() => _SubjectSectionWidgetState();
}

class _SubjectSectionWidgetState extends State<SubjectSectionWidget> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.subject,
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color:
                        AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.assignments.length}',
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.lightTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: CustomIconWidget(
                    iconName: 'keyboard_arrow_down',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _isExpanded ? null : 0,
          child: _isExpanded
              ? Column(
                  children: widget.assignments.map((assignment) {
                    return AssignmentCardWidget(
                      assignment: assignment,
                      onTap: () => widget.onAssignmentTap(assignment),
                      onDownload: () => widget.onDownload(assignment),
                      onReminder: () => widget.onReminder(assignment),
                      onPriority: () => widget.onPriority(assignment),
                    );
                  }).toList(),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
