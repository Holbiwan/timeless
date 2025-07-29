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
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: ColorRes.logoColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.arrow_back_ios_new_rounded,
        color: ColorRes.containerColor,
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
