import 'package:assesment/app/router/routes.dart';
import 'package:assesment/features/home/home.dart';
import 'package:assesment/features/onBoarding/onBoarding.dart';
import 'package:assesment/features/profile/profile.dart';
import 'package:assesment/features/question/question.dart';
import 'package:assesment/features/result/result.dart';
import 'package:assesment/features/sigin/signin.dart';
import 'package:assesment/features/verify_otp/otp_verify.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: Routes.onboarding,
  routes: [
    // Onboarding Route
    GoRoute(
      path: Routes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    // SignIn Route
    GoRoute(
      path: Routes.signIn,
      builder: (context, state) => const LoginScreen(),
    ),
    // OTP Verify Route
    GoRoute(
      path: Routes.otpVerify,
      builder: (context, state) {
        final phoneNumber = state.queryParams['phoneNumber'];
        // You could use Riverpod to manage the state for the phone number
        return OtpVerifyScreen(phoneNumber: phoneNumber ?? '');
      },
    ),
    // Home Route
    GoRoute(path: Routes.home, builder: (context, state) => const HomeScreen()),
    // Question Route
    GoRoute(
      path: Routes.question,
      builder: (context, state) {
        // Fetching survey data using Riverpod providers
        final surveyData = state.extra as Map<String, dynamic>? ?? {};
        return QuestionScreen(surveyData: surveyData);
      },
    ),
    // Result Route
    // Result Route
    GoRoute(
      path: Routes.result,
      builder: (context, state) {
        final responseIdString = state.queryParams['responseId'];
        // Convert responseId from String to int
        final responseId = responseIdString != null
            ? int.tryParse(responseIdString)
            : null;
        return ResultScreen(
          responseId: responseId ?? 0,
        ); // Default to 0 if null
      },
    ),

    // Profile Route
    GoRoute(
      path: Routes.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);
