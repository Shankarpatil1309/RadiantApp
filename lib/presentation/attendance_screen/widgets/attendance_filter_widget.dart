import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AttendanceFilterWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onFilterChanged;
  final Map<String, dynamic> currentFilters;

  const AttendanceFilterWidget({
    Key? key,
    required this.onFilterChanged,
    required this.currentFilters,
  }) : super(key: key);

  @override
  State<AttendanceFilterWidget> createState() => _AttendanceFilterWidgetState();
}

class _AttendanceFilterWidgetState extends State<AttendanceFilterWidget> {
  late Map<String, dynamic> filters;
  DateTimeRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    filters = Map.from(widget.currentFilters);
    if (filters['dateRange'] != null) {
      selectedDateRange = filters['dateRange'] as DateTimeRange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 3.h),
          _buildDateRangeFilter(),
          SizedBox(height: 2.h),
          _buildSubjectFilter(),
          SizedBox(height: 2.h),
          _buildAttendanceThresholdFilter(),
          SizedBox(height: 2.h),
          _buildStatusFilter(),
          SizedBox(height: 3.h),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CustomIconWidget(
          iconName: 'filter_list',
          color: AppTheme.lightTheme.primaryColor,
          size: 24,
        ),
        SizedBox(width: 3.w),
        Text(
          'Filter Attendance',
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _buildDateRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: AppTheme.lightTheme.textTheme.titleSmall,
        ),
        SizedBox(height: 1.h),
        InkWell(
          onTap: _selectDateRange,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              border:
                  Border.all(color: AppTheme.lightTheme.colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDateRange != null
                      ? '${_formatDate(selectedDateRange!.start)} - ${_formatDate(selectedDateRange!.end)}'
                      : 'Select date range',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: selectedDateRange != null
                        ? AppTheme.lightTheme.colorScheme.onSurface
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                CustomIconWidget(
                  iconName: 'date_range',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectFilter() {
    final subjects = [
      'All Subjects',
      'Mathematics',
      'Physics',
      'Chemistry',
      'Computer Science',
      'English',
      'Data Structures',
      'Algorithms',
      'Database Systems',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subject',
          style: AppTheme.lightTheme.textTheme.titleSmall,
        ),
        SizedBox(height: 1.h),
        DropdownButtonFormField<String>(
          value: filters['subject'] as String? ?? 'All Subjects',
          decoration: InputDecoration(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          items: subjects
              .map((subject) => DropdownMenuItem(
                    value: subject,
                    child: Text(subject),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              filters['subject'] = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAttendanceThresholdFilter() {
    final currentThreshold = (filters['attendanceThreshold'] as double?) ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Minimum Attendance %',
              style: AppTheme.lightTheme.textTheme.titleSmall,
            ),
            Text(
              '${currentThreshold.toInt()}%',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Slider(
          value: currentThreshold,
          min: 0,
          max: 100,
          divisions: 20,
          onChanged: (value) {
            setState(() {
              filters['attendanceThreshold'] = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildStatusFilter() {
    final statuses = ['All', 'Present', 'Absent', 'Holiday'];
    final selectedStatus = filters['status'] as String? ?? 'All';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: AppTheme.lightTheme.textTheme.titleSmall,
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          children: statuses.map((status) {
            final isSelected = selectedStatus == status;
            Color chipColor;

            switch (status) {
              case 'Present':
                chipColor = AppTheme.getStatusColor('success');
                break;
              case 'Absent':
                chipColor = AppTheme.getStatusColor('error');
                break;
              case 'Holiday':
                chipColor = AppTheme.lightTheme.colorScheme.onSurfaceVariant;
                break;
              default:
                chipColor = AppTheme.lightTheme.primaryColor;
            }

            return FilterChip(
              label: Text(status),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  filters['status'] = selected ? status : 'All';
                });
              },
              selectedColor: chipColor.withValues(alpha: 0.2),
              checkmarkColor: chipColor,
              labelStyle: TextStyle(
                color: isSelected
                    ? chipColor
                    : AppTheme.lightTheme.colorScheme.onSurface,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _clearFilters,
            child: const Text('Clear All'),
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: ElevatedButton(
            onPressed: _applyFilters,
            child: const Text('Apply Filters'),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      initialDateRange: selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.lightTheme.primaryColor,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDateRange = picked;
        filters['dateRange'] = picked;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      filters = {
        'subject': 'All Subjects',
        'attendanceThreshold': 0.0,
        'status': 'All',
        'dateRange': null,
      };
      selectedDateRange = null;
    });
  }

  void _applyFilters() {
    widget.onFilterChanged(filters);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
