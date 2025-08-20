// lib/features/authentication/screens/onboarding/onboarding_screen.dart
import 'package:assesment/features/onBoarding/notifier/onboarding_notifier.dart';
import 'package:assesment/features/onBoarding/screens/OnBoardingNextButton.dart';
import 'package:assesment/features/onBoarding/screens/onBoarding_skip_button.dart';
import 'package:assesment/features/onBoarding/screens/onboarding_dot_navigation.dart';
import 'package:assesment/features/onBoarding/screens/onboarding_page.dart';
import 'package:assesment/utils/constants/images.dart';
import 'package:assesment/utils/constants/sizes.dart';
import 'package:assesment/utils/constants/texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(onboardingNotifierProvider.notifier);
    final currentIndex = ref.watch(onboardingNotifierProvider).currentIndex;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: USizes.defaultSpace),
        child: Stack(
          children: [
            // PageView for Onboarding Screens
            PageView(
              controller: controller.pageController,
              onPageChanged: controller.updatePageIndicator,
              children: [
                OnBoardingPage(
                  animation: UImages.onboarding1Animation,
                  title: UTexts.onBoardingTitle1,
                  subtitle: UTexts.onBoardingSubTitle1,
                ),
                OnBoardingPage(
                  animation: UImages.onboarding2Animation,
                  title: UTexts.onBoardingTitle2,
                  subtitle: UTexts.onBoardingSubTitle2,
                ),
                OnBoardingPage(
                  animation: UImages.onboarding3Animation,
                  title: UTexts.onBoardingTitle3,
                  subtitle: UTexts.onBoardingSubTitle3,
                ),
              ],
            ),

            // Indicator (Smooth Page Indicator)
            const OnBoardingDotNavigation(),

            // Next Button (Trigger the next page or finish the onboarding)
            const OnBoardingNextButton(),

            // Skip Button (Skip to the last page)
            const OnBoardingSkipButton(),
          ],
        ),
      ),
    );
  }
}
