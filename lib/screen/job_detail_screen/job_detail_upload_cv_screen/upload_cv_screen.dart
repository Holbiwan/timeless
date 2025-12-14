import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/screen/job_detail_screen/job_detail_upload_cv_screen/upload_cv_controller.dart';
import 'package:timeless/screen/job_detail_screen/job_detail_upload_cv_screen/upload_cv_screen_helper.dart';
import 'package:timeless/services/unified_translation_service.dart';
import 'package:timeless/screen/job_detail_screen/job_detail_widget/job_details_appbar.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/asset_res.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/string.dart';
import 'package:timeless/utils/app_theme.dart';

// ignore: must_be_immutable
class JobDetailsUploadCvScreen extends StatelessWidget {
  JobDetailsUploadCvScreen({super.key});
  final JobDetailsUploadCvController controller =
      Get.put(JobDetailsUploadCvController());
  var args = Get.arguments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.backgroundColor,
      body: PopScope(
        onPopInvoked: (didPop) {
          if (didPop) {
            controller.filepath.value = "";
            controller.motivationController.clear();
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              jobDetailsAppBar(controller),
              SizedBox(
                height: Get.height - 100,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        height: 92,
                        width: Get.width,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15)),
                            border: Border.all(color: const Color(0xffF3ECFF)),
                            color: ColorRes.white),
                        child: Row(
                          children: [
                            Image.asset(AssetRes.airBnbLogo),
                            const SizedBox(width: 20),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  args["doc"]["Position"],
                                  style: appTextStyle(
                                      color: ColorRes.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  args["doc"]["CompanyName"],
                                  style: appTextStyle(
                                      color: ColorRes.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(
                        thickness: 0.5,
                        color: Color(0xffD9D9D9),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        Strings.uploadResume,
                        style: appTextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: ColorRes.black),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        Strings.uploadYourCvOr,
                        style: appTextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: ColorRes.black),
                      ),

                      //upload pdf error Container
                      Obx(
                        () => controller.isPdfUploadError.value
                            ? Container(
                                width: Get.width,
                                // height: 28,
                                margin: const EdgeInsets.only(top: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: ColorRes.invalidColor),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 18,
                                ),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Image(
                                        image: AssetImage(
                                          AssetRes.invalid,
                                        ),
                                        height: 25,
                                      ),
                                      const SizedBox(width: 10),
                                      SizedBox(
                                        width: Get.width * 0.65,
                                        child: Text(
                                          "Upload failed,please re-upload your file",
                                          style: appTextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                              color: ColorRes.starColor),
                                        ),
                                      ),
                                      const Spacer(),
                                      const Icon(
                                        Icons.clear,
                                        color: ColorRes.starColor,
                                      )
                                    ]),
                              )
                            : const SizedBox(),
                      ),

                      // Section pour accéder aux CV stockés
                      const SizedBox(height: 15),
                      Container(
                        width: Get.width,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F4FD),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: const Color(0xFF4A90E2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.folder_open,
                                  color: Color(0xFF4A90E2),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "CV stockés",
                                  style: appTextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF4A90E2),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Vous avez des CV déjà stockés dans votre profil",
                              style: appTextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF666666),
                              ),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () {
                                controller.loadStoredCVs();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4A90E2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "Voir mes CV",
                                  style: appTextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Obx(
                        () => controller.filepath.value != ""
                            ? Container(
                                // height: 82,
                                width: Get.width,
                                margin: const EdgeInsets.only(top: 10),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xffEEEBF4),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(15),
                                  ),
                                  border:
                                      Border.all(color: ColorRes.borderColor),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(AssetRes.pdfIcon, height: 90),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: Get.width * 0.6,
                                          child: Text(
                                            controller.filepath.value,
                                            style: appTextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: ColorRes.black),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          "440 kb",
                                          style: appTextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w400,
                                              color: ColorRes.grey),
                                        ),
                                      ],
                                    ),
                                    InkWell(
                                      onTap: () {
                                        controller.pdfUrl = null;
                                        controller.filepath.value = "";
                                      },
                                      child: const Image(
                                        image: AssetImage(
                                          AssetRes.pdfRemove,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            : const SizedBox(),
                      ),
                      GestureDetector(
                        onTap: () {
                          controller.applyResume();
                        },
                        child: Container(
                          width: Get.width,
                          margin: const EdgeInsets.only(top: 15),
                          padding: const EdgeInsets.only(top: 25, bottom: 20),
                          decoration: BoxDecoration(
                            color: ColorRes.white,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15)),
                            border: Border.all(color: ColorRes.borderColor),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(AssetRes.uploadIcon, height: 40),
                              const SizedBox(height: 10),
                              Text(
                                "Upload Resume/CV",
                                style: appTextStyle(
                                    color: ColorRes.grey,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500),
                              )
                            ],
                          ),
                        ),
                      ),

                      //uploading loader
                      /*         GestureDetector(
                         onTap: () {
                           controller.applyResume();
                         },

                         child: Container(
                          width: Get.width,
                          padding: const EdgeInsets.symmetric(vertical: 35),
                          margin: const EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                            color: ColorRes.white,
                            borderRadius: const BorderRadius.all(Radius.circular(15)),
                            border: Border.all(color: ColorRes.borderColor),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                  color: ColorRes.containerColor,
                                  backgroundColor:
                                      ColorRes.containerColor.withOpacity(0.3)),
                              const SizedBox(height: 20),
                              Text(Strings.uploading,
                                  style: appTextStyle(
                                      color: ColorRes.containerColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500))
                            ],
                          ),
                      ),
                       ),*/
                      // Champ lettre de motivation optionnelle
                      const SizedBox(height: 30),
                      Text(
                        Get.find<UnifiedTranslationService>().getText('motivation_letter_optional'),
                        style: appTextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: ColorRes.black),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: ColorRes.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: ColorRes.borderColor),
                        ),
                        child: TextField(
                          controller: controller.motivationController,
                          maxLines: 1,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText:
                                Get.find<UnifiedTranslationService>().getText('motivation_letter_hint'),
                            hintStyle: appTextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w400,
                              color: ColorRes.grey,
                            ),
                          ),
                          style: appTextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: ColorRes.black,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          if (controller.pdfUrl == null ||
                              controller.pdfUrl == "") {
                            AppTheme.showStandardSnackBar(
                              title: "❌ CV Required",
                              message: "Please upload your CV before applying",
                              isError: true,
                            );
                          } else {
                            // Show confirmation popup before applying
                            UploadCvScreenHelper.showApplicationConfirmationDialog(controller, args);
                          }
                        },
                        child: Obx(() {
                          return Container(
                            height: 38,
                            width: Get.width * 0.6,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            margin: const EdgeInsets.only(
                                right: 20, left: 20, top: 2, bottom: 5),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10),
                              ),
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFF000647),
                                width: 2.0,
                              ),
                            ),
                            child: Text(
                              Get.find<UnifiedTranslationService>().getText('apply_button'),
                              style: appTextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),
                          );
                        }),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
