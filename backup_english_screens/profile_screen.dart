import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import 'login_screen.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.neonBlue.withOpacity(0.1),
                    ),
                  ),
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.neonBlue.withOpacity(0.2),
                    child: const Icon(Icons.person, size: 40, color: AppTheme.neonBlue),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.nombre ?? 'Usuario',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              user?.correo ?? 'correo@ejemplo.com',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.neonBlueDark.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                user?.rol ?? 'Rol',
                style: const TextStyle(color: AppTheme.neonBlue, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 48),
            
            _buildListTile(context, Icons.person_outline, 'Mis datos'),
            _buildListTile(context, Icons.settings_outlined, 'Configuración'),
            _buildListTile(context, Icons.help_outline, 'Ayuda y soporte'),
            
            const SizedBox(height: 24),
            
            Card(
              color: AppTheme.surfaceDark,
              child: ListTile(
                leading: const Icon(Icons.logout, color: AppTheme.errorColor),
                title: const Text('Cerrar sesión', style: TextStyle(color: AppTheme.errorColor)),
                trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                onTap: () async {
                  await context.read<AuthController>().logout();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context, IconData icon, String title) {
    return Card(
      color: AppTheme.surfaceDark,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.white70),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
        onTap: () {},
      ),
    );
  }
}
