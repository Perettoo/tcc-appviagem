/// Ciclo de vida de uma carona. Hoje só criamos `pendente`; os demais já
/// existem para o fluxo futuro de aceitar/concluir.
enum StatusCarona { pendente, aceita, concluida, cancelada }

extension StatusCaronaLabel on StatusCarona {
  String get label => switch (this) {
        StatusCarona.pendente => 'Pendente',
        StatusCarona.aceita => 'Aceita',
        StatusCarona.concluida => 'Concluída',
        StatusCarona.cancelada => 'Cancelada',
      };
}

/// Resumo de uma carona embutido numa mensagem do tipo CARONA.
/// `idMotorista`/`motoristaNome` ficam nulos enquanto ninguém aceitou.
class CaronaResumo {
  final int idCarona;
  final StatusCarona status;
  final int? idMotorista;
  final String? motoristaNome;
  final DateTime data;

  const CaronaResumo({
    required this.idCarona,
    required this.status,
    required this.idMotorista,
    required this.motoristaNome,
    required this.data,
  });
}
