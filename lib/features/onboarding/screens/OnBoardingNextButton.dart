// lib/features/onBoarding/widgets/onboarding_next_button.dart

import 'package:assesment/common_ui/widgets/button/elevated_button.dart';
import 'package:assesment/features/onBoarding/notifier/onboarding_notifier.dart';
import 'package:assesment/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnBoardingNextButton extends ConsumerWidget {
  const OnBoardingNextButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingNotifierProvider);

    return Positioned(
      left: 0,
      right: 0,
      bottom: USizes.spaceBtwItems * 7,
      child: UElevatedButton(
        onPressed: () {
          // Call the nextPage function from the notifier and pass the context
          ref
              .read(onboardingNotifierProvider.notifier)
              .nextPage(context); // Pass context here
        },
        child: Text(onboardingState.isLastPage ? 'Get Started' : "Next"),
      ),
    );
  }
}
