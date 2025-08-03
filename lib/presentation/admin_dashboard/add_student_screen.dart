import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

class AddStudentScreen extends ConsumerStatefulWidget {
  const AddStudentScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends ConsumerState<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  
  // Controllers for form fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usnController = TextEditingController();
  final _addressController = TextEditingController();
  final _guardianNameController = TextEditingController();
  final _guardianPhoneController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  
  // Form state
  bool _isLoading = false;
  String _selectedDepartment = 'CSE';
  String _selectedSection = 'A';
  int _selectedSemester = 1;
  int _selectedYear = 1;
  String _selectedGender = 'Male';
  DateTime? _selectedDateOfBirth;
  DateTime? _selectedAdmissionDate;

  // Department and section options
  final List<String> _departments = ['CSE', 'ECE', 'EEE', 'MECH', 'CIVIL', 'IT'];
  final List<String> _sections = ['A', 'B', 'C', 'D'];
  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    _selectedAdmissionDate = DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _usnController.dispose();
    _addressController.dispose();
    _guardianNameController.dispose();
    _guardianPhoneController.dispose();
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
        'Add New Student',
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
            
            _buildSectionHeader('Academic Information', Icons.school),
            _buildAcademicInfoSection(),
            SizedBox(height: 3.h),
            
            _buildSectionHeader('Contact Information', Icons.contact_phone),
            _buildContactInfoSection(),
            SizedBox(height: 3.h),
            
            _buildSectionHeader('Guardian Information', Icons.family_restroom),
            _buildGuardianInfoSection(),
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
              hint: 'Enter student\'s full name',
              icon: Icons.person,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Name is required';
                if (value!.length < 2) return 'Name must be at least 2 characters';
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
                    onChanged: (value) => setState(() => _selectedGender = value!),
                    icon: Icons.person_outline,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: _buildDateField(
                    label: 'Date of Birth',
                    selectedDate: _selectedDateOfBirth,
                    onDateSelected: (date) => setState(() => _selectedDateOfBirth = date),
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

  Widget _buildAcademicInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            _buildTextFormField(
              controller: _usnController,
              label: 'USN (University Seat Number)',
              hint: 'e.g., 1BK21CS001',
              icon: Icons.confirmation_number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'USN is required';
                if (!RegExp(r'^[0-9][A-Z]{2}[0-9]{2}[A-Z]{2,3}[0-9]{3}$').hasMatch(value!)) {
                  return 'Invalid USN format (e.g., 1BK21CS001)';
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
                    onChanged: (value) => setState(() => _selectedDepartment = value!),
                    icon: Icons.business,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: _buildDropdownField(
                    label: 'Section',
                    value: _selectedSection,
                    items: _sections,
                    onChanged: (value) => setState(() => _selectedSection = value!),
                    icon: Icons.class_,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: _buildDropdownField(
                    label: 'Year',
                    value: _selectedYear.toString(),
                    items: ['1', '2', '3', '4'],
                    onChanged: (value) => setState(() => _selectedYear = int.parse(value!)),
                    icon: Icons.timeline,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: _buildDropdownField(
                    label: 'Semester',
                    value: _selectedSemester.toString(),
                    items: ['1', '2', '3', '4', '5', '6', '7', '8'],
                    onChanged: (value) => setState(() => _selectedSemester = int.parse(value!)),
                    icon: Icons.schedule,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            _buildDateField(
              label: 'Admission Date',
              selectedDate: _selectedAdmissionDate,
              onDateSelected: (date) => setState(() => _selectedAdmissionDate = date),
              icon: Icons.event,
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
              hint: 'student@bkit.edu.in',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Email is required';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
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
                if (!RegExp(r'^\+?[0-9]{10,13}$').hasMatch(value!.replaceAll(' ', ''))) {
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

  Widget _buildGuardianInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            _buildTextFormField(
              controller: _guardianNameController,
              label: 'Guardian Name',
              hint: 'Enter guardian\'s full name',
              icon: Icons.person_outline,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Guardian name is required';
                return null;
              },
            ),
            SizedBox(height: 2.h),
            _buildTextFormField(
              controller: _guardianPhoneController,
              label: 'Guardian Phone',
              hint: '+91 9876543210',
              icon: Icons.phone_android,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Guardian phone is required';
                if (!RegExp(r'^\+?[0-9]{10,13}$').hasMatch(value!.replaceAll(' ', ''))) {
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
                if (value?.isEmpty ?? true) return 'Emergency contact is required';
                if (!RegExp(r'^\+?[0-9]{10,13}$').hasMatch(value!.replaceAll(' ', ''))) {
                  return 'Enter a valid phone number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
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
                : AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6),
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
                  'Add Student',
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
    _usnController.clear();
    _addressController.clear();
    _guardianNameController.clear();
    _guardianPhoneController.clear();
    _emergencyContactController.clear();
    
    setState(() {
      _selectedDepartment = 'CSE';
      _selectedSection = 'A';
      _selectedSemester = 1;
      _selectedYear = 1;
      _selectedGender = 'Male';
      _selectedDateOfBirth = null;
      _selectedAdmissionDate = DateTime.now();
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
      // Check if USN already exists
      final usnCheck = await FirebaseFirestore.instance
          .collection('students')
          .where('usn', isEqualTo: _usnController.text.trim().toUpperCase())
          .get();

      if (usnCheck.docs.isNotEmpty) {
        throw Exception('A student with this USN already exists');
      }

      // Check if email already exists
      final emailCheck = await FirebaseFirestore.instance
          .collection('students')
          .where('email', isEqualTo: _emailController.text.trim().toLowerCase())
          .get();

      if (emailCheck.docs.isNotEmpty) {
        throw Exception('A student with this email already exists');
      }

      // Create student document
      final studentData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim().toLowerCase(),
        'phone': _phoneController.text.trim(),
        'usn': _usnController.text.trim().toUpperCase(),
        'department': _selectedDepartment,
        'section': _selectedSection,
        'year': _selectedYear,
        'semester': _selectedSemester,
        'gender': _selectedGender,
        'dateOfBirth': Timestamp.fromDate(_selectedDateOfBirth!),
        'admissionDate': Timestamp.fromDate(_selectedAdmissionDate!),
        'address': _addressController.text.trim(),
        'guardianName': _guardianNameController.text.trim(),
        'guardianPhone': _guardianPhoneController.text.trim(),
        'emergencyContact': _emergencyContactController.text.trim(),
        'role': 'STUDENT',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'createdBy': 'admin', // TODO: Get current admin user ID
      };

      await FirebaseFirestore.instance.collection('students').add(studentData);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Student ${_nameController.text} added successfully!'),
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