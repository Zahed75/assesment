// lib/features/authentication/notifiers/onboarding/onboarding_notifier.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'onboarding_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(OnboardingState());

  final pageController = PageController();

  // Update the current index when page scroll
  void updatePageIndicator(int index) {
    state = state.copyWith(currentIndex: index);
  }

  // Jump to a specific page when the dot is clicked
  void dotNavigationClick(int index) {
    state = state.copyWith(currentIndex: index);
    pageController.jumpToPage(index);
  }

  // Move to the next page
  Future<void> nextPage() async {
    if (state.currentIndex == 2) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboardingSeen', true); // Save the onboarding state
      // Navigate to the login screen
      // We can use the router system from your app for navigation instead of `Get.offAll`
      // Assuming you have GoRouter, Navigator or similar in place
    } else {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
      pageController.jumpToPage(state.currentIndex);
    }
  }

  // Skip to the last page
  void skipPage() {
    state = state.copyWith(currentIndex: 2);
    pageController.jumpToPage(state.currentIndex);
  }
}

// Riverpod provider for OnboardingNotifier
final onboardingNotifierProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
      return OnboardingNotifier();
    });
