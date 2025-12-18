import 'package:flutter/material.dart';
import 'package:timeless/utils/color_res.dart';

class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 3),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          color: ColorRes.lightGrey.withOpacity(0.8),
          height: 1,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}