import 'package:flutter/material.dart';
import 'package:timeless/utils/color_res.dart';

class LocalizationScreen extends StatelessWidget {
  const LocalizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Column(
      children: [
        SizedBox(
          height: 200,
          width: 200,
          child: Center(
            child: Text(
              'Choose a language',
              style: TextStyle(
                  color: ColorRes.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600),
            ),
          ),
        )
      ],
    ));
  }
}
