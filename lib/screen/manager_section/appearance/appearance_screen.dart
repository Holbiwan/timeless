import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:timeless/common/widgets/back_button.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/color_res.dart';
import 'appearance_controller.dart';

class AppearanceScreenM extends StatelessWidget {
  const AppearanceScreenM({super.key});

  @override
  Widget build(BuildContext context) {
    AppearanceControllerM controller = Get.put(AppearanceControllerM());

    return Scaffold(
      backgroundColor: ColorRes.backgroundColor,
      body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: backButton(),
                  ),
                ),
                const SizedBox(width: 67),
                Text(
                  'Appearance',
                  style: appTextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      height: 1,
                      color: ColorRes.black),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    'Dark Mode',
                    style: appTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: ColorRes.black),
                  ),
                ),
                const Spacer(),
                // SizedBox(width: Get.width - 170),
                Obx(() => FlutterSwitch(
                    height: 27,
                    width: 45,
                    value: controller.isSwitchedDarkMode.value,
                    activeColor: ColorRes.blueColor,
                    toggleSize: 20,
                    onToggle: (value) => controller.onchangeDarkMode(value))),
                const SizedBox(width: 15),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              color: ColorRes.lightGrey.withOpacity(0.8),
              height: 1,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    'Blur Background',
                    style: appTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: ColorRes.black),
                  ),
                ),
                const Spacer(),
                // SizedBox(width: Get.width - 210),
                Obx(() => FlutterSwitch(
                    height: 27,
                    width: 45,
                    value: controller.isSwitchedBlurBackground.value,
                    activeColor: ColorRes.blueColor,
                    toggleSize: 20,
                    onToggle: (value) => controller.onchangeBackground(value))),
                const SizedBox(width: 15),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              color: ColorRes.lightGrey.withOpacity(0.8),
              height: 1,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    'Full Screen Mode',
                    style: appTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: ColorRes.black),
                  ),
                ),
                const Spacer(),
                // SizedBox(width: Get.width - 211),
                Obx(() => FlutterSwitch(
                    height: 27,
                    width: 45,
                    value: controller.isSwitchedFullScreenMode.value,
                    activeColor: ColorRes.blueColor,
                    toggleSize: 20,
                    onToggle: (value) =>
                        controller.onchangeFullScreenMode(value))),
                const SizedBox(width: 15),
              ],
            ),
          ]),
    );
  }
}
