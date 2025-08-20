// lib/features/authentication/controllers/login/login_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginController extends StateNotifier<LoginState> {
  LoginController() : super(LoginState());

  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  // Toggle password visibility
  void togglePasswordVisibility() {
    state = state.copyWith(hidePassword: !state.hidePassword);
  }

  // Update remember me value
  void toggleRememberMe(bool value) {
    state = state.copyWith(rememberMe: value);
  }

  // Perform login (mocked for now)
  Future<void> loginUser() async {
    state = state.copyWith(isLoading: true);

    // Mock API request delay
    await Future.delayed(const Duration(seconds: 2));

    // Handle login logic (you can replace this with actual logic)
    state = state.copyWith(isLoading: false);
    // Mock login success, update user data or token here.
  }
}

class LoginState {
  final bool isLoading;
  final bool hidePassword;
  final bool rememberMe;

  const LoginState({
    this.isLoading = false,
    this.hidePassword = true,
    this.rememberMe = false,
  });

  LoginState copyWith({bool? isLoading, bool? hidePassword, bool? rememberMe}) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      hidePassword: hidePassword ?? this.hidePassword,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }
}

final loginControllerProvider =
    StateNotifierProvider<LoginController, LoginState>(
      (ref) => LoginController(),
    );
