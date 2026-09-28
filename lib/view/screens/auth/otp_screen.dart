import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../view_models/get_x/auth_controller.dart';
import '../dashboard.dart';

class OtpScreen extends StatefulWidget {
  final String whatsappNumber;
  const OtpScreen({super.key, required this.whatsappNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  Timer? _timer;
  int _start = 115; // 01:55 in seconds

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  void _startResendTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  String get _formattedTime {
    int minutes = _start ~/ 60;
    int seconds = _start % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _focusNode.dispose();
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2C3E50), size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 2,
                    shadowColor: Colors.black12,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      // Main Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
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
                          children: [
                            Text(
                              'Verify OTP',
                              style: GoogleFonts.poppins(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2C3E50),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Enter the 6-digit code sent to\n+91 ${widget.whatsappNumber}',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 35),

                            // Single Continuous Input Architecture (Zero Keyboard Jitter)
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                // Visual 6 OTP Boxes
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    _focusNode.requestFocus();
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: List.generate(6, (index) {
                                      final text = _otpController.text;
                                      final char = index < text.length ? text[index] : '';
                                      final isFocused = _focusNode.hasFocus &&
                                          (index == text.length || (index == 5 && text.length == 6));
                                      final isFilled = char.isNotEmpty;

                                      return AnimatedContainer(
                                        duration: const Duration(milliseconds: 150),
                                        width: 42,
                                        height: 58,
                                        decoration: BoxDecoration(
                                          color: isFocused
                                              ? Colors.white
                                              : isFilled
                                                  ? const Color(0xFFF1F5F9)
                                                  : const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(
                                            color: isFocused
                                                ? const Color(0xFF16A34A)
                                                : isFilled
                                                    ? const Color(0xFF64748B)
                                                    : const Color(0xFFCBD5E1),
                                            width: isFocused ? 2.0 : 1.2,
                                          ),
                                          boxShadow: isFocused
                                              ? [
                                                  BoxShadow(
                                                    color: const Color(0xFF16A34A).withValues(alpha: 0.2),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Center(
                                          child: Text(
                                            char,
                                            style: GoogleFonts.poppins(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF1E293B),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),

                                // Hidden Continuous TextField
                                Positioned.fill(
                                  child: Opacity(
                                    opacity: 0.0,
                                    child: TextField(
                                      controller: _otpController,
                                      focusNode: _focusNode,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(6),
                                      ],
                                      cursorColor: Colors.transparent,
                                      showCursor: false,
                                      enableInteractiveSelection: false,
                                      onChanged: (value) {
                                        setState(() {});
                                        if (value.length == 6) {
                                          _verifyOtp();
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 35),
                            // Timer or Resend Button
                            if (_start > 0)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.timer_outlined, color: Color(0xFF64748B), size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'OTP expires in ',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                  Text(
                                    _formattedTime,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF16A34A),
                                    ),
                                  ),
                                ],
                              )
                            else
                              TextButton.icon(
                                onPressed: _authController.isLoading.value
                                    ? null
                                    : () async {
                                        bool sent = await _authController.sendOtp(
                                          whatsappNumber: widget.whatsappNumber,
                                          deviceUuid: 'device-uuid-12345',
                                          deviceName: 'Android Phone',
                                          deviceOs: 'Android',
                                        );
                                        if (sent) {
                                          _otpController.clear();
                                          setState(() {
                                            _start = 115;
                                          });
                                          _focusNode.requestFocus();
                                          _startResendTimer();
                                        }
                                      },
                                icon: const Icon(Icons.refresh_rounded, color: Color(0xFF16A34A), size: 18),
                                label: Text(
                                  'Resend OTP',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF16A34A),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Obx(() => _authController.isLoading.value 
                        ? const CircularProgressIndicator(color: Color(0xFF16A34A))
                        : const SizedBox.shrink()
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _verifyOtp() async {
    if (_otpController.text.length != 6) return;

    bool success = await _authController.verifyOtp(
      whatsappNumber: widget.whatsappNumber,
      otpCode: _otpController.text,
      deviceUuid: 'device-uuid-12345',
      deviceName: 'Android Phone',
      deviceOs: 'Android',
    );
    if (success) {
      Get.offAll(() => const FrontDeskDashboard());
    } else {
      _otpController.clear();
      setState(() {});
      _focusNode.requestFocus();
    }
  }
}
