import 'package:flutter/material.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/color_res.dart';

// widget to show common error box
Widget commonErrorBox(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20), color: ColorRes.invalidColor),
    child: Row(
      children: [
        const Icon(
          Icons.error,
          color: ColorRes.starColor,
        ),
        const SizedBox(
          width: 20,
        ),
        Text(
          text,
          style: appTextStyle(
              color: ColorRes.starColor,
              fontWeight: FontWeight.w400,
              fontSize: 10),
        )
      ],
    ),
  );
}
