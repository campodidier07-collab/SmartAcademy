import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('smartacademy.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const realTypeNullable = 'REAL';
    const textTypeNullable = 'TEXT';

    await db.execute('''
CREATE TABLE usuarios (
  id $idType,
  nombre $textType,
  correo $textType,
  contrasena $textType,
  rol $textType
)
''');

    await db.execute('''
CREATE TABLE estudiantes (
  id $idType,
  documento $textType,
  nombre $textType,
  apellido $textType,
  correo $textType,
  telefono $textType,
  semestre $integerType,
  programa $textType,
  estado $textTypeNullable DEFAULT 'Activo'
)
''');

    await db.execute('''
CREATE TABLE profesores (
  id $idType,
  documento $textType,
  nombre $textType,
  especialidad $textType,
  correo $textType,
  telefono $textTypeNullable DEFAULT ''
)
''');

    await db.execute('''
CREATE TABLE cursos (
  id $idType,
  codigo $textType,
  nombre $textType,
  descripcion $textTypeNullable DEFAULT '',
  creditos $integerType,
  profesor_id $integerType,
  FOREIGN KEY (profesor_id) REFERENCES profesores (id)
)
''');

    await db.execute('''
CREATE TABLE notas (
  id $idType,
  estudiante_id $integerType,
  curso_id $integerType,
  parcial1 $realTypeNullable,
  parcial2 $realTypeNullable,
  parcial3 $realTypeNullable,
  trabajo_final $realTypeNullable,
  definitiva $realTypeNullable,
  FOREIGN KEY (estudiante_id) REFERENCES estudiantes (id),
  FOREIGN KEY (curso_id) REFERENCES cursos (id)
)
''');

    await db.execute('''
CREATE TABLE asistencias (
  id $idType,
  estudiante_id $integerType,
  curso_id $integerType,
  fecha $textType,
  estado $textType,
  FOREIGN KEY (estudiante_id) REFERENCES estudiantes (id),
  FOREIGN KEY (curso_id) REFERENCES cursos (id)
)
''');

    await db.execute('''
CREATE TABLE horarios (
  id $idType,
  curso_id $integerType,
  dia $textType,
  hora_inicio $textType,
  hora_fin $textType,
  salon $textType,
  FOREIGN KEY (curso_id) REFERENCES cursos (id)
)
''');

    // Insertar un administrador por defecto
    await db.insert('usuarios', {
      'nombre': 'Administrador',
      'correo': 'admin@smartacademy.com',
      'contrasena': 'admin123',
      'rol': 'Administrador',
    });
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE estudiantes ADD COLUMN estado TEXT DEFAULT 'Activo'");
      await db.execute("ALTER TABLE profesores ADD COLUMN telefono TEXT DEFAULT ''");
      await db.execute("ALTER TABLE cursos ADD COLUMN descripcion TEXT DEFAULT ''");
    }
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
