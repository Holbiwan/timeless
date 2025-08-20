import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeless/api/api_country.dart';
import 'package:timeless/screen/introducation_screen/introducation_screen.dart' as intro;
import 'package:timeless/screen/splashScreen/splash_controller.dart';
import 'package:timeless/service/pref_services.dart';
import 'package:timeless/utils/asset_res.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/utils/string.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SplashController controller = Get.put(SplashController());

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  /// Prépare les prefs + données puis lance le timer
  Future<void> _bootstrap() async {
    await PrefService.init();

    if (PrefService.getList(PrefKeys.allDesignation).isEmpty ||
        PrefService.getList(PrefKeys.allCountryData).isEmpty) {
      await _loadCountryData();
    }

    // Vers l’intro après 3 secondes
    Timer(const Duration(seconds: 3), () {
      Get.offAll(() => intro.IntroductionScreen());
    });
  }

  /// Pré-charge l’image pour éviter le flash blanc
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(AssetRes.splashScreenBack), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // fond net et uniforme
      body: SafeArea(
        child: Stack(
          children: [
            /// --- HERO IMAGE (grande, bien cadrée) ---
            Positioned.fill(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 3 / 4, // évite l’écrasement sur mobiles longs
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      AssetRes.splashScreenBack, // on réutilise cette image
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
              ),
            ),

            /// --- CARTOUCHE DE TITRE EN HAUT ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Carte blanche avec texte
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            height: 1.05,
                            color: Colors.black,
                          ),
                          children: const [
                            TextSpan(text: 'Find Your\n'),
                            TextSpan(text: 'dream job\n'),
                            TextSpan(text: 'here'),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Bouton loupe
                  Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child:
                        const Icon(Icons.search, size: 28, color: Colors.black),
                  ),
                ],
              ),
            ),

            /// --- LOGO TEXTE EN HAUT À DROITE (optionnel, comme avant) ---
            Positioned(
              top: 12,
              right: 16,
              child: Text(
                Strings.logo,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: ColorRes.splashLogoColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadCountryData() async {
    controller.countryData = await CountrySearch.countNotification();

    for (final country in controller.countryData ?? []) {
      controller.allData.add(country.name ?? "");
      for (final state in country.state ?? []) {
        controller.allData.add(state.name ?? "");
        for (final city in state.city ?? []) {
          controller.allData.add(city.name ?? "");
        }
      }
    }

    if (kDebugMode) {
      print(PrefService.getList(PrefKeys.allDesignation));
    }

    if (PrefService.getList(PrefKeys.allCountryData).isEmpty) {
      PrefService.setValue(PrefKeys.allCountryData, controller.allData);
    }
    if (PrefService.getList(PrefKeys.allDesignation).isEmpty) {
      PrefService.setValue(PrefKeys.allDesignation, controller.allDesignation);
    }
  }
}
