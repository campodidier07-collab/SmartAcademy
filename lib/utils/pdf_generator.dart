import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/models.dart';

class PdfGenerator {
  static Future<void> generateStudentReport(Student student, List<Grade> grades, List<Course> courses) async {
    final pdf = pw.Document();
    
    // Cargar logo
    final imageBytes = await rootBundle.load('lib/assets/imagenes/logo.png');
    final logoImage = pw.MemoryImage(imageBytes.buffer.asUint8List());

    final primaryColor = PdfColor.fromHex('3D5CFF');
    final secondaryColor = PdfColor.fromHex('7B61FF');
    final darkColor = PdfColor.fromHex('13172A');

    // Mapear cursos por ID para acceso rápido
    final courseMap = {for (var c in courses) c.id: c};

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header con nuevo diseño
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: primaryColor,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'BOLETÍN ACADÉMICO',
                          style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 24,
                              fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'SmartAcademy',
                          style: const pw.TextStyle(
                              color: PdfColors.white, fontSize: 16),
                        ),
                      ],
                    ),
                    pw.Image(logoImage, width: 50, height: 50),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),

              // Student Info
              pw.Text('Información del Estudiante',
                  style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: darkColor)),
              pw.Divider(color: secondaryColor),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _infoColumn('Nombre:', '${student.nombre} ${student.apellido}'),
                  _infoColumn('Documento:', student.documento),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _infoColumn('Programa:', student.programa),
                  _infoColumn('Semestre:', student.semestre.toString()),
                ],
              ),
              pw.SizedBox(height: 30),

              // Grades Table
              pw.Text('Calificaciones',
                  style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: darkColor)),
              pw.Divider(color: secondaryColor),
              pw.SizedBox(height: 10),
              pw.TableHelper.fromTextArray(
                context: context,
                border: const pw.TableBorder(
                  horizontalInside: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                  bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                ),
                headerDecoration: pw.BoxDecoration(color: secondaryColor),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerHeight: 30,
                cellHeight: 25,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.center,
                  2: pw.Alignment.center,
                  3: pw.Alignment.center,
                  4: pw.Alignment.center,
                  5: pw.Alignment.center,
                },
                headers: ['Curso', 'P1', 'P2', 'P3', 'Final', 'Definitiva'],
                data: grades.map((grade) {
                  final courseName = courseMap[grade.cursoId]?.nombre ?? 'Desconocido';
                  return [
                    courseName,
                    grade.parcial1?.toStringAsFixed(1) ?? '-',
                    grade.parcial2?.toStringAsFixed(1) ?? '-',
                    grade.parcial3?.toStringAsFixed(1) ?? '-',
                    grade.trabajoFinal?.toStringAsFixed(1) ?? '-',
                    grade.definitiva?.toStringAsFixed(1) ?? '-',
                  ];
                }).toList(),
              ),
              pw.Spacer(),
              pw.Center(
                child: pw.Text(
                  'Este documento es generado automáticamente por SmartAcademy y no requiere firma.',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'boletin_${student.documento}.pdf',
    );
  }

  static Future<void> generateCourseReport(Course course, List<Student> students, Map<int, Grade> gradesMap) async {
    final pdf = pw.Document();

    final imageBytes = await rootBundle.load('lib/assets/imagenes/logo.png');
    final logoImage = pw.MemoryImage(imageBytes.buffer.asUint8List());

    final primaryColor = PdfColor.fromHex('3D5CFF');
    final secondaryColor = PdfColor.fromHex('7B61FF');
    final darkColor = PdfColor.fromHex('13172A');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // Header
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: primaryColor,
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'REPORTE DE CALIFICACIONES',
                        style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'Curso: ${course.nombre}',
                        style: const pw.TextStyle(
                            color: PdfColors.white, fontSize: 16),
                      ),
                    ],
                  ),
                  pw.Image(logoImage, width: 40, height: 40),
                ],
              ),
            ),
            pw.SizedBox(height: 30),

            // Course Info
            pw.Text('Detalles del Curso',
                style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: darkColor)),
            pw.Divider(color: secondaryColor),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _infoColumn('Código:', course.codigo),
                _infoColumn('Créditos:', course.creditos.toString()),
              ],
            ),
            pw.SizedBox(height: 30),

            // Students Table
            pw.Text('Listado de Estudiantes',
                style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: darkColor)),
            pw.Divider(color: secondaryColor),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              context: context,
              border: const pw.TableBorder(
                horizontalInside: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
              ),
              headerDecoration: pw.BoxDecoration(color: secondaryColor),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerHeight: 30,
              cellHeight: 25,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.center,
                2: pw.Alignment.center,
                3: pw.Alignment.center,
                4: pw.Alignment.center,
                5: pw.Alignment.center,
                6: pw.Alignment.center,
              },
              headers: ['Estudiante', 'Doc.', 'P1', 'P2', 'P3', 'Final', 'Def.'],
              data: students.map((student) {
                final grade = gradesMap[student.id];
                return [
                  '${student.nombre} ${student.apellido}',
                  student.documento,
                  grade?.parcial1?.toStringAsFixed(1) ?? '-',
                  grade?.parcial2?.toStringAsFixed(1) ?? '-',
                  grade?.parcial3?.toStringAsFixed(1) ?? '-',
                  grade?.trabajoFinal?.toStringAsFixed(1) ?? '-',
                  grade?.definitiva?.toStringAsFixed(1) ?? '-',
                ];
              }).toList(),
            ),

            pw.SizedBox(height: 40),
            pw.Center(
              child: pw.Text(
                'Este documento es generado automáticamente por SmartAcademy y no requiere firma.',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'reporte_curso_${course.codigo}.pdf',
    );
  }

  static pw.Widget _infoColumn(String label, String value) {
    return pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  fontSize: 12, color: PdfColors.grey700, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(value, style: const pw.TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
