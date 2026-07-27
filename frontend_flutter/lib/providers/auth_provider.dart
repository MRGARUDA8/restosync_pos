import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_client.dart';
import '../core/constants.dart';
import '../models/user.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  AuthNotifier() : super(const AsyncValue.data(null));

  Future<bool> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final res = await ApiClient.post('/auth/login', {'email': email, 'password': password});
      if (res['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.tokenKey, res['data']['accessToken']);
        final user = UserModel.fromJson(res['data']['user']);
        state = AsyncValue.data(user);
        return true;
      } else {
        state = AsyncValue.error(res['message'] ?? 'Login failed', StackTrace.current);
        return false;
      }
    } catch (e, st) {
      state = AsyncValue.error('Network Error', st);
      return false;
    }
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    state = const AsyncValue.data(null);
  }
}
