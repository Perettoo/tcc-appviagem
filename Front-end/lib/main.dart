import 'package:test_tcc/tela_de_login.dart';
import 'package:test_tcc/user_provide.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return UserProvide(
      users: [],
      child: MaterialApp(
        title: 'Flutter Demo',
        home: Scaffold(
          body: const TelaDeLogin(),
        ),
        routes: {},
      ),
    );
  }
}
