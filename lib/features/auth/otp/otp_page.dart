import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'otp_controller.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  late final OtpController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<OtpController>()
        ? Get.find<OtpController>()
        : Get.put(OtpController(), permanent: true);
    final arguments = Get.arguments;
    if (arguments is Map) {
      controller.email = arguments['email']?.toString() ?? '';
      controller.flow = arguments['flow']?.toString() ?? 'signup';
    }
    controller.otpController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Verify OTP',
          style: TextStyle(color: Color(0xFF1E293B)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF334155)),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 48),
                Image.asset('assets/images/spLogo.png', width: 160),
                const SizedBox(height: 24),
                Text(
                  'Code sent to ${controller.email}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: controller.otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'Enter 4-digit OTP',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: Color(0xFF0D477D)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.verifyEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D477D),
                        disabledBackgroundColor:
                            const Color(0xFF0D477D).withOpacity(0.55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Verify',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}