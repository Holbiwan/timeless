import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/common/widgets/common_loader.dart';
import 'package:timeless/screen/create_vacancies/create_vacancies_controller.dart';
import 'package:timeless/screen/dashboard/home/home_controller.dart';
import 'package:timeless/screen/dashboard/home/widgets/quick_apply_button.dart';
import 'package:timeless/screen/job_recommendation_screen/job_recommendation_controller.dart';
import 'package:timeless/service/pref_services.dart';
import 'package:timeless/utils/app_res.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/asset_res.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/pref_keys.dart';

Widget allJobs(Stream stream, {bool? seeAll = false}) {
  final HomeController controller = HomeController();
  final create = Get.put(CreateVacanciesController());

  return GetBuilder<JobRecommendationController>(
    id: "search",
    // ✅ s'assure qu'une instance existe:
    init: JobRecommendationController(),
    builder: (jrController) {
      return StreamBuilder(
        stream: stream,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          try {
            // ✅ check avant d'accéder à .docs
            if (snapshot.hasData && snapshot.data != null) {
              jrController.documents = snapshot.data.docs;
            } else {
              return const CommonLoader();
            }

            controller.jobTypesSaved =
                List.generate(jrController.documents.length, (index) => false)
                    .obs;

            if (jrController.searchText.value.isNotEmpty) {
              final q = jrController.searchText.value.toLowerCase();
              jrController.documents = jrController.documents.where((e) {
                final pos = e.get('Position').toString().toLowerCase();
                final comp = e.get('CompanyName').toString().toLowerCase();
                return pos.contains(q) || comp.contains(q);
              }).toList();
            }

            final total = jrController.documents.length;
            if (total == 0) {
              return const Center(child: Text("No jobs found"));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(0),
              itemCount: seeAll! ? total : (total <= 15 ? total : 15),
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemBuilder: (context, index) {
                final revIndex = total - 1 - index;
                if (kDebugMode) {
                  print([revIndex]);
                  print(jrController.documents[revIndex].id);
                }

                final doc = jrController.documents[revIndex];
                final docData = doc.data() as Map<String, dynamic>;
                final position = docData["Position"] ?? "Non spécifié";
                final company = docData["CompanyName"] ?? "Entreprise";
                final location = docData["location"] ?? "Non spécifié";
                final type = docData["type"] ?? "Non spécifié";
                final salary = docData["salary"] ?? "0";
                final bookmarkList = docData.containsKey('BookMarkUserList') 
                    ? docData['BookMarkUserList'] 
                    : [];

                return InkWell(
                  onTap: () => Get.toNamed(
                    AppRes.jobDetailScreen,
                    arguments: {"saved": doc, "docId": revIndex},
                  ),
                  child: ClipRect(
                    child: Container(
                      width: Get.width,
                      constraints: const BoxConstraints(minHeight: 70),
                      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(15)),
                        border: Border.all(color: ColorRes.borderColor, width: 1),
                        color: ColorRes.cardColor,
                      ),
                    child: IntrinsicHeight(
                      child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: (create.url == "")
                                ? const Image(
                                    image: AssetImage(AssetRes.airBnbLogo),
                                    fit: BoxFit.cover,
                                  )
                                : Image(
                                    image: NetworkImage(create.url),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                position,
                                style: appTextStyle(
                                  color: ColorRes.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                company,
                                style: appTextStyle(
                                  color: ColorRes.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 1),
                              Text(
                                "$location  $type",
                                style: appTextStyle(
                                  color: ColorRes.grey,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                final docId = snapshot.data.docs[revIndex].id;
                                controller.onTapSave(
                                  revIndex,
                                  doc,
                                  docId,
                                );
                              },
                              child: GetBuilder<JobRecommendationController>(
                                builder: (_) {
                                  final hasBookmarks = bookmarkList != null &&
                                                      bookmarkList is List &&
                                                      bookmarkList.isNotEmpty;
                                  final isBookmarked = hasBookmarks &&
                                      bookmarkList.contains(
                                        PrefService.getString(PrefKeys.userId),
                                      );

                                  return SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Image.asset(
                                      isBookmarked
                                          ? AssetRes.bookMarkFillIcon
                                          : AssetRes.bookMarkBorderIcon,
                                      fit: BoxFit.contain,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Bouton candidature rapide
                            QuickApplyButton(
                              jobData: doc.data() as Map<String, dynamic>,
                              docId: snapshot.data.docs[revIndex].id,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "\$$salary",
                              style: appTextStyle(
                                fontSize: 14,
                                color: ColorRes.successColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                    ),
                    ),
                  ),
                );
              },
            );
          } catch (e) {
            if (kDebugMode) print('🔧 AllJobs error: $e');
            return const Center(
              child: Text('Chargement des emplois...', style: TextStyle(fontSize: 16)),
            );
          }
        },
      );
    },
  );
}
