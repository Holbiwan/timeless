import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:timeless/screen/applies_logo_screen/applies_logo_screen.dart';
import 'package:timeless/screen/chat_box_user/chat_box_user_screen.dart';
import 'package:timeless/screen/dashboard/dashboard_controller.dart';
import 'package:timeless/screen/dashboard/home/home_screen.dart';
import 'package:timeless/screen/dashboard/widget.dart';
import 'package:timeless/screen/inbox_logo_screen/inbox_logo_screen.dart';
import 'package:timeless/screen/new_home_page/new_home_page_screen.dart';
import 'package:timeless/screen/profile_logo_screen/profile_logo_screen.dart';
import 'package:timeless/screen/profile/edit_profile_user/edit_profile_user_screen.dart';
import 'package:timeless/screen/profile/profile_view_screen.dart';

import 'package:timeless/service/pref_services.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/asset_res.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/utils/string.dart';
import 'package:timeless/utils/color_res.dart';


/// --- Palette Turquoise avec icônes Jaunes/Turquoise ---
const _kJBlack = Color(0xFF1A1A1A); // fond foncé lisible
const _kJYellow = Color(0xFFFBBF24); // jaune pour icônes inactives
const _kJGreen = Color(0xFF00ACC1); // turquoise pour icônes actives

class DashBoardScreen extends StatelessWidget {
  DashBoardScreen({super.key});

  final DashBoardController controller = Get.put(DashBoardController());

  @override
  Widget build(BuildContext context) {
    final String token = PrefService.getString(PrefKeys.userId);

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
                canvasColor: ColorRes.backgroundColor, // fond turquoise
              ),
              child: BottomNavigationBar(
                currentIndex: c.currentTab,
                onTap: c.onBottomBarChange,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: _kJGreen,
                unselectedItemColor: _kJYellow,
                showUnselectedLabels: true,
                items: [
                  BottomNavigationBarItem(
                    icon: Image.asset(AssetRes.home,
                        height: 18, width: 18, color: _kGreenOrYellow(c, 0)),
                    label: "Jobs",
                  ),
                  BottomNavigationBarItem(
                    icon: Image.asset(AssetRes.profile1,
                        height: 18, width: 18, color: _kGreenOrYellow(c, 1)),
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

  Color _kGreenOrYellow(DashBoardController c, int i) =>
      c.currentTab == i ? _kJGreen : _kJYellow;
}
