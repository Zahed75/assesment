// lib/features/authentication/screens/login/widgets/login_header.dart
import 'package:assesment/utils/constants/sizes.dart';
import 'package:assesment/utils/constants/texts.dart';
import 'package:flutter/material.dart';

class ULoginHeader extends StatelessWidget {
  const ULoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          UTexts.loginTitle,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: USizes.sm),
        Text(
          UTexts.loginSubTitle,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
