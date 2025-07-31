import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radiant_app/models/assignment_model.dart';
import 'package:radiant_app/services/assignment_service.dart';

final assignmentServiceProvider = Provider<AssignmentService>((ref) => AssignmentService());

final assignmentControllerProvider = StateNotifierProvider<AssignmentController, AssignmentState>((ref) {
  final assignmentService = ref.watch(assignmentServiceProvider);
  return AssignmentController(assignmentService);
});

final facultyAssignmentsProvider = StateNotifierProvider<FacultyAssignmentsNotifier, AsyncValue<List<Assignment>>>((ref) {
  final assignmentService = ref.watch(assignmentServiceProvider);
  return FacultyAssignmentsNotifier(assignmentService);
});

final assignmentStatsProvider = StateNotifierProvider<AssignmentStatsNotifier, AsyncValue<Map<String, int>>>((ref) {
  final assignmentService = ref.watch(assignmentServiceProvider);
  return AssignmentStatsNotifier(assignmentService);
});

class AssignmentState {
  final List<Assignment> assignments;
  final List<Assignment> filteredAssignments;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final Map<String, dynamic> filters;
  final Map<String, int> stats;

  AssignmentState({
    this.assignments = const [],
    this.filteredAssignments = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.filters = const {
      'department': 'All',
      'semester': 'All',
      'subject': 'All',
      'status': 'All',
      'sortBy': 'deadline',
    },
    this.stats = const {
      'total': 0,
      'active': 0,
      'closed': 0,
      'overdue': 0,
    },
  });

  AssignmentState copyWith({
    List<Assignment>? assignments,
    List<Assignment>? filteredAssignments,
    bool? isLoading,
    String? error,
    String? searchQuery,
    Map<String, dynamic>? filters,
    Map<String, int>? stats,
  }) {
    return AssignmentState(
      assignments: assignments ?? this.assignments,
      filteredAssignments: filteredAssignments ?? this.filteredAssignments,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      filters: filters ?? this.filters,
      stats: stats ?? this.stats,
    );
  }
}

class AssignmentController extends StateNotifier<AssignmentState> {
  final AssignmentService _assignmentService;

  AssignmentController(this._assignmentService) : super(AssignmentState());

  Future<void> loadAssignments(String facultyId) async {
    print('📚 Loading assignments for faculty: $facultyId');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final assignments = await _assignmentService.getAssignmentsByFaculty(facultyId);
      final stats = await _assignmentService.getAssignmentStats(facultyId);
      
      print('📚 Loaded ${assignments.length} assignments from database');
      for (final assignment in assignments) {
        print('  - ${assignment.title} (${assignment.subject}) - Active: ${assignment.isActive}');
      }
      
      state = state.copyWith(
        assignments: assignments,
        filteredAssignments: assignments,
        stats: stats,
        isLoading: false,
      );
      
      print('📚 State updated with ${state.assignments.length} assignments');
      _applyFilters();
    } catch (e) {
      print('❌ Error loading assignments: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createAssignment(Assignment assignment) async {
    print('📝 Creating assignment: ${assignment.title}');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final assignmentId = await _assignmentService.addAssignment(assignment);
      print('✅ Assignment created with ID: $assignmentId');
      
      final newAssignment = assignment.copyWith(id: assignmentId);
      print('📋 Assignment object created: ${newAssignment.title} - ${newAssignment.subject}');
      
      final updatedAssignments = [newAssignment, ...state.assignments];
      print('📊 Total assignments after adding: ${updatedAssignments.length}');
      
      state = state.copyWith(
        assignments: updatedAssignments,
        isLoading: false,
      );
      
      _applyFilters();
      print('🔍 Filtered assignments: ${state.filteredAssignments.length}');
      
      await _refreshStats(assignment.facultyId);
      print('📈 Stats refreshed');
    } catch (e) {
      print('❌ Error creating assignment: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateAssignment(String assignmentId, Map<String, dynamic> updates, String facultyId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _assignmentService.updateAssignment(assignmentId, updates);
      
      final updatedAssignments = state.assignments.map((assignment) {
        if (assignment.id == assignmentId) {
          return assignment.copyWith(
            title: updates['title'] ?? assignment.title,
            description: updates['description'] ?? assignment.description,
            dueDate: updates['dueDate'] != null 
                ? (updates['dueDate'] as DateTime) 
                : assignment.dueDate,
            isActive: updates['isActive'] ?? assignment.isActive,
          );
        }
        return assignment;
      }).toList();

      state = state.copyWith(
        assignments: updatedAssignments,
        isLoading: false,
      );
      
      _applyFilters();
      await _refreshStats(facultyId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> deleteAssignment(String assignmentId, String facultyId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _assignmentService.deleteAssignment(assignmentId);
      
      final updatedAssignments = state.assignments
          .where((assignment) => assignment.id != assignmentId)
          .toList();

      state = state.copyWith(
        assignments: updatedAssignments,
        isLoading: false,
      );
      
      _applyFilters();
      await _refreshStats(facultyId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> extendDeadline(String assignmentId, DateTime newDeadline, String facultyId) async {
    try {
      await _assignmentService.extendDeadline(assignmentId, newDeadline);
      await updateAssignment(assignmentId, {'dueDate': newDeadline}, facultyId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> toggleAssignmentStatus(String assignmentId, bool isActive, String facultyId) async {
    try {
      await _assignmentService.toggleAssignmentStatus(assignmentId, isActive);
      await updateAssignment(assignmentId, {'isActive': isActive}, facultyId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  void updateFilters(Map<String, dynamic> newFilters) {
    state = state.copyWith(filters: newFilters);
    _applyFilters();
  }

  void _applyFilters() {
    print('🔍 Applying filters to ${state.assignments.length} assignments');
    print('🔍 Current filters: ${state.filters}');
    print('🔍 Search query: "${state.searchQuery}"');
    
    List<Assignment> filtered = List.from(state.assignments);
    print('🔍 Starting with ${filtered.length} assignments');

    // Apply search filter
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered = filtered.where((assignment) {
        final matchesTitle = assignment.title.toLowerCase().contains(query);
        final matchesDescription = assignment.description.toLowerCase().contains(query);
        final matchesSubject = assignment.subject.toLowerCase().contains(query);
        final matchesDepartment = assignment.department.toLowerCase().contains(query);
        return matchesTitle || matchesDescription || matchesSubject || matchesDepartment;
      }).toList();
      print('🔍 After search filter: ${filtered.length} assignments');
    }

    // Apply filters
    if (state.filters['department'] != 'All') {
      final beforeCount = filtered.length;
      filtered = filtered
          .where((assignment) => assignment.department == state.filters['department'])
          .toList();
      print('🔍 After department filter (${state.filters['department']}): ${filtered.length} assignments (was $beforeCount)');
    }

    if (state.filters['subject'] != 'All') {
      final beforeCount = filtered.length;
      filtered = filtered
          .where((assignment) => assignment.subject == state.filters['subject'])
          .toList();
      print('🔍 After subject filter (${state.filters['subject']}): ${filtered.length} assignments (was $beforeCount)');
    }

    if (state.filters['status'] != 'All') {
      final beforeCount = filtered.length;
      filtered = filtered.where((assignment) {
        final now = DateTime.now();
        switch (state.filters['status']) {
          case 'Active':
            return assignment.isActive && assignment.dueDate.isAfter(now);
          case 'Closed':
            return !assignment.isActive;
          case 'Overdue':
            return assignment.isActive && assignment.dueDate.isBefore(now);
          default:
            return true;
        }
      }).toList();
      print('🔍 After status filter (${state.filters['status']}): ${filtered.length} assignments (was $beforeCount)');
    }

    // Apply sorting
    switch (state.filters['sortBy']) {
      case 'deadline':
        filtered.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        break;
      case 'subject':
        filtered.sort((a, b) => a.subject.compareTo(b.subject));
        break;
      case 'uploadDate':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'title':
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
    }

    print('🔍 Final filtered assignments: ${filtered.length}');
    if (filtered.isNotEmpty) {
      print('🔍 First assignment: ${filtered.first.title} - ${filtered.first.subject}');
    }

    state = state.copyWith(filteredAssignments: filtered);
  }

  Future<void> _refreshStats(String facultyId) async {
    try {
      final stats = await _assignmentService.getAssignmentStats(facultyId);
      state = state.copyWith(stats: stats);
    } catch (e) {
      // Don't update error state for stats refresh failure
    }
  }

  Map<String, List<Assignment>> groupAssignmentsBySubject() {
    final Map<String, List<Assignment>> grouped = {};
    for (final assignment in state.filteredAssignments) {
      if (!grouped.containsKey(assignment.subject)) {
        grouped[assignment.subject] = [];
      }
      grouped[assignment.subject]!.add(assignment);
    }
    return grouped;
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

class FacultyAssignmentsNotifier extends StateNotifier<AsyncValue<List<Assignment>>> {
  final AssignmentService _assignmentService;

  FacultyAssignmentsNotifier(this._assignmentService) : super(const AsyncValue.loading());

  Future<void> loadAssignments(String facultyId) async {
    state = const AsyncValue.loading();
    try {
      final assignments = await _assignmentService.getAssignmentsByFaculty(facultyId);
      state = AsyncValue.data(assignments);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> loadActiveAssignments(String facultyId) async {
    state = const AsyncValue.loading();
    try {
      final assignments = await _assignmentService.getActiveAssignmentsByFaculty(facultyId);
      state = AsyncValue.data(assignments);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

class AssignmentStatsNotifier extends StateNotifier<AsyncValue<Map<String, int>>> {
  final AssignmentService _assignmentService;

  AssignmentStatsNotifier(this._assignmentService) : super(const AsyncValue.loading());

  Future<void> loadStats(String facultyId) async {
    state = const AsyncValue.loading();
    try {
      final stats = await _assignmentService.getAssignmentStats(facultyId);
      state = AsyncValue.data(stats);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// Helper extension for Assignment model
extension AssignmentCopyWith on Assignment {
  Assignment copyWith({
    String? id,
    String? title,
    String? description,
    String? fileUrl,
    String? subject,
    String? department,
    String? section,
    int? semester,
    DateTime? dueDate,
    String? facultyId,
    String? facultyName,
    int? maxMarks,
    String? type,
    bool? isActive,
    List<String>? allowedFormats,
    String? instructions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Assignment(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      fileUrl: fileUrl ?? this.fileUrl,
      subject: subject ?? this.subject,
      department: department ?? this.department,
      section: section ?? this.section,
      semester: semester ?? this.semester,
      dueDate: dueDate ?? this.dueDate,
      facultyId: facultyId ?? this.facultyId,
      facultyName: facultyName ?? this.facultyName,
      maxMarks: maxMarks ?? this.maxMarks,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
      allowedFormats: allowedFormats ?? this.allowedFormats,
      instructions: instructions ?? this.instructions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}