import 'package:flutter/material.dart';

class HomePageNewScreenU extends StatelessWidget {
  const HomePageNewScreenU({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // fond neutre
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// Exemple avec RichText multicolore
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  children: const [
                    TextSpan(
                      text: "Timeless ",
                      style: TextStyle(color: Colors.green), // Vert Jamaïque
                    ),
                    TextSpan(
                      text: "Job ",
                      style:
                          TextStyle(color: Color(0xFFFED100)), // Jaune Jamaïque
                    ),
                    TextSpan(
                      text: "Search",
                      style: TextStyle(color: Colors.black), // Noir Jamaïque
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// Variante slogan en RichText
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: "Find ",
                      style: TextStyle(color: Colors.green),
                    ),
                    TextSpan(
                      text: "your ",
                      style: TextStyle(color: Color(0xFFFED100)),
                    ),
                    TextSpan(
                      text: "future",
                      style: TextStyle(color: Colors.black),
                    ),
                    TextSpan(
                      text: " today.",
                      style: TextStyle(
                          color: Colors.white, backgroundColor: Colors.black),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              /// Exemple bouton stylisé aux couleurs Jamaïcaines
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1FA24A), // vert
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  shadowColor: Colors.black.withOpacity(0.5),
                  elevation: 6,
                ),
                onPressed: () {},
                child: const Text(
                  "Start Now",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color.fromARGB(255, 255, 208, 0), // texte jaune
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
