import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/skills.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/validators/app_validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/skill_chip.dart';
import '../controllers/auth_controller.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _telegramController = TextEditingController();
  final _customSkillController = TextEditingController();

  final List<String> _selectedSkills = [];
  String? _skillsValidationError;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _telegramController.dispose();
    _customSkillController.dispose();
    super.dispose();
  }

  void _toggleSkill(String skill) {
    setState(() {
      if (_selectedSkills.contains(skill)) {
        _selectedSkills.remove(skill);
      } else {
        _selectedSkills.add(skill);
      }
      _skillsValidationError = AppValidators.validateProfileSkills(_selectedSkills);
    });
  }

  void _addCustomSkill() {
    final text = _customSkillController.text.trim();
    if (text.isNotEmpty && !_selectedSkills.contains(text)) {
      setState(() {
        _selectedSkills.add(text);
        _customSkillController.clear();
        _skillsValidationError = AppValidators.validateProfileSkills(_selectedSkills);
      });
    }
  }

  Future<void> _submitRegistration() async {
    setState(() {
      _skillsValidationError = AppValidators.validateProfileSkills(_selectedSkills);
    });

    if (!_formKey.currentState!.validate()) return;
    if (_skillsValidationError != null) return;

    final success = await ref.read(authControllerProvider.notifier).register(
          email: _emailController.text,
          password: _passwordController.text,
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          telegramUsername: _telegramController.text,
          skills: _selectedSkills,
        );

    if (!mounted) return;

    if (success) {
      context.go('/home');
    } else {
      final error = ref.read(authControllerProvider).errorMessage;
      if (error != null) {
        context.showSnackBarMessage(error, isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Регистрация'),
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
                Text(
                  'Создание профиля',
                  style: AppTypography.headline,
                ),
                const SizedBox(height: 6.0),
                Text(
                  'Заполните информацию для поиска проектов и формирования команды',
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 24.0),

                // Name & Surname
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _firstNameController,
                        label: 'Имя',
                        hint: 'Адильжан',
                        validator: (v) => AppValidators.validateName(v, 'Имя'),
                        enabled: !authState.isLoading,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: AppTextField(
                        controller: _lastNameController,
                        label: 'Фамилия',
                        hint: 'Касымов',
                        validator: (v) => AppValidators.validateName(v, 'Фамилия'),
                        enabled: !authState.isLoading,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18.0),

                // Email
                AppTextField(
                  controller: _emailController,
                  label: 'Электронная почта',
                  hint: 'student@university.edu',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.mail_outline, size: 20.0),
                  validator: AppValidators.validateEmail,
                  enabled: !authState.isLoading,
                ),
                const SizedBox(height: 18.0),

                // Telegram username
                AppTextField(
                  controller: _telegramController,
                  label: 'Telegram (без @)',
                  hint: 'username',
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
                  enabled: !authState.isLoading,
                ),
                const SizedBox(height: 18.0),

                // Password
                AppTextField(
                  controller: _passwordController,
                  label: 'Пароль',
                  hint: 'Минимум 8 символов',
                  isPassword: true,
                  prefixIcon: const Icon(Icons.lock_outline, size: 20.0),
                  validator: AppValidators.validatePassword,
                  enabled: !authState.isLoading,
                ),
                const SizedBox(height: 18.0),

                // Confirm Password
                AppTextField(
                  controller: _confirmPasswordController,
                  label: 'Подтверждение пароля',
                  hint: 'Повторите пароль',
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  prefixIcon: const Icon(Icons.lock_reset_outlined, size: 20.0),
                  validator: (v) => AppValidators.validateConfirmPassword(
                    v,
                    _passwordController.text,
                  ),
                  enabled: !authState.isLoading,
                ),
                const SizedBox(height: 24.0),

                // Skills Selector
                Text(
                  'Навыки (минимум 2)',
                  style: AppTypography.labelLarge,
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Выберите навыки из списка или добавьте свои',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: 12.0),

                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: SkillsCatalog.all.map((skill) {
                    final isSelected = _selectedSkills.contains(skill);
                    return SkillChip(
                      label: skill,
                      isSelected: isSelected,
                      onTap: authState.isLoading ? null : () => _toggleSkill(skill),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12.0),

                // Custom skill input
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _customSkillController,
                        hint: 'Другой навык...',
                        enabled: !authState.isLoading,
                        textInputAction: TextInputAction.done,
                        onEditingComplete: _addCustomSkill,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    IconButton.filledTonal(
                      onPressed: authState.isLoading ? null : _addCustomSkill,
                      icon: const Icon(Icons.add, size: 20.0),
                    ),
                  ],
                ),

                if (_skillsValidationError != null) ...[
                  const SizedBox(height: 8.0),
                  Text(
                    _skillsValidationError!,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.error),
                  ),
                ],
                const SizedBox(height: 32.0),

                AppButton(
                  text: 'Зарегистрироваться',
                  isLoading: authState.isLoading,
                  onPressed: _submitRegistration,
                ),
                const SizedBox(height: 20.0),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Уже есть аккаунт? ', style: AppTypography.bodyMedium),
                    GestureDetector(
                      onTap: authState.isLoading ? null : () => context.pop(),
                      child: Text(
                        'Войти',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
