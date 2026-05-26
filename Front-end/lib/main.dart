import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_tcc/app.dart';
import 'package:test_tcc/data/datasources/auth_remote_datasource.dart';
import 'package:test_tcc/data/datasources/grupo_remote_datasource.dart';
import 'package:test_tcc/data/datasources/token_storage.dart';
import 'package:test_tcc/data/repositories/auth_repository_impl.dart';
import 'package:test_tcc/data/repositories/grupo_repository_impl.dart';
import 'package:test_tcc/domain/repositories/auth_repository.dart';
import 'package:test_tcc/domain/repositories/grupo_repository.dart';
import 'package:test_tcc/domain/usecases/criar_grupo_usecase.dart';
import 'package:test_tcc/domain/usecases/listar_grupos_usecase.dart';
import 'package:test_tcc/domain/usecases/login_usecase.dart';
import 'package:test_tcc/domain/usecases/logout_usecase.dart';
import 'package:test_tcc/domain/usecases/register_usecase.dart';
import 'package:test_tcc/presentation/controllers/auth_controller.dart';
import 'package:test_tcc/presentation/controllers/grupo_controller.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // Infra
        Provider<TokenStorage>(create: (_) => TokenStorage()),
        ProxyProvider<TokenStorage, AuthRemoteDatasource>(
          update: (_, storage, _) => AuthRemoteDatasource(tokenStorage: storage),
        ),
        ProxyProvider<TokenStorage, GrupoRemoteDatasource>(
          update: (_, storage, _) =>
              GrupoRemoteDatasource(tokenStorage: storage),
        ),
        // Repositórios
        ProxyProvider<AuthRemoteDatasource, AuthRepository>(
          update: (_, remote, _) => AuthRepositoryImpl(remote),
        ),
        ProxyProvider<GrupoRemoteDatasource, GrupoRepository>(
          update: (_, remote, _) => GrupoRepositoryImpl(remote),
        ),
        // Casos de uso
        ProxyProvider<AuthRepository, LoginUseCase>(
          update: (_, repo, _) => LoginUseCase(repo),
        ),
        ProxyProvider<AuthRepository, RegisterUseCase>(
          update: (_, repo, _) => RegisterUseCase(repo),
        ),
        ProxyProvider<TokenStorage, LogoutUseCase>(
          update: (_, storage, _) => LogoutUseCase(storage),
        ),
        ProxyProvider<GrupoRepository, CriarGrupoUseCase>(
          update: (_, repo, _) => CriarGrupoUseCase(repo),
        ),
        ProxyProvider<GrupoRepository, ListarGruposUseCase>(
          update: (_, repo, _) => ListarGruposUseCase(repo),
        ),
        // Controllers
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
        ChangeNotifierProxyProvider2<ListarGruposUseCase, CriarGrupoUseCase,
            GrupoController>(
          create: (ctx) => GrupoController(
            listar: ctx.read<ListarGruposUseCase>(),
            criar: ctx.read<CriarGrupoUseCase>(),
          ),
          update: (_, listar, criar, previous) =>
              previous ?? GrupoController(listar: listar, criar: criar),
        ),
      ],
      child: const App(),
    ),
  );
}
