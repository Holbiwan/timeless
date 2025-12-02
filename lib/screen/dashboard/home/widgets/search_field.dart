import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Import supprimé : chat_box_controller.dart n'existe plus
// Import supprimé : chat_box_usercontroller.dart n'existe plus
import 'package:timeless/screen/dashboard/home/home_controller.dart';
import 'package:timeless/screen/job_recommendation_screen/job_recommendation_controller.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/color_res.dart';

Widget searchArea() {
  final HomeController controller = HomeController();
  final jrController = Get.put(JobRecommendationController());
  // ChatBoxUserController supprimé - fonctionnalité Chat supprimée

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 18),
    child: Row(
      children: [
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: ColorRes.white2,
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            child: TextField(
              controller: controller.searchNewController,
              onChanged: (value) {
                jrController.searchText.value = value;
                jrController.update(["search"]);

                // Fonctionnalité Chat supprimée
              },
              // Code de recherche Firestore supprimé pour simplification
              decoration: InputDecoration(
                border: InputBorder.none,
                suffixIcon: const Icon(Icons.search, color: ColorRes.grey),
                hintText: "Search",
                hintStyle: appTextStyle(
                    fontSize: 14,
                    color: ColorRes.grey,
                    fontWeight: FontWeight.w500),
                contentPadding: const EdgeInsets.only(left: 20, top: 13),
              ),
            ),
          ),
        ),
        // const SizedBox(width: 20),
        // Container(
        //   height: 40,
        //   width: 40,
        //   alignment: Alignment.center,
        //   decoration: const BoxDecoration(
        //     borderRadius: BorderRadius.all(Radius.circular(10)),
        //     color: ColorRes.logoColor,
        //   ),
        //   child: Image.asset(
        //     AssetRes.menuIcon,
        //     color: ColorRes.containerColor,
        //     height: 15,
        //   ),
        // ),
      ],
    ),
  );
}

// Widget searchAreaChatU() supprimé - fonctionnalité Chat supprimée

// Widget searchAreaChatM() supprimé - fonctionnalité Chat supprimée
