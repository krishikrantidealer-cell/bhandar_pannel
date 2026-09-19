import 'package:equatable/equatable.dart';
import '../../data/models/user_model.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final UserModel? currentUser;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.currentUser,
    this.errorMessage,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated && currentUser != null && currentUser!.isAdmin;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? currentUser,
    bool clearUser = false,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      currentUser: clearUser ? null : (currentUser ?? this.currentUser),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, currentUser, errorMessage];
}
