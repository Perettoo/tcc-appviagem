enum TipoUsuario { passageiro, motorista, ambos }

extension TipoUsuarioLabel on TipoUsuario {
  String get label => switch (this) {
        TipoUsuario.passageiro => 'Passageiro',
        TipoUsuario.motorista => 'Motorista',
        TipoUsuario.ambos => 'Passageiro e Motorista',
      };
}

/// Identidade do usuário autenticado. NÃO carrega senha — isso é credencial,
/// não dado de perfil; trafega só nas chamadas de auth.
class User {
  final String name;
  final String email;
  final DateTime dataNascimento;
  final TipoUsuario tipo;

  const User({
    required this.name,
    required this.email,
    required this.dataNascimento,
    required this.tipo,
  });
}
