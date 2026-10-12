import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/providers/app_providers.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/validators/app_validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_outlined_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import 'package:calista/features/projects/domain/entities/project.dart';

class ApplyBottomSheet extends ConsumerStatefulWidget {
  final Project project;

  const ApplyBottomSheet({super.key, required this.project});

  static Future<bool?> show(BuildContext context, Project project) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => ApplyBottomSheet(project: project),
    );
  }

  @override
  ConsumerState<ApplyBottomSheet> createState() => _ApplyBottomSheetState();
}

class _ApplyBottomSheetState extends ConsumerState<ApplyBottomSheet> {
  final _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final applicantProfile = ref.read(currentUserProfileProvider).value;
    if (applicantProfile == null) {
      context.showSnackBarMessage('Профиль пользователя не загружен', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(applicationRepositoryProvider).submitApplication(
            project: widget.project,
            applicant: applicantProfile,
            message: _commentController.text.trim().isNotEmpty
                ? _commentController.text.trim()
                : null,
          );

      if (!mounted) return;
      context.showSnackBarMessage('Заявка успешно отправлена создателю проекта');
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      context.showSnackBarMessage(e.toString(), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        padding: AppSpacing.bottomSheetPadding,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: AppRadius.radiusRound,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Подать заявку в команду',
                style: AppTypography.titleLarge,
              ),
              const SizedBox(height: 6.0),
              Text(
                'Проект: «${widget.project.title}»',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20.0),
              AppTextField(
                controller: _commentController,
                label: 'Комментарий к заявке (необязательно)',
                hint: 'Расскажите, какую роль вы можете взять на себя...',
                maxLines: 4,
                maxLength: AppConstants.maxApplicationMessageLength,
                validator: AppValidators.validateApplicationMessage,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 20.0),
              Row(
                children: [
                  Expanded(
                    child: AppOutlinedButton(
                      text: 'Отмена',
                      enabled: !_isLoading,
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: AppButton(
                      text: 'Отправить',
                      isLoading: _isLoading,
                      onPressed: _submit,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
