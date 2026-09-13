class User {
  final int? id;
  final String nombre;
  final String correo;
  final String contrasena;
  final String rol;

  User({
    this.id,
    required this.nombre,
    required this.correo,
    required this.contrasena,
    required this.rol,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'correo': correo,
      'contrasena': contrasena,
      'rol': rol,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      nombre: map['nombre'],
      correo: map['correo'],
      contrasena: map['contrasena'],
      rol: map['rol'],
    );
  }
}

class Student {
  final int? id;
  final String documento;
  final String nombre;
  final String apellido;
  final String correo;
  final String telefono;
  final int semestre;
  final String programa;
  final String estado;

  Student({
    this.id,
    required this.documento,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.telefono,
    required this.semestre,
    required this.programa,
    this.estado = 'Activo',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'documento': documento,
      'nombre': nombre,
      'apellido': apellido,
      'correo': correo,
      'telefono': telefono,
      'semestre': semestre,
      'programa': programa,
      'estado': estado,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      documento: map['documento'],
      nombre: map['nombre'],
      apellido: map['apellido'],
      correo: map['correo'],
      telefono: map['telefono'],
      semestre: map['semestre'],
      programa: map['programa'],
      estado: map['estado'] ?? 'Activo',
    );
  }
}

class Teacher {
  final int? id;
  final String documento;
  final String nombre;
  final String especialidad;
  final String correo;
  final String telefono;

  Teacher({
    this.id,
    required this.documento,
    required this.nombre,
    required this.especialidad,
    required this.correo,
    this.telefono = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'documento': documento,
      'nombre': nombre,
      'especialidad': especialidad,
      'correo': correo,
      'telefono': telefono,
    };
  }

  factory Teacher.fromMap(Map<String, dynamic> map) {
    return Teacher(
      id: map['id'],
      documento: map['documento'],
      nombre: map['nombre'],
      especialidad: map['especialidad'],
      correo: map['correo'],
      telefono: map['telefono'] ?? '',
    );
  }
}

class Course {
  final int? id;
  final String codigo;
  final String nombre;
  final String descripcion;
  final int creditos;
  final int profesorId;

  Course({
    this.id,
    required this.codigo,
    required this.nombre,
    this.descripcion = '',
    required this.creditos,
    required this.profesorId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'codigo': codigo,
      'nombre': nombre,
      'descripcion': descripcion,
      'creditos': creditos,
      'profesor_id': profesorId,
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'],
      codigo: map['codigo'],
      nombre: map['nombre'],
      descripcion: map['descripcion'] ?? '',
      creditos: map['creditos'],
      profesorId: map['profesor_id'],
    );
  }
}

class Grade {
  final int? id;
  final int estudianteId;
  final int cursoId;
  final double? parcial1;
  final double? parcial2;
  final double? parcial3;
  final double? trabajoFinal;
  final double? definitiva;

  Grade({
    this.id,
    required this.estudianteId,
    required this.cursoId,
    this.parcial1,
    this.parcial2,
    this.parcial3,
    this.trabajoFinal,
    this.definitiva,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'estudiante_id': estudianteId,
      'curso_id': cursoId,
      'parcial1': parcial1,
      'parcial2': parcial2,
      'parcial3': parcial3,
      'trabajo_final': trabajoFinal,
      'definitiva': definitiva,
    };
  }

  factory Grade.fromMap(Map<String, dynamic> map) {
    return Grade(
      id: map['id'],
      estudianteId: map['estudiante_id'],
      cursoId: map['curso_id'],
      parcial1: map['parcial1'],
      parcial2: map['parcial2'],
      parcial3: map['parcial3'],
      trabajoFinal: map['trabajo_final'],
      definitiva: map['definitiva'],
    );
  }
}

class Attendance {
  final int? id;
  final int estudianteId;
  final int cursoId;
  final String fecha;
  final String estado;

  Attendance({
    this.id,
    required this.estudianteId,
    required this.cursoId,
    required this.fecha,
    required this.estado,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'estudiante_id': estudianteId,
      'curso_id': cursoId,
      'fecha': fecha,
      'estado': estado,
    };
  }

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'],
      estudianteId: map['estudiante_id'],
      cursoId: map['curso_id'],
      fecha: map['fecha'],
      estado: map['estado'],
    );
  }
}

class Schedule {
  final int? id;
  final int cursoId;
  final String dia;
  final String horaInicio;
  final String horaFin;
  final String salon;

  Schedule({
    this.id,
    required this.cursoId,
    required this.dia,
    required this.horaInicio,
    required this.horaFin,
    required this.salon,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'curso_id': cursoId,
      'dia': dia,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'salon': salon,
    };
  }

  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map['id'],
      cursoId: map['curso_id'],
      dia: map['dia'],
      horaInicio: map['hora_inicio'],
      horaFin: map['hora_fin'],
      salon: map['salon'],
    );
  }
}
