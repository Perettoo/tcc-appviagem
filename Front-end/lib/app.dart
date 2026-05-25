import 'package:flutter/material.dart';
import 'package:test_tcc/core/theme/app_theme.dart';
import 'package:test_tcc/presentation/pages/login_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Compartilhe Caronas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const LoginPage(),
    );
  }
}
