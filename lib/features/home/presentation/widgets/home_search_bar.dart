import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../controllers/home_controller.dart';
import 'project_filter_sheet.dart';

class HomeSearchBar extends ConsumerStatefulWidget {
  const HomeSearchBar({super.key});

  @override
  ConsumerState<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends ConsumerState<HomeSearchBar> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      ref.read(searchQueryProvider.notifier).setQuery(value);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(searchQueryProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final filterState = ref.watch(projectFilterProvider);
    final hasActiveFilters = filterState.hasActiveFilters;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48.0,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.radiusMd,
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Поиск проектов...',
                hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 20.0,
                  color: AppColors.textSecondary,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18.0),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10.0),
        Stack(
          clipBehavior: Clip.none,
          children: [
            InkWell(
              onTap: () => ProjectFilterSheet.show(context),
              borderRadius: AppRadius.radiusMd,
              child: Container(
                width: 48.0,
                height: 48.0,
                decoration: BoxDecoration(
                  color: hasActiveFilters ? AppColors.primary : AppColors.surface,
                  borderRadius: AppRadius.radiusMd,
                  border: Border.all(
                    color: hasActiveFilters ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Icon(
                  Icons.tune_outlined,
                  size: 20.0,
                  color: hasActiveFilters ? AppColors.textInverse : AppColors.textPrimary,
                ),
              ),
            ),
            if (hasActiveFilters)
              Positioned(
                top: -3,
                right: -3,
                child: Container(
                  width: 10.0,
                  height: 10.0,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
