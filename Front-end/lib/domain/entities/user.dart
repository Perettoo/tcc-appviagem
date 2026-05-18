enum TipoUsuario { carona, motorista, ambos }

class User {
  final String name;
  final String email;
  final String password;
  final TipoUsuario tipo;

  const User({
    required this.name,
    required this.email,
    required this.password,
    required this.tipo,
  });
}
