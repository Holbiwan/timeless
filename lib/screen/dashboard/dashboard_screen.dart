import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import 'package:timeless/screen/applies_logo_screen/applies_logo_screen.dart';
import 'package:timeless/screen/chat_box_user/chat_box_user_screen.dart';
import 'package:timeless/screen/dashboard/dashboard_controller.dart';
import 'package:timeless/screen/dashboard/home/home_screen.dart';
import 'package:timeless/screen/dashboard/widget.dart';
import 'package:timeless/screen/inbox_logo_screen/inbox_logo_screen.dart';
import 'package:timeless/screen/new_home_page/new_home_page_screen.dart';
import 'package:timeless/screen/profile/profile_screen.dart';
import 'package:timeless/screen/profile_logo_screen/profile_logo_screen.dart';
import 'package:timeless/service/pref_services.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/asset_res.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/utils/string.dart';

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

        /// Contenu selon l’onglet et selon authentification
        body: GetBuilder<DashBoardController>(
          id: "bottom_bar",
          builder: (c) {
            switch (c.currentTab) {
              case 0:
                return token.isEmpty ? HomePageNewScreenU() : HomeScreen();
              case 1:
                // Si tu as un vrai écran des candidatures, remplace par ApplicationsScreen()
                return token.isEmpty
                    ? const AppliesLogoScreen()
                    : const AppliesLogoScreen();
              case 2:
                return token.isEmpty
                    ? const InboxLogoScreen()
                    : ChatBoxUserScreen();
              default:
                return token.isEmpty
                    ? const ProfileLogoScreen()
                    : ProfileUserScreenU();
            }
          },
        ),

        /// Bottom Navigation – noir/jaune/vert, pleine largeur
        bottomNavigationBar: GetBuilder<DashBoardController>(
          id: "bottom_bar",
          builder: (c) {
            Color _iconColor(int i) =>
                c.currentTab == i ? _kJYellow : _kJGreen.withOpacity(0.85);

            TextStyle _labelStyle(int i) => appTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: c.currentTab == i
                      ? _kJYellow
                      : _kJGreen.withOpacity(0.85),
                );

            return SafeArea(
              top: false,
              child: Container(
                width: double.infinity,
                color: _kJBlack, // fond noir pleine largeur
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: SalomonBottomBar(
                  margin: EdgeInsets.zero,
                  backgroundColor: Colors.transparent,
                  currentIndex: c.currentTab,
                  selectedItemColor: _kJYellow,
                  unselectedItemColor: _kJGreen.withOpacity(0.85),
                  onTap: c.onBottomBarChange,
                  items: [
                    /// Home
                    SalomonBottomBarItem(
                      selectedColor: _kJYellow,
                      icon: Image.asset(
                        AssetRes.home,
                        height: 18,
                        width: 18,
                        color: _iconColor(0),
                      ),
                      title: Text("Home", style: _labelStyle(0)),
                    ),

                    /// Applies
                    SalomonBottomBarItem(
                      selectedColor: _kJYellow,
                      icon: Image.asset(
                        AssetRes.applies,
                        height: 18,
                        width: 18,
                        color: _iconColor(1),
                      ),
                      title: Text("Applies", style: _labelStyle(1)),
                    ),

                    /// Inbox
                    SalomonBottomBarItem(
                      selectedColor: _kJYellow,
                      icon: Image.asset(
                        AssetRes.chat,
                        height: 18,
                        width: 18,
                        color: _iconColor(2),
                      ),
                      title: Text("Inbox", style: _labelStyle(2)),
                    ),

                    /// Profile
                    SalomonBottomBarItem(
                      selectedColor: _kJYellow,
                      icon: Image.asset(
                        AssetRes.profile1,
                        height: 18,
                        width: 18,
                        color: _iconColor(3),
                      ),
                      title: Text(Strings.profile, style: _labelStyle(3)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
