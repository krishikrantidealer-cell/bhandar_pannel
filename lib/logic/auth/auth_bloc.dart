import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/bhandar_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  static const String prefUserKey = 'bhandar_admin_user';
  static const String prefTokenKey = 'bhandar_admin_token';
  static const String prefRememberMeKey = 'bhandar_admin_remember_me';
  static const String prefIdentifierKey = 'bhandar_admin_identifier';

  final BhandarRepository repository;

  AuthBloc({required this.repository, SharedPreferences? prefs})
      : super(getInitialAuthState(repository, prefs)) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LogoutRequested>(_onLogoutRequested);

    if (prefs == null) {
      add(const CheckAuthStatus());
    }
  }

  static AuthState getInitialAuthState(BhandarRepository repository, SharedPreferences? prefs) {
    if (prefs == null) return const AuthState();
    try {
      final rememberMe = prefs.getBool(prefRememberMeKey) ?? true;
      if (!rememberMe) {
        return const AuthState(status: AuthStatus.unauthenticated);
      }

      final userJson = prefs.getString(prefUserKey);
      final token = prefs.getString(prefTokenKey);

      if (userJson != null && token != null && token.isNotEmpty) {
        final decoded = jsonDecode(userJson);
        final user = UserModel.fromJson(Map<String, dynamic>.from(decoded), token: token);

        if (user.isAdmin) {
          repository.setAuthToken(token);
          return AuthState(status: AuthStatus.authenticated, currentUser: user);
        }
      }
    } catch (_) {}
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      emit(getInitialAuthState(repository, prefs));
    } catch (_) {
      emit(state.copyWith(status: AuthStatus.unauthenticated, clearUser: true));
    }
  }

  Future<void> _onLoginSubmitted(LoginSubmitted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      final user = await repository.login(
        identifier: event.identifier,
        password: event.password,
        rememberMe: event.rememberMe,
      );

      if (!user.isAdmin) {
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Access Denied: Customer accounts cannot access the Bhandar Admin Panel.',
        ));
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(prefRememberMeKey, event.rememberMe);

      if (event.rememberMe && user.token != null) {
        await prefs.setString(prefUserKey, jsonEncode(user.toJson()));
        await prefs.setString(prefTokenKey, user.token!);
        await prefs.setString(prefIdentifierKey, event.identifier);
      } else {
        await prefs.remove(prefUserKey);
        await prefs.remove(prefTokenKey);
        await prefs.remove(prefIdentifierKey);
      }

      repository.setAuthToken(user.token);
      emit(state.copyWith(status: AuthStatus.authenticated, currentUser: user));
    } catch (e) {
      final cleanMsg = e.toString().replaceFirst('Exception: ', '');
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: cleanMsg,
      ));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    repository.logout();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(prefUserKey);
      await prefs.remove(prefTokenKey);
      await prefs.remove(prefRememberMeKey);
      await prefs.remove(prefIdentifierKey);
    } catch (_) {}

    emit(state.copyWith(status: AuthStatus.unauthenticated, clearUser: true));
  }
}
