// Identificadores e regras fixas do app.
// Override via --dart-define quando precisar variar por ambiente.

class AppConstants {
  AppConstants._();

  static const String adminEmail = String.fromEnvironment(
    'ADMIN_EMAIL',
    defaultValue: 'admin@admin.com',
  );

  // Regras do carro (espelham config/security.js no backend, que é a fonte de
  // verdade; aqui são só para validação imediata no formulário).
  static const int carroAnoMin = 1900;
  // Placa BR (após upcase): antiga ABC1234 e Mercosul ABC1D23.
  static final RegExp carroPlacaRegex =
      RegExp(r'^[A-Z]{3}[0-9][0-9A-Z][0-9]{2}$');
}
