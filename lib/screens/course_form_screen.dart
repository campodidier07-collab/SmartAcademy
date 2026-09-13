import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/course_controller.dart';
import '../controllers/teacher_controller.dart';
import '../models/models.dart';

class CourseFormScreen extends StatefulWidget {
  final Course? course;

  const CourseFormScreen({super.key, this.course});

  @override
  State<CourseFormScreen> createState() => _CourseFormScreenState();
}

class _CourseFormScreenState extends State<CourseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _codigoController;
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _creditosController;
  
  int? _profesorId;

  @override
  void initState() {
    super.initState();
    _codigoController = TextEditingController(text: widget.course?.codigo ?? '');
    _nombreController = TextEditingController(text: widget.course?.nombre ?? '');
    _descripcionController = TextEditingController(text: widget.course?.descripcion ?? '');
    _creditosController = TextEditingController(text: widget.course?.creditos.toString() ?? '');
    _profesorId = widget.course?.profesorId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeacherController>().loadTeachers();
    });
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    _descripcionController.dispose();
    _creditosController.dispose();
    super.dispose();
  }

  void _saveCourse() async {
    if (_formKey.currentState!.validate() && _profesorId != null) {
      final newCourse = Course(
        id: widget.course?.id,
        codigo: _codigoController.text,
        nombre: _nombreController.text,
        descripcion: _descripcionController.text,
        creditos: int.tryParse(_creditosController.text) ?? 3,
        profesorId: _profesorId!,
      );

      final controller = context.read<CourseController>();
      if (widget.course == null) {
        await controller.addCourse(newCourse);
      } else {
        await controller.updateCourse(newCourse);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white),
                const SizedBox(width: 8),
                Text(widget.course == null 
                  ? 'Curso agregado exitosamente' 
                  : 'Curso actualizado exitosamente'),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } else if (_profesorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor selecciona un profesor'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course == null ? 'Nuevo Curso' : 'Editar Curso'),
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
                'Información del Curso',
                style: Theme.of(context).textTheme.titleLarge,
              ).animate().fade().slideX(begin: -0.1),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(flex: 2, child: _buildTextField(_codigoController, 'Código', Icons.qr_code_outlined)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(_creditosController, 'Créditos', Icons.credit_score_outlined, isNumber: true)),
                ],
              ).animate().fade(delay: 100.ms).slideY(begin: 0.1),
              const SizedBox(height: 16),
              _buildTextField(_nombreController, 'Nombre del Curso', Icons.menu_book_outlined)
                .animate().fade(delay: 200.ms).slideY(begin: 0.1),
              const SizedBox(height: 16),
              _buildTextField(_descripcionController, 'Descripción', Icons.description_outlined, maxLines: 3)
                .animate().fade(delay: 300.ms).slideY(begin: 0.1),
              
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 32),
              
              Text(
                'Asignación Docente',
                style: Theme.of(context).textTheme.titleLarge,
              ).animate().fade(delay: 400.ms).slideX(begin: -0.1),
              const SizedBox(height: 16),
              
              Consumer<TeacherController>(
                builder: (context, teacherController, child) {
                  if (teacherController.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return DropdownButtonFormField<int>(
                    value: _profesorId,
                    decoration: const InputDecoration(
                      labelText: 'Profesor Asignado',
                      prefixIcon: Icon(Icons.co_present_outlined),
                    ),
                    items: teacherController.teachers.map((teacher) {
                      return DropdownMenuItem(
                        value: teacher.id,
                        child: Text('${teacher.nombre} (${teacher.especialidad})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _profesorId = value;
                      });
                    },
                  );
                },
              ).animate().fade(delay: 500.ms).slideY(begin: 0.1),
              
              const SizedBox(height: 48),
              FilledButton.icon(
                onPressed: _saveCourse,
                icon: const Icon(Icons.save_outlined),
                label: Text(widget.course == null ? 'Guardar Curso' : 'Actualizar Curso'),
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
    {bool isNumber = false, int maxLines = 1}
  ) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: maxLines == 1 ? Icon(icon) : Padding(padding: const EdgeInsets.only(bottom: 48), child: Icon(icon)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Requerido';
        }
        return null;
      },
    );
  }
}
