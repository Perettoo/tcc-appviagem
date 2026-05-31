import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_tcc/app.dart';
import 'package:test_tcc/data/datasources/auth_remote_datasource.dart';
import 'package:test_tcc/data/datasources/chat_remote_datasource.dart';
import 'package:test_tcc/data/datasources/chat_socket_service.dart';
import 'package:test_tcc/data/datasources/grupo_remote_datasource.dart';
import 'package:test_tcc/data/datasources/session_socket_service.dart';
import 'package:test_tcc/data/datasources/token_storage.dart';
import 'package:test_tcc/data/repositories/auth_repository_impl.dart';
import 'package:test_tcc/data/repositories/chat_repository_impl.dart';
import 'package:test_tcc/data/repositories/grupo_repository_impl.dart';
import 'package:test_tcc/domain/repositories/auth_repository.dart';
import 'package:test_tcc/domain/repositories/chat_repository.dart';
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
        ProxyProvider<TokenStorage, ChatRemoteDatasource>(
          update: (_, storage, _) => ChatRemoteDatasource(tokenStorage: storage),
        ),
        ProxyProvider<TokenStorage, ChatSocketService>(
          update: (_, storage, _) => ChatSocketService(tokenStorage: storage),
        ),
        ProxyProvider<TokenStorage, SessionSocketService>(
          update: (_, storage, _) => SessionSocketService(tokenStorage: storage),
        ),
        // Repositórios
        ProxyProvider<AuthRemoteDatasource, AuthRepository>(
          update: (_, remote, _) => AuthRepositoryImpl(remote),
        ),
        ProxyProvider<GrupoRemoteDatasource, GrupoRepository>(
          update: (_, remote, _) => GrupoRepositoryImpl(remote),
        ),
        ProxyProvider2<ChatRemoteDatasource, ChatSocketService, ChatRepository>(
          update: (_, remote, socket, _) =>
              ChatRepositoryImpl(remote: remote, socket: socket),
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
        ChangeNotifierProxyProvider3<ListarGruposUseCase, CriarGrupoUseCase,
            SessionSocketService, GrupoController>(
          create: (ctx) => GrupoController(
            listar: ctx.read<ListarGruposUseCase>(),
            criar: ctx.read<CriarGrupoUseCase>(),
            sessionSocket: ctx.read<SessionSocketService>(),
          ),
          update: (_, listar, criar, sessionSocket, previous) =>
              previous ??
              GrupoController(
                listar: listar,
                criar: criar,
                sessionSocket: sessionSocket,
              ),
        ),
      ],
      child: const App(),
    ),
  );
}
