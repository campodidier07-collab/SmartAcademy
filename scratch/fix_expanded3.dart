import 'dart:io';

void main() {
  final dir = Directory('c:/src/academia/lib/screens');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  
  int fixedCount = 0;
  
  for (final file in files) {
    var content = file.readAsStringSync();
    final original = content;
    
    // Fix CustomHeader
    content = content.replaceAllMapped(RegExp(r'const Text\(\s*title:'), (match) => 'const CustomHeader(\n              title:');
    
    // Fix Center/Expanded
    content = content.replaceAllMapped(RegExp(r'const Text\(\s*child:'), (match) => 'const Center(\n              child:');
    
    // Fix padding
    content = content.replaceAllMapped(RegExp(r'const Text\(\s*padding:'), (match) => 'const Padding(\n              padding:');
    
    if (content != original) {
      file.writeAsStringSync(content);
      fixedCount++;
    }
  }
  print('Fixed $fixedCount files');
}
