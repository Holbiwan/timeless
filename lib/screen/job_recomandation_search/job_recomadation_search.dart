import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/common/widgets/back_button.dart';
import 'package:timeless/screen/dashboard/home/widgets/all_jobs.dart';
import 'package:timeless/screen/dashboard/home/widgets/search_field.dart';
import 'package:timeless/screen/job_recomandation_search/job_recomandation_search_controller.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/string.dart';

class JobRecomandationSearch extends StatelessWidget {
  JobRecomandationSearch({super.key});
  final controller = Get.put(JobRecomandationSearchController());

  @override
  Widget build(BuildContext context) {
    controller.totalJobs();
    return Scaffold(
      backgroundColor: ColorRes.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: backButton(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 25.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      Strings.jobRecommendation,
                      style: appTextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          height: 1,
                          color: ColorRes.black),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            searchArea(),
            const SizedBox(
              height: 10,
            ),
            GetBuilder<JobRecomandationSearchController>(
                id: "length",
                builder: (con) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 18.0),
                    child: Text("${con.totalLength} jobs"),
                  );
                }),
            const SizedBox(
              height: 10,
            ),
            /* Container(
              padding: const EdgeInsets.only(left: 20, right: 20),
              height: 32,
              child: ListView.builder(
                  itemCount: controller.jobs2.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => controller.onTapJobs2(index),
                      child: Obx(() => Container(
                        margin: const EdgeInsets.only(right: 10),
                        height: 32,
                        width: 70,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: ColorRes.containerColor, width: 2),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                            ),
                            color: controller.selectedJobs2.value == index
                                ? ColorRes.containerColor
                                : ColorRes.white),
                        child: Text(
                          controller.jobs2[index],
                          style: appTextStyle(
                              color: controller.selectedJobs2.value == index
                                  ? ColorRes.white
                                  : ColorRes.containerColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      )),
                    );
                  }),
            ),*/
            GetBuilder<JobRecomandationSearchController>(
                builder: (con) => allJobs(
                    FirebaseFirestore.instance
                        .collection("allPost")
                        .snapshots(),
                    seeAll: true)
                /*: controller.selectedJobs2.value == 1
                ? allJobs(fireStore
                .collection("category")
                .doc("UX")
                .collection("UX")
                .snapshots())
                : controller.selectedJobs2.value == 2
                ? allJobs(fireStore
                .collection("category")
                .doc("Design")
                .collection("Design")
                .snapshots())
                : controller.selectedJobs2.value == 3
                ? allJobs(fireStore
                .collection("category")
                .doc("UX")
                .collection("UX")
                .snapshots())
                : Center(
              child: Text(controller
                  .jobs2[controller.selectedJobs2.value]),*/
                //      )
                ),
          ],
        ),
      ),
    );
  }
}
