// lib/features/authentication/screens/signup/widgets/signup_form.dart
import 'package:assesment/features/signup/notifier/signup_provider.dart';
import 'package:assesment/utils/constants/colors.dart';
import 'package:assesment/utils/constants/sizes.dart';
import 'package:assesment/utils/constants/texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

class USignupForm extends ConsumerStatefulWidget {
  const USignupForm({super.key});

  @override
  ConsumerState<USignupForm> createState() => _USignupFormState();
}

class _USignupFormState extends ConsumerState<USignupForm> {
  bool _obscurePassword = true; // local UI toggle (since state doesn't have it)
  bool _agreed = true;          // local checkbox (old UI defaulted to checked)

  static const _designations = <String>[
    'Zonal Manager (ZM)',
    'Outlet Manager (OM)',
    'Inventory & Cash Management Officer (ICMO)',
    'Back store Manager (BSM)',
    'Manager',
    'Sales',
    'Support',
    'HR',
    'Developer',
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signUpProvider);
    final ctrl = ref.read(signUpProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Name
        TextFormField(
          controller: TextEditingController(text: state.name),
          onChanged: ctrl.updateName,
          decoration: const InputDecoration(
            labelText: UTexts.firstName,
            prefixIcon: Icon(Iconsax.direct_right),
          ),
        ),
        const SizedBox(height: USizes.spaceBtwInputFields),

        // Email
        TextFormField(
          controller: TextEditingController(text: state.email),
          onChanged: ctrl.updateEmail,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: UTexts.email,
            prefixIcon: Icon(Iconsax.direct_right),
          ),
        ),
        const SizedBox(height: USizes.spaceBtwInputFields),

        // Phone Number
        TextFormField(
          controller: TextEditingController(text: state.phoneNumber),
          onChanged: ctrl.updatePhoneNumber,
          keyboardType: TextInputType.number,
          maxLength: 11,
          // ❌ Do NOT make this list const
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
          controller: TextEditingController(text: state.staffId),
          onChanged: ctrl.updateStaffId,
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

        // Designation (old UI look)
        DropdownButtonFormField<String>(
          value: state.designation.isEmpty ? null : state.designation,
          isExpanded: true,
          icon: const Icon(Iconsax.arrow_down_1),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          style: Theme.of(context).textTheme.bodyMedium,
          items: _designations.map((role) {
            return DropdownMenuItem<String>(
              value: role,
              child: Row(
                children: [
                  const Icon(Iconsax.user, size: 18, color: UColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      role,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) => ctrl.updateDesignation(value ?? ''),
          decoration: InputDecoration(
            labelText: UTexts.designation,
            prefixIcon: const Icon(Iconsax.briefcase),
            filled: true,
            fillColor: isDark ? Colors.black12 : Colors.grey[100],
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
          ),
        ),
        const SizedBox(height: USizes.spaceBtwInputFields),

        // Password (with eye)
        TextFormField(
          controller: TextEditingController(text: state.password),
          onChanged: ctrl.updatePassword,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            prefixIcon: const Icon(Iconsax.password_check),
            labelText: UTexts.password,
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Iconsax.eye : Iconsax.eye_slash),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
          ),
        ),
        const SizedBox(height: USizes.spaceBtwInputFields),

        // I agree row (old UI)
        Row(
          children: [
            Checkbox(
              value: _agreed,
              onChanged: (v) => setState(() => _agreed = v ?? false),
            ),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: [
                    const TextSpan(text: UTexts.iAgreeTo),
                    TextSpan(
                      text: ' ${UTexts.privacyPolicy}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? UColors.white : UColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    TextSpan(
                      text: ' ${UTexts.and} ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextSpan(
                      text: UTexts.termsOfUse,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? UColors.white : UColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: USizes.spaceBtwItems / 2),

        // Full-width themed button (like old app)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: state.isLoading
                ? null
                : () => ctrl.registerUser(context),
            child: state.isLoading
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Text(UTexts.createAccount),
          ),
        ),
      ],
    );
  }
}
