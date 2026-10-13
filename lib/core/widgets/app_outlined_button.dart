import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

/// Standard Outlined Button for Calista secondary actions.
class AppOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;
  final bool isFullWidth;
  final IconData? icon;
  final Color? borderColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;

  const AppOutlinedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.isFullWidth = true,
    this.icon,
    this.borderColor,
    this.textColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorder = borderColor ?? AppColors.border;
    final effectiveFg = textColor ?? AppColors.textPrimary;

    final textWidget = Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: AppTypography.labelLarge.copyWith(color: effectiveFg),
    );

    Widget child = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 18.0,
            height: 18.0,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveFg),
            ),
          ),
          const SizedBox(width: 8.0),
        ] else if (icon != null) ...[
          Icon(icon, size: 18.0, color: effectiveFg),
          const SizedBox(width: 8.0),
        ],
        if (isFullWidth)
          Flexible(child: textWidget)
        else
          textWidget,
      ],
    );

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: 48.0,
      child: OutlinedButton(
        onPressed: (!enabled || isLoading) ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: effectiveFg,
          side: BorderSide(color: effectiveBorder, width: 1.0),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16.0),
        ),
        child: child,
      ),
    );
  }
}
