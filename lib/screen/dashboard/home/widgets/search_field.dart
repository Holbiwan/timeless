import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/screen/dashboard/home/home_controller.dart';
import 'package:timeless/screen/job_recommendation_screen/job_recommendation_controller.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/color_res.dart';

Widget searchArea() {
  final HomeController controller = HomeController();
  final jrController = Get.put(JobRecommendationController());

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 18),
    child: Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: ColorRes.white2,
              border: Border.all(
                color: const Color.fromARGB(255, 0, 6, 71).withOpacity(0.3),
                width: 1.5,
              ),
              borderRadius: const BorderRadius.all(
                Radius.circular(8),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 0, 6, 71).withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: controller.searchNewController,
              onChanged: (value) {
                jrController.searchText.value = value;
                jrController.update(["search"]);
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                suffixIcon: Icon(Icons.search, 
                  color: const Color.fromARGB(255, 0, 6, 71).withOpacity(0.7)),
                hintText: "Search",
                hintStyle: appTextStyle(
                    fontSize: 14,
                    color: ColorRes.grey.withOpacity(0.8),
                    fontWeight: FontWeight.w400),
                contentPadding: const EdgeInsets.only(left: 20, top: 13),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
