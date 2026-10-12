import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/providers/app_providers.dart';
import '../../../../core/constants/skills.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/validators/app_validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/avatar_widget.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../../core/widgets/skill_chip.dart';
import 'package:calista/features/auth/domain/entities/user_profile.dart';
import '../controllers/profile_controller.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _telegramController;
  late final TextEditingController _bioController;
  late final TextEditingController _courseController;
  late final TextEditingController _specialtyController;
  final _customSkillController = TextEditingController();

  String? _currentAvatarUrl;
  List<String> _skills = [];
  bool _initialized = false;
  String? _skillsError;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _telegramController = TextEditingController();
    _bioController = TextEditingController();
    _courseController = TextEditingController();
    _specialtyController = TextEditingController();
  }

  void _initFromProfile(UserProfile profile) {
    if (_initialized) return;
    _firstNameController.text = profile.firstName;
    _lastNameController.text = profile.lastName;
    _telegramController.text = profile.telegramUsername;
    _bioController.text = profile.bio ?? '';
    _courseController.text = profile.course != null ? profile.course.toString() : '';
    _specialtyController.text = profile.specialty ?? '';
    _currentAvatarUrl = profile.avatarUrl;
    _skills = List.from(profile.skills);
    _initialized = true;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _telegramController.dispose();
    _bioController.dispose();
    _courseController.dispose();
    _specialtyController.dispose();
    _customSkillController.dispose();
    super.dispose();
  }

  void _toggleSkill(String skill) {
    setState(() {
      if (_skills.contains(skill)) {
        _skills.remove(skill);
      } else {
        _skills.add(skill);
      }
      _skillsError = AppValidators.validateProfileSkills(_skills);
    });
  }

  void _addCustomSkill() {
    final text = _customSkillController.text.trim();
    if (text.isNotEmpty && !_skills.contains(text)) {
      setState(() {
        _skills.add(text);
        _customSkillController.clear();
        _skillsError = AppValidators.validateProfileSkills(_skills);
      });
    }
  }

  Future<void> _pickAvatar(String uid) async {
    final newUrl = await ref.read(profileControllerProvider.notifier).pickAndUploadAvatar(uid);
    if (newUrl != null && mounted) {
      setState(() {
        _currentAvatarUrl = newUrl;
      });
      context.showSnackBarMessage('Фото профиля обновлено');
    }
  }

  Future<void> _saveProfile(UserProfile currentProfile) async {
    setState(() {
      _skillsError = AppValidators.validateProfileSkills(_skills);
    });

    if (!_formKey.currentState!.validate()) return;
    if (_skillsError != null) return;

    final courseVal = int.tryParse(_courseController.text.trim());

    final updated = currentProfile.copyWith(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      telegramUsername: AppValidators.normalizeTelegram(_telegramController.text),
      bio: _bioController.text.trim().isNotEmpty ? _bioController.text.trim() : null,
      course: courseVal,
      specialty: _specialtyController.text.trim().isNotEmpty
          ? _specialtyController.text.trim()
          : null,
      avatarUrl: _currentAvatarUrl,
      skills: _skills,
      updatedAt: DateTime.now(),
    );

    final success =
        await ref.read(profileControllerProvider.notifier).updateProfile(updated);

    if (!mounted) return;

    if (success) {
      context.showSnackBarMessage('Профиль успешно сохранён');
      context.pop();
    } else {
      final error = ref.read(profileControllerProvider).errorMessage;
      if (error != null) {
        context.showSnackBarMessage(error, isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProfileProvider);
    final editState = ref.watch(profileControllerProvider);

    return profileAsync.when(
      loading: () => const Scaffold(
        body: LoadingState(message: 'Загрузка профиля...'),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(),
        body: ErrorState(
          message: err.toString(),
          onRetry: () => ref.invalidate(currentUserProfileProvider),
        ),
      ),
      data: (profile) {
        if (profile == null) {
          return const Scaffold(
            body: Center(child: Text('Профиль не найден')),
          );
        }

        _initFromProfile(profile);

        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            title: const Text('Редактирование профиля'),
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
                    // Avatar picker
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AvatarWidget(
                            avatarUrl: _currentAvatarUrl,
                            firstName: profile.firstName,
                            lastName: profile.lastName,
                            size: 96.0,
                            showEditBadge: true,
                            onTap: editState.isUploadingAvatar
                                ? null
                                : () => _pickAvatar(profile.uid),
                          ),
                          if (editState.isUploadingAvatar)
                            Container(
                              width: 96.0,
                              height: 96.0,
                              decoration: BoxDecoration(
                                color: AppColors.scrim,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.surface,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Center(
                      child: TextButton(
                        onPressed: editState.isUploadingAvatar
                            ? null
                            : () => _pickAvatar(profile.uid),
                        child: const Text('Изменить фото'),
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // First & Last Name
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _firstNameController,
                            label: 'Имя',
                            validator: (v) => AppValidators.validateName(v, 'Имя'),
                            enabled: !editState.isLoading,
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: AppTextField(
                            controller: _lastNameController,
                            label: 'Фамилия',
                            validator: (v) => AppValidators.validateName(v, 'Фамилия'),
                            enabled: !editState.isLoading,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18.0),

                    // Telegram
                    AppTextField(
                      controller: _telegramController,
                      label: 'Telegram (без @)',
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 14.0, right: 8.0, top: 14.0),
                        child: Text(
                          '@',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      validator: AppValidators.validateTelegram,
                      enabled: !editState.isLoading,
                    ),
                    const SizedBox(height: 18.0),

                    // Specialty & Course
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: AppTextField(
                            controller: _specialtyController,
                            label: 'Специальность',
                            hint: 'Программная инженерия',
                            enabled: !editState.isLoading,
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          flex: 1,
                          child: AppTextField(
                            controller: _courseController,
                            label: 'Курс',
                            hint: '1–5',
                            keyboardType: TextInputType.number,
                            enabled: !editState.isLoading,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18.0),

                    // Bio
                    AppTextField(
                      controller: _bioController,
                      label: 'О себе',
                      hint: 'Расскажите о ваших интересах и учебном опыте...',
                      maxLines: 4,
                      maxLength: 300,
                      enabled: !editState.isLoading,
                    ),
                    const SizedBox(height: 20.0),

                    // Skills (Minimum 2)
                    Text('Навыки (минимум 2)', style: AppTypography.labelLarge),
                    const SizedBox(height: 4.0),
                    Text(
                      'Выберите навыки из каталога или добавьте новые',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: 10.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: SkillsCatalog.all.map((skill) {
                        final isSelected = _skills.contains(skill);
                        return SkillChip(
                          label: skill,
                          isSelected: isSelected,
                          onTap: editState.isLoading ? null : () => _toggleSkill(skill),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10.0),

                    // Custom skill input
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _customSkillController,
                            hint: 'Другой навык...',
                            enabled: !editState.isLoading,
                            textInputAction: TextInputAction.done,
                            onEditingComplete: _addCustomSkill,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        IconButton.filledTonal(
                          onPressed: editState.isLoading ? null : _addCustomSkill,
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
                      isLoading: editState.isLoading,
                      onPressed: () => _saveProfile(profile),
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
}
