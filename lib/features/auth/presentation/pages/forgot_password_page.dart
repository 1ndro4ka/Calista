import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/validators/app_validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitReset() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(authControllerProvider.notifier)
        .sendPasswordReset(_emailController.text.trim());

    if (!mounted) return;

    if (success) {
      setState(() {
        _sent = true;
      });
      context.showSnackBarMessage('Инструкция по сбросу пароля отправлена на почту');
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
        title: const Text('Сброс пароля'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: _sent ? _buildSuccessView() : _buildFormView(authState),
        ),
      ),
    );
  }

  Widget _buildFormView(AuthState authState) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16.0),
          Text(
            'Восстановление доступа',
            style: AppTypography.headline,
          ),
          const SizedBox(height: 8.0),
          Text(
            'Укажите адрес электронной почты, привязанный к аккаунту. Мы отправим ссылку для смены пароля.',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: 28.0),
          AppTextField(
            controller: _emailController,
            label: 'Электронная почта',
            hint: 'student@university.edu',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.mail_outline, size: 20.0),
            validator: AppValidators.validateEmail,
            enabled: !authState.isLoading,
            onEditingComplete: _submitReset,
          ),
          const SizedBox(height: 28.0),
          AppButton(
            text: 'Отправить ссылку',
            isLoading: authState.isLoading,
            onPressed: _submitReset,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: AppColors.successLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              size: 48.0,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 20.0),
          Text(
            'Письмо отправлено',
            style: AppTypography.titleLarge,
          ),
          const SizedBox(height: 8.0),
          Text(
            'Проверьте вашу почту ${_emailController.text} и следуйте инструкции для сброса пароля.',
            style: AppTypography.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32.0),
          AppButton(
            text: 'Вернуться к входу',
            isFullWidth: false,
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }
}
