// lib/app/router/app_router.dart
import 'package:assesment/app/router/routes.dart';
import 'package:assesment/features/onBoarding/onBoarding.dart';
import 'package:assesment/features/signin/signin.dart';

import 'package:assesment/features/verify_otp/otp_verify.dart';
import 'package:assesment/features/profile/profile.dart';
import 'package:assesment/features/question/question.dart';
import 'package:assesment/features/result/result.dart';
import 'package:assesment/navigation_menu.dart'; // ⬅️ add this
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: Routes.onboarding,
  routes: [
    GoRoute(
      path: Routes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      name: 'signIn',
      path: Routes.signIn,
      builder: (context, state) =>
          const LoginScreen(), // this must be the real Sign-In UI
    ),
    GoRoute(
      path: Routes.otpVerify,
      builder: (context, state) {
        final phoneNumber = state.queryParams['phoneNumber'] ?? '';
        final otp = state.queryParams['otp']; // <-- add this
        return OtpVerifyScreen(phoneNumber: phoneNumber, otp: otp);
      },
    ),

    /// ⬇️ Home shows the NavigationMenu (which renders HomeScreen as tab 0)
    GoRoute(
      path: Routes.home,
      builder: (context, state) => const NavigationMenu(),
    ),

    GoRoute(
      path: Routes.question,
      builder: (context, state) {
        final surveyData = state.extra as Map<String, dynamic>? ?? {};
        return QuestionScreen(surveyData: surveyData);
      },
    ),
    GoRoute(
      path: Routes.result,
      builder: (context, state) {
        final responseIdString = state.queryParams['responseId'];
        final responseId = responseIdString != null
            ? int.tryParse(responseIdString)
            : null;
        return ResultScreen(responseId: responseId ?? 0);
      },
    ),
    GoRoute(
      path: Routes.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);
