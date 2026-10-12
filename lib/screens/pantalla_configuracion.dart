import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/controlador_auth.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_header.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/custom_text_field.dart';
import 'pantalla_cuentas.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = true;
  String _selectedLanguage = 'Español';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _darkModeEnabled = prefs.getBool('dark_mode_enabled') ?? true;
      _selectedLanguage = prefs.getString('selected_language') ?? 'Español';
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userRole = context.watch<AuthController>().currentUser?.rol;

    return Scaffold(
      backgroundColor: AppTheme.backgroundMain,
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(
              title: 'Configuración',
              subtitle: 'Ajustes y preferencias de la aplicación',
              showBackButton: true,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                children: [
                  _buildSectionHeader('PREFERENCIAS DE LA APLICACIÓN'),
                  _buildSwitchTile(
                    title: 'Notificaciones Push',
                    subtitle: 'Alertas de calificaciones y nuevas clases',
                    icon: LucideIcons.bellRing,
                    value: _notificationsEnabled,
                    onChanged: (val) {
                      setState(() => _notificationsEnabled = val);
                      _saveSetting('notifications_enabled', val);
                    },
                  ),
                  _buildSwitchTile(
                    title: 'Modo Oscuro',
                    subtitle: 'Tema visual optimizado para baja fatiga',
                    icon: LucideIcons.moon,
                    value: _darkModeEnabled,
                    onChanged: (val) {
                      setState(() => _darkModeEnabled = val);
                      _saveSetting('dark_mode_enabled', val);
                    },
                  ),
                  _buildDropdownTile(
                    title: 'Idioma de la Interfaz',
                    subtitle: 'Selecciona tu idioma preferido',
                    icon: LucideIcons.languages,
                    value: _selectedLanguage,
                    items: ['Español', 'English', 'Português'],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedLanguage = val);
                        _saveSetting('selected_language', val);
                        CustomSnackbar.show(context, message: 'Idioma cambiado a $val', type: SnackbarType.success);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader('SEGURIDAD Y PRIVACIDAD'),
                  _buildActionTile(
                    title: 'Borrar Caché Local',
                    subtitle: 'Libera memoria y recursos temporales',
                    icon: LucideIcons.trash2,
                    iconColor: AppTheme.warning,
                    onTap: () async {
                      PaintingBinding.instance.imageCache.clear();
                      PaintingBinding.instance.imageCache.clearLiveImages();
                      CustomSnackbar.show(context, message: 'Caché de imágenes borrado exitosamente', type: SnackbarType.success);
                    },
                  ),
                  _buildActionTile(
                    title: 'Cambiar Contraseña',
                    subtitle: 'Actualiza tu clave de acceso',
                    icon: LucideIcons.key,
                    iconColor: AppTheme.primaryBlue,
                    onTap: () => _showChangePasswordDialog(context),
                  ),
                  _buildActionTile(
                    title: 'Política de Privacidad',
                    subtitle: 'Información sobre el manejo de tus datos',
                    icon: LucideIcons.shieldCheck,
                    iconColor: AppTheme.secondaryPurple,
                    onTap: () => _showPrivacyPolicyDialog(context),
                  ),
                  if (userRole == 'Administrador') ...[
                    const SizedBox(height: 24),
                    _buildSectionHeader('ADMINISTRACIÓN'),
                    _buildActionTile(
                      title: 'Gestión de Cuentas',
                      subtitle: 'Restablecer credenciales de usuarios',
                      icon: LucideIcons.users,
                      iconColor: AppTheme.warning,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AccountManagementScreen()),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4, left: 4),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          color: AppTheme.primaryBlue,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CustomCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primaryBlue, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title, 
                    style: GoogleFonts.outfit(
                      color: AppTheme.textPrimary, 
                      fontWeight: FontWeight.w600, 
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    subtitle, 
                    style: GoogleFonts.outfit(
                      color: AppTheme.textMuted, 
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppTheme.primaryBlue,
              activeTrackColor: AppTheme.primaryBlue.withValues(alpha: 0.35),
              inactiveThumbColor: AppTheme.textMuted,
              inactiveTrackColor: AppTheme.surfaceCardElevated,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CustomCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primaryBlue, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title, 
                    style: GoogleFonts.outfit(
                      color: AppTheme.textPrimary, 
                      fontWeight: FontWeight.w600, 
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    subtitle, 
                    style: GoogleFonts.outfit(
                      color: AppTheme.textMuted, 
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                dropdownColor: AppTheme.surfaceCardElevated,
                borderRadius: BorderRadius.circular(14),
                style: GoogleFonts.outfit(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
                icon: const Icon(LucideIcons.chevronDown, color: AppTheme.textMuted, size: 18),
                items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    String? subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CustomCard(
        padding: EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title, 
                          style: GoogleFonts.outfit(
                            color: AppTheme.textPrimary, 
                            fontWeight: FontWeight.w600, 
                            fontSize: 15,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle, 
                            style: GoogleFonts.outfit(
                              color: AppTheme.textMuted, 
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(LucideIcons.chevronRight, color: AppTheme.textMuted, size: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Cambiar Contraseña', 
            style: GoogleFonts.outfit(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: currentPasswordController,
                obscureText: true,
                label: 'Contraseña Actual',
                icon: LucideIcons.lock,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: newPasswordController,
                obscureText: true,
                label: 'Nueva Contraseña',
                icon: LucideIcons.key,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar', style: GoogleFonts.outfit(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final current = currentPasswordController.text.trim();
                final newPass = newPasswordController.text.trim();
                if (current.isEmpty || newPass.isEmpty) {
                  CustomSnackbar.show(context, message: 'Completa ambos campos', type: SnackbarType.warning);
                  return;
                }
                
                final auth = context.read<AuthController>();
                Navigator.pop(context); // close dialog first
                
                final success = await auth.changePassword(current, newPass);
                if (mounted) {
                  if (success) {
                    CustomSnackbar.show(this.context, message: 'Contraseña actualizada exitosamente', type: SnackbarType.success);
                  } else {
                    CustomSnackbar.show(this.context, message: 'La contraseña actual es incorrecta', type: SnackbarType.error);
                  }
                }
              },
              child: Text('Guardar', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Política de Privacidad', style: GoogleFonts.outfit(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Text(
            'En SmartAcademy valoramos la privacidad y confidencialidad de tu información académica.\n\nTodos los datos personales, asistencias y calificaciones son almacenados en infraestructura cifrada y segura con acceso basado en roles.\n\nNo compartimos información con terceros sin consentimiento explícito.',
            style: GoogleFonts.outfit(color: AppTheme.textSecondary, height: 1.5, fontSize: 14),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text('Entendido', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
