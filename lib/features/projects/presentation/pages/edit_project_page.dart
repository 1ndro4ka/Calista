import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/categories.dart';
import '../../../../core/constants/skills.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/validators/app_validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/category_chip.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../../core/widgets/skill_chip.dart';
import 'package:calista/features/projects/presentation/controllers/project_controller.dart';
import 'package:calista/features/projects/domain/entities/project.dart';

class EditProjectPage extends ConsumerStatefulWidget {
  final String projectId;

  const EditProjectPage({super.key, required this.projectId});

  @override
  ConsumerState<EditProjectPage> createState() => _EditProjectPageState();
}

class _EditProjectPageState extends ConsumerState<EditProjectPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  final _customSkillController = TextEditingController();

  String _selectedCategory = ProjectCategories.development;
  int _maxMembers = 4;
  DateTime? _selectedDeadline;
  List<String> _requiredSkills = [];

  bool _initialized = false;
  String? _skillsError;
  String? _deadLineError;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  void _initFromProject(Project project) {
    if (_initialized) return;
    _titleController.text = project.title;
    _descriptionController.text = project.description;
    _selectedCategory = project.category;
    _maxMembers = project.maxMembers;
    _selectedDeadline = project.deadline;
    _requiredSkills = List.from(project.requiredSkills);
    _initialized = true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _customSkillController.dispose();
    super.dispose();
  }

  void _toggleSkill(String skill) {
    setState(() {
      if (_requiredSkills.contains(skill)) {
        _requiredSkills.remove(skill);
      } else {
        _requiredSkills.add(skill);
      }
      _skillsError = AppValidators.validateProjectSkills(_requiredSkills);
    });
  }

  void _addCustomSkill() {
    final text = _customSkillController.text.trim();
    if (text.isNotEmpty && !_requiredSkills.contains(text)) {
      setState(() {
        _requiredSkills.add(text);
        _customSkillController.clear();
        _skillsError = AppValidators.validateProjectSkills(_requiredSkills);
      });
    }
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? now.add(const Duration(days: 14)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365 * 3)),
      helpText: 'Выберите дедлайн проекта',
      confirmText: 'Выбрать',
      cancelText: 'Отмена',
    );

    if (picked != null) {
      setState(() {
        _selectedDeadline = picked;
        _deadLineError = AppValidators.validateDeadline(_selectedDeadline);
      });
    }
  }

  Future<void> _submitEdit(Project originalProject) async {
    setState(() {
      _skillsError = AppValidators.validateProjectSkills(_requiredSkills);
      _deadLineError = AppValidators.validateDeadline(_selectedDeadline);
    });

    if (!_formKey.currentState!.validate()) return;
    if (_skillsError != null || _deadLineError != null) return;

    // Check capacity rule: maxMembers >= currentMemberCount
    if (_maxMembers < originalProject.memberCount) {
      context.showSnackBarMessage(
        'Размер команды не может быть меньше текущего числа участников (${originalProject.memberCount})',
        isError: true,
      );
      return;
    }

    final newStatus = originalProject.memberCount >= _maxMembers ? 'full' : 'open';

    final updatedProject = originalProject.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      requiredSkills: _requiredSkills,
      maxMembers: _maxMembers,
      deadline: _selectedDeadline!,
      status: newStatus,
      updatedAt: DateTime.now(),
    );

    final success = await ref
        .read(projectActionControllerProvider.notifier)
        .updateProject(updatedProject);

    if (!mounted) return;

    if (success) {
      context.showSnackBarMessage('Проект успешно обновлён');
      context.pop();
    } else {
      final error = ref.read(projectActionControllerProvider).errorMessage;
      if (error != null) {
        context.showSnackBarMessage(error, isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectAsync = ref.watch(projectDetailsProvider(widget.projectId));
    final actionState = ref.watch(projectActionControllerProvider);

    return projectAsync.when(
      loading: () => const Scaffold(
        body: LoadingState(message: 'Загрузка данных проекта...'),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(),
        body: ErrorState(
          message: err.toString(),
          onRetry: () => ref.invalidate(projectDetailsProvider(widget.projectId)),
        ),
      ),
      data: (project) {
        if (project == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const ErrorState(
              title: 'Проект не найден',
              message: 'Невозможно отредактировать удаленный проект.',
            ),
          );
        }

        _initFromProject(project);

        // Minimum allowed slider value is at least the current memberCount
        final minSliderValue = originalMinMembers(project.memberCount);

        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            title: const Text('Редактирование проекта'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: AppSpacing.pagePadding,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    AppTextField(
                      controller: _titleController,
                      label: 'Название проекта',
                      maxLength: AppConstants.maxProjectTitleLength,
                      validator: AppValidators.validateProjectTitle,
                      enabled: !actionState.isLoading,
                    ),
                    const SizedBox(height: 18.0),

                    // Description
                    AppTextField(
                      controller: _descriptionController,
                      label: 'Описание проекта',
                      maxLines: 5,
                      maxLength: AppConstants.maxProjectDescriptionLength,
                      validator: AppValidators.validateProjectDescription,
                      enabled: !actionState.isLoading,
                    ),
                    const SizedBox(height: 20.0),

                    // Category
                    Text('Категория', style: AppTypography.labelLarge),
                    const SizedBox(height: 8.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: ProjectCategories.all.map((cat) {
                        return CategoryChip(
                          label: cat,
                          isSelected: _selectedCategory == cat,
                          onTap: actionState.isLoading
                              ? null
                              : () => setState(() => _selectedCategory = cat),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24.0),

                    // Max members with current member count constraint
                    Text(
                      'Количество участников: $_maxMembers',
                      style: AppTypography.labelLarge,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'В проекте уже состоит ${project.memberCount} чел. Минимальный размер: $minSliderValue',
                      style: AppTypography.bodySmall,
                    ),
                    Slider(
                      value: _maxMembers.toDouble().clamp(
                            minSliderValue.toDouble(),
                            AppConstants.maxProjectMembers.toDouble(),
                          ),
                      min: minSliderValue.toDouble(),
                      max: AppConstants.maxProjectMembers.toDouble(),
                      divisions: AppConstants.maxProjectMembers - minSliderValue > 0
                          ? AppConstants.maxProjectMembers - minSliderValue
                          : 1,
                      label: '$_maxMembers',
                      onChanged: actionState.isLoading ||
                              AppConstants.maxProjectMembers <= minSliderValue
                          ? null
                          : (val) => setState(() => _maxMembers = val.round()),
                    ),
                    const SizedBox(height: 16.0),

                    // Deadline
                    Text('Дедлайн проекта', style: AppTypography.labelLarge),
                    const SizedBox(height: 8.0),
                    InkWell(
                      onTap: actionState.isLoading ? null : _pickDeadline,
                      borderRadius: AppRadius.radiusMd,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppRadius.radiusMd,
                          border: Border.all(
                            color: _deadLineError != null
                                ? AppColors.error
                                : AppColors.border,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined, size: 20.0),
                                const SizedBox(width: 12.0),
                                Text(
                                  _selectedDeadline != null
                                      ? _selectedDeadline!.toRussianFormattedString()
                                      : 'Выберите дату',
                                  style: AppTypography.bodyLarge,
                                ),
                              ],
                            ),
                            const Icon(Icons.arrow_drop_down,
                                color: AppColors.textTertiary),
                          ],
                        ),
                      ),
                    ),
                    if (_deadLineError != null) ...[
                      const SizedBox(height: 6.0),
                      Text(
                        _deadLineError!,
                        style: AppTypography.bodySmall.copyWith(color: AppColors.error),
                      ),
                    ],
                    const SizedBox(height: 24.0),

                    // Required Skills
                    Text('Требуемые навыки (минимум 1)', style: AppTypography.labelLarge),
                    const SizedBox(height: 10.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: SkillsCatalog.all.map((skill) {
                        final isSelected = _requiredSkills.contains(skill);
                        return SkillChip(
                          label: skill,
                          isSelected: isSelected,
                          onTap: actionState.isLoading ? null : () => _toggleSkill(skill),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10.0),

                    // Custom skill
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _customSkillController,
                            hint: 'Другой навык...',
                            enabled: !actionState.isLoading,
                            textInputAction: TextInputAction.done,
                            onEditingComplete: _addCustomSkill,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        IconButton.filledTonal(
                          onPressed: actionState.isLoading ? null : _addCustomSkill,
                          icon: const Icon(Icons.add, size: 20.0),
                        ),
                      ],
                    ),

                    if (_skillsError != null) ...[
                      const SizedBox(height: 6.0),
                      Text(
                        _skillsError!,
                        style: AppTypography.bodySmall.copyWith(color: AppColors.error),
                      ),
                    ],
                    const SizedBox(height: 32.0),

                    AppButton(
                      text: 'Сохранить изменения',
                      isLoading: actionState.isLoading,
                      onPressed: () => _submitEdit(project),
                    ),
                    const SizedBox(height: 24.0),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  int originalMinMembers(int currentMembers) {
    return currentMembers > AppConstants.minProjectMembers
        ? currentMembers
        : AppConstants.minProjectMembers;
  }
}
