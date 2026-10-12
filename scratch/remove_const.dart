import 'dart:io';

void main() {
  final dir = Directory('c:/src/academia/lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart') && !f.path.contains('app_theme.dart'));
  
  int removedCount = 0;
  
  for (final file in files) {
    var content = file.readAsStringSync();
    
    // We want to replace 'const ' with '' when it's part of a Widget or TextStyle 
    // that eventually uses AppTheme. A simple regex to remove all 'const ' before known classes:
    // This is a bit aggressive but we can format afterwards.
    
    // Remove 'const ' before TextStyle, Icon, Text, Border, BoxBorder, Color
    final regex = RegExp(r'const\s+(TextStyle|Icon|Text|BorderSide|Border|EdgeInsets|EdgeInsetsGeometry|SizedBox|Row|Column|Center|Padding|CustomHeader|_EventItem|_HeroStat|_QuickActionButton|_TimelineItem|BoxDecoration|LinearGradient|ColorFilter)');
    
    if (regex.hasMatch(content)) {
      final newContent = content.replaceAll(regex, r'$1');
      if (newContent != content) {
        file.writeAsStringSync(newContent);
        removedCount++;
      }
    }
    
    // Also catch any simple 'const ' before AppTheme usages in arrays
    final regex2 = RegExp(r'const\s+\[(.*?)\]', dotAll: true);
    if (regex2.hasMatch(content)) {
       // just remove 'const' from arrays
       final newContent2 = content.replaceAll(RegExp(r'const\s+\['), '[');
       file.writeAsStringSync(newContent2);
    }
  }
  print('Removed const from $removedCount files');
}
