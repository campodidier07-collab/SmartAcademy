import 'dart:io';

void main() {
  final dir = Directory('c:/src/academia/lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  
  int fixedCount = 0;
  
  for (final file in files) {
    var content = file.readAsStringSync();
    final original = content;
    
    // Any const Text( that is followed by spaces/newlines and then title: is a CustomHeader
    content = content.replaceAllMapped(RegExp(r'const Text\(\s*title:'), (match) => 'const CustomHeader(\n              title:');
    
    // Any const Text( that is followed by padding: is probably Padding
    content = content.replaceAllMapped(RegExp(r'const Text\(\s*padding:'), (match) => 'const Padding(\n              padding:');
    
    // Fix specific icon issues 
    content = content.replaceAll(r'const Text(size', 'const Icon(size');
    content = content.replaceAll(r'const Text(color', 'const Icon(color');

    if (content != original) {
      file.writeAsStringSync(content);
      fixedCount++;
    }
  }
  print('Fixed $fixedCount files');
}
