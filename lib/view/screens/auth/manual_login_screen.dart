import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/app_snackbar.dart';
import '../../../utils/token_manager.dart';
import '../../../view_models/get_x/auth_controller.dart';
import '../main_screen.dart';

class ManualLoginScreen extends StatefulWidget {
  final String? initialPhone;
  const ManualLoginScreen({super.key, this.initialPhone});

  @override
  State<ManualLoginScreen> createState() => _ManualLoginScreenState();
}

class _ManualLoginScreenState extends State<ManualLoginScreen> {
  final AuthController _authController = Get.find<AuthController>();
  late final TextEditingController _phoneController;
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.initialPhone ?? '');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _otpFocusNode.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  void _submitManualLogin() async {
    final phone = _phoneController.text.trim();
    final otp = _otpController.text.trim();

    if (phone.length != 10) {
      AppSnackbar.showError(
        title: 'Invalid Mobile Number',
        message: 'Please enter a valid 10-digit mobile number.',
      );
      return;
    }

    if (otp.length != 6) {
      AppSnackbar.showError(
        title: 'Invalid OTP Code',
        message: 'Please enter a valid 6-digit manual OTP code.',
      );
      return;
    }

    final uuid = await TokenManager.getDeviceUuid();
    final isIos = defaultTargetPlatform == TargetPlatform.iOS;
    bool success = await _authController.verifyOtp(
      whatsappNumber: phone,
      otpCode: otp,
      deviceUuid: uuid,
      deviceName: isIos ? 'iPhone' : 'Android Phone',
      deviceOs: isIos ? 'iOS' : 'Android',
    );

    if (success) {
      Get.offAll(() => const MainScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD1E9FF),
      body: Stack(
        children: [
          // Background Gradient Base (Matching LoginScreen)
          Container(
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
          ),



          // Main Scrollable Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Navigation Bar (Back button)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: IconButton(
                    onPressed: () => Get.back(),
                    constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2C3E50), size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                      elevation: 2,
                      shadowColor: Colors.black.withValues(alpha: 0.08),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),

                        // Title & Subtitle
                        Text(
                          'Manual OTP Login',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Contact Your School Administration To Get a Temporary OTP',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF64748B),
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Attention Required Warning Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED), // Warm Cream / Peach
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFFFEDD5),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 2.0),
                                child: Icon(
                                  Icons.warning_amber_rounded,
                                  color: Color(0xFF9A3412),
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Attention Required',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF9A3412),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Use This Option Only If You Did Not Receive Your WhatsApp OTP. Contact School Admin With Registered Mobile Number To Get a Temporary OTP.',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.5,
                                        height: 1.4,
                                        color: const Color(0xFFC2410C),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Input 1: Registered Mobile Number
                        Text(
                          'Registered Mobile Number',
                          style: GoogleFonts.poppins(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _phoneController,
                            focusNode: _phoneFocusNode,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF1E293B),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              counterText: "",
                              hintText: 'Enter mobile number',
                              hintStyle: GoogleFonts.poppins(
                                color: const Color(0xFF94A3B8),
                                fontSize: 14.5,
                                fontWeight: FontWeight.w400,
                              ),
                              prefixIcon: const Icon(
                                Icons.call,
                                color: Color(0xFF475569),
                                size: 20,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: Color(0xFF22C55E), width: 1.5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Input 2: Enter Temporary OTP (Provided By School Admin)
                        Text(
                          'Enter Temporary OTP (Provided By School Admin)',
                          style: GoogleFonts.poppins(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            _otpFocusNode.requestFocus();
                          },
                          child: Container(
                            height: 56,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _otpFocusNode.hasFocus ? const Color(0xFF22C55E) : Colors.transparent,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.confirmation_number_outlined,
                                      color: Color(0xFF475569),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: List.generate(6, (index) {
                                          final text = _otpController.text;
                                          final hasChar = index < text.length;
                                          final char = hasChar ? text[index] : '-';

                                          return Text(
                                            char,
                                            style: GoogleFonts.poppins(
                                              fontSize: hasChar ? 20 : 18,
                                              fontWeight: FontWeight.bold,
                                              color: hasChar ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                  ],
                                ),

                                // Invisible text field for seamless input capture
                                Positioned.fill(
                                  child: Opacity(
                                    opacity: 0.0,
                                    child: TextField(
                                      controller: _otpController,
                                      focusNode: _otpFocusNode,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(6),
                                      ],
                                      cursorColor: Colors.transparent,
                                      showCursor: false,
                                      enableInteractiveSelection: false,
                                      onChanged: (val) {
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Login Action Button
                        Obx(() => SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: _authController.isLoading.value ? null : _submitManualLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF22C55E), // Vibrant Green matching screenshot
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 0,
                                ),
                                child: _authController.isLoading.value
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        'Login With Manual OTP',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            )),
                        const SizedBox(height: 18),

                        // Footer Security Note
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.lock_rounded,
                              size: 14,
                              color: Color(0xFF1E293B),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Manual OTP Is Valid For Limited Time And Single Use Only.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 35),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
