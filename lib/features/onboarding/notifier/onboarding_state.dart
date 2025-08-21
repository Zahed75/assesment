// lib/features/authentication/notifiers/onboarding/onboarding_state.dart

class OnboardingState {
  final int currentIndex;

  OnboardingState({this.currentIndex = 0});

  // Getter to check if the current page is the last one (index 2)
  bool get isLastPage => currentIndex == 2;

  OnboardingState copyWith({int? currentIndex}) {
    return OnboardingState(currentIndex: currentIndex ?? this.currentIndex);
  }
}
