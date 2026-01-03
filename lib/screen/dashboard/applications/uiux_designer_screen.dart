import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/common/widgets/back_button.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/asset_res.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/services/unified_translation_service.dart'; // Import the translation service

// ignore: must_be_immutable
class SentScreen extends StatelessWidget {
  String? position;
  String? companyName;
  String? message;
  String? salary;
  String? location;
  String? type;
  SentScreen(
      {super.key,
      this.position,
      this.companyName,
      this.message,
      this.salary,
      this.location,
      this.type});

  final translationService = Get.find<UnifiedTranslationService>(); // Inject translation service

  // Helper function to format salary
  String _formatSalary(String? salary, UnifiedTranslationService ts) {
    if (salary == null || salary.isEmpty || salary == '0' || salary.toLowerCase().contains('negotiable')) {
      return ts.getText('salary_negotiable');
    }
    return salary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: InkWell(
                      onTap: () => Get.back(), // Added onTap for back button
                      child: backButton(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 25.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      translationService.getText('application_screen_title'), // Localized
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
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 135,
                      width: Get.width,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 4),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15)),
                          border: Border.all(color: const Color(0xffF3ECFF)),
                          color: ColorRes.white),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Image(
                                    image: AssetImage(AssetRes.logo),
                                    height: 40,
                                    width: 40,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      position ?? translationService.getText('position_not_specified'), // Localized
                                      style: appTextStyle(
                                          color: ColorRes.black,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      companyName ?? translationService.getText('company_not_specified'), // Localized
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
                          const Divider(
                            color: ColorRes.grey,
                          ),
                          const SizedBox(height: 10),
                          Container(
                            height: 28,
                            width: Get.width,
                            decoration: BoxDecoration(
                              color: const Color(0xffEEF2FA),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Center(
                              child: Text(
                                translationService.getText('application_sent'), // Localized
                                style: appTextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xff2E5AAC)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: Get.width,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 5),
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 18),
                      decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15)),
                          border: Border.all(color: ColorRes.borderColor),
                          color: ColorRes.white),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                translationService.getText('salary'), // Localized
                                style: appTextStyle(
                                    color: ColorRes.black.withOpacity(0.8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500),
                              ),
                              Text(
                                _formatSalary(salary, translationService), // Formatted salary
                                style: appTextStyle(
                                    color: ColorRes.containerColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                translationService.getText('type'), // Localized
                                style: appTextStyle(
                                    color: ColorRes.black.withOpacity(0.8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500),
                              ),
                              Text(
                                type ?? translationService.getText('not_specified'), // Localized
                                style: appTextStyle(
                                    color: ColorRes.containerColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                translationService.getText('location_match'), // Re-using existing key
                                style: appTextStyle(
                                    color: ColorRes.black.withOpacity(0.8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500),
                              ),
                              Text(
                                location ?? translationService.getText('location_not_specified'), // Localized
                                style: appTextStyle(
                                    color: ColorRes.containerColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        message ?? translationService.getText('description_not_available'), // Localized
                        style: appTextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: ColorRes.black.withOpacity(0.9)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
