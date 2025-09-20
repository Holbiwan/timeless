import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/screen/dashboard/dashboard_screen.dart';
import 'package:timeless/screen/new_home_page/new_home_page_screen.dart';

// Classes temporaires pour éviter les erreurs de build

class ManagerDashboardScreen extends StatelessWidget {
  const ManagerDashboardScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    // Rediriger vers le dashboard principal pour l'instant
    return DashBoardScreen();
  }
}

class NewHomePageScreen extends StatelessWidget {
  const NewHomePageScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    // Rediriger vers l'écran d'accueil existant
    return const HomePageNewScreenU();
  }
}