import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_tcc/app.dart';
import 'package:test_tcc/data/datasources/user_local_datasource.dart';
import 'package:test_tcc/data/repositories/auth_repository_impl.dart';
import 'package:test_tcc/data/repositories/user_repository_impl.dart';
import 'package:test_tcc/domain/repositories/auth_repository.dart';
import 'package:test_tcc/domain/repositories/user_repository.dart';
import 'package:test_tcc/domain/usecases/delete_user_usecase.dart';
import 'package:test_tcc/domain/usecases/list_users_usecase.dart';
import 'package:test_tcc/domain/usecases/login_usecase.dart';
import 'package:test_tcc/domain/usecases/logout_usecase.dart';
import 'package:test_tcc/domain/usecases/register_usecase.dart';
import 'package:test_tcc/presentation/controllers/auth_controller.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<UserLocalDatasource>(create: (_) => UserLocalDatasource()),
        ProxyProvider<UserLocalDatasource, AuthRepository>(
          update: (_, ds, _) => AuthRepositoryImpl(ds),
        ),
        ProxyProvider<UserLocalDatasource, UserRepository>(
          update: (_, ds, _) => UserRepositoryImpl(ds),
        ),
        ProxyProvider<AuthRepository, LoginUseCase>(
          update: (_, repo, _) => LoginUseCase(repo),
        ),
        ProxyProvider<AuthRepository, RegisterUseCase>(
          update: (_, repo, _) => RegisterUseCase(repo),
        ),
        Provider<LogoutUseCase>(create: (_) => const LogoutUseCase()),
        ProxyProvider<UserRepository, ListUsersUseCase>(
          update: (_, repo, _) => ListUsersUseCase(repo),
        ),
        ProxyProvider<UserRepository, DeleteUserUseCase>(
          update: (_, repo, _) => DeleteUserUseCase(repo),
        ),
        ChangeNotifierProxyProvider3<LoginUseCase, RegisterUseCase,
            LogoutUseCase, AuthController>(
          create: (ctx) => AuthController(
            loginUseCase: ctx.read<LoginUseCase>(),
            registerUseCase: ctx.read<RegisterUseCase>(),
            logoutUseCase: ctx.read<LogoutUseCase>(),
          ),
          update: (_, login, register, logout, previous) =>
              previous ??
              AuthController(
                loginUseCase: login,
                registerUseCase: register,
                logoutUseCase: logout,
              ),
        ),
      ],
      child: const App(),
    ),
  );
}
