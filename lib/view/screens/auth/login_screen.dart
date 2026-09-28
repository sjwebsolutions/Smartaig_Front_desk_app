import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/app_snackbar.dart';
import '../../../view_models/get_x/auth_controller.dart';
import 'manual_login_screen.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool justLoggedOut;
  final bool sessionExpired;

  const LoginScreen({
    super.key,
    this.justLoggedOut = false,
    this.sessionExpired = false,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController _authController = Get.put(AuthController());
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.sessionExpired) {
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) {
          AppSnackbar.showError(
            title: 'Logged Out',
            message: 'Logged in from another device or session expired. Please log in again.',
          );
        }
      });
    } else if (widget.justLoggedOut) {
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) {
          AppSnackbar.showSuccess(
            title: 'Logout Successful',
            message: 'You have been successfully logged out.',
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFD1E9FF), // Vibrant Light Blue
              Color(0xFFE9D5FF), // Vibrant Light Purple
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 50),
                // Logo Container
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/login_logo.png',
                    height: 170,
                    width: 170,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.business_center_rounded,
                      size: 75,
                      color: Color(0xFF4E54C8),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  'Front Desk Login',
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Enter your Registered Mobile Number',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 35),

                // Input Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mobile Number',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 18,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          counterText: "",
                          hintText: '0000000000',
                          hintStyle: const TextStyle(
                            color: Color(0xFF94A3B8),
                            letterSpacing: 2,
                          ),
                          prefixIcon: const Icon(
                            Icons.phone_android_rounded,
                            color: Color(0xFF16A34A),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Color(0xFF16A34A), width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Obx(() => SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _authController.isLoading.value
                                  ? null
                                  : () async {
                                      if (_phoneController.text.length == 10) {
                                        bool success = await _authController.sendOtp(
                                          whatsappNumber: _phoneController.text,
                                          deviceUuid: 'device-uuid-12345',
                                          deviceName: 'Android Phone',
                                          deviceOs: 'Android',
                                        );
                                        if (success) {
                                          Get.to(() => OtpScreen(whatsappNumber: _phoneController.text));
                                        }
                                      } else {
                                         AppSnackbar.showError(
                                           title: 'Invalid Mobile Number',
                                           message: 'Please enter a valid 10-digit WhatsApp mobile number.',
                                         );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF16A34A),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 0,
                              ),
                              child: _authController.isLoading.value
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Send OTP',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          )),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Get.to(() => ManualLoginScreen(
                                  initialPhone: _phoneController.text.trim(),
                                ));
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          ),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text: "Didn't receive OTP? ",
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                              children: [
                                TextSpan(
                                  text: "Use Manual OTP",
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: const Color(0xFF16A34A),
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),

                // Footer Info Boxes
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoBox(
                        Icons.shield_outlined,
                        'Secure AES-256\nencrypted access',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoBox(
                        Icons.verified_user_outlined,
                        'Institutional verified\ngateway.',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4E54C8), size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: const Color(0xFF475569),
                height: 1.2,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
