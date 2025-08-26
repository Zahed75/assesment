// lib/features/authentication/screens/login/widgets/remember_me.dart

import 'package:assesment/features/signin/notifier/login_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class URememberMeCheckbox extends ConsumerWidget {
  const URememberMeCheckbox({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rememberMe = ref.watch(loginControllerProvider).rememberMe;
    final controller = ref.read(loginControllerProvider.notifier);

    return Row(
      children: [
        Checkbox(
          value: rememberMe,
          onChanged: (value) {
            controller.toggleRememberMe(value ?? false);
          },
        ),
        const Text("Remember Me"),
      ],
    );
  }
}
