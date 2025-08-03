import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

class AddFacultyScreen extends ConsumerStatefulWidget {
  const AddFacultyScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddFacultyScreen> createState() => _AddFacultyScreenState();
}

class _AddFacultyScreenState extends ConsumerState<AddFacultyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Controllers for form fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _addressController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _specializedSubjectsController = TextEditingController();
  final _emergencyContactController = TextEditingController();

  // Form state
  bool _isLoading = false;
  String _selectedDepartment = 'CSE';
  String _selectedDesignation = 'Assistant Professor';
  String _selectedGender = 'Male';
  DateTime? _selectedDateOfBirth;
  DateTime? _selectedJoiningDate;
  double _selectedSalary = 50000.0;

  // Options
  final List<String> _departments = [
    'CSE',
    'ECE',
    'EEE',
    'MECH',
    'CIVIL',
    'IT'
  ];
  final List<String> _designations = [
    'Assistant Professor',
    'Associate Professor',
    'Professor',
    'Head of Department',
    'Principal',
    'Lecturer',
  ];
  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    _selectedJoiningDate = DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _employeeIdController.dispose();
    _addressController.dispose();
    _qualificationController.dispose();
    _experienceController.dispose();
    _specializedSubjectsController.dispose();
    _emergencyContactController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Add New Faculty',
        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
          color: AppTheme.getRoleColor('admin'),
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          color: AppTheme.lightTheme.colorScheme.onSurface,
          size: 24,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _resetForm,
          child: Text(
            'Reset',
            style: TextStyle(
              color: AppTheme.getRoleColor('admin'),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Personal Information', Icons.person),
            _buildPersonalInfoSection(),
            SizedBox(height: 3.h),

            _buildSectionHeader('Professional Information', Icons.work),
            _buildProfessionalInfoSection(),
            SizedBox(height: 3.h),

            _buildSectionHeader('Contact Information', Icons.contact_phone),
            _buildContactInfoSection(),
            SizedBox(height: 3.h),

            _buildSectionHeader('Academic Information', Icons.school),
            _buildAcademicInfoSection(),
            SizedBox(height: 10.h), // Space for bottom button
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.getRoleColor('admin'),
            size: 24,
          ),
          SizedBox(width: 3.w),
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.getRoleColor('admin'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            _buildTextFormField(
              controller: _nameController,
              label: 'Full Name',
              hint: 'Enter faculty\'s full name',
              icon: Icons.person,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Name is required';
                if (value!.length < 2)
                  return 'Name must be at least 2 characters';
                return null;
              },
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: _buildDropdownField(
                    label: 'Gender',
                    value: _selectedGender,
                    items: _genders,
                    onChanged: (value) =>
                        setState(() => _selectedGender = value!),
                    icon: Icons.person_outline,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: _buildDateField(
                    label: 'Date of Birth',
                    selectedDate: _selectedDateOfBirth,
                    onDateSelected: (date) =>
                        setState(() => _selectedDateOfBirth = date),
                    icon: Icons.cake,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            _buildTextFormField(
              controller: _employeeIdController,
              label: 'Employee ID',
              hint: 'e.g., EMP2024001',
              icon: Icons.badge,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Employee ID is required';
                if (!RegExp(r'^EMP[0-9]{7}$').hasMatch(value!)) {
                  return 'Invalid Employee ID format (e.g., EMP2024001)';
                }
                return null;
              },
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: _buildDropdownField(
                    label: 'Department',
                    value: _selectedDepartment,
                    items: _departments,
                    onChanged: (value) =>
                        setState(() => _selectedDepartment = value!),
                    icon: Icons.business,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: _buildDropdownField(
                    label: 'Designation',
                    value: _selectedDesignation,
                    items: _designations,
                    onChanged: (value) =>
                        setState(() => _selectedDesignation = value!),
                    icon: Icons.work_outline,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    label: 'Joining Date',
                    selectedDate: _selectedJoiningDate,
                    onDateSelected: (date) =>
                        setState(() => _selectedJoiningDate = date),
                    icon: Icons.event,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: _buildSalaryField(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            _buildTextFormField(
              controller: _emailController,
              label: 'Email Address',
              hint: 'faculty@bkit.edu.in',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Email is required';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value!)) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            SizedBox(height: 2.h),
            _buildTextFormField(
              controller: _phoneController,
              label: 'Phone Number',
              hint: '+91 9876543210',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Phone number is required';
                if (!RegExp(r'^\+?[0-9]{10,13}$')
                    .hasMatch(value!.replaceAll(' ', ''))) {
                  return 'Enter a valid phone number';
                }
                return null;
              },
            ),
            SizedBox(height: 2.h),
            _buildTextFormField(
              controller: _emergencyContactController,
              label: 'Emergency Contact',
              hint: '+91 9876543210',
              icon: Icons.emergency,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value?.isEmpty ?? true)
                  return 'Emergency contact is required';
                if (!RegExp(r'^\+?[0-9]{10,13}$')
                    .hasMatch(value!.replaceAll(' ', ''))) {
                  return 'Enter a valid phone number';
                }
                return null;
              },
            ),
            SizedBox(height: 2.h),
            _buildTextFormField(
              controller: _addressController,
              label: 'Address',
              hint: 'Enter complete address',
              icon: Icons.home,
              maxLines: 3,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Address is required';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademicInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            _buildTextFormField(
              controller: _qualificationController,
              label: 'Qualification',
              hint: 'e.g., M.Tech in Computer Science, Ph.D',
              icon: Icons.school,
              maxLines: 2,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Qualification is required';
                return null;
              },
            ),
            SizedBox(height: 2.h),
            _buildTextFormField(
              controller: _experienceController,
              label: 'Experience',
              hint: 'e.g., 5 years in teaching, 2 years in industry',
              icon: Icons.timeline,
              maxLines: 2,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Experience is required';
                return null;
              },
            ),
            SizedBox(height: 2.h),
            _buildTextFormField(
              controller: _specializedSubjectsController,
              label: 'Specialized Subjects',
              hint: 'e.g., Data Structures, Algorithms, Machine Learning',
              icon: Icons.subject,
              maxLines: 3,
              validator: (value) {
                if (value?.isEmpty ?? true)
                  return 'Specialized subjects are required';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monthly Salary (₹)',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.6),
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.currency_rupee, color: AppTheme.getRoleColor('admin')),
              SizedBox(width: 2.w),
              Expanded(
                child: Slider(
                  value: _selectedSalary,
                  min: 20000,
                  max: 200000,
                  divisions: 18,
                  activeColor: AppTheme.getRoleColor('admin'),
                  label: '₹${_selectedSalary.round()}',
                  onChanged: (value) {
                    setState(() {
                      _selectedSalary = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          '₹${_selectedSalary.round()}',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.getRoleColor('admin'),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.getRoleColor('admin')),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.getRoleColor('admin')),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.getRoleColor('admin')),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.getRoleColor('admin')),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? selectedDate,
    required Function(DateTime) onDateSelected,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppTheme.getRoleColor('admin')),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppTheme.getRoleColor('admin')),
          ),
        ),
        child: Text(
          selectedDate != null
              ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
              : 'Select date',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: selectedDate != null
                ? AppTheme.lightTheme.colorScheme.onSurface
                : AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 6.h,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.getRoleColor('admin'),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  'Add Faculty',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _employeeIdController.clear();
    _addressController.clear();
    _qualificationController.clear();
    _experienceController.clear();
    _specializedSubjectsController.clear();
    _emergencyContactController.clear();

    setState(() {
      _selectedDepartment = 'CSE';
      _selectedDesignation = 'Assistant Professor';
      _selectedGender = 'Male';
      _selectedDateOfBirth = null;
      _selectedJoiningDate = DateTime.now();
      _selectedSalary = 50000.0;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill all required fields correctly'),
          backgroundColor: AppTheme.getStatusColor('error'),
        ),
      );
      return;
    }

    if (_selectedDateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select date of birth'),
          backgroundColor: AppTheme.getStatusColor('error'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if Employee ID already exists
      final empIdCheck = await FirebaseFirestore.instance
          .collection('faculty')
          .where('employeeId',
              isEqualTo: _employeeIdController.text.trim().toUpperCase())
          .get();

      if (empIdCheck.docs.isNotEmpty) {
        throw Exception('A faculty with this Employee ID already exists');

        // show snackbar instead of throwing
      }

      // Check if email already exists
      final emailCheck = await FirebaseFirestore.instance
          .collection('faculty')
          .where('email', isEqualTo: _emailController.text.trim().toLowerCase())
          .get();

      if (emailCheck.docs.isNotEmpty) {
        throw Exception('A faculty with this email already exists');
      }

      // Create faculty document
      final facultyData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim().toLowerCase(),
        'phone': _phoneController.text.trim(),
        'employeeId': _employeeIdController.text.trim().toUpperCase(),
        'department': _selectedDepartment,
        'designation': _selectedDesignation,
        'gender': _selectedGender,
        'dateOfBirth': Timestamp.fromDate(_selectedDateOfBirth!),
        'joiningDate': Timestamp.fromDate(_selectedJoiningDate!),
        'salary': _selectedSalary,
        'address': _addressController.text.trim(),
        'qualification': _qualificationController.text.trim(),
        'experience': _experienceController.text.trim(),
        'specializedSubjects': _specializedSubjectsController.text
            .trim()
            .split(',')
            .map((s) => s.trim())
            .toList(),
        'emergencyContact': _emergencyContactController.text.trim(),
        'role': 'FACULTY',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'createdBy': 'admin', // TODO: Get current admin user ID
      };

      // Use employeeId as document ID for direct access
      await FirebaseFirestore.instance
          .collection('faculty')
          .doc(_employeeIdController.text.trim().toUpperCase())
          .set(facultyData);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Faculty ${_nameController.text} added successfully!'),
          backgroundColor: AppTheme.getStatusColor('success'),
        ),
      );

      // Reset form and navigate back
      _resetForm();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppTheme.getStatusColor('error'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
