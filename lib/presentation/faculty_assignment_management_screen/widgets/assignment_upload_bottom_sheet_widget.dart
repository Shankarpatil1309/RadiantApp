
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AssignmentUploadBottomSheetWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onUploadAssignment;
  final VoidCallback onClose;

  const AssignmentUploadBottomSheetWidget({
    Key? key,
    required this.onUploadAssignment,
    required this.onClose,
  }) : super(key: key);

  @override
  State<AssignmentUploadBottomSheetWidget> createState() =>
      _AssignmentUploadBottomSheetWidgetState();
}

class _AssignmentUploadBottomSheetWidgetState
    extends State<AssignmentUploadBottomSheetWidget> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedDepartment = 'Engineering';
  String _selectedSemester = '1st Semester';
  String _selectedSubject = 'Computer Science';
  DateTime _selectedDeadline = DateTime.now().add(Duration(days: 7));
  int _totalStudents = 30;

  List<PlatformFile> _attachedFiles = [];
  bool _isUploading = false;

  final List<String> _departments = [
    'Engineering',
    'Science',
    'Management',
    'Arts',
    'Commerce',
  ];

  final List<String> _semesters = [
    '1st Semester',
    '2nd Semester',
    '3rd Semester',
    '4th Semester',
    '5th Semester',
    '6th Semester',
    '7th Semester',
    '8th Semester',
  ];

  final Map<String, List<String>> _departmentSubjects = {
    'Engineering': [
      'Computer Science',
      'Electronics',
      'Mechanical',
      'Civil',
      'Electrical',
    ],
    'Science': [
      'Physics',
      'Chemistry',
      'Mathematics',
      'Biology',
      'Environmental Science',
    ],
    'Management': [
      'Marketing',
      'Finance',
      'Human Resources',
      'Operations',
      'Business Strategy',
    ],
    'Arts': [
      'English',
      'History',
      'Philosophy',
      'Psychology',
      'Sociology',
    ],
    'Commerce': [
      'Accounting',
      'Economics',
      'Business Studies',
      'Statistics',
      'Banking',
    ],
  };

  @override
  void initState() {
    super.initState();
    _selectedSubject =
        _departmentSubjects[_selectedDepartment]?.first ?? 'Computer Science';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'ppt', 'pptx'],
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _attachedFiles.addAll(result.files);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking files: ${e.toString()}'),
          backgroundColor: AppTheme.getStatusColor('error'),
        ),
      );
    }
  }

  void _removeFile(int index) {
    setState(() {
      _attachedFiles.removeAt(index);
    });
  }

  Future<void> _selectDeadline() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.getRoleColor('faculty'),
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDeadline),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: AppTheme.getRoleColor('faculty'),
                  ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        setState(() {
          _selectedDeadline = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _uploadAssignment() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUploading = true;
      });

      // Simulate file upload delay
      await Future.delayed(Duration(seconds: 2));

      final assignmentData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'subject': _selectedSubject,
        'department': _selectedDepartment,
        'semester': _selectedSemester,
        'deadline': _selectedDeadline,
        'totalStudents': _totalStudents,
        'hasAttachments': _attachedFiles.isNotEmpty,
        'attachmentCount': _attachedFiles.length,
      };

      widget.onUploadAssignment(assignmentData);
      setState(() {
        _isUploading = false;
      });
      widget.onClose();
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
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
                  onPressed: widget.onClose,
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 24,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Upload New Assignment',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      color: AppTheme.getRoleColor('faculty'),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _isUploading ? null : _uploadAssignment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.getRoleColor('faculty'),
                    foregroundColor: Colors.white,
                  ),
                  child: _isUploading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text('Upload'),
                ),
              ],
            ),
          ),

          Divider(height: 1),

          // Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Assignment Title
                    Text(
                      'Assignment Title *',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Enter assignment title',
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(3.w),
                          child: CustomIconWidget(
                            iconName: 'assignment',
                            color: AppTheme.getRoleColor('faculty'),
                            size: 20,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter assignment title';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 3.h),

                    // Department and Semester Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Department *',
                                style: AppTheme.lightTheme.textTheme.titleSmall
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              DropdownButtonFormField<String>(
                                value: _selectedDepartment,
                                decoration: InputDecoration(
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.all(3.w),
                                    child: CustomIconWidget(
                                      iconName: 'business',
                                      color: AppTheme.getRoleColor('faculty'),
                                      size: 20,
                                    ),
                                  ),
                                ),
                                items: _departments.map((dept) {
                                  return DropdownMenuItem(
                                    value: dept,
                                    child: Text(dept),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedDepartment = value!;
                                    _selectedSubject =
                                        _departmentSubjects[value]?.first ??
                                            'Computer Science';
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Semester *',
                                style: AppTheme.lightTheme.textTheme.titleSmall
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              DropdownButtonFormField<String>(
                                value: _selectedSemester,
                                decoration: InputDecoration(
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.all(3.w),
                                    child: CustomIconWidget(
                                      iconName: 'school',
                                      color: AppTheme.getRoleColor('faculty'),
                                      size: 20,
                                    ),
                                  ),
                                ),
                                items: _semesters.map((sem) {
                                  return DropdownMenuItem(
                                    value: sem,
                                    child: Text(sem),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedSemester = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 3.h),

                    // Subject and Total Students Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Subject *',
                                style: AppTheme.lightTheme.textTheme.titleSmall
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              DropdownButtonFormField<String>(
                                value: _selectedSubject,
                                decoration: InputDecoration(
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.all(3.w),
                                    child: CustomIconWidget(
                                      iconName: 'book',
                                      color: AppTheme.getRoleColor('faculty'),
                                      size: 20,
                                    ),
                                  ),
                                ),
                                items: _departmentSubjects[_selectedDepartment]
                                        ?.map((subject) {
                                      return DropdownMenuItem(
                                        value: subject,
                                        child: Text(subject),
                                      );
                                    }).toList() ??
                                    [],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedSubject = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Students *',
                                style: AppTheme.lightTheme.textTheme.titleSmall
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              TextFormField(
                                initialValue: _totalStudents.toString(),
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Enter total students',
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.all(3.w),
                                    child: CustomIconWidget(
                                      iconName: 'people',
                                      color: AppTheme.getRoleColor('faculty'),
                                      size: 20,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Required';
                                  }
                                  final num = int.tryParse(value);
                                  if (num == null || num <= 0) {
                                    return 'Invalid number';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  _totalStudents = int.tryParse(value) ?? 30;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 3.h),

                    // Deadline
                    Text(
                      'Deadline *',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    InkWell(
                      onTap: _selectDeadline,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: AppTheme.lightTheme.colorScheme.outline),
                          borderRadius: BorderRadius.circular(8),
                          color: AppTheme
                              .lightTheme.colorScheme.surfaceContainerHighest,
                        ),
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'schedule',
                              color: AppTheme.getRoleColor('faculty'),
                              size: 20,
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              '${_selectedDeadline.day}/${_selectedDeadline.month}/${_selectedDeadline.year} at ${_selectedDeadline.hour.toString().padLeft(2, '0')}:${_selectedDeadline.minute.toString().padLeft(2, '0')}',
                              style: AppTheme.lightTheme.textTheme.bodyMedium,
                            ),
                            Spacer(),
                            CustomIconWidget(
                              iconName: 'arrow_drop_down',
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 3.h),

                    // Description
                    Text(
                      'Description *',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText:
                            'Enter assignment description, instructions, and requirements...',
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter assignment description';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 3.h),

                    // File Attachments
                    Text(
                      'Attachments (Optional)',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),

                    // File Upload Button
                    OutlinedButton.icon(
                      onPressed: _pickFiles,
                      icon: CustomIconWidget(
                        iconName: 'attach_file',
                        color: AppTheme.getRoleColor('faculty'),
                        size: 20,
                      ),
                      label: Text(
                        'Attach Files',
                        style:
                            TextStyle(color: AppTheme.getRoleColor('faculty')),
                      ),
                      style: OutlinedButton.styleFrom(
                        side:
                            BorderSide(color: AppTheme.getRoleColor('faculty')),
                        padding: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 3.h),
                      ),
                    ),

                    // Attached Files List
                    if (_attachedFiles.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      ...List.generate(_attachedFiles.length, (index) {
                        final file = _attachedFiles[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: 1.h),
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
                                iconName: 'description',
                                color: AppTheme.getRoleColor('faculty'),
                                size: 20,
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      file.name,
                                      style: AppTheme
                                          .lightTheme.textTheme.bodyMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      _formatFileSize(file.size),
                                      style: AppTheme
                                          .lightTheme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: AppTheme
                                            .lightTheme.colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => _removeFile(index),
                                icon: CustomIconWidget(
                                  iconName: 'close',
                                  color: AppTheme.getStatusColor('error'),
                                  size: 20,
                                ),
                                padding: EdgeInsets.all(1.w),
                                constraints: BoxConstraints(),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],

                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
