import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/common/widgets/back_button.dart';
import 'package:timeless/service/pref_services.dart';
import 'package:timeless/utils/app_res.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/utils/string.dart';

Widget homeAppBar() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    margin: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: ColorRes.cardColor,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(
        color: ColorRes.borderColor,
        width: 1,
      ),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ColorRes.primaryAccent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: logo(),
        ),
        Expanded(
          child: Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  Strings.hello,
                  style: appTextStyle(
                      color: ColorRes.textSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 2),
                Text(
                  PrefService.getString(PrefKeys.fullName),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: appTextStyle(
                      color: ColorRes.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () => Get.toNamed(AppRes.notificationScreen),
          child: Container(
            height: 44,
            width: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ColorRes.primaryAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_rounded,
              color: ColorRes.white,
              size: 22,
            ),
          ),
        ),
      ],
    ),
  );
}
