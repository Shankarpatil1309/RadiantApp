import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radiant_app/config/app_config.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../models/class_session_model.dart';

class AddClassSessionWidget extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  final VoidCallback onClose;
  final Function(ClassSession) onSave;

  const AddClassSessionWidget({
    Key? key,
    required this.selectedDate,
    required this.onClose,
    required this.onSave,
  }) : super(key: key);

  @override
  ConsumerState<AddClassSessionWidget> createState() =>
      _AddClassSessionWidgetState();
}

class _AddClassSessionWidgetState extends ConsumerState<AddClassSessionWidget> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  final _roomController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedDepartment = 'CSE';
  String _selectedSection = 'A';
  int _selectedSemester = 1;
  String _selectedType = 'lecture';
  TimeOfDay _startTime = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = TimeOfDay(hour: 10, minute: 30);

  final List<String> _departments = AppConfig.departmentCodes;

  final List<String> _sessionTypes = ['lecture', 'lab', 'tutorial', 'exam'];

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    _roomController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBasicInfo(),
                    SizedBox(height: 3.h),
                    _buildTimeSelection(),
                    SizedBox(height: 3.h),
                    _buildClassDetails(),
                    SizedBox(height: 3.h),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.getRoleColor('faculty').withValues(alpha: 0.1),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'add_circle',
            color: AppTheme.getRoleColor('faculty'),
            size: 24,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Class Session',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.getRoleColor('faculty'),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'For ${_formatDate(widget.selectedDate)}',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: widget.onClose,
            icon: CustomIconWidget(
              iconName: 'close',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Information',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: 'Class Title',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'title',
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
                size: 20,
              ),
            ),
          ),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Title is required' : null,
        ),
        SizedBox(height: 2.h),
        TextFormField(
          controller: _subjectController,
          decoration: InputDecoration(
            labelText: 'Subject',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'book',
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
                size: 20,
              ),
            ),
          ),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Subject is required' : null,
        ),
        SizedBox(height: 2.h),
        TextFormField(
          controller: _roomController,
          decoration: InputDecoration(
            labelText: 'Room Number',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'room',
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
                size: 20,
              ),
            ),
          ),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Room is required' : null,
        ),
      ],
    );
  }

  Widget _buildTimeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time Schedule',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectTime(context, true),
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'schedule',
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Start Time',
                            style: AppTheme.lightTheme.textTheme.bodySmall,
                          ),
                          Text(
                            _startTime.format(context),
                            style: AppTheme.lightTheme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: InkWell(
                onTap: () => _selectTime(context, false),
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'schedule',
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'End Time',
                            style: AppTheme.lightTheme.textTheme.bodySmall,
                          ),
                          Text(
                            _endTime.format(context),
                            style: AppTheme.lightTheme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClassDetails() {
    final List<String> _sections =
        AppConfig.sectionsByDepartment[_selectedDepartment] ?? ['A', 'B'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Class Details',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedDepartment,
                decoration: InputDecoration(
                  labelText: 'Department',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                items: _departments
                    .map((dept) => DropdownMenuItem(
                          value: dept,
                          child: Text(dept),
                        ))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedDepartment = value!),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedSection,
                decoration: InputDecoration(
                  labelText: 'Section',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                items: _sections
                    .map((section) => DropdownMenuItem(
                          value: section,
                          child: Text(section),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedSection = value!),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                value: _selectedSemester,
                decoration: InputDecoration(
                  labelText: 'Semester',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                items: List.generate(
                    8,
                    (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text('Semester ${index + 1}'),
                        )),
                onChanged: (value) =>
                    setState(() => _selectedSemester = value!),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                items: _sessionTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.toUpperCase()),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedType = value!),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: 'Description (Optional)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            alignLabelWithHint: true,
          ),
          maxLines: 3,
        ),
      ],
    );
  }


  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: widget.onClose,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 2.h),
            ),
            child: Text('Cancel'),
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveClassSession,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.getRoleColor('faculty'),
              padding: EdgeInsets.symmetric(vertical: 2.h),
            ),
            child: Text(
              'Save Class',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
          // Auto-adjust end time to be 1.5 hours later
          final startMinutes = _startTime.hour * 60 + _startTime.minute;
          final endMinutes = startMinutes + 90; // 1.5 hours
          _endTime =
              TimeOfDay(hour: (endMinutes ~/ 60) % 24, minute: endMinutes % 60);
        } else {
          _endTime = picked;
        }
      });
    }
  }


  void _saveClassSession() {
    if (_formKey.currentState?.validate() ?? false) {
      final startDateTime = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day,
        _startTime.hour,
        _startTime.minute,
      );

      final endDateTime = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day,
        _endTime.hour,
        _endTime.minute,
      );

      final dateStr = '${widget.selectedDate.year}-${widget.selectedDate.month.toString().padLeft(2, '0')}-${widget.selectedDate.day.toString().padLeft(2, '0')}';
      
      final session = ClassSession(
        id: '', // Will be generated by Firestore
        title: _titleController.text.trim(),
        subject: _subjectController.text.trim(),
        department: _selectedDepartment,
        section: _selectedSection,
        semester: _selectedSemester,
        facultyId: 'EMP2024011', // TODO: Get from auth
        facultyName: 'Current Faculty', // TODO: Get from auth
        room: _roomController.text.trim(),
        date: dateStr,
        startTime: startDateTime,
        endTime: endDateTime,
        type: _selectedType,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      widget.onSave(session);
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      '',
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
    return '${months[date.month]} ${date.day}, ${date.year}';
  }
}
