import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StudentAttendanceListWidget extends StatefulWidget {
  final List<Map<String, dynamic>> students;
  final Function(String studentId, bool isPresent) onAttendanceToggle;
  final bool isMarkingMode;

  const StudentAttendanceListWidget({
    Key? key,
    required this.students,
    required this.onAttendanceToggle,
    this.isMarkingMode = false,
  }) : super(key: key);

  @override
  State<StudentAttendanceListWidget> createState() =>
      _StudentAttendanceListWidgetState();
}

class _StudentAttendanceListWidgetState
    extends State<StudentAttendanceListWidget> {
  Map<String, bool> attendanceStatus = {};

  @override
  void initState() {
    super.initState();
    _initializeAttendanceStatus();
  }

  void _initializeAttendanceStatus() {
    for (var student in widget.students) {
      attendanceStatus[student['id'] as String] =
          student['isPresent'] as bool? ?? true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
            color: AppTheme.lightTheme.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2)),
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildHeader(),
          if (widget.isMarkingMode) _buildQuickActions(),
          _buildStudentList(),
        ]));
  }

  Widget _buildHeader() {
    final presentCount =
        attendanceStatus.values.where((isPresent) => isPresent).length;
    final totalCount = widget.students.length;

    return Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
            color: AppTheme.getRoleColor('faculty').withValues(alpha: 0.1),
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12), topRight: Radius.circular(12))),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            CustomIconWidget(
                iconName: 'people',
                color: AppTheme.getRoleColor('faculty'),
                size: 24),
            SizedBox(width: 3.w),
            Text('Student List',
                style: AppTheme.lightTheme.textTheme.titleMedium
                    ?.copyWith(color: AppTheme.getRoleColor('faculty'))),
          ]),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                  color: AppTheme.getRoleColor('faculty'),
                  borderRadius: BorderRadius.circular(16)),
              child: Text('$presentCount/$totalCount',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w600))),
        ]));
  }

  Widget _buildQuickActions() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Row(children: [
          Expanded(
              child: OutlinedButton.icon(
                  onPressed: _markAllPresent,
                  icon: CustomIconWidget(
                      iconName: 'check_circle_outline',
                      color: AppTheme.getStatusColor('success'),
                      size: 18),
                  label: Text('Mark All Present',
                      style:
                          TextStyle(color: AppTheme.getStatusColor('success'))),
                  style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: AppTheme.getStatusColor('success'))))),
          SizedBox(width: 3.w),
          Expanded(
              child: OutlinedButton.icon(
                  onPressed: _markAllAbsent,
                  icon: CustomIconWidget(
                      iconName: 'cancel_outlined',
                      color: AppTheme.getStatusColor('error'),
                      size: 18),
                  label: Text('Mark All Absent',
                      style:
                          TextStyle(color: AppTheme.getStatusColor('error'))),
                  style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: AppTheme.getStatusColor('error'))))),
        ]));
  }

  Widget _buildStudentList() {
    return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.students.length,
        separatorBuilder: (context, index) => Divider(
            height: 1,
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2)),
        itemBuilder: (context, index) {
          final student = widget.students[index];
          return _buildStudentTile(student);
        });
  }

  Widget _buildStudentTile(Map<String, dynamic> student) {
    final studentId = student['id'] as String;
    final name = student['name'] as String;
    final usn = student['usn'] as String;
    final profileImage = student['profileImage'] as String?;
    final isPresent = attendanceStatus[studentId] ?? false;

    return Dismissible(
        key: Key(studentId),
        background: Container(
            color: AppTheme.getStatusColor('success'),
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 4.w),
            child: Row(children: [
              CustomIconWidget(
                  iconName: 'check_circle', color: Colors.white, size: 24),
              SizedBox(width: 2.w),
              Text('Present',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w500)),
            ])),
        secondaryBackground: Container(
            color: AppTheme.getStatusColor('error'),
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 4.w),
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Text('Absent',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w500)),
              SizedBox(width: 2.w),
              CustomIconWidget(
                  iconName: 'cancel', color: Colors.white, size: 24),
            ])),
        onDismissed: (direction) {
          final newStatus = direction == DismissDirection.startToEnd;
          _toggleAttendance(studentId, newStatus);
        },
        child: ListTile(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            leading: CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                child: profileImage != null
                    ? ClipOval(
                        child: CustomImageWidget(
                            imageUrl: profileImage,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover))
                    : Text(name.isNotEmpty ? name[0].toUpperCase() : 'S',
                        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant))),
            title: Text(name,
                style: AppTheme.lightTheme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500)),
            subtitle: Text(usn, style: AppTheme.lightTheme.textTheme.bodySmall),
            trailing: widget.isMarkingMode
                ? GestureDetector(
                    onTap: () => _toggleAttendance(studentId, !isPresent),
                    child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(color: isPresent ? AppTheme.getStatusColor('success') : Colors.transparent, border: Border.all(color: isPresent ? AppTheme.getStatusColor('success') : AppTheme.lightTheme.colorScheme.outline, width: 2), borderRadius: BorderRadius.circular(4)),
                        child: isPresent ? CustomIconWidget(iconName: 'check', color: Colors.white, size: 16) : null))
                : Container(padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h), decoration: BoxDecoration(color: isPresent ? AppTheme.getStatusColor('success').withValues(alpha: 0.1) : AppTheme.getStatusColor('error').withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Text(isPresent ? 'Present' : 'Absent', style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(color: isPresent ? AppTheme.getStatusColor('success') : AppTheme.getStatusColor('error'), fontWeight: FontWeight.w500))),
            onTap: widget.isMarkingMode ? () => _toggleAttendance(studentId, !isPresent) : null,
            onLongPress: widget.isMarkingMode ? () => _showStudentOptions(student) : null));
  }

  void _toggleAttendance(String studentId, bool isPresent) {
    setState(() {
      attendanceStatus[studentId] = isPresent;
    });
    widget.onAttendanceToggle(studentId, isPresent);
  }

  void _markAllPresent() {
    setState(() {
      for (var student in widget.students) {
        final studentId = student['id'] as String;
        attendanceStatus[studentId] = true;
        widget.onAttendanceToggle(studentId, true);
      }
    });
  }

  void _markAllAbsent() {
    setState(() {
      for (var student in widget.students) {
        final studentId = student['id'] as String;
        attendanceStatus[studentId] = false;
        widget.onAttendanceToggle(studentId, false);
      }
    });
  }

  void _showStudentOptions(Map<String, dynamic> student) {
    showModalBottomSheet(
        context: context,
        builder: (context) => Container(
            padding: EdgeInsets.all(4.w),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              ListTile(
                  leading: CustomIconWidget(
                      iconName: 'note_add',
                      color: AppTheme.lightTheme.primaryColor,
                      size: 24),
                  title: Text('Add Note'),
                  onTap: () {
                    Navigator.pop(context);
                    _showAddNoteDialog(student);
                  }),
              ListTile(
                  leading: CustomIconWidget(
                      iconName: 'history',
                      color: AppTheme.lightTheme.primaryColor,
                      size: 24),
                  title: Text('View History'),
                  onTap: () {
                    Navigator.pop(context);
                    _showAttendanceHistory(student);
                  }),
            ])));
  }

  void _showAddNoteDialog(Map<String, dynamic> student) {
    final noteController = TextEditingController();

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: Text('Add Note for ${student['name']}'),
                content: TextField(
                    controller: noteController,
                    decoration:
                        const InputDecoration(hintText: 'Enter note...'),
                    maxLines: 3),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel')),
                  ElevatedButton(
                      onPressed: () {
                        // Handle note saving
                        Navigator.pop(context);
                      },
                      child: const Text('Save')),
                ]));
  }

  void _showAttendanceHistory(Map<String, dynamic> student) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: Text('${student['name']} - Attendance History'),
                content: SizedBox(
                    width: double.maxFinite,
                    height: 40.h,
                    child: const Center(
                        child:
                            Text('Attendance history will be displayed here'))),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close')),
                ]));
  }
}
