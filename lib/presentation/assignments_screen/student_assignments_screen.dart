import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../controllers/student_dashboard_controller.dart';
import '../../models/assignment_model.dart';
import './widgets/assignment_detail_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/subject_section_widget.dart';

class StudentAssignmentsScreen extends ConsumerStatefulWidget {
  final bool isEmbedded;
  final VoidCallback? onBackPressed;

  const StudentAssignmentsScreen({
    Key? key,
    this.isEmbedded = false,
    this.onBackPressed,
  }) : super(key: key);

  @override
  ConsumerState<StudentAssignmentsScreen> createState() =>
      _StudentAssignmentsScreenState();
}

class _StudentAssignmentsScreenState
    extends ConsumerState<StudentAssignmentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic> _filters = {
    'subject': 'All',
    'status': 'All',
    'priority': 'All',
    'sortBy': 'dueDate',
  };

  List<Assignment> _filteredAssignments = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
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
    });
  }

  void _applyFilters(List<Assignment> assignments) {
    List<Assignment> filtered = List.from(assignments);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((assignment) {
        final title = assignment.title.toLowerCase();
        final description = assignment.description.toLowerCase();
        final subject = assignment.subject.toLowerCase();
        final query = _searchQuery.toLowerCase();
        return title.contains(query) ||
            description.contains(query) ||
            subject.contains(query);
      }).toList();
    }

    // Apply subject filter
    if (_filters['subject'] != 'All') {
      filtered = filtered
          .where((assignment) => assignment.subject == _filters['subject'])
          .toList();
    }

    // Apply status filter
    if (_filters['status'] != 'All') {
      filtered = filtered.where((assignment) {
        final dueDate = assignment.dueDate;
        final now = DateTime.now();
        final isActive = assignment.isActive;

        switch (_filters['status']) {
          case 'Pending':
            return isActive && dueDate.isAfter(now);
          case 'Submitted':
            return !isActive; // Assuming inactive means submitted/completed
          case 'Overdue':
            return isActive && dueDate.isBefore(now);
          default:
            return true;
        }
      }).toList();
    }

    // Apply priority filter - Note: Assignment model doesn't have priority field
    // This filter will be skipped for now
    // if (_filters['priority'] != 'All') {
    //   filtered = filtered
    //       .where((assignment) => assignment.priority == _filters['priority'])
    //       .toList();
    // }

    // Apply sorting
    switch (_filters['sortBy']) {
      case 'dueDate':
        filtered.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        break;
      case 'subject':
        filtered.sort((a, b) => a.subject.compareTo(b.subject));
        break;
      case 'title':
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'createdAt':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    setState(() {
      _filteredAssignments = filtered;
    });
  }

  Map<String, List<Assignment>> _groupAssignmentsBySubject() {
    Map<String, List<Assignment>> grouped = {};
    for (var assignment in _filteredAssignments) {
      final subject = assignment.subject;
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
          });
        },
      ),
    );
  }

  void _showAssignmentDetail(Assignment assignment) {
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

  void _downloadAttachment(Assignment assignment) {
    // Implement download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading attachment for ${assignment.title}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _setReminder(Assignment assignment) {
    // Implement reminder functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reminder set for ${assignment.title}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _togglePriority(Assignment assignment) {
    // Implement priority toggle functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Priority updated for ${assignment.title}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _submitAssignment(Assignment assignment) {
    // Implement assignment submission
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening submission interface for ${assignment.title}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final assignmentsAsync = ref.watch(studentAssignmentsProvider);

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
      body: assignmentsAsync.when(
        data: (assignments) {
          // Apply filters to the assignments
          _applyFilters(assignments);
          final groupedAssignments = _groupAssignmentsBySubject();

          if (_filteredAssignments.isEmpty) {
            return EmptyStateWidget(
              title: _searchQuery.isNotEmpty
                  ? 'No Results Found'
                  : 'No Assignments',
              subtitle: _searchQuery.isNotEmpty
                  ? 'Try adjusting your search or filters'
                  : 'Your assignments will appear here when available',
              iconName: _searchQuery.isNotEmpty ? 'search_off' : 'assignment',
              onAction: _searchQuery.isNotEmpty
                  ? () => _searchController.clear()
                  : null,
              actionText: _searchQuery.isNotEmpty ? 'Clear Search' : null,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(studentAssignmentsProvider);
              await _refreshAssignments();
            },
            color: AppTheme.lightTheme.primaryColor,
            child: ListView(
              padding: EdgeInsets.only(bottom: 10.h),
              children: [
                // Summary Stats
                Container(
                  margin: EdgeInsets.all(4.w),
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color:
                        AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '${_filteredAssignments.where((a) => a.isActive && a.dueDate.isAfter(DateTime.now())).length}',
                              style: AppTheme.lightTheme.textTheme.headlineSmall
                                  ?.copyWith(
                                color: AppTheme.lightTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Pending',
                              style: AppTheme.lightTheme.textTheme.bodySmall,
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
                              '${_filteredAssignments.where((a) => !a.isActive).length}',
                              style: AppTheme.lightTheme.textTheme.headlineSmall
                                  ?.copyWith(
                                color: AppTheme.getStatusColor('success'),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Submitted',
                              style: AppTheme.lightTheme.textTheme.bodySmall,
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
                              '${_filteredAssignments.where((a) => a.dueDate.isBefore(DateTime.now()) && a.isActive).length}',
                              style: AppTheme.lightTheme.textTheme.headlineSmall
                                  ?.copyWith(
                                color: AppTheme.getStatusColor('error'),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Overdue',
                              style: AppTheme.lightTheme.textTheme.bodySmall,
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
                    assignments: entry.value
                        .map((assignment) => {
                              'id': assignment.id,
                              'title': assignment.title,
                              'subject': assignment.subject,
                              'description': assignment.description,
                              'dueDate': assignment.dueDate,
                              'hasAttachments': assignment.fileUrl != null &&
                                  assignment.fileUrl!.isNotEmpty,
                              'attachmentCount': assignment.fileUrl != null &&
                                      assignment.fileUrl!.isNotEmpty
                                  ? 1
                                  : 0,
                              'submissionStatus':
                                  assignment.isActive ? 'pending' : 'submitted',
                              'priority': 'Medium',
                              'facultyName': assignment.facultyName,
                              'maxMarks': assignment.maxMarks,
                              'type': assignment.type,
                            })
                        .toList(),
                    onAssignmentTap: (assignmentMap) {
                      final assignment = entry.value
                          .firstWhere((a) => a.id == assignmentMap['id']);
                      _showAssignmentDetail(assignment);
                    },
                    onDownload: (assignmentMap) {
                      final assignment = entry.value
                          .firstWhere((a) => a.id == assignmentMap['id']);
                      _downloadAttachment(assignment);
                    },
                    onReminder: (assignmentMap) {
                      final assignment = entry.value
                          .firstWhere((a) => a.id == assignmentMap['id']);
                      _setReminder(assignment);
                    },
                    onPriority: (assignmentMap) {
                      final assignment = entry.value
                          .firstWhere((a) => a.id == assignmentMap['id']);
                      _togglePriority(assignment);
                    },
                  );
                }).toList(),
              ],
            ),
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(
            color: AppTheme.lightTheme.primaryColor,
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('Error loading assignments'),
              TextButton(
                onPressed: () => ref.refresh(studentAssignmentsProvider),
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
