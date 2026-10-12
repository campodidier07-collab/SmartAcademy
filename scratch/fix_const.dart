import 'dart:io';

void main() {
  final dir = Directory('c:/src/academia/lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  
  int fixedCount = 0;
  
  for (final file in files) {
    var content = file.readAsStringSync();
    final original = content;
    
    // Fix EdgeInsets
    content = content.replaceAll(r'$1.all', 'const EdgeInsets.all');
    content = content.replaceAll(r'$1.symmetric', 'const EdgeInsets.symmetric');
    content = content.replaceAll(r'$1.only', 'const EdgeInsets.only');
    content = content.replaceAll(r'$1.zero', 'EdgeInsets.zero'); // usually not const or already handled
    
    // Fix SizedBox
    content = content.replaceAll(r'$1(height:', 'const SizedBox(height:');
    content = content.replaceAll(r'$1(width:', 'const SizedBox(width:');
    content = content.replaceAll(r'$1()', 'const SizedBox()');
    
    // Fix Text
    content = content.replaceAll(r'$1(' + "'", "const Text('");
    content = content.replaceAll(r'$1("', 'const Text("');
    content = content.replaceAll(r'child: $1(', 'child: const Text(');
    content = content.replaceAll(r'title: $1(', 'title: const Text(');
    content = content.replaceAll(r'subtitle: $1(', 'subtitle: const Text(');
    content = content.replaceAll(r'label: $1(', 'label: const Text(');
    
    // Fix Icon
    content = content.replaceAll(r'$1(Icons.', 'const Icon(Icons.');
    content = content.replaceAll(r'$1(LucideIcons.', 'const Icon(LucideIcons.');
    
    // Fix TextStyle
    content = content.replaceAll(r'style: $1(', 'style: const TextStyle(');
    content = content.replaceAll(r'labelStyle: $1(', 'labelStyle: const TextStyle(');
    content = content.replaceAll(r'hintStyle: $1(', 'hintStyle: const TextStyle(');
    
    // Fix Padding
    content = content.replaceAll(r'padding: $1(', 'padding: const EdgeInsets('); 
    
    // Fix remaining
    content = content.replaceAll(r'$1.shrink()', 'const SizedBox.shrink()');
    content = content.replaceAll(r'$1({', 'const CustomHeader({');
    content = content.replaceAll(r'border: $1(bottom:', 'border: const Border(bottom:');
    content = content.replaceAll(r'border: $1(top:', 'border: const Border(top:');
    content = content.replaceAll(r'gradient: $1(', 'gradient: const LinearGradient(');
    content = content.replaceAll(r'$1Radius.vertical', 'BorderRadius.vertical');
    content = content.replaceAll(r'$1.fromLTRB', 'const EdgeInsets.fromLTRB');
    content = content.replaceAll(r'$1(child: CircularProgressIndicator', 'const Center(child: CircularProgressIndicator');
    content = content.replaceAll(r'side: $1(color:', 'side: const BorderSide(color:');
    content = content.replaceAll(r'decoration: $1(', 'decoration: const BoxDecoration(');
    content = content.replaceAll(r'$1InputType', 'TextInputType');
    
    // Check remaining $1(
    content = content.replaceAll(r'            $1(', '            const Expanded(');
    content = content.replaceAll(r'                        $1(', '                        const Expanded(');
    content = content.replaceAll(r'                  $1(', '                  const Expanded(');
    content = content.replaceAll(r'                          $1(', '                          const Expanded(');
    content = content.replaceAll(r'                            $1(', '                            const Expanded(');
    content = content.replaceAll(r'                      $1(', '                      const Expanded(');
    content = content.replaceAll(r'                    $1(', '                    const Expanded(');
    content = content.replaceAll(r'                                        $1(', '                                        const Expanded(');
    content = content.replaceAll(r'                                          $1(', '                                          const Expanded(');

    if (content.contains(r'$1')) {
      print('Warning: Still contains \$1 in ${file.path}');
    }
    
    if (content != original) {
      file.writeAsStringSync(content);
      fixedCount++;
    }
  }
  print('Fixed $fixedCount files');
}
