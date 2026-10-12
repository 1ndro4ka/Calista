import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/categories.dart';
import '../../../../core/constants/skills.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_outlined_button.dart';
import '../../../../core/widgets/category_chip.dart';
import '../../../../core/widgets/skill_chip.dart';
import '../controllers/home_controller.dart';

class ProjectFilterSheet extends ConsumerStatefulWidget {
  const ProjectFilterSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => const ProjectFilterSheet(),
    );
  }

  @override
  ConsumerState<ProjectFilterSheet> createState() => _ProjectFilterSheetState();
}

class _ProjectFilterSheetState extends ConsumerState<ProjectFilterSheet> {
  String? _tempCategory;
  late Set<String> _tempSkills;
  String? _tempCapacity;
  String? _tempDeadline;

  @override
  void initState() {
    super.initState();
    final current = ref.read(projectFilterProvider);
    _tempCategory = current.category;
    _tempSkills = Set<String>.from(current.skills);
    _tempCapacity = current.capacityRange;
    _tempDeadline = current.deadlineOption;
  }

  void _apply() {
    final notifier = ref.read(projectFilterProvider.notifier);
    notifier.setCategory(_tempCategory);
    // Sync skills
    final currentSkills = Set<String>.from(ref.read(projectFilterProvider).skills);
    for (final s in currentSkills) {
      if (!_tempSkills.contains(s)) notifier.toggleSkill(s);
    }
    for (final s in _tempSkills) {
      if (!currentSkills.contains(s)) notifier.toggleSkill(s);
    }
    notifier.setCapacityRange(_tempCapacity);
    notifier.setDeadlineOption(_tempDeadline);

    Navigator.of(context).pop();
  }

  void _reset() {
    setState(() {
      _tempCategory = null;
      _tempSkills.clear();
      _tempCapacity = null;
      _tempDeadline = null;
    });
    ref.read(projectFilterProvider.notifier).resetFilters();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle bar
            const SizedBox(height: 12.0),
            Container(
              width: 36.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: AppRadius.radiusRound,
              ),
            ),
            const SizedBox(height: 12.0),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Фильтры', style: AppTypography.titleLarge),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20.0),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.border),

            // Content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: AppSpacing.bottomSheetPadding,
                children: [
                  // Category
                  Text('Категория', style: AppTypography.titleMedium),
                  const SizedBox(height: 10.0),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      CategoryChip(
                        label: 'Все',
                        isSelected: _tempCategory == null,
                        onTap: () => setState(() => _tempCategory = null),
                      ),
                      ...ProjectCategories.all.map((cat) {
                        return CategoryChip(
                          label: cat,
                          isSelected: _tempCategory == cat,
                          onTap: () => setState(() => _tempCategory = cat),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 24.0),

                  // Skills
                  Text('Навыки', style: AppTypography.titleMedium),
                  const SizedBox(height: 10.0),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: SkillsCatalog.all.map((skill) {
                      final isSelected = _tempSkills.contains(skill);
                      return SkillChip(
                        label: skill,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _tempSkills.remove(skill);
                            } else {
                              _tempSkills.add(skill);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24.0),

                  // Team capacity
                  Text('Размер команды', style: AppTypography.titleMedium),
                  const SizedBox(height: 10.0),
                  Row(
                    children: [
                      _buildFilterChoiceChip(
                        label: '2–3',
                        selected: _tempCapacity == '2-3',
                        onTap: () => setState(() {
                          _tempCapacity = _tempCapacity == '2-3' ? null : '2-3';
                        }),
                      ),
                      const SizedBox(width: 8.0),
                      _buildFilterChoiceChip(
                        label: '4–5',
                        selected: _tempCapacity == '4-5',
                        onTap: () => setState(() {
                          _tempCapacity = _tempCapacity == '4-5' ? null : '4-5';
                        }),
                      ),
                      const SizedBox(width: 8.0),
                      _buildFilterChoiceChip(
                        label: '6+',
                        selected: _tempCapacity == '6+',
                        onTap: () => setState(() {
                          _tempCapacity = _tempCapacity == '6+' ? null : '6+';
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),

                  // Deadline
                  Text('Дедлайн', style: AppTypography.titleMedium),
                  const SizedBox(height: 10.0),
                  Row(
                    children: [
                      _buildFilterChoiceChip(
                        label: 'Все',
                        selected: _tempDeadline == null,
                        onTap: () => setState(() => _tempDeadline = null),
                      ),
                      const SizedBox(width: 8.0),
                      _buildFilterChoiceChip(
                        label: 'Ближайшие 30 дней',
                        selected: _tempDeadline == 'upcoming',
                        onTap: () => setState(() {
                          _tempDeadline = _tempDeadline == 'upcoming' ? null : 'upcoming';
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Bottom action buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: AppOutlinedButton(
                      text: 'Сбросить',
                      onPressed: _reset,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: AppButton(
                      text: 'Применить',
                      onPressed: _apply,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChoiceChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.radiusRound,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: AppRadius.radiusRound,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: selected ? AppColors.textInverse : AppColors.textPrimary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
