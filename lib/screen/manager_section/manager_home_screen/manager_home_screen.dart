import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeless/common/widgets/back_button.dart';
import 'package:timeless/common/widgets/common_loader.dart';
import 'package:timeless/screen/job_detail_screen/job_detail_upload_cv_screen/upload_cv_controller.dart';
import 'package:timeless/screen/manager_section/received_applications_screen.dart';
import 'package:timeless/screen/manager_section/manager_home_screen/manager_home_screen_controller.dart';
import 'package:timeless/screen/manager_section/manager_home_screen/manager_home_screen_widget/manager_home_screen_widget.dart';
import 'package:timeless/screen/manager_section/notification1/notification1_screen.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/app_res.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/utils/string.dart';
import 'package:timeless/utils/asset_res.dart';
import 'package:timeless/utils/employer_migration_helper.dart';

// ignore: must_be_immutable
class ManagerHomeScreen extends StatelessWidget {
  ManagerHomeScreen({super.key});
  final controller = Get.put(ManagerHomeScreenController());

  JobDetailsUploadCvController jobDetailsUploadCvController =
      Get.put(JobDetailsUploadCvController());

  @override
  Widget build(BuildContext context) {
    jobDetailsUploadCvController.init();
    return Scaffold(
      backgroundColor: ColorRes.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header fixe qui ne scroll pas
            Container(
              color: ColorRes.backgroundColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Stack(
                  children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Exit button to return to first page
                    InkWell(
                      onTap: () {
                        // Exit employer dashboard and return to main app
                        Get.dialog(
                          AlertDialog(
                            title: const Text('Exit Employer Dashboard'),
                            content: const Text('Do you want to return to the main application?'),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Get.back();
                                  Get.offAllNamed('/home'); // Return to first page
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF000647),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Exit'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.red[600],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.exit_to_app,
                            color: Colors.white,
                          )),
                    ),

                    logo(),
                    Row(
                      children: [
                        // Migration Button (test - jaune)
                        GestureDetector(
                          onTap: () async {
                            try {
                              final results = await EmployerMigrationHelper.migrateExistingEmployers();
                              Get.snackbar(
                                '✅ Migration OK',
                                'Processed: ${results['employersProcessed']} | Activated: ${results['employersActivated']} | Jobs: ${results['jobsMarked']}',
                                backgroundColor: Colors.green,
                                colorText: Colors.white,
                                duration: const Duration(seconds: 3),
                                snackPosition: SnackPosition.TOP,
                              );
                            } catch (e) {
                              Get.snackbar('❌ Error', e.toString(), backgroundColor: Colors.red);
                            }
                          },
                          child: Container(
                            width: 16,
                            height: 16,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: const BoxDecoration(
                              color: Colors.amber,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.settings,
                              size: 10,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        // Refresh Button
                        InkWell(
                          onTap: () {
                            controller.refreshData();
                            Get.snackbar(
                              '🔄 Refreshing',
                              'Updating dashboard data...',
                              backgroundColor: ColorRes.logoColor,
                              colorText: ColorRes.containerColor,
                              duration: const Duration(seconds: 1),
                              snackPosition: SnackPosition.TOP,
                            );
                          },
                          child: Container(
                            height: 40,
                            width: 40,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: ColorRes.brightYellow,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.refresh,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        // Notification Button
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (con) => NotificationScreenM(),
                              ),
                            );
                          },
                          child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: ColorRes.logoColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.notifications,
                                color: ColorRes.containerColor,
                              )),
                        ),
                      ],
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          Strings.welcome,
                          style: appTextStyle(
                              color: ColorRes.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w600),
                        ),
                        Text(
                          PreferencesService.getString(PrefKeys.companyName),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: appTextStyle(
                              color: ColorRes.containerColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                )
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Contenu scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Recent Job Posts Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Recent Job Posts",
                          style: appTextStyle(
                              color: ColorRes.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 16),
                        ),
                        InkWell(
                          onTap: () {
                            // Navigate to all job posts screen
                            Get.toNamed('/manager-applications');
                          },
                          child: Text(
                            "View All",
                            style: appTextStyle(
                                color: ColorRes.containerColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    
                    // Recent Job Posts List
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("allPost")
                          .orderBy("createdAt", descending: true)
                          .limit(3)
                          .snapshots(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.data == null || !snapshot.hasData) {
                          return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
                        }
                        
                        if (snapshot.data.docs.isEmpty) {
                          return Container(
                            height: 100,
                            margin: const EdgeInsets.symmetric(horizontal: 18),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: const Center(
                              child: Text(
                                "No job posts yet.\nClick 'Create Job' to get started!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        }
                        
                        return SizedBox(
                          height: snapshot.data.docs.length * 96.0,
                          child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(0),
                            itemCount: snapshot.data.docs.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final doc = snapshot.data!.docs[index];
                              
                              if (controller.companyName != doc["CompanyName"]) {
                                return const SizedBox();
                              }
                              
                              return InkWell(
                                onTap: () => Get.toNamed(
                                    AppRes.managerApplicationDetailScreen,
                                    arguments: {
                                      "docs": doc,
                                      "DocId": doc.id
                                    }),
                                child: Container(
                                  height: 92,
                                  width: Get.width,
                                  margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                                      border: Border.all(color: const Color(0xffF3ECFF)),
                                      color: ColorRes.white),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: doc["imageUrl"] != null && doc["imageUrl"].isNotEmpty
                                            ? Image.network(
                                                doc["imageUrl"],
                                                height: 62,
                                                width: 62,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => 
                                                    Image.asset(AssetRes.airBnbLogo, height: 62, width: 62),
                                              )
                                            : Image.asset(AssetRes.airBnbLogo, height: 62, width: 62),
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                doc["Position"] ?? "No Title",
                                                style: appTextStyle(
                                                    color: ColorRes.black,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis),
                                            Text(
                                                doc["CompanyName"] ?? "Unknown Company",
                                                style: appTextStyle(
                                                    color: ColorRes.black,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w400),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis),
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    "${doc["location"] ?? "Unknown"} - ${doc["type"] ?? "Unknown"}",
                                                    style: appTextStyle(
                                                        color: ColorRes.black,
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.w400),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            height: 20,
                                            padding: const EdgeInsets.symmetric(horizontal: 15),
                                            decoration: BoxDecoration(
                                              color: doc["Status"] == "Active"
                                                  ? ColorRes.lightGreen
                                                  : ColorRes.invalidColor,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              doc["Status"] ?? "Unknown",
                                              style: appTextStyle(
                                                  color: doc["Status"] == "Active"
                                                      ? ColorRes.darkGreen
                                                      : ColorRes.starColor,
                                                  fontSize: 12),
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            doc["salary"] ?? "N/A",
                                            style: appTextStyle(
                                                fontSize: 16,
                                                color: ColorRes.containerColor,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  
                  const SizedBox(height: 20),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Strings.RecentPeopleApplication,
                        style: appTextStyle(
                            color: ColorRes.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 16),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (con) => const ReceivedApplicationsScreen(),
                            ),
                          );
                        },
                        child: Text(
                          Strings.seeAll,
                          style: appTextStyle(
                              color: ColorRes.containerColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 14),
                        ),
                      ),
                    ],
                  ),

                  GetBuilder<ManagerHomeScreenController>(
                      id: "userdata",
                      builder: (contro) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: (contro.loader == true)
                              ? const CommonLoader()
                              : recentPeopleBox(),
                        );
                      }),
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
