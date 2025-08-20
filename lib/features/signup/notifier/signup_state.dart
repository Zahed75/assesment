// lib/features/authentication/notifiers/signup/signup_state.dart

class SignUpState {
  final bool isLoading;
  final String name;
  final String email;
  final String phoneNumber;
  final String staffId;
  final String designation;
  final String password;

  SignUpState({
    this.isLoading = false,
    this.name = '',
    this.email = '',
    this.phoneNumber = '',
    this.staffId = '',
    this.designation = '',
    this.password = '',
  });

  SignUpState copyWith({
    bool? isLoading,
    String? name,
    String? email,
    String? phoneNumber,
    String? staffId,
    String? designation,
    String? password,
  }) {
    return SignUpState(
      isLoading: isLoading ?? this.isLoading,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      staffId: staffId ?? this.staffId,
      designation: designation ?? this.designation,
      password: password ?? this.password,
    );
  }
}
