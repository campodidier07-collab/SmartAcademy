import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import 'custom_snackbar.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final String? avatarUrl;
  final VoidCallback? onNotificationTap;
  final bool hasNotification;
  final bool showBackButton;
  final Widget? trailing;

  const CustomHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.avatarUrl,
    this.onNotificationTap,
    this.hasNotification = false,
    this.showBackButton = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    // Calcular el top padding evitando doble SafeArea
    final topPadding = MediaQuery.of(context).padding.top > 0 ? 8.0 : 16.0;

    return Container(
      padding: EdgeInsets.fromLTRB(20, topPadding, 20, 14),
      decoration: BoxDecoration(
        color: AppTheme.backgroundMain.withValues(alpha: 0.85),
        border: const Border(bottom: BorderSide(color: AppTheme.borderLight, width: 1)),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Row(
            children: [
              if (showBackButton) ...[
                _HeaderIconButton(
                  icon: LucideIcons.arrowLeft,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 12),
              ],
              if (!showBackButton && avatarUrl != null) ...[
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.cardElevated,
                  backgroundImage: NetworkImage(avatarUrl!),
                ),
                const SizedBox(width: 12),
              ] else if (!showBackButton) ...[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.cardElevated,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'lib/assets/imagenes/logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        LucideIcons.graduationCap,
                        color: AppTheme.primaryBlue,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textMain,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                trailing!,
              ] else ...[
                _HeaderIconButton(
                  icon: LucideIcons.search,
                  onPressed: () {
                    CustomSnackbar.show(
                      context,
                      message: 'La búsqueda global estará disponible próximamente.',
                      type: SnackbarType.info,
                    );
                  },
                ),
                const SizedBox(width: 8),
                Stack(
                  children: [
                    _HeaderIconButton(
                      icon: LucideIcons.bell,
                      onPressed: onNotificationTap ??
                          () {
                            CustomSnackbar.show(
                              context,
                              message: 'No tienes nuevas notificaciones en este momento.',
                              type: SnackbarType.info,
                            );
                          },
                    ),
                    if (hasNotification)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppTheme.error,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.cardBase, width: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _HeaderIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppTheme.cardElevated.withValues(alpha: 0.8),
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: IconButton(
        icon: Icon(icon, color: AppTheme.textMain, size: 18),
        padding: EdgeInsets.zero,
        splashRadius: 20,
        onPressed: onPressed,
      ),
    );
  }
}
