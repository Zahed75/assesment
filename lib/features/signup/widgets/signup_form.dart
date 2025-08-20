// lib/features/authentication/screens/signup/widgets/signup_form.dart

import 'package:assesment/features/signup/notifier/signup_provider.dart';
import 'package:assesment/utils/constants/sizes.dart';
import 'package:assesment/utils/constants/texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

class USignupForm extends ConsumerWidget {
  const USignupForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signUpState = ref.watch(signUpProvider); // Watch the state
    final signUpController = ref.read(
      signUpProvider.notifier,
    ); // Access the notifier

    return Column(
      children: [
        // Name
        TextFormField(
          controller: TextEditingController(text: signUpState.name),
          onChanged: (value) => signUpController.updateName(value),
          decoration: const InputDecoration(
            labelText: UTexts.firstName,
            prefixIcon: Icon(Iconsax.direct_right),
          ),
        ),
        const SizedBox(height: USizes.spaceBtwInputFields),

        // Email
        TextFormField(
          controller: TextEditingController(text: signUpState.email),
          onChanged: (value) => signUpController.updateEmail(value),
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: UTexts.email,
            prefixIcon: Icon(Iconsax.direct_right),
          ),
        ),
        const SizedBox(height: USizes.spaceBtwInputFields),

        // Phone Number
        TextFormField(
          controller: TextEditingController(text: signUpState.phoneNumber),
          onChanged: (value) => signUpController.updatePhoneNumber(value),
          keyboardType: TextInputType.number,
          maxLength: 11,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ],
          decoration: const InputDecoration(
            prefixIcon: Icon(Iconsax.call),
            prefixText: '+88 ',
            labelText: UTexts.phoneNumber,
            counterText: '',
          ),
        ),
        const SizedBox(height: USizes.spaceBtwInputFields),

        // Staff ID
        TextFormField(
          controller: TextEditingController(text: signUpState.staffId),
          onChanged: (value) => signUpController.updateStaffId(value),
          keyboardType: TextInputType.number,
          maxLength: 6,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          decoration: const InputDecoration(
            labelText: UTexts.staffId,
            prefixIcon: Icon(Iconsax.direct_right),
            counterText: '',
          ),
        ),
        const SizedBox(height: USizes.spaceBtwInputFields),

        // Designation Dropdown
        DropdownButtonFormField<String>(
          value: signUpState.designation.isEmpty
              ? null
              : signUpState.designation,
          isExpanded: true,
          icon: const Icon(Iconsax.arrow_down_1),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          items: ['Manager', 'Sales', 'Support', 'Developer'].map((role) {
            return DropdownMenuItem<String>(value: role, child: Text(role));
          }).toList(),
          onChanged: (value) {
            signUpController.updateDesignation(value ?? '');
          },
          decoration: InputDecoration(
            labelText: UTexts.designation,
            prefixIcon: const Icon(Iconsax.briefcase),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
          ),
        ),
        const SizedBox(height: USizes.spaceBtwInputFields),

        // Password
        TextFormField(
          controller: TextEditingController(text: signUpState.password),
          onChanged: (value) => signUpController.updatePassword(value),
          obscureText: true,
          decoration: InputDecoration(
            prefixIcon: const Icon(Iconsax.password_check),
            labelText: UTexts.password,
          ),
        ),
        const SizedBox(height: USizes.spaceBtwInputFields),

        // Submit Button
        ElevatedButton(
          onPressed: () => signUpController.registerUser(
            context,
          ), // Using context in registerUser
          child: signUpState.isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(UTexts.createAccount),
        ),
      ],
    );
  }
}
