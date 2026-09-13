import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/teacher_controller.dart';
import '../models/models.dart';

class TeacherFormScreen extends StatefulWidget {
  final Teacher? teacher;

  const TeacherFormScreen({super.key, this.teacher});

  @override
  State<TeacherFormScreen> createState() => _TeacherFormScreenState();
}

class _TeacherFormScreenState extends State<TeacherFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _docController;
  late TextEditingController _nombreController;
  late TextEditingController _correoController;
  late TextEditingController _telefonoController;
  late TextEditingController _especialidadController;

  @override
  void initState() {
    super.initState();
    _docController = TextEditingController(text: widget.teacher?.documento ?? '');
    _nombreController = TextEditingController(text: widget.teacher?.nombre ?? '');
    _correoController = TextEditingController(text: widget.teacher?.correo ?? '');
    _telefonoController = TextEditingController(text: widget.teacher?.telefono ?? '');
    _especialidadController = TextEditingController(text: widget.teacher?.especialidad ?? '');
  }

  @override
  void dispose() {
    _docController.dispose();
    _nombreController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _especialidadController.dispose();
    super.dispose();
  }

  void _saveTeacher() async {
    if (_formKey.currentState!.validate()) {
      final newTeacher = Teacher(
        id: widget.teacher?.id,
        documento: _docController.text,
        nombre: _nombreController.text,
        correo: _correoController.text,
        telefono: _telefonoController.text,
        especialidad: _especialidadController.text,
      );

      final controller = context.read<TeacherController>();
      if (widget.teacher == null) {
        await controller.addTeacher(newTeacher);
      } else {
        await controller.updateTeacher(newTeacher);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white),
                const SizedBox(width: 8),
                Text(widget.teacher == null 
                  ? 'Profesor agregado exitosamente' 
                  : 'Profesor actualizado exitosamente'),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.teacher == null ? 'Nuevo Profesor' : 'Editar Profesor'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Información Personal',
                style: Theme.of(context).textTheme.titleLarge,
              ).animate().fade().slideX(begin: -0.1),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField(_docController, 'Documento', Icons.badge_outlined)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(_telefonoController, 'Teléfono', Icons.phone_outlined, isNumber: true)),
                ],
              ).animate().fade(delay: 100.ms).slideY(begin: 0.1),
              const SizedBox(height: 16),
              _buildTextField(_nombreController, 'Nombre Completo', Icons.person_outline)
                .animate().fade(delay: 200.ms).slideY(begin: 0.1),
              const SizedBox(height: 16),
              _buildTextField(_correoController, 'Correo Electrónico', Icons.email_outlined, isEmail: true)
                .animate().fade(delay: 300.ms).slideY(begin: 0.1),
              
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 32),
              
              Text(
                'Información Profesional',
                style: Theme.of(context).textTheme.titleLarge,
              ).animate().fade(delay: 400.ms).slideX(begin: -0.1),
              const SizedBox(height: 16),
              _buildTextField(_especialidadController, 'Especialidad', Icons.workspace_premium_outlined)
                .animate().fade(delay: 500.ms).slideY(begin: 0.1),
              
              const SizedBox(height: 48),
              FilledButton.icon(
                onPressed: _saveTeacher,
                icon: const Icon(Icons.save_outlined),
                label: Text(widget.teacher == null ? 'Guardar Profesor' : 'Actualizar Profesor'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
              ).animate().fade(delay: 600.ms).scale(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, 
    String label, 
    IconData icon, 
    {bool isEmail = false, bool isNumber = false}
  ) {
    return TextFormField(
      controller: controller,
      keyboardType: isEmail ? TextInputType.emailAddress : (isNumber ? TextInputType.number : TextInputType.text),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Requerido';
        }
        if (isEmail && !value.contains('@')) {
          return 'Correo inválido';
        }
        return null;
      },
    );
  }
}
