import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/bhandar_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  static const String _prefUserKey = 'bhandar_admin_user';
  static const String _prefTokenKey = 'bhandar_admin_token';

  final BhandarRepository repository;

  AuthBloc({required this.repository}) : super(const AuthState()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LogoutRequested>(_onLogoutRequested);

    add(const CheckAuthStatus());
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_prefUserKey);
      final token = prefs.getString(_prefTokenKey);

      if (userJson != null && token != null) {
        final decoded = jsonDecode(userJson);
        final user = UserModel.fromJson(Map<String, dynamic>.from(decoded), token: token);

        if (user.isAdmin) {
          repository.setAuthToken(token);
          emit(state.copyWith(status: AuthStatus.authenticated, currentUser: user));
          return;
        }
      }
    } catch (_) {}

    // Default to unauthenticated
    emit(state.copyWith(status: AuthStatus.unauthenticated, clearUser: true));
  }

  Future<void> _onLoginSubmitted(LoginSubmitted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      final user = await repository.login(
        identifier: event.identifier,
        password: event.password,
      );

      if (!user.isAdmin) {
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Access Denied: Customer accounts cannot access the Bhandar Admin Panel.',
        ));
        return;
      }

      if (event.rememberMe && user.token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefUserKey, jsonEncode(user.toJson()));
        await prefs.setString(_prefTokenKey, user.token!);
      }

      emit(state.copyWith(status: AuthStatus.authenticated, currentUser: user));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Invalid credentials or connection error: $e',
      ));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    repository.logout();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefUserKey);
      await prefs.remove(_prefTokenKey);
    } catch (_) {}

    emit(state.copyWith(status: AuthStatus.unauthenticated, clearUser: true));
  }
}
