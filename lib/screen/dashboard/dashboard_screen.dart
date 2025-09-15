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

import 'package:timeless/service/pref_services.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/asset_res.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/utils/string.dart';

// ⬇️ bouton DEV (debug only)
import 'package:timeless/test/dev_fab.dart';

/// --- Palette Jamaïque ---
const _kJBlack = Colors.black; // fond
const _kJYellow = Color(0xFFFED100); // actif
const _kJGreen = Color(0xFF1FA24A); // inactif

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
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,

        body: GetBuilder<DashBoardController>(
          id: "bottom_bar",
          builder: (c) {
            switch (c.currentTab) {
              case 0:
                return token.isEmpty
                    ? const HomePageNewScreenU()
                    : HomeScreen();
              case 1:
                return const AppliesLogoScreen();
              case 2:
                return token.isEmpty
                    ? const InboxLogoScreen()
                    : ChatBoxUserScreen();
              default:
                return token.isEmpty
                    ? const ProfileLogoScreen()
                    : EditProfileUserScreen();
            }
          },
        ),

        // FAB supprimé pour démo propre

        bottomNavigationBar: GetBuilder<DashBoardController>(
          id: "bottom_bar",
          builder: (c) {
            return Theme(
              data: Theme.of(context).copyWith(
                canvasColor: _kJBlack, // fond de la barre
              ),
              child: BottomNavigationBar(
                currentIndex: c.currentTab,
                onTap: c.onBottomBarChange,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: _kJYellow,
                unselectedItemColor: _kJGreen.withOpacity(0.85),
                showUnselectedLabels: true,
                items: [
                  BottomNavigationBarItem(
                    icon: Image.asset(AssetRes.home,
                        height: 18, width: 18, color: _kGreenOrYellow(c, 0)),
                    label: "Home",
                  ),
                  BottomNavigationBarItem(
                    icon: Image.asset(AssetRes.applies,
                        height: 18, width: 18, color: _kGreenOrYellow(c, 1)),
                    label: "Applies",
                  ),
                  BottomNavigationBarItem(
                    icon: Image.asset(AssetRes.chat,
                        height: 18, width: 18, color: _kGreenOrYellow(c, 2)),
                    label: "Inbox",
                  ),
                  BottomNavigationBarItem(
                    icon: Image.asset(AssetRes.profile1,
                        height: 18, width: 18, color: _kGreenOrYellow(c, 3)),
                    label: Strings.profile,
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
      c.currentTab == i ? _kJYellow : _kJGreen.withOpacity(0.85);
}
