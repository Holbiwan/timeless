import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/utils/asset_res.dart';
import 'package:timeless/utils/color_res.dart';

Widget backButton() {
  return InkWell(
    onTap: () {
      Get.back();
    },
    child: Container(
      height: 36,
      width: 36,
      decoration: BoxDecoration(
        color: ColorRes.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: ColorRes.darkGold,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: ColorRes.darkGold.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.arrow_back_ios_new_rounded,
        color: ColorRes.darkGold,
        size: 18,
      ),
    ),
  );
}

Widget logo() {
  return Container(
    alignment: Alignment.center,
    height: 40,
    width: 40,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(13),
    ),
    child: const Image(
      image: AssetImage(AssetRes.logo),
    ),
  );
}
