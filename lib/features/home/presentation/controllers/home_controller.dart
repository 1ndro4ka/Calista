import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calista/app/providers/app_providers.dart';
import 'package:calista/features/projects/domain/entities/project.dart';

class ProjectFilterState {
  final String? category;
  final Set<String> skills;
  final String? capacityRange; // '2-3' | '4-5' | '6+'
  final String? deadlineOption; // 'upcoming' | null

  const ProjectFilterState({
    this.category,
    this.skills = const {},
    this.capacityRange,
    this.deadlineOption,
  });

  bool get hasActiveFilters =>
      category != null ||
      skills.isNotEmpty ||
      capacityRange != null ||
      deadlineOption != null;

  ProjectFilterState copyWith({
    String? category,
    bool clearCategory = false,
    Set<String>? skills,
    String? capacityRange,
    bool clearCapacity = false,
    String? deadlineOption,
    bool clearDeadline = false,
  }) {
    return ProjectFilterState(
      category: clearCategory ? null : (category ?? this.category),
      skills: skills ?? this.skills,
      capacityRange: clearCapacity ? null : (capacityRange ?? this.capacityRange),
      deadlineOption: clearDeadline ? null : (deadlineOption ?? this.deadlineOption),
    );
  }
}

// Controller for filter state
class ProjectFilterNotifier extends Notifier<ProjectFilterState> {
  @override
  ProjectFilterState build() => const ProjectFilterState();

  void setCategory(String? category) {
    if (category == null || category == 'Все') {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(category: category);
    }
  }

  void toggleSkill(String skill) {
    final nextSkills = Set<String>.from(state.skills);
    if (nextSkills.contains(skill)) {
      nextSkills.remove(skill);
    } else {
      nextSkills.add(skill);
    }
    state = state.copyWith(skills: nextSkills);
  }

  void setCapacityRange(String? range) {
    if (range == null || state.capacityRange == range) {
      state = state.copyWith(clearCapacity: true);
    } else {
      state = state.copyWith(capacityRange: range);
    }
  }

  void setDeadlineOption(String? option) {
    if (option == null || state.deadlineOption == option) {
      state = state.copyWith(clearDeadline: true);
    } else {
      state = state.copyWith(deadlineOption: option);
    }
  }

  void resetFilters() {
    state = const ProjectFilterState();
  }
}

final projectFilterProvider =
    NotifierProvider<ProjectFilterNotifier, ProjectFilterState>(ProjectFilterNotifier.new);

// Search query notifier
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
  void clear() => state = '';
}

final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

// Base stream of new projects directly from Firestore
final newProjectsStreamProvider = StreamProvider<List<Project>>((ref) {
  return ref.watch(projectRepositoryProvider).watchNewProjects();
});

// Filtered and searched projects provider computed locally from new projects
final filteredProjectsProvider = Provider<AsyncValue<List<Project>>>((ref) {
  final projectsAsync = ref.watch(newProjectsStreamProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final filter = ref.watch(projectFilterProvider);

  return projectsAsync.whenData((projects) {
    return projects.where((project) {
      // 1. Search Query
      if (query.isNotEmpty) {
        final titleMatch = project.title.toLowerCase().contains(query);
        final descMatch = project.description.toLowerCase().contains(query);
        final catMatch = project.category.toLowerCase().contains(query);
        final skillMatch = project.requiredSkills
            .any((s) => s.toLowerCase().contains(query));

        if (!titleMatch && !descMatch && !catMatch && !skillMatch) {
          return false;
        }
      }

      // 2. Category Filter
      if (filter.category != null && filter.category != 'Все') {
        if (project.category != filter.category) {
          return false;
        }
      }

      // 3. Skills Filter
      if (filter.skills.isNotEmpty) {
        final matchesSkill = project.requiredSkills.any(
          (skill) => filter.skills.contains(skill),
        );
        if (!matchesSkill) {
          return false;
        }
      }

      // 4. Team Capacity Filter
      if (filter.capacityRange != null) {
        if (filter.capacityRange == '2-3') {
          if (project.maxMembers < 2 || project.maxMembers > 3) return false;
        } else if (filter.capacityRange == '4-5') {
          if (project.maxMembers < 4 || project.maxMembers > 5) return false;
        } else if (filter.capacityRange == '6+') {
          if (project.maxMembers < 6) return false;
        }
      }

      // 5. Deadline Filter
      if (filter.deadlineOption == 'upcoming') {
        final now = DateTime.now();
        final daysDiff = project.deadline.difference(now).inDays;
        if (daysDiff < 0 || daysDiff > 30) {
          return false;
        }
      }

      return true;
    }).toList();
  });
});
