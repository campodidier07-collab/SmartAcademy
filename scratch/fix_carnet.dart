import 'dart:io';

void main() {
  final file = File('c:/src/academia/lib/widgets/carnet_digital.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('widget.student.nombre', 'widget.nombre');
  content = content.replaceAll('widget.student.apellido', "''"); // We don't have apellido in User, so just empty string
  content = content.replaceAll('widget.student.documento', 'widget.documento');
  content = content.replaceAll('widget.student.programa', 'widget.programa');
  content = content.replaceAll('widget.student.telefono', 'widget.telefono');
  content = content.replaceAll('widget.student.id', "'USR'");
  file.writeAsStringSync(content);
}
