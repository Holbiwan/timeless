import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/common/widgets/back_button.dart';
import 'package:timeless/screen/job_detail_screen/job_detail_upload_cv_screen/upload_cv_controller.dart';
import 'package:timeless/screen/manager_section/manager_home_screen/manager_home_screen_controller.dart';
import 'package:timeless/screen/manager_section/manager_home_screen/manager_home_screen_widget/manager_home_screen_widget.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/string.dart';

// ignore: must_be_immutable
class RecentApplicationScreen extends StatelessWidget {
  RecentApplicationScreen({super.key});
  JobDetailsUploadCvController jobDetailsUploadCvController =
      Get.put(JobDetailsUploadCvController());

  @override
  Widget build(BuildContext context) {
    jobDetailsUploadCvController.init();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorRes.backgroundColor,
      body: Column(
        children: [
          const SizedBox(height: 55),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: backButton(),
                ),
              ),
              SizedBox(width: Get.width - 350),
              Text(
                Strings.recentPeopleApplication,
                style: appTextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    height: 1,
                    color: ColorRes.black),
              ),
            ],
          ),
          // const SizedBox(height: 5),
          //  searchArea(),
          //   const SizedBox(height: 12),
          GetBuilder<ManagerHomeScreenController>(
              id: "userDataSeeAll",
              builder: (con) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20,),
                    child: InkWell(
                        //  onTap: () => Get.toNamed(AppRes.applicantsDetails),
                        child: recentPeopleBox()),
                  ),
                );
              }),
        ],
      ),
    );
  }
}
