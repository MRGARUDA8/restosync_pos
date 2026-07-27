import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hacky_pizza_pos/services/api_service.dart';
import 'package:hacky_pizza_pos/models/user.dart';

class AuthState {
  final bool isAuthenticated;
  final String? accessToken;
  final String? refreshToken;
  final User? user;

  const AuthState({
    this.isAuthenticated = false,
    this.accessToken,
    this.refreshToken,
    this.user,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? accessToken,
    String? refreshToken,
    User? user,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<void> login(String email, String password) async {
    final result = await ApiService.login(email, password);
    if (result != null) {
      state = state.copyWith(
        isAuthenticated: true,
        accessToken: result['accessToken'],
        refreshToken: result['refreshToken'],
        user: User.fromJson(result['user']),
      );
    }
  }

  void logout() {
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());
