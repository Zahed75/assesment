import 'package:assesment/common_ui/styles/padding.dart';
import 'package:assesment/features/site/site_location.dart';
import 'package:assesment/utils/constants/colors.dart';
import 'package:assesment/utils/constants/images.dart';
import 'package:assesment/utils/constants/sizes.dart';
import 'package:assesment/utils/constants/texts.dart';
import 'package:assesment/utils/helpers/device_helpers.dart';
import 'package:assesment/utils/helpers/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';

// StateProvider for loading state and error handling
final otpVerificationStateProvider = StateProvider.autoDispose<bool>(
  (ref) => false,
);
final otpVerificationErrorProvider = StateProvider.autoDispose<String?>(
  (ref) => null,
);

class OtpVerifyScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String? otp; // Add optional OTP parameter for autofill

  const OtpVerifyScreen({super.key, required this.phoneNumber, this.otp});

  @override
  _OtpVerifyScreenState createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends ConsumerState<OtpVerifyScreen> {
  late TextEditingController _otpController;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController(
      text: widget.otp,
    ); // Auto-fill OTP if available

    // Automatically verify OTP if it's provided
    if (widget.otp != null) {
      _verifyOtp(widget.otp!); // Trigger OTP verification automatically
    }
  }

  Future<void> _verifyOtp(String otp) async {
    // Mock API call for OTP verification
    // Replace this with actual API call when available

    final mockSuccess = true; // Change to false to simulate failure

    // Set loading state
    ref.read(otpVerificationStateProvider.state).state = true;

    try {
      // Simulating OTP verification process
      await Future.delayed(const Duration(seconds: 2)); // Simulate delay

      if (mockSuccess) {
        // Set error state to null, since OTP was verified successfully
        ref.read(otpVerificationErrorProvider.state).state = null;

        // Show success message
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("OTP Verified Successfully!")));

        // Navigate to HomeSiteLocation after successful OTP verification
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const SiteLocation(isSelectionMode: false),
          ),
        ); // Navigate to HomeSiteLocation
      } else {
        // Simulate error in OTP verification
        throw Exception("Invalid OTP");
      }
    } catch (e) {
      // Set error message state
      ref.read(otpVerificationErrorProvider.state).state = e.toString();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "OTP Failed: ${e.toString().replaceAll("Exception:", "").trim()}",
          ),
        ),
      );
    } finally {
      // Set loading state to false
      ref.read(otpVerificationStateProvider.state).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = UHelperFunctions.isDarkMode(context);

    // Read loading and error states from Riverpod
    final isLoading = ref.watch(otpVerificationStateProvider);
    final errorMessage = ref.watch(otpVerificationErrorProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context); // Go back to the previous screen
            },
            icon: const Icon(CupertinoIcons.clear),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: UPadding.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Lottie Animation
              Image.asset(
                UImages.mailSentImage,
                height: UDeviceHelper.getScreenWidth(context) * 0.6,
              ),
              SizedBox(height: USizes.spaceBtwItems),

              // Title
              Text(
                UTexts.verifyYourOtp,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: USizes.spaceBtwItems),

              // Phone number display
              Text(
                '+88${widget.phoneNumber}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: USizes.spaceBtwItems),

              // Subtitle
              Text(
                'Enter the 5-digit code sent to your number',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: USizes.spaceBtwSections),

              // OTP Pinput with autofill
              Center(
                child: Pinput(
                  length: 5,
                  controller: _otpController, // Bind the OTP controller here
                  defaultPinTheme: PinTheme(
                    height: 56,
                    width: 56,
                    textStyle: Theme.of(context).textTheme.titleLarge,
                    decoration: BoxDecoration(
                      color: dark ? UColors.darkGrey : UColors.light,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: UColors.primary),
                    ),
                  ),
                  onCompleted: (otp) async {
                    // Trigger OTP verification after completion
                    await _verifyOtp(otp); // Trigger verification
                  },
                ),
              ),

              const SizedBox(height: USizes.spaceBtwItems),

              // Resend button
              TextButton(
                onPressed: () {
                  // TODO: Add resend logic here
                },
                child: Text(UTexts.resendOTP),
              ),

              // Show error message if any
              if (errorMessage != null) ...[
                const SizedBox(height: USizes.spaceBtwItems),
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],

              // Loading indicator while verifying OTP
              if (isLoading) const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
