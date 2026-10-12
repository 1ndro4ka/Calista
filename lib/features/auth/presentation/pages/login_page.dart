import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/validators/app_validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authControllerProvider.notifier).login(
          email: _emailController.text,
          password: _passwordController.text,
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.pagePaddingHorizontal,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24.0),
                  Center(
                    child: SvgPicture.asset(
                      AppConstants.logoSvg,
                      width: 64.0,
                      height: 64.0,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Text(
                    'Добро пожаловать в ${AppConstants.appName}',
                    style: AppTypography.headline,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Войдите в свой аккаунт для поиска проектов и участников',
                    style: AppTypography.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 36.0),

                  AppTextField(
                    controller: _emailController,
                    label: 'Электронная почта',
                    hint: 'student@university.edu',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.mail_outline, size: 20.0),
                    validator: AppValidators.validateEmail,
                    enabled: !authState.isLoading,
                  ),
                  const SizedBox(height: 20.0),

                  AppTextField(
                    controller: _passwordController,
                    label: 'Пароль',
                    hint: 'Минимум 8 символов',
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                    prefixIcon: const Icon(Icons.lock_outline, size: 20.0),
                    validator: AppValidators.validatePassword,
                    enabled: !authState.isLoading,
                    onEditingComplete: _submitLogin,
                  ),
                  const SizedBox(height: 12.0),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: authState.isLoading
                          ? null
                          : () => context.push('/forgot-password'),
                      child: const Text('Забыли пароль?'),
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  AppButton(
                    text: 'Войти',
                    isLoading: authState.isLoading,
                    onPressed: _submitLogin,
                  ),
                  const SizedBox(height: 24.0),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Нет аккаунта? ',
                        style: AppTypography.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: authState.isLoading
                            ? null
                            : () => context.push('/register'),
                        child: Text(
                          'Зарегистрироваться',
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
