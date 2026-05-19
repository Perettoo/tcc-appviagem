enum TipoUsuario { passageiro, motorista, ambos }

class User {
  final String name;
  final String email;
  final String password;
  final String cpf;
  final DateTime dataNascimento;
  final TipoUsuario tipo;

  const User({
    required this.name,
    required this.email,
    required this.password,
    required this.cpf,
    required this.dataNascimento,
    required this.tipo,
  });
}
