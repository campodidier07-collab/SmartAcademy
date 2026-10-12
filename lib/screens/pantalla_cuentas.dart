import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/controlador_auth.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_header.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_snackbar.dart';

class AccountManagementScreen extends StatefulWidget {
  const AccountManagementScreen({super.key});

  @override
  State<AccountManagementScreen> createState() => _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  List<User> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final authCtrl = context.read<AuthController>();
    final users = await authCtrl.getAllUsers();
    
    if (mounted) {
      setState(() {
        _users = users;
        _isLoading = false;
      });
    }
  }

  void _showResetPasswordDialog(User targetUser) {
    final passwordController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;
            return Container(
              padding: EdgeInsets.only(
                bottom: bottomInset > 0 ? bottomInset + 20 : 24,
                left: 20, right: 20, top: 16,
              ),
              decoration: const BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: AppTheme.surfaceCardElevated)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36, height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppTheme.textMuted.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.warning.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(LucideIcons.shieldAlert, color: AppTheme.warning, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Restablecer Clave',
                                style: GoogleFonts.outfit(
                                  color: AppTheme.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${targetUser.nombre} (${targetUser.correo})',
                                style: GoogleFonts.outfit(
                                  color: AppTheme.textMuted,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: passwordController,
                      label: 'Nueva Contraseña Temporal',
                      icon: LucideIcons.key,
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Actualizar Contraseña',
                      icon: LucideIcons.save,
                      onPressed: () async {
                        if (passwordController.text.trim().length < 6) {
                          CustomSnackbar.show(context, message: 'La contraseña debe tener al menos 6 caracteres', type: SnackbarType.error);
                          return;
                        }
                        
                        final authCtrl = context.read<AuthController>();
                        Navigator.pop(context); // close sheet
                        
                        if (!mounted) return;
                        CustomSnackbar.show(this.context, message: 'Actualizando credenciales...', type: SnackbarType.info);
                        
                        final success = await authCtrl.resetUserPassword(targetUser.id!, passwordController.text.trim());
                        
                        if (mounted) {
                          if (success) {
                            CustomSnackbar.show(this.context, message: 'Contraseña actualizada exitosamente', type: SnackbarType.success);
                          } else {
                            CustomSnackbar.show(this.context, message: 'Error al actualizar contraseña', type: SnackbarType.error);
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundMain,
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(
              title: 'Gestión de Cuentas',
              subtitle: 'Restablecer contraseñas de usuarios registrados',
              showBackButton: true,
            ),
            
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    itemCount: _users.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      Color roleColor = AppTheme.primaryBlue;
                      if (user.rol == 'Profesor') roleColor = AppTheme.secondaryPurple;
                      if (user.rol == 'Administrador') roleColor = AppTheme.warning;

                      return CustomCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: roleColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: roleColor.withValues(alpha: 0.3)),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                user.nombre.isNotEmpty ? user.nombre[0].toUpperCase() : '?',
                                style: GoogleFonts.outfit(color: roleColor, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.nombre,
                                    style: GoogleFonts.outfit(
                                      color: AppTheme.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                    maxLines: 1, 
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user.correo,
                                    style: GoogleFonts.outfit(
                                      color: AppTheme.textMuted,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1, 
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: roleColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: roleColor.withValues(alpha: 0.3)),
                                    ),
                                    child: Text(
                                      user.rol,
                                      style: GoogleFonts.outfit(color: roleColor, fontSize: 10, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(LucideIcons.key, color: AppTheme.textMuted, size: 20),
                              tooltip: 'Restablecer contraseña',
                              onPressed: () => _showResetPasswordDialog(user),
                            ),
                          ],
                        ),
                      ).animate().fade(delay: (index * 40).ms).slideX(begin: 0.04);
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
