import 'package:test_tcc/user.dart';
import 'package:flutter/material.dart';

class UserProvide extends InheritedWidget {
  final List<User> users;
  const UserProvide({super.key, required super.child, required this.users});

  static UserProvide? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<UserProvide>();
  }

  @override
  bool updateShouldNotify(UserProvide oldWidget) {
    return users != oldWidget.users;
  }
}
