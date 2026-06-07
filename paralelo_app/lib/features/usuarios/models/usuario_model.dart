class Usuario {
  final int id;
  final String nombre;
  final String email;
  final String rol;
  final String? createdAt;

  Usuario({required this.id, required this.nombre, required this.email, required this.rol, this.createdAt});

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
    id:        json['id'],
    nombre:    json['nombre'] ?? '',
    email:     json['email'] ?? '',
    rol:       json['rol'] ?? '',
    createdAt: json['created_at'],
  );

  Map<String, dynamic> toJson() => {'nombre': nombre, 'email': email, 'rol': rol};
}
