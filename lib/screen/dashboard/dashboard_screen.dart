import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:timeless/screen/applies_logo_screen/applies_logo_screen.dart';
// Import supprimé : chat_box_user_screen.dart n'existe plus
import 'package:timeless/screen/dashboard/dashboard_controller.dart';
import 'package:timeless/screen/dashboard/home/home_screen.dart';
import 'package:timeless/screen/dashboard/widget.dart';
import 'package:timeless/screen/inbox_logo_screen/inbox_logo_screen.dart';
import 'package:timeless/screen/new_home_page/new_home_page_screen.dart';
import 'package:timeless/screen/profile_logo_screen/profile_logo_screen.dart';
import 'package:timeless/screen/profile/edit_profile_user/edit_profile_user_screen.dart';
import 'package:timeless/screen/profile/profile_view_screen.dart';

import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/asset_res.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/utils/string.dart';
import 'package:timeless/utils/color_res.dart';

// --- Palette avec icônes noires ---
const _kBlack = Color(0xFF000000); // noir pour icônes

class DashBoardScreen extends StatelessWidget {
  DashBoardScreen({super.key});

  final DashBoardController controller = Get.put(DashBoardController());

  @override
  Widget build(BuildContext context) {
    final String token = PreferencesService.getString(PrefKeys.userId);

    return WillPopScope(
      onWillPop: () async {
        alertU(context);
        return true;
      },
      child: Scaffold(
        backgroundColor: ColorRes.backgroundColor,
        resizeToAvoidBottomInset: false,
        body: GetBuilder<DashBoardController>(
          id: "bottom_bar",
          builder: (c) {
            switch (c.currentTab) {
              case 0:
                return token.isEmpty
                    ? const HomePageNewScreenU()
                    : HomeScreen();
              default:
                return token.isEmpty
                    ? const ProfileLogoScreen()
                    : const ProfileViewScreen();
            }
          },
        ),
        bottomNavigationBar: GetBuilder<DashBoardController>(
          id: "bottom_bar",
          builder: (c) {
            return Theme(
              data: Theme.of(context).copyWith(
                canvasColor: Colors.black, // fond noir
              ),
              child: BottomNavigationBar(
                currentIndex: c.currentTab,
                onTap: c.onBottomBarChange,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.white,
                showUnselectedLabels: true,
                items: [
                  BottomNavigationBarItem(
                    icon: Image.asset(AssetRes.home,
                        height: 18, width: 18, color: Colors.white),
                    label: "Home",
                  ),
                  BottomNavigationBarItem(
                    icon: Image.asset(AssetRes.profile1,
                        height: 18, width: 18, color: Colors.white),
                    label: "Profile",
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
