// lib/app/app_router.dart
import 'package:assesment/app/router/routes.dart';
import 'package:assesment/features/home/home.dart';
import 'package:assesment/features/onBoarding/onBoarding.dart';
import 'package:assesment/features/profile/profile.dart';
import 'package:assesment/features/sigin/signin.dart';
import 'package:assesment/features/verify_otp/otp_verify.dart';
import 'package:go_router/go_router.dart';

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
        return OtpVerifyScreen(phoneNumber: phoneNumber ?? '');
      },
    ),
    // Home Route
    GoRoute(path: Routes.home, builder: (context, state) => const HomeScreen()),
    // Survey List Route
    GoRoute(
      path: Routes.surveyList,
      builder: (context, state) => const SurveyListScreen(),
    ),
    // Question Route
    GoRoute(
      path: Routes.question,
      builder: (context, state) {
        final surveyData = state.extra;
        return QuestionScreen(surveyData: surveyData);
      },
    ),
    // Result Route
    GoRoute(
      path: Routes.result,
      builder: (context, state) {
        final responseId = state.queryParams['responseId'];
        return ResultScreen(responseId: responseId ?? '');
      },
    ),
    // Profile Route
    GoRoute(
      path: Routes.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);
