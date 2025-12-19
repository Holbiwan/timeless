import 'package:flutter/material.dart';
import 'package:timeless/utils/color_res.dart';

// Loading indicator widget used across the app
class CommonLoader extends StatelessWidget {
  const CommonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(35),
          height: 110,
          width: 110,
          decoration: BoxDecoration(
              color: ColorRes.white, borderRadius: BorderRadius.circular(25)),
          child: const CircularProgressIndicator(
            backgroundColor: Color(0x1A000647),
            color: Color(0xFF000647),
          ),
        ),
      ),
    );
  }
}
