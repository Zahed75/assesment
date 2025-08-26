// lib/features/signin/notifier/login_notifier.dart
import 'package:assesment/features/signin/api/login_api.dart';
import 'package:assesment/features/signin/model/user_login_model.dart';
import 'package:assesment/features/signin/provider/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

class LoginState {
  final bool isLoading;
  final UserLoginModel? user;
  final bool hidePassword;
  final bool rememberMe;

  LoginState({
    this.isLoading = false,
    this.user,
    this.hidePassword = true,
    this.rememberMe = false,
  });

  LoginState copyWith({
    bool? isLoading,
    UserLoginModel? user,
    bool? hidePassword,
    bool? rememberMe,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      hidePassword: hidePassword ?? this.hidePassword,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }
}

class LoginNotifier extends StateNotifier<LoginState> {
  final LoginApi _loginApi;
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginNotifier(this._loginApi) : super(LoginState());

  void togglePasswordVisibility() {
    state = state.copyWith(hidePassword: !state.hidePassword);
  }

  void toggleRememberMe(bool value) {
    state = state.copyWith(rememberMe: value);
  }

  Future<void> login() async {
    if (state.isLoading) return;

    final phoneNumber = phoneController.text.trim();
    final password = passwordController.text.trim();

    state = state.copyWith(isLoading: true);

    try {
      final user = await _loginApi.login(
        phoneNumber: phoneNumber,
        password: password,
      );

      state = state.copyWith(isLoading: false, user: user);

      _handleSuccessfulLogin(user);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow; // Re-throw the error to handle it in the UI layer
    }
  }

  void _handleSuccessfulLogin(UserLoginModel user) {
    if (user.user != null && user.user!.isNotEmpty) {
      final userData = user.user!.first;
      _saveTokens(
        userData.accessToken,
        userData.refreshToken,
        state.rememberMe,
      );
      _saveUserData(userData);
    }
  }

  void _saveTokens(String? accessToken, String? refreshToken, bool rememberMe) {
    // TODO: Implement token saving
    print('Access Token: $accessToken');
    print('Remember Me: $rememberMe');
  }

  void _saveUserData(User userData) {
    // TODO: Implement user data saving
    print('User logged in: ${userData.name}');
  }

  void clearForm() {
    phoneController.clear();
    passwordController.clear();
    state = LoginState();
  }

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

final loginControllerProvider =
    StateNotifierProvider<LoginNotifier, LoginState>((ref) {
      final loginApi = ref.watch(loginApiProvider);
      return LoginNotifier(loginApi);
    });
