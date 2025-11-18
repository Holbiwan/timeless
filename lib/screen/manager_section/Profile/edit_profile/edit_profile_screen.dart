import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/common/widgets/back_button.dart';
import 'package:timeless/screen/create_vacancies/create_vacancies_controller.dart';
import 'package:timeless/screen/manager_section/profile/manager_profile_controller.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/asset_res.dart';
import 'package:timeless/utils/color_res.dart';



// ignore: must_be_immutable
class EditProfileScreen extends StatelessWidget {
  EditProfileScreen({super.key});
  final controller = Get.put(ManagerProfileController()); // CHANGEMENT ICI

  CreateVacanciesController getCreate = Get.put(CreateVacanciesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.backgroundColor,
      body: Column(
        children: [
          const SizedBox(height: 60),
          Row(children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: InkWell(
                onTap: () {
                  controller.init();
                  Get.back();
                },
                child: backButton(),
              ),
            ),
            const Spacer(),
            Center(
              child: Text(
                'Edit Profile',
                style: appTextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    height: 1,
                    color: ColorRes.black),
              ),
            ),
            const Spacer(),
            Container(
              margin: const EdgeInsets.all(15),
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ]),
          Expanded(
            child: SingleChildScrollView(
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          GetBuilder<ManagerProfileController>( // CHANGEMENT ICI
                              id: "image",
                              builder: (context) {
                                return Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: (getCreate.url.isEmpty) // CHANGEMENT ICI
                                        ? const DecorationImage(
                                            image: AssetImage(AssetRes.roundAirbnb),
                                            fit: BoxFit.cover, // Changé de fill à cover
                                          )
                                        : DecorationImage(
                                            image: NetworkImage(getCreate.url),
                                            fit: BoxFit.cover), // Changé de fill à cover
                                  ),
                                );
                              }),
                          Positioned(
                            bottom: 0,
                            right: 10,
                            child: InkWell(
                              onTap: () {
                                showModalBottomSheet<void>(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  backgroundColor: Colors.transparent,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Container(
                                      height: 450,
                                      decoration: const BoxDecoration(
                                        color: ColorRes.white,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(45),
                                          topRight: Radius.circular(45),
                                        ),
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: <Widget>[
                                            const SizedBox(height: 30),
                                            Text(
                                              'Change Logo Company',
                                              style: appTextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: ColorRes.black.withOpacity(0.8)),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                                              child: Container(
                                                height: 120,
                                                width: Get.width,
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: const Color(0xffF3ECFF)),
                                                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                                                ),
                                                child: Column(
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        controller.onTapImage(); // ASSUREZ-VOUS QUE CETTE MÉTHODE EXISTE
                                                      },
                                                      child: Container(
                                                        height: 70,
                                                        width: 70,
                                                        margin: const EdgeInsets.symmetric(horizontal: 100, vertical: 10),
                                                        decoration: BoxDecoration(
                                                          color: ColorRes.logoColor,
                                                          borderRadius: BorderRadius.circular(80),
                                                        ),
                                                        child: const Icon(
                                                          Icons.camera_alt,
                                                          size: 40,
                                                          color: ColorRes.containerColor,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      "Take photo",
                                                      style: appTextStyle(
                                                          fontWeight: FontWeight.w500,
                                                          fontSize: 14,
                                                          color: ColorRes.black),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 18),
                                              child: Container(
                                                height: 120,
                                                width: Get.width,
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: const Color(0xffF3ECFF)),
                                                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                                                ),
                                                child: Column(
                                                  children: [
                                                    InkWell(
                                                      onTap: () => controller.onTapGallery1(), // ASSUREZ-VOUS QUE CETTE MÉTHODE EXISTE
                                                      child: Container(
                                                        height: 70,
                                                        width: 70,
                                                        margin: const EdgeInsets.symmetric(horizontal: 100, vertical: 10),
                                                        decoration: BoxDecoration(
                                                          color: ColorRes.logoColor,
                                                          borderRadius: BorderRadius.circular(80),
                                                        ),
                                                        child: const Image(
                                                          image: AssetImage(AssetRes.galleryImage),
                                                          color: ColorRes.containerColor,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      "From gallery", // Corrigé "Form" en "From"
                                                      style: appTextStyle(
                                                          fontWeight: FontWeight.w500,
                                                          fontSize: 14,
                                                          color: ColorRes.black),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: const CircleAvatar(
                                radius: 10,
                                backgroundColor: ColorRes.containerColor,
                                child: Icon(
                                  Icons.edit,
                                  size: 11,
                                  color: ColorRes.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.companyNameController.text,
                            style: appTextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: ColorRes.black),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            controller.companyEmailController.text,
                            style: appTextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: ColorRes.black.withOpacity(0.6)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            controller.countryController.text,
                            style: appTextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: ColorRes.black.withOpacity(0.6)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Obx(
                    () => Column(children: [
                      // ... (le reste du code reste similaire mais utilise ManagerProfileController)
                      GetBuilder<ManagerProfileController>( // CHANGEMENT ICI
                          id: "Organization",
                          builder: (con) {
                            return InkWell(
                              onTap: con.onTapSubmit, // ASSUREZ-VOUS QUE CETTE MÉTHODE EXISTE
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: const LinearGradient(colors: [
                                    ColorRes.gradientColor,
                                    ColorRes.containerColor
                                  ]),
                                ),
                                child: Text("Save Changes",
                                    style: appTextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: ColorRes.white)),
                              ),
                            );
                          }),
                      const SizedBox(height: 20),
                    ]),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}