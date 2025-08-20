import 'package:assesment/common_ui/widgets/alerts/u_alert.dart';
import 'package:assesment/features/signup/notifier/signup_state.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Mock repository class for now
class MockAuthRepository {
  Future<Map<String, dynamic>> registerUser(Map<String, dynamic> body) async {
    // Simulating a successful API response after a delay
    await Future.delayed(const Duration(seconds: 2));
    return {"message": "Registration Successful!"};
    // For testing error response, uncomment the following:
    // throw Exception('Failed to register user');
  }
}

class SignUpNotifier extends StateNotifier<SignUpState> {
  SignUpNotifier() : super(SignUpState());

  final _repo = MockAuthRepository(); // Using the mock repository

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updatePhoneNumber(String phoneNumber) {
    state = state.copyWith(phoneNumber: phoneNumber);
  }

  void updateStaffId(String staffId) {
    state = state.copyWith(staffId: staffId);
  }

  void updateDesignation(String designation) {
    state = state.copyWith(designation: designation);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password);
  }

  // Registration method
  Future<void> registerUser(BuildContext context) async {
    // Validate fields
    if (state.name.isEmpty) {
      UAlert.show(
        title: "Required",
        message: "Please enter your full name.",
        context: context,
      );
      return;
    }

    if (state.email.isEmpty) {
      UAlert.show(
        title: "Required",
        message: "Please enter your email address.",
        context: context,
      );
      return;
    }

    // Replace GetUtils.isEmail with email_validator package
    if (!EmailValidator.validate(state.email)) {
      UAlert.show(
        title: "Invalid Email",
        message: "Please enter a valid email address.",
        context: context,
      );
      return;
    }

    if (state.phoneNumber.isEmpty || state.phoneNumber.length != 11) {
      UAlert.show(
        title: "Invalid Phone",
        message: "Phone number must be 11 digits.",
        context: context,
      );
      return;
    }

    if (state.staffId.isEmpty || int.tryParse(state.staffId) == null) {
      UAlert.show(
        title: "Invalid ID",
        message: "Staff ID must be numeric.",
        context: context,
      );
      return;
    }

    if (state.designation.isEmpty) {
      UAlert.show(
        title: "Required",
        message: "Please select your designation.",
        context: context,
      );
      return;
    }

    if (state.password.isEmpty) {
      UAlert.show(
        title: "Required",
        message: "Please enter a password.",
        context: context,
      );
      return;
    }

    try {
      state = state.copyWith(isLoading: true);

      final body = {
        "name": state.name,
        "phone_number": state.phoneNumber,
        "password": state.password,
        "email": state.email,
        "staff_id": int.tryParse(state.staffId) ?? 0,
        "designation": state.designation,
      };

      // Simulate API call with the mock repository
      final data = await _repo.registerUser(body);

      if (data.containsKey("message")) {
        UAlert.show(
          title: "Success",
          message: data["message"],
          context: context,
        );
        // Handle OTP Screen Navigation (to OTP verification screen)
      } else {
        UAlert.show(
          title: "Error",
          message: "Unexpected response from the server.",
          context: context,
        );
      }
    } catch (e) {
      UAlert.show(
        title: "Error",
        message: "Failed to register user.",
        context: context,
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
