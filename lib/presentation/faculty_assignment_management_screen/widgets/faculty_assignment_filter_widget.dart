import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FacultyAssignmentFilterWidget extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onFiltersChanged;

  const FacultyAssignmentFilterWidget({
    Key? key,
    required this.currentFilters,
    required this.onFiltersChanged,
  }) : super(key: key);

  @override
  State<FacultyAssignmentFilterWidget> createState() =>
      _FacultyAssignmentFilterWidgetState();
}

class _FacultyAssignmentFilterWidgetState
    extends State<FacultyAssignmentFilterWidget> {
  late Map<String, dynamic> _filters;

  final List<String> _departments = [
    'All',
    'Engineering',
    'Science',
    'Management',
    'Arts',
    'Commerce',
  ];

  final List<String> _semesters = [
    'All',
    '1st Semester',
    '2nd Semester',
    '3rd Semester',
    '4th Semester',
    '5th Semester',
    '6th Semester',
    '7th Semester',
    '8th Semester',
  ];

  final List<String> _subjects = [
    'All',
    'Computer Science',
    'Physics',
    'Chemistry',
    'Mathematics',
    'Marketing',
    'English',
    'Accounting',
  ];

  final List<String> _statuses = [
    'All',
    'Active',
    'Closed',
    'Overdue',
  ];

  final List<String> _sortOptions = [
    'deadline',
    'subject',
    'uploadDate',
    'submissions',
  ];

  final Map<String, String> _sortLabels = {
    'deadline': 'Deadline',
    'subject': 'Subject',
    'uploadDate': 'Upload Date',
    'submissions': 'Submissions',
  };

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.currentFilters);
  }

  void _applyFilters() {
    widget.onFiltersChanged(_filters);
    Navigator.pop(context);
  }

  void _resetFilters() {
    setState(() {
      _filters = {
        'department': 'All',
        'semester': 'All',
        'subject': 'All',
        'status': 'All',
        'sortBy': 'deadline',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85.h,
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
                CustomIconWidget(
                  iconName: 'filter_list',
                  color: AppTheme.getRoleColor('faculty'),
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Filter & Sort',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      color: AppTheme.getRoleColor('faculty'),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _resetFilters,
                  child: Text(
                    'Reset',
                    style: TextStyle(color: AppTheme.getStatusColor('error')),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1),

          // Filter Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Department Filter
                  _buildFilterSection(
                    title: 'Department',
                    icon: 'business',
                    options: _departments,
                    currentValue: _filters['department'],
                    onChanged: (value) {
                      setState(() {
                        _filters['department'] = value;
                      });
                    },
                  ),

                  SizedBox(height: 3.h),

                  // Semester Filter
                  _buildFilterSection(
                    title: 'Semester',
                    icon: 'school',
                    options: _semesters,
                    currentValue: _filters['semester'],
                    onChanged: (value) {
                      setState(() {
                        _filters['semester'] = value;
                      });
                    },
                  ),

                  SizedBox(height: 3.h),

                  // Subject Filter
                  _buildFilterSection(
                    title: 'Subject',
                    icon: 'book',
                    options: _subjects,
                    currentValue: _filters['subject'],
                    onChanged: (value) {
                      setState(() {
                        _filters['subject'] = value;
                      });
                    },
                  ),

                  SizedBox(height: 3.h),

                  // Status Filter
                  _buildFilterSection(
                    title: 'Status',
                    icon: 'info',
                    options: _statuses,
                    currentValue: _filters['status'],
                    onChanged: (value) {
                      setState(() {
                        _filters['status'] = value;
                      });
                    },
                  ),

                  SizedBox(height: 3.h),

                  // Sort Section
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'sort',
                        color: AppTheme.getRoleColor('faculty'),
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Sort By',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),

                  Wrap(
                    spacing: 2.w,
                    runSpacing: 1.h,
                    children: _sortOptions.map((option) {
                      final isSelected = _filters['sortBy'] == option;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _filters['sortBy'] = option;
                          });
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 4.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.getRoleColor('faculty')
                                : AppTheme.lightTheme.colorScheme
                                    .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.getRoleColor('faculty')
                                  : AppTheme.lightTheme.colorScheme.outline,
                            ),
                          ),
                          child: Text(
                            _sortLabels[option] ?? option,
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.lightTheme.colorScheme.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),

          // Apply Button
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
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.getRoleColor('faculty'),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 3.h),
                ),
                child: Text(
                  'Apply Filters',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required String icon,
    required List<String> options,
    required String currentValue,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: AppTheme.getRoleColor('faculty'),
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: options.map((option) {
            final isSelected = currentValue == option;
            return InkWell(
              onTap: () => onChanged(option),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.getRoleColor('faculty')
                      : AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.getRoleColor('faculty')
                        : AppTheme.lightTheme.colorScheme.outline,
                  ),
                ),
                child: Text(
                  option,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? Colors.white
                        : AppTheme.lightTheme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
