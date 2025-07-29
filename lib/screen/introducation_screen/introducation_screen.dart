import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/screen/dashboard/dashboard_controller.dart';
import 'package:timeless/screen/dashboard/dashboard_screen.dart';
import 'package:timeless/screen/manager_section/dashboard/manager_dashboard_screen.dart';
import 'package:timeless/screen/organization_profile_screen/organization_profile_screen.dart';
import 'package:timeless/service/pref_services.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/asset_res.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'introduction_controller.dart';

// ignore: must_be_immutable
class IntroductionScreen extends StatelessWidget {
  IntroductionScreen({Key? key}) : super(key: key);
  PageController controller = PageController();
  IntroductionController introductionController =
      Get.put(IntroductionController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.backgroundColor,
      body: Obx(() => Column(
            children: [
              const SizedBox(height: 60),
              introductionController.selectedIndex.value != 2
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: const [
                          Text(
                            "skip",
                            style: TextStyle(color: ColorRes.containerColor),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),
              const SizedBox(height: 50),
              SizedBox(
                height: 400,
                child: PageView.builder(
                    onPageChanged: (val) =>
                        introductionController.onChangeInd(val),
                    controller: controller,
                    itemCount: 3,
                    itemBuilder: (context, i) {
                      return (introductionController.selectedIndex.value == 0)
                          ? Column(
                              children: [
                                const Image(
                                  image: AssetImage(AssetRes.page1),
                                  height: 200,
                                ),
                                const SizedBox(height: 80),
                                Text(
                                  "Search Jobs",
                                  style: appTextStyle(
                                      color: ColorRes.containerColor,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  "Lorem ipsum dolor sit amet, consectetur \n                         adipiscing elit",
                                  style: appTextStyle(
                                      color: ColorRes.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400),
                                )
                              ],
                            )
                          : (introductionController.selectedIndex.value == 1)
                              ? Column(
                                  children: [
                                    const Image(
                                      image: AssetImage(AssetRes.page2),
                                      height: 200,
                                    ),
                                    const SizedBox(height: 80),
                                    Text(
                                      "Apply Job",
                                      style: appTextStyle(
                                          color: ColorRes.containerColor,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      "Lorem ipsum dolor sit amet, consectetur \n                         adipiscing elit",
                                      style: appTextStyle(
                                          color: ColorRes.black,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400),
                                    )
                                  ],
                                )
                              : (introductionController.selectedIndex.value ==
                                      2)
                                  ? Column(
                                      children: [
                                        const Image(
                                          image: AssetImage(AssetRes.page3),
                                          height: 200,
                                        ),
                                        const SizedBox(height: 80),
                                        Text(
                                          "Ready For The Job!",
                                          style: appTextStyle(
                                              color: ColorRes.containerColor,
                                              fontSize: 24,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          "Lorem ipsum dolor sit amet, consectetur \n                         adipiscing elit",
                                          style: appTextStyle(
                                              color: ColorRes.black,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    )
                                  : const SizedBox();
                    }),
              ),
              SmoothPageIndicator(
                controller: controller,
                count: 3,
                effect: SlideEffect(
                  activeDotColor: ColorRes.containerColor,
                  dotHeight: 9,
                  dotColor: ColorRes.black.withOpacity(0.20),
                  dotWidth: 9,
                ),
              ),
              const SizedBox(height: 40),
              introductionController.selectedIndex.value == 2
                  ? InkWell(
                      onTap: () {
                        String token = PrefService.getString(PrefKeys.userId);
                        String rol = PrefService.getString(PrefKeys.rol);
                        bool company = PrefService.getBool(PrefKeys.company);
                        final DashBoardController controller =
                            Get.put(DashBoardController());
                        controller.currentTab = 0;
                        Get.off(() => token == ""
                            ? DashBoardScreen()
                            : rol == "User"
                                ? DashBoardScreen()
                                : company
                                    ? ManagerDashBoardScreen()
                                    : const OrganizationProfileScreen());
                      },
                      child: Container(
                        height: 50,
                        width: 294,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        margin:
                            const EdgeInsets.only(right: 18, left: 18, top: 10),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                          gradient: LinearGradient(colors: [
                            ColorRes.gradientColor,
                            ColorRes.containerColor,
                          ]),
                        ),
                        child: Text(
                          "Get Started",
                          style: appTextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ),
                    )
                  : const SizedBox(),
            ],
          )),
    );
  }
}
