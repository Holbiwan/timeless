import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/common/widgets/back_button.dart';
import 'package:timeless/common/widgets/common_loader.dart';
import 'package:timeless/screen/dashboard/applications/applications_controller.dart';
import 'package:timeless/screen/dashboard/applications/rejected_screen.dart';
import 'package:timeless/screen/dashboard/home/widgets/search_field.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/asset_res.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/utils/string.dart';
import 'package:timeless/services/unified_translation_service.dart';
import 'uiux_designer_screen.dart';
import 'accepted_screen.dart';

class ApplicationsScreen extends StatelessWidget {
  ApplicationsScreen({super.key});

  final applicationController = Get.put(ApplicationsController());
  final translationService = Get.find<UnifiedTranslationService>();

  // Helper function for secure access to Firestore fields
  String getFieldSafely(DocumentSnapshot doc, String field,
      [String defaultValue = 'Pending']) {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      return data?[field]?.toString() ?? defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("fastbacks");
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: Get.width,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  backButton(),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            Strings.applications,
                            style: appTextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: const Color.fromARGB(255, 0, 6, 71)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            translationService.getText('cv_sent'),
                            style: appTextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: const Color.fromARGB(255, 0, 6, 71).withOpacity(0.7)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      // Force refresh by updating the controller and triggering stream refresh
                      applicationController.update();
                      Get.snackbar(
                        'Refreshed',
                        'Application list updated',
                        backgroundColor: Colors.blue,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 2),
                        snackPosition: SnackPosition.TOP,
                      );
                    },
                    icon: const Icon(
                      Icons.refresh,
                      color: Color.fromARGB(255, 0, 6, 71),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Container(
                alignment: Alignment.center,
                height: 200,
                width: Get.width * 0.85,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: RepaintBoundary(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 180,
                    width: Get.width * 0.8,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    gaplessPlayback: false,
                    isAntiAlias: false,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            searchArea(),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  applicationController.jobs.length,
                  (index) => Expanded(
                    child: GestureDetector(
                      onTap: () => applicationController.onTapJobs2(index),
                      child: Obx(
                        () => Container(
                          margin: EdgeInsets.only(
                            right: index < applicationController.jobs.length - 1
                                ? 8
                                : 0,
                          ),
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color.fromARGB(255, 0, 6, 71), width: 2),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10),
                              ),
                              color: applicationController.selectedJobs.value ==
                                      index
                                  ? const Color.fromARGB(255, 0, 6, 71)
                                  : Colors.white),
                          child: Text(
                            applicationController.jobs[index],
                            style: appTextStyle(
                                color:
                                    applicationController.selectedJobs.value ==
                                            index
                                        ? Colors.white
                                        : const Color.fromARGB(255, 0, 6, 71),
                                fontSize: 11,
                                fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection("Applicants")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.data == null || snapshot.hasData == false) {
                      return const CommonLoader();
                    }

                    return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          return StreamBuilder<
                              QuerySnapshot<Map<String, dynamic>>>(
                            stream: FirebaseFirestore.instance
                                .collection('Applicants')
                                .doc(snapshot.data!.docs[index].id)
                                .collection('userDetails')
                                .snapshots(),
                            builder: (context, snapshot2) {
                              if (snapshot2.data == null ||
                                  snapshot2.hasData == false) {
                                return const SizedBox();
                              }
                              return ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: snapshot2.data!.docs.length,
                                itemBuilder: (context, index2) {
                                  return (snapshot2
                                              .data!.docs[index2]['userName']
                                              .toString()
                                              .toLowerCase()
                                              .removeAllWhitespace ==
                                          PreferencesService.getString(
                                                  PrefKeys.fullName)
                                              .toString()
                                              .toLowerCase()
                                              .removeAllWhitespace)
                                      ? StreamBuilder<QuerySnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection('Interviews')
                                              .where('candidateEmail', isEqualTo: PreferencesService.getString(PrefKeys.email))
                                              .where('candidateName', isEqualTo: PreferencesService.getString(PrefKeys.fullName))
                                              .where('jobTitle', isEqualTo: snapshot2.data!.docs[index2]['position'])
                                              .snapshots(),
                                          builder: (context, interviewSnapshot) {
                                            String currentStatus = getFieldSafely(
                                                snapshot2.data!.docs[index2],
                                                'status');
                                            
                                            // If there's an interview scheduled, update status
                                            if (interviewSnapshot.hasData && interviewSnapshot.data!.docs.isNotEmpty) {
                                              currentStatus = 'Schedule Interview';
                                            }
                                            
                                            return Obx(() {
                                              final selectedIndex = applicationController.selectedJobs.value;

                                              bool shouldShow = false;
                                              switch (selectedIndex) {
                                                case 0: // All
                                                  shouldShow = true;
                                                  break;
                                                case 1: // Interview
                                                  shouldShow = currentStatus == 'Schedule Interview';
                                                  break;
                                                case 2: // Sent
                                                  shouldShow = currentStatus == 'Sent';
                                                  break;
                                                case 3: // Erase - Show all applications with delete mode
                                                  shouldShow = true;
                                                  break;
                                              }

                                              return Column(
                                                children: [
                                                  shouldShow
                                                      ? Container(
                                                        height: 160,
                                                        width: Get.width,
                                                        margin: const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 18,
                                                            vertical: 4),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(15),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .all(
                                                            Radius.circular(15),
                                                          ),
                                                          border: Border.all(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.3),
                                                          ),
                                                          color: applicationController
                                                                      .selectedJobs
                                                                      .value ==
                                                                  3
                                                              ? Colors
                                                                  .red.shade800
                                                              : const Color.fromARGB(255, 0, 6, 71),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.3),
                                                              spreadRadius: 2,
                                                              blurRadius: 8,
                                                              offset:
                                                                  const Offset(
                                                                      0, 3),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      bottom:
                                                                          8),
                                                              child: Row(
                                                                children: [
                                                                  Expanded(
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          snapshot2
                                                                              .data!
                                                                              .docs[index2]['position'],
                                                                          style:
                                                                              appTextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          snapshot
                                                                              .data!
                                                                              .docs[index]['companyName'],
                                                                          style:
                                                                              appTextStyle(
                                                                            color:
                                                                                ColorRes.appleGreen,
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  IconButton(
                                                                    onPressed:
                                                                        () async {
                                                                      // Confirmation dialog
                                                                      bool?
                                                                          confirm =
                                                                          await showDialog<
                                                                              bool>(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (context) =>
                                                                                AlertDialog(
                                                                          title:
                                                                              const Text('Delete Application'),
                                                                          content:
                                                                              const Text('Are you sure you want to delete this application?'),
                                                                          actions: [
                                                                            TextButton(
                                                                              onPressed: () => Navigator.of(context).pop(false),
                                                                              child: const Text('Cancel'),
                                                                            ),
                                                                            TextButton(
                                                                              onPressed: () => Navigator.of(context).pop(true),
                                                                              child: const Text('Delete'),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      );

                                                                      if (confirm ==
                                                                          true) {
                                                                        try {
                                                                          // Delete from userDetails subcollection
                                                                          await FirebaseFirestore
                                                                              .instance
                                                                              .collection('Applicants')
                                                                              .doc(snapshot.data!.docs[index].id)
                                                                              .collection('userDetails')
                                                                              .doc(snapshot2.data!.docs[index2].id)
                                                                              .delete();

                                                                          Get.snackbar(
                                                                            'Deleted',
                                                                            'Application deleted successfully',
                                                                            backgroundColor: const Color.fromARGB(
                                                                                255,
                                                                                0,
                                                                                6,
                                                                                71),
                                                                            colorText:
                                                                                Colors.white,
                                                                          );
                                                                        } catch (e) {
                                                                          Get.snackbar(
                                                                            'Error',
                                                                            'Unable to delete application',
                                                                            backgroundColor:
                                                                                Colors.red,
                                                                            colorText:
                                                                                Colors.white,
                                                                          );
                                                                        }
                                                                      }
                                                                    },
                                                                    icon:
                                                                        const Icon(
                                                                      Icons
                                                                          .delete_outline,
                                                                      color: Colors
                                                                          .white,
                                                                      size: 20,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            const Divider(
                                                              color:
                                                                  Colors.grey,
                                                              height: 8,
                                                            ),
                                                            InkWell(
                                                              onTap: () {
                                                                if (currentStatus == 'Sent') {
                                                                  Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder: (con) => SentScreen(
                                                                        position: snapshot2.data!.docs[index2]['position'],
                                                                        companyName: snapshot.data!.docs[index]['companyName'],
                                                                        message: snapshot2.data!.docs[index2]['message'],
                                                                        salary: snapshot2.data!.docs[index2]['salary'],
                                                                        location: snapshot2.data!.docs[index2]['location'],
                                                                        type: snapshot2.data!.docs[index2]['type'],
                                                                      ),
                                                                    ),
                                                                  );
                                                                } else if (currentStatus == 'Rejected') {
                                                                  Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder: (con) => RejectedScreen(
                                                                        position: snapshot2.data!.docs[index2]['position'],
                                                                        companyName: snapshot.data!.docs[index]['companyName'],
                                                                        message: snapshot2.data!.docs[index2]['message'],
                                                                        salary: snapshot2.data!.docs[index2]['salary'],
                                                                        location: snapshot2.data!.docs[index2]['location'],
                                                                        type: snapshot2.data!.docs[index2]['type'],
                                                                      ),
                                                                    ),
                                                                  );
                                                                } else if (currentStatus == 'Schedule Interview') {
                                                                  // Show interview details if available
                                                                  if (interviewSnapshot.hasData && interviewSnapshot.data!.docs.isNotEmpty) {
                                                                    final interviewDoc = interviewSnapshot.data!.docs.first;
                                                                    final interviewData = interviewDoc.data() as Map<String, dynamic>;
                                                                    _showInterviewDetails(context, interviewData);
                                                                  } else {
                                                                    Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder: (con) => SentScreen(
                                                                          position: snapshot2.data!.docs[index2]['position'],
                                                                          companyName: snapshot.data!.docs[index]['companyName'],
                                                                          message: snapshot2.data!.docs[index2]['message'],
                                                                          salary: snapshot2.data!.docs[index2]['salary'],
                                                                          location: snapshot2.data!.docs[index2]['location'],
                                                                          type: snapshot2.data!.docs[index2]['type'],
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }
                                                                }
                                                              },
                                                              child: Container(
                                                                height: 28,
                                                                width:
                                                                    Get.width,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: applicationController
                                                                              .selectedJobs
                                                                              .value ==
                                                                          3
                                                                      ? const Color(
                                                                          0xffFEEFEF)
                                                                      : currentStatus == 'Schedule Interview'
                                                                          ? const Color(0xffFFFBED)
                                                                          : currentStatus == 'Sent'
                                                                              ? const Color(0xffEEF2FA)
                                                                              : const Color(0xffFFFBED),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              99),
                                                                ),
                                                                child: Center(
                                                                  child: Text(
                                                                    applicationController.selectedJobs.value == 3
                                                                        ? "Delete Application"
                                                                        : currentStatus == 'Schedule Interview'
                                                                            ? "Interview Scheduled"
                                                                            : currentStatus == 'Sent'
                                                                                ? "Application Sent"
                                                                                : "Application Pending",
                                                                    style:
                                                                        appTextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: applicationController.selectedJobs.value == 3
                                                                          ? const Color(0xffDA1414)
                                                                          : currentStatus == 'Schedule Interview'
                                                                              ? const Color(0xff28a745)
                                                                              : currentStatus == 'Sent'
                                                                                  ? const Color(0xff2E5AAC)
                                                                                  : const Color(0xffF1C100),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    : const SizedBox(),
                                                ],
                                              );
                                            });
                                          },
                                        )
                                      : const SizedBox();
                                },
                              );
                            },
                          );
                        });
                  }),
            ),
          ],
        ),
      ),
    );
  }

  // Show interview details dialog
  void _showInterviewDetails(BuildContext context, Map<String, dynamic> interviewData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final interviewDate = interviewData['interviewDate']?.toDate() ?? DateTime.now();
        final formattedDate = "${interviewDate.day}/${interviewDate.month}/${interviewDate.year}";
        final formattedTime = "${interviewDate.hour.toString().padLeft(2, '0')}:${interviewDate.minute.toString().padLeft(2, '0')}";

        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.calendar_month,
                color: const Color.fromARGB(255, 0, 6, 71),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Interview Details',
                style: appTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color.fromARGB(255, 0, 6, 71),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 0, 6, 71).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color.fromARGB(255, 0, 6, 71).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Company', interviewData['companyName'] ?? 'Unknown'),
                      _buildDetailRow('Position', interviewData['jobTitle'] ?? 'Unknown'),
                      _buildDetailRow('Date', formattedDate),
                      _buildDetailRow('Time', formattedTime),
                      _buildDetailRow('Location', interviewData['location'] ?? 'TBD'),
                      if (interviewData['additionalMessage'] != null && 
                          interviewData['additionalMessage'].toString().isNotEmpty)
                        _buildDetailRow('Message', interviewData['additionalMessage']),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Interview scheduled! Please check your email for confirmation.',
                          style: appTextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: appTextStyle(
                  color: const Color.fromARGB(255, 0, 6, 71),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: appTextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color.fromARGB(255, 0, 6, 71),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: appTextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
