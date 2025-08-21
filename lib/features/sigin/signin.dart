// lib/features/authentication/screens/login/login.dart
import 'package:assesment/common_ui/styles/padding.dart';
import 'package:assesment/common_ui/widgets/button/elevated_button.dart';
import 'package:assesment/features/forget_password/forget_password.dart';
import 'package:assesment/features/sigin/widgets/login_form.dart';
import 'package:assesment/features/sigin/widgets/login_header.dart';
import 'package:assesment/features/sigin/widgets/remember_me.dart';
import 'package:assesment/features/signup/signup.dart';
import 'package:assesment/utils/constants/sizes.dart';
import 'package:assesment/utils/constants/texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/routes.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  String appVersion = '';
  String buildNumber = '';

  @override
  void initState() {
    super.initState();
    // You can initialize any state here if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: UPadding.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: USizes.spaceBtwSections * 2),
                const Center(
                  child: Image(
                    image: AssetImage('assets/icons/circleIcon.png'),
                    height: 80,
                    width: 80,
                  ),
                ),
                SizedBox(height: USizes.spaceBtwSections * 2.4),
                const ULoginHeader(),
                const SizedBox(height: USizes.spaceBtwSections),
                const ULoginForm(),
                const SizedBox(height: USizes.spaceBtwInputFields / 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const URememberMeCheckbox(),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgetPasswordScreen(),
                        ),
                      ),
                      child: const Text(UTexts.forgetPassword),
                    ),
                  ],
                ),
                const SizedBox(height: USizes.spaceBtwSections),
                UElevatedButton(
                  onPressed: () {
                    // Handle login logic here when connected to API
                    context.go(Routes.home);
                  },
                  child: const Text(UTexts.signIn),
                ),
                const SizedBox(height: USizes.spaceBtwItems),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUpScreen()),
                    ),
                    child: const Text(UTexts.createAccount),
                  ),
                ),

                // App Version Info (minimal addition)
                const SizedBox(height: USizes.spaceBtwSections),
                if (appVersion.isNotEmpty)
                  Center(
                    child: Text(
                      'v$appVersion • Build $buildNumber',
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
