import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/token_manager.dart';
import '../../../view_models/get_x/auth_controller.dart';
import 'login_screen.dart';
import '../dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _containerController;
  late Animation<Offset> _containerSlide;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _updateSystemUI();
    _setupAnimation();
    _startAnimation();
    _startTimer();
  }

  void _updateSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFFE9D5FF),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  void _setupAnimation() {
    _containerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _containerSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _containerController,
        curve: Curves.easeOutBack,
      ),
    );
  }

  void _startAnimation() {
    _containerController.forward();
  }

  void _startTimer() {
    _timer = Timer(const Duration(seconds: 3), () async {
      try {
        String? token = await TokenManager.getToken();

        if (!mounted) return;

        if (token != null && token.isNotEmpty) {
          final authController = Get.put(AuthController());
          authController.token.value = token;

          Get.offAll(
            () => const FrontDeskDashboard(),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 500),
          );
        } else {
          Get.offAll(
            () => const LoginScreen(),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 500),
          );
        }
      } catch (e) {
        debugPrint("Splash Error: $e");
        if (mounted) {
          Get.offAll(() => const LoginScreen());
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _containerController.dispose();
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
            children: [
              Expanded(
                child: Center(
                  child: SlideTransition(
                    position: _containerSlide,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "assets/images/splash_logo.png",
                            width: 200,
                            height: 200,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.business_center_rounded,
                                size: 100,
                                color: Color(0xFF4E54C8),
                              );
                            },
                          ),
                          Text(
                            'SMART AIG FRONT DESK',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF2C3E50),
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ADMINISTRATIVE INFORMATIVE GROUP',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 80,
                  right: 80,
                  bottom: 40,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    color: const Color(0xFF4E54C8),
                    backgroundColor: Colors.white.withValues(alpha: 0.6),
                    minHeight: 5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
