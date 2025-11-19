import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/common/widgets/back_button.dart';
import 'package:timeless/common/widgets/logout_menu.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/asset_res.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/string.dart';
import 'package:timeless/utils/app_res.dart';

class TipsForYouScreen extends StatelessWidget {
  const TipsForYouScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Stack(
              children: [
                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: InkWell(
                      onTap: () {
                        // Multiple options to go back
                        if (Navigator.canPop(context)) {
                          Get.back();
                        } else {
                          // If can't go back, go to dashboard
                          Get.offAllNamed(AppRes.dashBoardScreen);
                        }
                      },
                      child: backButton(),
                    ),
                  ),
                ),
                // Title
                Padding(
                  padding: const EdgeInsets.only(top: 25.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      Strings.tipsForYou,
                      style: appTextStyle(
                        color: ColorRes.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // Menu button (logout/home)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: LogoutMenu.buildMenuButton(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Contenu scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bandeau
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 18),
                      height: 176,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 5, 5, 5),
                            ColorRes.containerColor
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(6, 6),
                            color: ColorRes.containerColor.withOpacity(0.2),
                            blurRadius: 10,
                          ),
                          BoxShadow(
                            offset: const Offset(0, 7),
                            color: ColorRes.containerColor.withOpacity(0.5),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 20),
                            width: Get.width - 180,
                            height: 180,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Strings.howToFindAPerfectJob,
                                  style: appTextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 17,
                                    color: ColorRes.white,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Divider(
                                    height: 10, color: ColorRes.white),
                                const SizedBox(height: 10),
                                Text(
                                  'Sabrina PAPEAU',
                                  style: appTextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: ColorRes.white,
                                  ),
                                ),
                                Text(
                                  'Creator of Timeless',
                                  style: appTextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w500,
                                    color: ColorRes.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: Image.asset(
                                AssetRes.girlImage, 
                                height: 150,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 5),

                    // Titre de section
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        'How to find a perfect job for you',
                        style: appTextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: ColorRes.black,
                        ),
                      ),
                    ),

                    // Paragraphe principal
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: Text(
                        '''Looking for a job in tech can be hard. Timeless makes it easy. Create your profile once and we show you jobs that fit your skills—design, product, data, marketing, development, and more. You can choose city or remote.

See a clean list of good offers, save the ones you like, and get alerts when new jobs match you. Apply in a few taps and follow your applications in one place.

Need help? We give simple tips for your CV and interviews. Whether you want an internship, a first job, or a senior role, Timeless helps you find the right digital job faster.''',
                        style: appTextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: ColorRes.black.withOpacity(0.6),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Petit paragraphe à la fin
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: Text(
                        'Timeless also helps you grow. Add your CV or portfolio, link GitHub/Behance/LinkedIn, and pick the roles you want to learn. You’ll get practice tips, interview guides, and real offers from verified companies with clear salary ranges and remote/hybrid options. Track every step—applied, interview, feedback—and get reminders so you never miss a deadline. One profile, smarter matches, faster results.',
                        style: appTextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: ColorRes.black.withOpacity(0.6),
                        ),
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
