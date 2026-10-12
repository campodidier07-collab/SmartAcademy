import 'dart:io';

void main() {
  final file = File('c:/src/academia/lib/screens/formulario_estudiantes.dart');
  var content = file.readAsStringSync();

  // Insert AuthController import if missing
  if (!content.contains("import '../controllers/controlador_auth.dart';")) {
    content = content.replaceAll(
      "import '../controllers/controlador_estudiantes.dart';", 
      "import '../controllers/controlador_estudiantes.dart';\nimport '../controllers/controlador_auth.dart';"
    );
  }

  // Insert _passwordController
  if (!content.contains("late TextEditingController _passwordController;")) {
    content = content.replaceAll(
      "late TextEditingController _semestreController;", 
      "late TextEditingController _semestreController;\n  late TextEditingController _passwordController;"
    );
  }

  // Initialize _passwordController
  if (!content.contains("_passwordController = TextEditingController();")) {
    content = content.replaceAll(
      "_semestreController = TextEditingController(text: widget.student?.semestre.toString() ?? '');",
      "_semestreController = TextEditingController(text: widget.student?.semestre.toString() ?? '');\n    _passwordController = TextEditingController();"
    );
  }

  // Dispose _passwordController
  if (!content.contains("_passwordController.dispose();")) {
    content = content.replaceAll(
      "_semestreController.dispose();",
      "_semestreController.dispose();\n    _passwordController.dispose();"
    );
  }

  // Handle _saveStudent
  if (!content.contains("final authCtrl = context.read<AuthController>();")) {
    content = content.replaceAll(
      "final controller = context.read<StudentController>();\n      if (widget.student == null) {",
      """final controller = context.read<StudentController>();
      final authCtrl = context.read<AuthController>();
      
      if (widget.student == null) {
        final userCreated = await authCtrl.registerUserWithoutLogin(
          _nombreController.text, 
          _correoController.text, 
          _passwordController.text, 
          'Estudiante'
        );
        if (!userCreated) {
          if (mounted) CustomSnackbar.show(context, message: 'El correo ya está en uso', type: SnackbarType.error);
          return;
        }"""
    );
  }

  // Build the field in UI
  if (!content.contains("_buildPasswordField()")) {
    content = content.replaceAll(
      "_buildEmailField().animate().fade(delay: 300.ms).slideY(begin: 0.1),",
      "_buildEmailField().animate().fade(delay: 300.ms).slideY(begin: 0.1),\n                            if (widget.student == null) ...[\n                              const SizedBox(height: 16),\n                              _buildPasswordField().animate().fade(delay: 350.ms).slideY(begin: 0.1),\n                            ],"
    );
  }

  // Add the method at the end
  if (!content.contains("Widget _buildPasswordField()")) {
    content = content.replaceAll(
      """  Widget _buildEmailField() => CustomTextField(
    controller: _correoController, 
    label: 'Correo Electrónico', 
    icon: LucideIcons.mail, 
    keyboardType: TextInputType.emailAddress,
    validator: (val) {
      if (val == null || val.isEmpty) return 'Requerido';
      if (!val.contains('@')) return 'Correo inválido';
      return null;
    },
  );""",
      """  Widget _buildEmailField() => CustomTextField(
    controller: _correoController, 
    label: 'Correo Electrónico', 
    icon: LucideIcons.mail, 
    keyboardType: TextInputType.emailAddress,
    validator: (val) {
      if (val == null || val.isEmpty) return 'Requerido';
      if (!val.contains('@')) return 'Correo inválido';
      return null;
    },
  );
  
  Widget _buildPasswordField() => CustomTextField(
    controller: _passwordController,
    label: 'Contraseña de Acceso',
    icon: LucideIcons.key,
    obscureText: true,
    validator: (val) {
      if (widget.student == null && (val == null || val.isEmpty)) return 'La contraseña es requerida';
      if (val != null && val.isNotEmpty && val.length < 6) return 'Mínimo 6 caracteres';
      return null;
    },
  );"""
    );
  }

  file.writeAsStringSync(content);
}
