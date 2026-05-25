// Identificadores e regras fixas do app.
// Override via --dart-define quando precisar variar por ambiente.

class AppConstants {
  AppConstants._();

  static const String adminEmail = String.fromEnvironment(
    'ADMIN_EMAIL',
    defaultValue: 'admin@admin.com',
  );
}
