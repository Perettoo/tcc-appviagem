// Enum para o tipo de usuário
enum TipoUsuario { carona, motorista, ambos }

class User {
  String name;
  String email;
  String password;
  TipoUsuario tipo;

  User({
    required this.name,
    required this.email,
    required this.password,
    required this.tipo,
  });
}
