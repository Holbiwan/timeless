import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/common/widgets/back_button.dart';
import 'package:timeless/screen/manager_section/Notification/notification_services.dart';
import 'package:timeless/screen/manager_section/applicants_detail_screen/applicants_details_controller.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/asset_res.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/string.dart';

// ignore: must_be_immutable
class NotificationScreenM extends StatelessWidget {
  NotificationScreenM({super.key});
  ApplicantsDetailsController anscontro =
      Get.put(ApplicantsDetailsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorRes.backgroundColor,
      body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: backButton(),
                  ),
                ),
                const SizedBox(width: 60),
                Text(
                  Strings.notification,
                  style: appTextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      height: 1,
                      color: ColorRes.black),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: Get.height - 150,
              child: ListView.builder(
                padding: const EdgeInsets.all(0),
                itemCount: 5,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    margin:
                        const EdgeInsets.only(left: 18, right: 18, bottom: 20),
                    padding: const EdgeInsets.all(15),
                    width: Get.width,
                    decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(15),
                        ),
                        border: Border.all(
                          color: const Color(0xffF3ECFF),
                        ),
                        color: ColorRes.white),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 80,
                          child: Image(
                            image: AssetImage(AssetRes.rightLogo),
                          ),
                        ),
                        SizedBox(
                          height: 92,
                          width: Get.width / 1.5 - 26,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  anscontro.selectedValue ??
                                      NotificationService.noti["title"],

                                  // 'Your application to Apple Company has been read',
                                  style: appTextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: ColorRes.black),
                                ),
                                Text(
                                  anscontro.selectedValue ??
                                      NotificationService.noti["body"],
                                  //'17.00',
                                  style: appTextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: ColorRes.black.withOpacity(0.5),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ]),
    );
  }
}
