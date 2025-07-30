
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/assignment_detail_bottom_sheet_widget.dart';
import './widgets/assignment_upload_bottom_sheet_widget.dart';
import './widgets/faculty_assignment_card_widget.dart';
import './widgets/faculty_assignment_filter_widget.dart';

class FacultyAssignmentManagementScreen extends StatefulWidget {
  const FacultyAssignmentManagementScreen({Key? key}) : super(key: key);

  @override
  State<FacultyAssignmentManagementScreen> createState() =>
      _FacultyAssignmentManagementScreenState();
}

class _FacultyAssignmentManagementScreenState
    extends State<FacultyAssignmentManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String _searchQuery = '';
  Map<String, dynamic> _filters = {
    'department': 'All',
    'semester': 'All',
    'subject': 'All',
    'status': 'All',
    'sortBy': 'deadline',
  };

  // Mock faculty assignments data
  final List<Map<String, dynamic>> _allAssignments = [
    {
      "id": 1,
      "title": "Data Structures and Algorithms Assignment",
      "subject": "Computer Science",
      "department": "Engineering",
      "semester": "3rd Semester",
      "description":
          "Implement various sorting algorithms and analyze their time complexity. Submit working code with documentation.",
      "deadline": DateTime.now().add(Duration(days: 7)),
      "uploadDate": DateTime.now().subtract(Duration(days: 2)),
      "submissionCount": 28,
      "totalStudents": 45,
      "hasAttachments": true,
      "attachmentCount": 2,
      "status": "active",
      "grade": null,
    },
    {
      "id": 2,
      "title": "Quantum Physics Problem Set",
      "subject": "Physics",
      "department": "Science",
      "semester": "4th Semester",
      "description":
          "Solve problems related to wave-particle duality and uncertainty principle. Show all mathematical derivations.",
      "deadline": DateTime.now().add(Duration(days: 3)),
      "uploadDate": DateTime.now().subtract(Duration(days: 5)),
      "submissionCount": 15,
      "totalStudents": 32,
      "hasAttachments": true,
      "attachmentCount": 1,
      "status": "active",
      "grade": null,
    },
    {
      "id": 3,
      "title": "Organic Chemistry Lab Report",
      "subject": "Chemistry",
      "department": "Science",
      "semester": "2nd Semester",
      "description":
          "Analyze the synthesis of aspirin and write a comprehensive lab report including mechanism and yield calculations.",
      "deadline": DateTime.now().subtract(Duration(days: 1)),
      "uploadDate": DateTime.now().subtract(Duration(days: 10)),
      "submissionCount": 25,
      "totalStudents": 30,
      "hasAttachments": false,
      "attachmentCount": 0,
      "status": "closed",
      "grade": 85.5,
    },
    {
      "id": 4,
      "title": "Digital Marketing Campaign Analysis",
      "subject": "Marketing",
      "department": "Management",
      "semester": "5th Semester",
      "description":
          "Create and analyze a digital marketing campaign for a startup company. Include social media strategy and ROI analysis.",
      "deadline": DateTime.now().add(Duration(days: 14)),
      "uploadDate": DateTime.now().subtract(Duration(days: 1)),
      "submissionCount": 5,
      "totalStudents": 38,
      "hasAttachments": true,
      "attachmentCount": 3,
      "status": "active",
      "grade": null,
    },
  ];

  List<Map<String, dynamic>> _filteredAssignments = [];

  @override
  void initState() {
    super.initState();
    _filteredAssignments = List.from(_allAssignments);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_allAssignments);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((assignment) {
        final title = (assignment['title'] as String).toLowerCase();
        final description = (assignment['description'] as String).toLowerCase();
        final subject = (assignment['subject'] as String).toLowerCase();
        final department = (assignment['department'] as String).toLowerCase();
        final query = _searchQuery.toLowerCase();
        return title.contains(query) ||
            description.contains(query) ||
            subject.contains(query) ||
            department.contains(query);
      }).toList();
    }

    // Apply department filter
    if (_filters['department'] != 'All') {
      filtered = filtered
          .where((assignment) =>
              assignment['department'] == _filters['department'])
          .toList();
    }

    // Apply semester filter
    if (_filters['semester'] != 'All') {
      filtered = filtered
          .where((assignment) => assignment['semester'] == _filters['semester'])
          .toList();
    }

    // Apply subject filter
    if (_filters['subject'] != 'All') {
      filtered = filtered
          .where((assignment) => assignment['subject'] == _filters['subject'])
          .toList();
    }

    // Apply status filter
    if (_filters['status'] != 'All') {
      filtered = filtered.where((assignment) {
        final status = assignment['status'] as String;
        final deadline = assignment['deadline'] as DateTime;
        final now = DateTime.now();

        switch (_filters['status']) {
          case 'Active':
            return status == 'active' && deadline.isAfter(now);
          case 'Closed':
            return status == 'closed';
          case 'Overdue':
            return status == 'active' && deadline.isBefore(now);
          default:
            return true;
        }
      }).toList();
    }

    // Apply sorting
    switch (_filters['sortBy']) {
      case 'deadline':
        filtered.sort((a, b) =>
            (a['deadline'] as DateTime).compareTo(b['deadline'] as DateTime));
        break;
      case 'subject':
        filtered.sort((a, b) =>
            (a['subject'] as String).compareTo(b['subject'] as String));
        break;
      case 'uploadDate':
        filtered.sort((a, b) => (b['uploadDate'] as DateTime)
            .compareTo(a['uploadDate'] as DateTime));
        break;
      case 'submissions':
        filtered.sort((a, b) => (b['submissionCount'] as int)
            .compareTo(a['submissionCount'] as int));
        break;
    }

    setState(() {
      _filteredAssignments = filtered;
    });
  }

  Map<String, List<Map<String, dynamic>>> _groupAssignmentsBySubject() {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var assignment in _filteredAssignments) {
      final subject = assignment['subject'] as String;
      if (!grouped.containsKey(subject)) {
        grouped[subject] = [];
      }
      grouped[subject]!.add(assignment);
    }
    return grouped;
  }

  Future<void> _refreshAssignments() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FacultyAssignmentFilterWidget(
        currentFilters: _filters,
        onFiltersChanged: (newFilters) {
          setState(() {
            _filters = newFilters;
            _applyFilters();
          });
        },
      ),
    );
  }

  void _showAssignmentDetail(Map<String, dynamic> assignment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AssignmentDetailBottomSheetWidget(
        assignment: assignment,
        onEditAssignment: () => _editAssignment(assignment),
        onExtendDeadline: () => _extendDeadline(assignment),
        onDownloadSubmissions: () => _downloadSubmissions(assignment),
        onSendReminders: () => _sendReminders(assignment),
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  void _showUploadAssignmentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AssignmentUploadBottomSheetWidget(
        onUploadAssignment: _uploadNewAssignment,
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  void _uploadNewAssignment(Map<String, dynamic> assignmentData) {
    // Add new assignment to the list
    final newAssignment = {
      "id": _allAssignments.length + 1,
      ...assignmentData,
      "uploadDate": DateTime.now(),
      "submissionCount": 0,
      "status": "active",
    };

    setState(() {
      _allAssignments.add(newAssignment);
      _applyFilters();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Assignment "${assignmentData['title']}" uploaded successfully'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.getStatusColor('success'),
      ),
    );
  }

  void _editAssignment(Map<String, dynamic> assignment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening edit interface for ${assignment['title']}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _extendDeadline(Map<String, dynamic> assignment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deadline extended for ${assignment['title']}'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.getStatusColor('success'),
      ),
    );
  }

  void _downloadSubmissions(Map<String, dynamic> assignment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading submissions for ${assignment['title']}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _sendReminders(Map<String, dynamic> assignment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reminders sent for ${assignment['title']}'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.getStatusColor('success'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupedAssignments = _groupAssignmentsBySubject();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Faculty Assignment Management',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.getRoleColor('faculty'),
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showFilterBottomSheet,
            icon: CustomIconWidget(
              iconName: 'filter_list',
              color: AppTheme.getRoleColor('faculty'),
              size: 24,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(8.h),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search assignments, subjects, departments...',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'search',
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                    size: 20,
                  ),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                        },
                        icon: CustomIconWidget(
                          iconName: 'clear',
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                          size: 20,
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppTheme.getRoleColor('faculty'),
              ),
            )
          : _filteredAssignments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'assignment',
                        size: 64,
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.3),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'No Results Found'
                            : 'No Assignments Created',
                        style: AppTheme.lightTheme.textTheme.headlineSmall
                            ?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'Try adjusting your search or filters'
                            : 'Start by creating your first assignment',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_searchQuery.isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        ElevatedButton(
                          onPressed: () => _searchController.clear(),
                          child: Text('Clear Search'),
                        ),
                      ],
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshAssignments,
                  color: AppTheme.getRoleColor('faculty'),
                  child: ListView(
                    padding: EdgeInsets.only(bottom: 10.h),
                    children: [
                      // Statistics Summary
                      Container(
                        margin: EdgeInsets.all(4.w),
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: AppTheme.getRoleColor('faculty')
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assignment Overview',
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                color: AppTheme.getRoleColor('faculty'),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        '${_filteredAssignments.where((a) => a['status'] == 'active').length}',
                                        style: AppTheme
                                            .lightTheme.textTheme.headlineSmall
                                            ?.copyWith(
                                          color:
                                              AppTheme.getRoleColor('faculty'),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'Active',
                                        style: AppTheme
                                            .lightTheme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 6.h,
                                  color:
                                      AppTheme.lightTheme.colorScheme.outline,
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        '${_filteredAssignments.where((a) => a['status'] == 'closed').length}',
                                        style: AppTheme
                                            .lightTheme.textTheme.headlineSmall
                                            ?.copyWith(
                                          color: AppTheme.getStatusColor(
                                              'success'),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'Completed',
                                        style: AppTheme
                                            .lightTheme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 6.h,
                                  color:
                                      AppTheme.lightTheme.colorScheme.outline,
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        '${_filteredAssignments.fold<int>(0, (sum, a) => sum + (a['submissionCount'] as int))}',
                                        style: AppTheme
                                            .lightTheme.textTheme.headlineSmall
                                            ?.copyWith(
                                          color:
                                              AppTheme.lightTheme.primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'Total Submissions',
                                        style: AppTheme
                                            .lightTheme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Subject Sections
                      ...groupedAssignments.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4.w, vertical: 1.h),
                              child: Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'book',
                                    color: AppTheme.getRoleColor('faculty'),
                                    size: 20,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    entry.key,
                                    style: AppTheme
                                        .lightTheme.textTheme.titleMedium
                                        ?.copyWith(
                                      color: AppTheme.getRoleColor('faculty'),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 2.w, vertical: 0.5.h),
                                    decoration: BoxDecoration(
                                      color: AppTheme.getRoleColor('faculty')
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${entry.value.length}',
                                      style: AppTheme
                                          .lightTheme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: AppTheme.getRoleColor('faculty'),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...entry.value.map((assignment) {
                              return FacultyAssignmentCardWidget(
                                assignment: assignment,
                                onTap: () => _showAssignmentDetail(assignment),
                              );
                            }).toList(),
                            SizedBox(height: 2.h),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showUploadAssignmentSheet,
        backgroundColor: AppTheme.getRoleColor('faculty'),
        foregroundColor: Colors.white,
        icon: CustomIconWidget(
          iconName: 'add',
          color: Colors.white,
          size: 24,
        ),
        label: Text(
          'New Assignment',
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
