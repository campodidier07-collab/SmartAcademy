import 'dart:convert';
import 'package:crypto/crypto.dart';

void main() {
  print(sha256.convert(utf8.encode('admin123')).toString());
}
