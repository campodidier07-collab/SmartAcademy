import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/student_controller.dart';
import '../models/models.dart';

class StudentFormScreen extends StatefulWidget {
  final Student? student;

  const StudentFormScreen({super.key, this.student});

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _docController;
  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _correoController;
  late TextEditingController _telefonoController;
  late TextEditingController _programaController;
  late TextEditingController _semestreController;
  
  String _estado = 'Activo';

  @override
  void initState() {
    super.initState();
    _docController = TextEditingController(text: widget.student?.documento ?? '');
    _nombreController = TextEditingController(text: widget.student?.nombre ?? '');
    _apellidoController = TextEditingController(text: widget.student?.apellido ?? '');
    _correoController = TextEditingController(text: widget.student?.correo ?? '');
    _telefonoController = TextEditingController(text: widget.student?.telefono ?? '');
    _programaController = TextEditingController(text: widget.student?.programa ?? '');
    _semestreController = TextEditingController(text: widget.student?.semestre.toString() ?? '');
    _estado = widget.student?.estado ?? 'Activo';
  }

  @override
  void dispose() {
    _docController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _programaController.dispose();
    _semestreController.dispose();
    super.dispose();
  }

  void _saveStudent() async {
    if (_formKey.currentState!.validate()) {
      final newStudent = Student(
        id: widget.student?.id,
        documento: _docController.text,
        nombre: _nombreController.text,
        apellido: _apellidoController.text,
        correo: _correoController.text,
        telefono: _telefonoController.text,
        programa: _programaController.text,
        semestre: int.tryParse(_semestreController.text) ?? 1,
        estado: _estado,
      );

      final controller = context.read<StudentController>();
      if (widget.student == null) {
        await controller.addStudent(newStudent);
      } else {
        await controller.updateStudent(newStudent);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white),
                const SizedBox(width: 8),
                Text(widget.student == null 
                  ? 'Estudiante agregado exitosamente' 
                  : 'Estudiante actualizado exitosamente'),
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
        title: Text(widget.student == null ? 'Nuevo Estudiante' : 'Editar Estudiante'),
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
              Row(
                children: [
                  Expanded(child: _buildTextField(_nombreController, 'Nombres', Icons.person_outline)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(_apellidoController, 'Apellidos', Icons.person_outline)),
                ],
              ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
              const SizedBox(height: 16),
              _buildTextField(_correoController, 'Correo Electrónico', Icons.email_outlined, isEmail: true)
                .animate().fade(delay: 300.ms).slideY(begin: 0.1),
              
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 32),
              
              Text(
                'Información Académica',
                style: Theme.of(context).textTheme.titleLarge,
              ).animate().fade(delay: 400.ms).slideX(begin: -0.1),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(flex: 2, child: _buildTextField(_programaController, 'Programa', Icons.school_outlined)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(_semestreController, 'Semestre', Icons.format_list_numbered_outlined, isNumber: true)),
                ],
              ).animate().fade(delay: 500.ms).slideY(begin: 0.1),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _estado,
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  prefixIcon: Icon(Icons.toggle_on_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: 'Activo', child: Text('Activo')),
                  DropdownMenuItem(value: 'Inactivo', child: Text('Inactivo')),
                ],
                onChanged: (value) {
                  setState(() {
                    _estado = value!;
                  });
                },
              ).animate().fade(delay: 600.ms).slideY(begin: 0.1),
              
              const SizedBox(height: 48),
              FilledButton.icon(
                onPressed: _saveStudent,
                icon: const Icon(Icons.save_outlined),
                label: Text(widget.student == null ? 'Guardar Estudiante' : 'Actualizar Estudiante'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
              ).animate().fade(delay: 700.ms).scale(),
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
