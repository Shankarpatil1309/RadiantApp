import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../config/app_config.dart';

class AssignmentUploadBottomSheetWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onUploadAssignment;
  final VoidCallback onClose;
  final Map<String, dynamic>? existingAssignment; // For edit mode
  final bool isEditMode;

  const AssignmentUploadBottomSheetWidget({
    Key? key,
    required this.onUploadAssignment,
    required this.onClose,
    this.existingAssignment,
    this.isEditMode = false,
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
  final _instructionsController = TextEditingController();

  String _selectedDepartment = AppConfig.departmentCodes.first;
  String _selectedSemester = AppConfig.semesters.first;
  String _selectedSection = AppConfig.sections2.first;
  String _selectedSubject = '';
  String _selectedType = 'assignment';
  DateTime _selectedDeadline = DateTime.now().add(Duration(days: 7));

  List<PlatformFile> _attachedFiles = [];
  bool _isUploading = false;

  // File attachment method: 'upload' or 'url'
  String _attachmentMethod = 'upload';
  final _fileUrlController = TextEditingController();

  final List<String> _assignmentTypes = [
    'assignment',
    'project',
    'lab',
    'quiz',
    'presentation',
    'case_study',
    'report',
    'practical',
  ];

  @override
  void initState() {
    super.initState();
    
    if (widget.isEditMode && widget.existingAssignment != null) {
      // Populate form fields with existing assignment data
      _populateFormWithExistingData(widget.existingAssignment!);
    } else {
      // Default initialization for create mode
      _selectedSubject = AppConfig.getSubjectsForDepartment(_selectedDepartment, _selectedSemester).isNotEmpty
          ? AppConfig.getSubjectsForDepartment(_selectedDepartment, _selectedSemester).first
          : '';
    }
  }
  
  void _populateFormWithExistingData(Map<String, dynamic> assignment) {
    _titleController.text = assignment['title'] ?? '';
    _descriptionController.text = assignment['description'] ?? '';
    _instructionsController.text = assignment['instructions'] ?? '';
    
    _selectedDepartment = assignment['department'] ?? AppConfig.departmentCodes.first;
    
    // Extract semester number from formatted string like "1st Semester" -> "1"
    String semesterValue = assignment['semester']?.toString() ?? '1';
    if (semesterValue.contains(' ')) {
      // Extract just the number part from "1st Semester" format
      semesterValue = semesterValue.split(' ').first.replaceAll(RegExp(r'[^\d]'), '');
    }
    _selectedSemester = semesterValue.isNotEmpty ? semesterValue : '1';
    
    _selectedSection = assignment['section'] ?? 'A';
    _selectedType = assignment['type'] ?? 'assignment';
    
    // Set deadline if available
    if (assignment['deadline'] != null) {
      _selectedDeadline = assignment['deadline'] as DateTime;
    }
    
    // Set file URL if available
    if (assignment['fileUrl'] != null && (assignment['fileUrl'] as String).isNotEmpty) {
      _fileUrlController.text = assignment['fileUrl'];
      _attachmentMethod = 'url';
    }
    
    // Update subject based on selected department and semester
    final subjects = AppConfig.getSubjectsForDepartment(_selectedDepartment, _selectedSemester);
    if (subjects.contains(assignment['subject'])) {
      _selectedSubject = assignment['subject'];
    } else if (subjects.isNotEmpty) {
      _selectedSubject = subjects.first;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _instructionsController.dispose();
    _fileUrlController.dispose();
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

      // Determine file URL based on attachment method
      String? fileUrl;
      if (_attachmentMethod == 'url' &&
          _fileUrlController.text.trim().isNotEmpty) {
        fileUrl = _fileUrlController.text.trim();
      } else if (_attachmentMethod == 'upload' && _attachedFiles.isNotEmpty) {
        // TODO: Handle actual file upload and get the uploaded file URL
        // For now, we'll use a placeholder
        fileUrl = null; // Will be set after actual file upload
      }

      final assignmentData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'instructions': _instructionsController.text.trim(),
        'subject': _selectedSubject,
        'department': _selectedDepartment,
        'section': _selectedSection,
        'semester': int.parse(_selectedSemester),
        'type': _selectedType,
        'deadline': _selectedDeadline,
        if (widget.isEditMode && widget.existingAssignment != null)
          'id': widget.existingAssignment!['id'],
        'hasAttachments': _attachedFiles.isNotEmpty ||
            (_attachmentMethod == 'url' &&
                _fileUrlController.text.trim().isNotEmpty),
        'attachmentCount': _attachmentMethod == 'upload'
            ? _attachedFiles.length
            : (_fileUrlController.text.trim().isNotEmpty ? 1 : 0),
        'fileUrl': fileUrl,
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

  String _getOrdinalSuffix(int number) {
    if (number >= 11 && number <= 13) return 'st';
    switch (number % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
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
                    widget.isEditMode ? 'Edit Assignment' : 'Upload New Assignment',
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
                      : Text(widget.isEditMode ? 'Update' : 'Upload'),
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
                                items: AppConfig.departmentCodes.map((deptCode) {
                                  return DropdownMenuItem(
                                    value: deptCode,
                                    child: Text(deptCode),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedDepartment = value!;
                                    final subjects = AppConfig.getSubjectsForDepartment(value, _selectedSemester);
                                    _selectedSubject = subjects.isNotEmpty ? subjects.first : '';
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
                                items: AppConfig.semesters.map((sem) {
                                  return DropdownMenuItem(
                                    value: sem,
                                    child: Text('${sem}${_getOrdinalSuffix(int.parse(sem))} Semester'),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedSemester = value!;
                                    final subjects = AppConfig.getSubjectsForDepartment(_selectedDepartment, value);
                                    _selectedSubject = subjects.isNotEmpty ? subjects.first : '';
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
                                items: AppConfig.getSubjectsForDepartment(_selectedDepartment, _selectedSemester)
                                    .map((subject) {
                                  return DropdownMenuItem(
                                    value: subject,
                                    child: Text(subject),
                                  );
                                }).toList(),
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
                                'Section *',
                                style: AppTheme.lightTheme.textTheme.titleSmall
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              DropdownButtonFormField<String>(
                                value: _selectedSection,
                                decoration: InputDecoration(
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.all(3.w),
                                    child: CustomIconWidget(
                                      iconName: 'class',
                                      color: AppTheme.getRoleColor('faculty'),
                                      size: 20,
                                    ),
                                  ),
                                ),
                                items: AppConfig.sections2.map((section) {
                                  return DropdownMenuItem(
                                    value: section,
                                    child: Text(section),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedSection = value!;
                                  });
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

                    // Assignment Type
                    Text(
                      'Assignment Type *',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(3.w),
                          child: CustomIconWidget(
                            iconName: 'category',
                            color: AppTheme.getRoleColor('faculty'),
                            size: 20,
                          ),
                        ),
                      ),
                      items: _assignmentTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.replaceAll('_', ' ').split(' ').map((word) => 
                            word[0].toUpperCase() + word.substring(1)).join(' ')),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
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

                    // Instructions
                    Text(
                      'Instructions (Optional)',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    TextFormField(
                      controller: _instructionsController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Enter specific instructions for students (e.g., submission format, requirements, etc.)',
                        alignLabelWithHint: true,
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(3.w),
                          child: CustomIconWidget(
                            iconName: 'info',
                            color: AppTheme.getRoleColor('faculty'),
                            size: 20,
                          ),
                        ),
                      ),
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

                    // Attachment Method Selection
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
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile<String>(
                                  title: Text(
                                    'Upload Files',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodyMedium,
                                  ),
                                  subtitle: Text(
                                    'Upload files from device',
                                    style:
                                        AppTheme.lightTheme.textTheme.bodySmall,
                                  ),
                                  value: 'upload',
                                  groupValue: _attachmentMethod,
                                  activeColor: AppTheme.getRoleColor('faculty'),
                                  onChanged: (value) {
                                    setState(() {
                                      _attachmentMethod = value!;
                                      if (value == 'upload') {
                                        _fileUrlController.clear();
                                      } else {
                                        _attachedFiles.clear();
                                      }
                                    });
                                  },
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile<String>(
                                  title: Text(
                                    'Use File URL',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodyMedium,
                                  ),
                                  subtitle: Text(
                                    'Google Drive, Dropbox, etc.',
                                    style:
                                        AppTheme.lightTheme.textTheme.bodySmall,
                                  ),
                                  value: 'url',
                                  groupValue: _attachmentMethod,
                                  activeColor: AppTheme.getRoleColor('faculty'),
                                  onChanged: (value) {
                                    setState(() {
                                      _attachmentMethod = value!;
                                      if (value == 'url') {
                                        _attachedFiles.clear();
                                      } else {
                                        _fileUrlController.clear();
                                      }
                                    });
                                  },
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // File Upload Section
                    if (_attachmentMethod == 'upload') ...[
                      OutlinedButton.icon(
                        onPressed: _pickFiles,
                        icon: CustomIconWidget(
                          iconName: 'attach_file',
                          color: AppTheme.getRoleColor('faculty'),
                          size: 20,
                        ),
                        label: Text(
                          'Attach Files',
                          style: TextStyle(
                              color: AppTheme.getRoleColor('faculty')),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: AppTheme.getRoleColor('faculty')),
                          padding: EdgeInsets.symmetric(
                              horizontal: 4.w, vertical: 3.h),
                        ),
                      ),

                      // Attached Files List for Upload
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                    ],

                    // File URL Section
                    if (_attachmentMethod == 'url') ...[
                      TextFormField(
                        controller: _fileUrlController,
                        decoration: InputDecoration(
                          hintText:
                              'Enter file URL (Google Drive, Dropbox, etc.)',
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(3.w),
                            child: CustomIconWidget(
                              iconName: 'link',
                              color: AppTheme.getRoleColor('faculty'),
                              size: 20,
                            ),
                          ),
                          suffixIcon: _fileUrlController.text.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _fileUrlController.clear();
                                    });
                                  },
                                  icon: CustomIconWidget(
                                    iconName: 'clear',
                                    color: AppTheme
                                        .lightTheme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                    size: 20,
                                  ),
                                )
                              : null,
                        ),
                        validator: (value) {
                          if (_attachmentMethod == 'url' &&
                              value != null &&
                              value.trim().isNotEmpty) {
                            // Basic URL validation
                            try {
                              final uri = Uri.parse(value.trim());
                              if (!uri.hasScheme ||
                                  (!uri.scheme.startsWith('http') &&
                                      !uri.scheme.startsWith('https'))) {
                                return 'Please enter a valid URL starting with http:// or https://';
                              }
                            } catch (e) {
                              return 'Please enter a valid URL';
                            }
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(
                              () {}); // Trigger rebuild to show/hide clear button
                        },
                      ),

                      SizedBox(height: 1.h),

                      // URL Preview/Info
                      if (_fileUrlController.text.trim().isNotEmpty) ...[
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
                                iconName: 'cloud',
                                color: AppTheme.getRoleColor('faculty'),
                                size: 20,
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'File URL Added',
                                      style: AppTheme
                                          .lightTheme.textTheme.bodyMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.getRoleColor('faculty'),
                                      ),
                                    ),
                                    Text(
                                      _fileUrlController.text.length > 50
                                          ? '${_fileUrlController.text.substring(0, 50)}...'
                                          : _fileUrlController.text,
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
                            ],
                          ),
                        ),
                      ],

                      SizedBox(height: 1.h),

                      // Helper text for URL sharing
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
                              iconName: 'info',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 16,
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Text(
                                'Make sure the file URL is publicly accessible or shared with proper permissions for students to download.',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
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
          ),
        ],
      ),
    );
  }
}
