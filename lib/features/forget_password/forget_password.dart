import 'package:assesment/common_ui/styles/padding.dart';
import 'package:assesment/common_ui/widgets/button/elevated_button.dart';
import 'package:assesment/features/reset_password/reset_password.dart';
import 'package:assesment/utils/constants/sizes.dart';
import 'package:assesment/utils/constants/texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

class ForgetPasswordScreen extends ConsumerWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: UPadding.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title
            Text(
              UTexts.forgetPassword,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: USizes.spaceBtwItems / 2),

            /// Subtitle
            Text(
              UTexts.forgetPasswordSubTitle,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            SizedBox(height: USizes.spaceBtwSections * 2),
            Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: UTexts.email,
                    prefixIcon: Icon(Iconsax.direct_right),
                  ),
                ),
                SizedBox(height: USizes.spaceBtwItems),
                UElevatedButton(
                  onPressed: () {
                    // Use Riverpod to handle navigation instead of GetX
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ResetPasswordScreen(),
                      ),
                    );
                  },
                  child: Text(UTexts.submit),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
