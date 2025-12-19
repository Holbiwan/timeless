import 'package:flutter/material.dart';

class HomePageNewScreenU extends StatelessWidget {
  const HomePageNewScreenU({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 115, 3, 12),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: "Timeless ",
                      style: TextStyle(color: Colors.green),
                    ),
                    TextSpan(
                      text: "Job ",
                      style:
                          TextStyle(color: Color(0xFFFED100)),
                    ),
                    TextSpan(
                      text: "Search",
                      style: TextStyle(
                          color: Color.fromARGB(
                              255, 255, 255, 255)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "Find your future today.",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 15, 15, 15),
                  foregroundColor: const Color.fromARGB(255, 255, 251, 1),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  shadowColor: Colors.black.withOpacity(0.5),
                  elevation: 6,
                ),
                onPressed: null,
                child: Text(
                  "Start your journey today",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color.fromARGB(255, 255, 255, 0),
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
