import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class FilterBottomSheetWidget extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onFiltersChanged;

  const FilterBottomSheetWidget({
    Key? key,
    required this.currentFilters,
    required this.onFiltersChanged,
  }) : super(key: key);

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late Map<String, dynamic> _filters;

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.currentFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Filter Assignments',
                  style: AppTheme.lightTheme.textTheme.titleLarge,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _filters = {
                      'subject': 'All',
                      'status': 'All',
                      'priority': 'All',
                      'sortBy': 'dueDate',
                    };
                  });
                },
                child: Text('Reset'),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Subject Filter
          Text(
            'Subject',
            style: AppTheme.lightTheme.textTheme.titleMedium,
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            children: [
              'All',
              'Mathematics',
              'Physics',
              'Chemistry',
              'Computer Science',
              'English'
            ].map((subject) {
              final isSelected = _filters['subject'] == subject;
              return FilterChip(
                label: Text(subject),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _filters['subject'] = subject;
                  });
                },
                backgroundColor: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                selectedColor:
                    AppTheme.lightTheme.primaryColor.withValues(alpha: 0.2),
                labelStyle: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: isSelected ? AppTheme.lightTheme.primaryColor : null,
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 3.h),

          // Status Filter
          Text(
            'Status',
            style: AppTheme.lightTheme.textTheme.titleMedium,
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            children: ['All', 'Pending', 'Submitted', 'Overdue'].map((status) {
              final isSelected = _filters['status'] == status;
              return FilterChip(
                label: Text(status),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _filters['status'] = status;
                  });
                },
                backgroundColor: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                selectedColor:
                    AppTheme.lightTheme.primaryColor.withValues(alpha: 0.2),
                labelStyle: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: isSelected ? AppTheme.lightTheme.primaryColor : null,
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 3.h),

          // Priority Filter
          Text(
            'Priority',
            style: AppTheme.lightTheme.textTheme.titleMedium,
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            children: ['All', 'High', 'Medium', 'Low'].map((priority) {
              final isSelected = _filters['priority'] == priority;
              return FilterChip(
                label: Text(priority),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _filters['priority'] = priority;
                  });
                },
                backgroundColor: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                selectedColor:
                    AppTheme.lightTheme.primaryColor.withValues(alpha: 0.2),
                labelStyle: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: isSelected ? AppTheme.lightTheme.primaryColor : null,
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 3.h),

          // Sort By
          Text(
            'Sort By',
            style: AppTheme.lightTheme.textTheme.titleMedium,
          ),
          SizedBox(height: 1.h),
          DropdownButtonFormField<String>(
            value: _filters['sortBy'],
            decoration: InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            ),
            items: [
              DropdownMenuItem(value: 'dueDate', child: Text('Due Date')),
              DropdownMenuItem(value: 'subject', child: Text('Subject')),
              DropdownMenuItem(value: 'priority', child: Text('Priority')),
              DropdownMenuItem(value: 'title', child: Text('Title')),
            ],
            onChanged: (value) {
              setState(() {
                _filters['sortBy'] = value!;
              });
            },
          ),
          SizedBox(height: 4.h),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onFiltersChanged(_filters);
                Navigator.pop(context);
              },
              child: Text('Apply Filters'),
            ),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}
