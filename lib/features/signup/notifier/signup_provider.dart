// lib/features/authentication/notifiers/signup/signup_provider.dart

import 'package:assesment/features/signup/notifier/signup_notifier.dart';
import 'package:assesment/features/signup/notifier/signup_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final signUpProvider = StateNotifierProvider<SignUpNotifier, SignUpState>((
  ref,
) {
  return SignUpNotifier();
});
