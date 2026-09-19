import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

class LoginSubmitted extends AuthEvent {
  final String identifier;
  final String password;
  final bool rememberMe;

  const LoginSubmitted({
    required this.identifier,
    required this.password,
    this.rememberMe = true,
  });

  @override
  List<Object?> get props => [identifier, password, rememberMe];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
