import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:timeless/utils/asset_res.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/app_res.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Petite attente, puis navigation vers la première page
    Future.microtask(() async {
      await Future.delayed(const Duration(milliseconds: 1200));
      Get.offAllNamed(AppRes.firstScreen); // adapte si tu veux aller ailleurs
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.white,
      body: Center(
        child: Image.asset(AssetRes.logo, height: 96),
      ),
    );
  }
}
