import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/token_manager.dart';
import '../../../view_models/get_x/auth_controller.dart';
import 'login_screen.dart';
import '../main_screen.dart';

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
      duration: const Duration(milliseconds: 1800),
    );

    _containerSlide = Tween<Offset>(
      begin: const Offset(0.0, 1.3),
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
            () => const MainScreen(),
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final double scaleFactor = (screenWidth / 390).clamp(0.85, 1.5);
    final double logoSize = (200 * scaleFactor).clamp(140.0, 280.0);
    final double titleFontSize = 22 * scaleFactor;
    final double subtitleFontSize = 13 * scaleFactor;

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
                            width: logoSize,
                            height: logoSize,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.business_center_rounded,
                                size: logoSize * 0.5,
                                color: const Color(0xFF4E54C8),
                              );
                            },
                          ),
                          Text(
                            'Smart AIG - Front Desk App',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Administrative Info Group',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: subtitleFontSize,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                              letterSpacing: (5.0 * scaleFactor).clamp(2.0, 7.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 25, right: 25, bottom: 40),
                child: Container(
                  width: double.infinity,
                  height: 14,
                  margin: const EdgeInsets.symmetric(horizontal: 50),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF4E54C8).withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Center(
                    child: SizedBox(
                      height: 5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: LinearProgressIndicator(
                          borderRadius: const BorderRadius.all(Radius.circular(20)),
                          color: const Color(0xFF4E54C8),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    ),
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
