import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable avatar widget showing user photo or clean initials fallback.
/// Strictly no emoji.
class AvatarWidget extends StatelessWidget {
  final String? avatarUrl;
  final String firstName;
  final String lastName;
  final double size;
  final VoidCallback? onTap;
  final bool showEditBadge;

  const AvatarWidget({
    super.key,
    this.avatarUrl,
    required this.firstName,
    required this.lastName,
    this.size = 48.0,
    this.onTap,
    this.showEditBadge = false,
  });

  String get _initials {
    final first = firstName.trim().isNotEmpty ? firstName.trim()[0].toUpperCase() : '';
    final last = lastName.trim().isNotEmpty ? lastName.trim()[0].toUpperCase() : '';
    final combined = '$first$last';
    return combined.isNotEmpty ? combined : 'C';
  }

  @override
  Widget build(BuildContext context) {
    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: ClipOval(
        child: avatarUrl != null && avatarUrl!.isNotEmpty
            ? Image.network(
                avatarUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildInitials(),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: SizedBox(
                      width: 16.0,
                      height: 16.0,
                      child: CircularProgressIndicator(strokeWidth: 1.5),
                    ),
                  );
                },
              )
            : _buildInitials(),
      ),
    );

    if (showEditBadge) {
      avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 2.0),
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                size: 14.0,
                color: AppColors.textInverse,
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }

  Widget _buildInitials() {
    return Center(
      child: Text(
        _initials,
        style: TextStyle(
          fontSize: size * 0.38,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
