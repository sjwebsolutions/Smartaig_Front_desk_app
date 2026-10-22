import 'package:flutter/material.dart';
import 'package:front_desk_app/view/screens/settings_screen.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../view_models/get_x/unread_counter_controller.dart';
import 'dashboard.dart';
import 'get_pass_screen.dart';
import 'visitors_screen.dart';


import 'dart:io';

class MainNavigationController extends GetxController {
  static MainNavigationController get to => Get.put(MainNavigationController());

  final RxInt selectedIndex = 0.obs;

  void changeTab(int index) {
    if (index >= 0 && index < 5) {
      selectedIndex.value = index;
    }
  }
}

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final MainNavigationController _navController = Get.put(MainNavigationController());

  @override
  void initState() {
    super.initState();
    if (widget.initialIndex >= 0 && widget.initialIndex < 5) {
      _navController.selectedIndex.value = widget.initialIndex;
    }
  }

  final List<Widget> _screens = const [
    FrontDeskDashboard(),
    VisitorsScreen(),
    GetPassScreen(),
    SettingsScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentIndex = _navController.selectedIndex.value;

      Widget bottomNavBar = Container(
        margin: EdgeInsets.only(
          bottom: Platform.isIOS ? 25 : 0,
          left: 10,
          right: 10,
          top: 10,
        ),
        height: 68,
        decoration: BoxDecoration(
          color: const Color(0xFF0D2159), // Exact Dark Navy Blue background from design
          borderRadius: BorderRadius.circular(10),
        ),
        child: Obx(() {
          final unread = UnreadCounterController.to;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                currentIndex: currentIndex,
                icon: Icons.grid_view_rounded,
                label: 'Dashboard',
              ),
              _buildNavItem(
                index: 1,
                currentIndex: currentIndex,
                icon: Icons.groups_rounded,
                label: 'Visitors',
                badgeCount: unread.visitorCount.value,
              ),
              _buildNavItem(
                index: 2,
                currentIndex: currentIndex,
                icon: Icons.badge_rounded,
                label: 'Get Pass',
                badgeCount: unread.gatePassCount.value,
              ),
              _buildNavItem(
                index: 3,
                currentIndex: currentIndex,
                icon: Icons.settings,
                label: 'Settings',
                badgeCount: 0,
              ),
            ],
          );
        }),
      );

      if (Platform.isAndroid) {
        bottomNavBar = SafeArea(child: bottomNavBar);
      }

      return Container(
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
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: IndexedStack(
            index: currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: bottomNavBar,
        ),
      );
    });
  }

  Widget _buildNavItem({
    required int index,
    required int currentIndex,
    required IconData icon,
    required String label,
    int badgeCount = 0,
  }) {
    final isSelected = index == currentIndex;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _navController.changeTab(index);
          final unread = UnreadCounterController.to;
          switch (index) {
            case 1:
              unread.clearVisitor();
              break;
            case 2:
              unread.clearGatePass();
              break;
            case 3:
              unread.clearCallback();
              break;
            case 4:
              unread.clearAdmission();
              break;
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: -8,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                      child: Center(
                        child: Text(
                          badgeCount > 99 ? '99+' : '$badgeCount',
                          style: GoogleFonts.poppins(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
