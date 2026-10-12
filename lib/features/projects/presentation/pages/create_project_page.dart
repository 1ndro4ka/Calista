import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/providers/app_providers.dart';
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
import '../../../../core/widgets/skill_chip.dart';
import '../controllers/project_controller.dart';

class CreateProjectPage extends ConsumerStatefulWidget {
  const CreateProjectPage({super.key});

  @override
  ConsumerState<CreateProjectPage> createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends ConsumerState<CreateProjectPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _customSkillController = TextEditingController();

  String _selectedCategory = ProjectCategories.development;
  int _maxMembers = 4;
  DateTime? _selectedDeadline;
  final List<String> _requiredSkills = [];

  String? _skillsError;
  String? _deadLineError;

  @override
  void initState() {
    super.initState();
    // Default deadline 1 month ahead
    _selectedDeadline = DateTime.now().add(const Duration(days: 30));
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

  Future<void> _submitCreate() async {
    setState(() {
      _skillsError = AppValidators.validateProjectSkills(_requiredSkills);
      _deadLineError = AppValidators.validateDeadline(_selectedDeadline);
    });

    if (!_formKey.currentState!.validate()) return;
    if (_skillsError != null || _deadLineError != null) return;

    final creator = ref.read(currentUserProfileProvider).value;
    if (creator == null) {
      context.showSnackBarMessage('Профиль пользователя не загружен', isError: true);
      return;
    }

    final created = await ref.read(projectActionControllerProvider.notifier).createProject(
          title: _titleController.text,
          description: _descriptionController.text,
          category: _selectedCategory,
          requiredSkills: _requiredSkills,
          maxMembers: _maxMembers,
          deadline: _selectedDeadline!,
          creator: creator,
        );

    if (!mounted) return;

    if (created != null) {
      context.showSnackBarMessage('Проект «${created.title}» успешно создан');
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
    final actionState = ref.watch(projectActionControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Создание проекта'),
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
                Text('Информация о проекте', style: AppTypography.headline),
                const SizedBox(height: 6.0),
                Text(
                  'Опишите цели учебного проекта, чтобы привлечь подходящих участников',
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 24.0),

                // Title
                AppTextField(
                  controller: _titleController,
                  label: 'Название проекта',
                  hint: 'Например: Разработка мобильного сервиса',
                  maxLength: AppConstants.maxProjectTitleLength,
                  validator: AppValidators.validateProjectTitle,
                  enabled: !actionState.isLoading,
                ),
                const SizedBox(height: 18.0),

                // Description
                AppTextField(
                  controller: _descriptionController,
                  label: 'Описание проекта',
                  hint: 'Подробно расскажите о проекте, стеке технологий и роли участников...',
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

                // Team capacity selector
                Text(
                  'Количество участников: $_maxMembers',
                  style: AppTypography.labelLarge,
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Включая создателя проекта (от ${AppConstants.minProjectMembers} до ${AppConstants.maxProjectMembers} человек)',
                  style: AppTypography.bodySmall,
                ),
                Slider(
                  value: _maxMembers.toDouble(),
                  min: AppConstants.minProjectMembers.toDouble(),
                  max: AppConstants.maxProjectMembers.toDouble(),
                  divisions: AppConstants.maxProjectMembers - AppConstants.minProjectMembers,
                  label: '$_maxMembers',
                  onChanged: actionState.isLoading
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
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.radiusMd,
                      border: Border.all(
                        color: _deadLineError != null ? AppColors.error : AppColors.border,
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
                        const Icon(Icons.arrow_drop_down, color: AppColors.textTertiary),
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
                const SizedBox(height: 4.0),
                Text('Выберите навыки, необходимые вашей команде', style: AppTypography.bodySmall),
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
                  text: 'Создать проект',
                  isLoading: actionState.isLoading,
                  onPressed: _submitCreate,
                ),
                const SizedBox(height: 24.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
