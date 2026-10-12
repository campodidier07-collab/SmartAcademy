import 'dart:io';

void main() {
  final dir = Directory('c:/src/academia/lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  
  int fixedCount = 0;
  
  for (final file in files) {
    var content = file.readAsStringSync();
    final original = content;
    
    // We are looking for "const Expanded(" that was mistakenly placed.
    // We will do a regex to capture "const Expanded(" and the contents inside.
    // Wait, regex for balanced parentheses is hard. 
    // Let's just do line by line or simple replacements.
    
    // CustomHeader
    content = content.replaceAll(r'const Expanded(' + '\n' + r'              title:', 'const CustomHeader(\n              title:');
    content = content.replaceAll(r'const Expanded(' + '\n' + r'                title:', 'const CustomHeader(\n                title:');
    content = content.replaceAll(r'const Expanded(' + '\n' + r'              title: ', 'const CustomHeader(\n              title: ');
    
    // Text
    content = content.replaceAll(r'const Expanded(' + '\n' + r'                            "No tienes cuenta? ",', 'const Text(\n                            "No tienes cuenta? ",');
    content = content.replaceAll(r'const Expanded(' + '\n' + r'                            "Regístrate aquí",', 'const Text(\n                            "Regístrate aquí",');
    content = content.replaceAll(r'const Expanded(' + '\n' + r'                            "Ya tienes cuenta? ",', 'const Text(\n                            "Ya tienes cuenta? ",');
    content = content.replaceAll(r'const Expanded(' + '\n' + r'                            "Inicia sesión aquí",', 'const Text(\n                            "Inicia sesión aquí",');
    
    // Let's use a more general approach for Text. If next line has a quote " or '
    content = content.replaceAll(r'const Expanded(', 'const Text(');
    content = content.replaceAll(r'const Text(' + '\n' + r'              title:', 'const CustomHeader(\n              title:');
    content = content.replaceAll(r'const Text(' + '\n' + r'                title:', 'const CustomHeader(\n                title:');
    content = content.replaceAll(r'const Text(' + '\n' + r'              child:', 'const Expanded(\n              child:');
    content = content.replaceAll(r'const Text(' + '\n' + r'                        child:', 'const Expanded(\n                        child:');
    content = content.replaceAll(r'const Text(' + '\n' + r'                          child:', 'const Expanded(\n                          child:');
    content = content.replaceAll(r'const Text(' + '\n' + r'                            child:', 'const Expanded(\n                            child:');
    
    // Icon mismatch?
    // "error - A value of type 'IconData' can't be assigned to a parameter of type 'String'" -> it means we used `const Text(LucideIcons.mail)` instead of `const Icon(LucideIcons.mail)`
    content = content.replaceAll(r'const Text(LucideIcons', 'const Icon(LucideIcons');
    content = content.replaceAll(r'const Text(Icons', 'const Icon(Icons');
    
    if (content != original) {
      file.writeAsStringSync(content);
      fixedCount++;
    }
  }
  print('Fixed $fixedCount files');
}
