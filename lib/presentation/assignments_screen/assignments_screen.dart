import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/assignment_detail_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/subject_section_widget.dart';

class AssignmentsScreen extends StatefulWidget {
  final bool isEmbedded;
  final VoidCallback? onBackPressed;

  const AssignmentsScreen({
    Key? key,
    this.isEmbedded = false,
    this.onBackPressed,
  }) : super(key: key);

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic> _filters = {
    'subject': 'All',
    'status': 'All',
    'priority': 'All',
    'sortBy': 'dueDate',
  };

  // Mock assignments data
  final List<Map<String, dynamic>> _allAssignments = [
    {
      "id": 1,
      "title": "Linear Algebra Problem Set 3",
      "subject": "Mathematics",
      "description":
          """Solve the following linear algebra problems focusing on matrix operations, eigenvalues, and eigenvectors. Show all work and provide detailed explanations for each step. This assignment covers chapters 4-6 from the textbook.""",
      "dueDate": DateTime.now().add(Duration(days: 3)),
      "hasAttachments": true,
      "attachmentCount": 2,
      "submissionStatus": "pending",
      "priority": "High",
      "grade": null,
      "feedback": null,
    },
    {
      "id": 2,
      "title": "Quantum Mechanics Lab Report",
      "subject": "Physics",
      "description":
          """Write a comprehensive lab report on the double-slit experiment. Include theoretical background, experimental procedure, data analysis, and conclusions. The report should be 8-10 pages long.""",
      "dueDate": DateTime.now().add(Duration(days: 1)),
      "hasAttachments": true,
      "attachmentCount": 1,
      "submissionStatus": "submitted",
      "priority": "Medium",
      "grade": 85,
      "feedback":
          "Good analysis, but could improve on theoretical explanation.",
    },
    {
      "id": 3,
      "title": "Organic Chemistry Synthesis",
      "subject": "Chemistry",
      "description":
          """Design a synthetic pathway for the given organic compound. Show all intermediate steps, reagents, and conditions. Explain the mechanism for each reaction step.""",
      "dueDate": DateTime.now().subtract(Duration(days: 2)),
      "hasAttachments": false,
      "attachmentCount": 0,
      "submissionStatus": "pending",
      "priority": "High",
      "grade": null,
      "feedback": null,
    },
    {
      "id": 4,
      "title": "Data Structures Implementation",
      "subject": "Computer Science",
      "description":
          """Implement a balanced binary search tree (AVL tree) in your preferred programming language. Include all basic operations: insert, delete, search, and traversal methods.""",
      "dueDate": DateTime.now().add(Duration(days: 7)),
      "hasAttachments": true,
      "attachmentCount": 3,
      "submissionStatus": "pending",
      "priority": "Medium",
      "grade": null,
      "feedback": null,
    },
    {
      "id": 5,
      "title": "Shakespeare Essay Analysis",
      "subject": "English",
      "description":
          """Write a 1500-word essay analyzing the themes of power and corruption in Macbeth. Use specific examples from the text and incorporate at least 5 scholarly sources.""",
      "dueDate": DateTime.now().add(Duration(days: 5)),
      "hasAttachments": false,
      "attachmentCount": 0,
      "submissionStatus": "submitted",
      "priority": "Low",
      "grade": 92,
      "feedback": "Excellent analysis and use of textual evidence.",
    },
  ];

  List<Map<String, dynamic>> _filteredAssignments = [];
  String _searchQuery = '';

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

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
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
        final query = _searchQuery.toLowerCase();
        return title.contains(query) ||
            description.contains(query) ||
            subject.contains(query);
      }).toList();
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
        final status = assignment['submissionStatus'] as String;
        final dueDate = assignment['dueDate'] as DateTime;
        final now = DateTime.now();

        switch (_filters['status']) {
          case 'Pending':
            return status == 'pending' && dueDate.isAfter(now);
          case 'Submitted':
            return status == 'submitted';
          case 'Overdue':
            return status == 'pending' && dueDate.isBefore(now);
          default:
            return true;
        }
      }).toList();
    }

    // Apply priority filter
    if (_filters['priority'] != 'All') {
      filtered = filtered
          .where((assignment) => assignment['priority'] == _filters['priority'])
          .toList();
    }

    // Apply sorting
    switch (_filters['sortBy']) {
      case 'dueDate':
        filtered.sort((a, b) =>
            (a['dueDate'] as DateTime).compareTo(b['dueDate'] as DateTime));
        break;
      case 'subject':
        filtered.sort((a, b) =>
            (a['subject'] as String).compareTo(b['subject'] as String));
        break;
      case 'priority':
        final priorityOrder = {'High': 0, 'Medium': 1, 'Low': 2};
        filtered.sort((a, b) => priorityOrder[a['priority']]!
            .compareTo(priorityOrder[b['priority']]!));
        break;
      case 'title':
        filtered.sort(
            (a, b) => (a['title'] as String).compareTo(b['title'] as String));
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
      builder: (context) => FilterBottomSheetWidget(
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
      builder: (context) => AssignmentDetailWidget(
        assignment: assignment,
        onDownloadAttachment: () => _downloadAttachment(assignment),
        onSubmit: () => _submitAssignment(assignment),
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  void _downloadAttachment(Map<String, dynamic> assignment) {
    // Implement download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading attachment for ${assignment['title']}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _setReminder(Map<String, dynamic> assignment) {
    // Implement reminder functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reminder set for ${assignment['title']}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _togglePriority(Map<String, dynamic> assignment) {
    // Implement priority toggle functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Priority updated for ${assignment['title']}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _submitAssignment(Map<String, dynamic> assignment) {
    // Implement assignment submission
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Opening submission interface for ${assignment['title']}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupedAssignments = _groupAssignmentsBySubject();

    return Scaffold(
      appBar: AppBar(
        title: Text('Assignments'),
        leading: widget.isEmbedded
            ? IconButton(
                onPressed: widget.onBackPressed ?? () {},
                icon: CustomIconWidget(
                  iconName: 'arrow_back',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 24,
                ),
              )
            : IconButton(
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
              color: AppTheme.lightTheme.colorScheme.onSurface,
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
                hintText: 'Search assignments...',
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
                color: AppTheme.lightTheme.primaryColor,
              ),
            )
          : _filteredAssignments.isEmpty
              ? EmptyStateWidget(
                  title: _searchQuery.isNotEmpty
                      ? 'No Results Found'
                      : 'No Assignments',
                  subtitle: _searchQuery.isNotEmpty
                      ? 'Try adjusting your search or filters'
                      : 'Your assignments will appear here when available',
                  iconName:
                      _searchQuery.isNotEmpty ? 'search_off' : 'assignment',
                  onAction: _searchQuery.isNotEmpty
                      ? () => _searchController.clear()
                      : null,
                  actionText: _searchQuery.isNotEmpty ? 'Clear Search' : null,
                )
              : RefreshIndicator(
                  onRefresh: _refreshAssignments,
                  color: AppTheme.lightTheme.primaryColor,
                  child: ListView(
                    padding: EdgeInsets.only(bottom: 10.h),
                    children: [
                      // Summary Stats
                      Container(
                        margin: EdgeInsets.all(4.w),
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.primaryColor
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    '${_filteredAssignments.where((a) => a['submissionStatus'] == 'pending').length}',
                                    style: AppTheme
                                        .lightTheme.textTheme.headlineSmall
                                        ?.copyWith(
                                      color: AppTheme.lightTheme.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Pending',
                                    style:
                                        AppTheme.lightTheme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 6.h,
                              color: AppTheme.lightTheme.colorScheme.outline,
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    '${_filteredAssignments.where((a) => a['submissionStatus'] == 'submitted').length}',
                                    style: AppTheme
                                        .lightTheme.textTheme.headlineSmall
                                        ?.copyWith(
                                      color: AppTheme.getStatusColor('success'),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Submitted',
                                    style:
                                        AppTheme.lightTheme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 6.h,
                              color: AppTheme.lightTheme.colorScheme.outline,
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    '${_filteredAssignments.where((a) => (a['dueDate'] as DateTime).isBefore(DateTime.now()) && a['submissionStatus'] == 'pending').length}',
                                    style: AppTheme
                                        .lightTheme.textTheme.headlineSmall
                                        ?.copyWith(
                                      color: AppTheme.getStatusColor('error'),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Overdue',
                                    style:
                                        AppTheme.lightTheme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Subject Sections
                      ...groupedAssignments.entries.map((entry) {
                        return SubjectSectionWidget(
                          subject: entry.key,
                          assignments: entry.value,
                          onAssignmentTap: _showAssignmentDetail,
                          onDownload: _downloadAttachment,
                          onReminder: _setReminder,
                          onPriority: _togglePriority,
                        );
                      }).toList(),
                    ],
                  ),
                ),
    );
  }
}
