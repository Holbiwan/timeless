import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timeless/common/widgets/back_button.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/utils/string.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationScreenM extends StatelessWidget {
  const NotificationScreenM({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine the correct user ID (try Auth first, then Prefs)
    final uid = FirebaseAuth.instance.currentUser?.uid ?? PreferencesService.getString(PrefKeys.userId);

    return Scaffold(
      backgroundColor: ColorRes.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Get.back(),
                    child: backButton(),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    Strings.notification,
                    style: appTextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: ColorRes.black,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('employers')
                    .doc(uid)
                    .collection('notifications')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_off_outlined,
                              size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            "No notifications yet",
                            style: appTextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final title = data['title_en'] ?? data['title'] ?? 'Notification';
                      final body = data['message_en'] ?? data['message'] ?? '';
                      final timestamp = (data['createdAt'] as Timestamp?)?.toDate();
                      final timeStr = timestamp != null
                          ? DateFormat('MMM d, HH:mm').format(timestamp)
                          : '';
                      final cvUrl = data['cvUrl'];

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 8),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: ColorRes.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: const Color(0xffF3ECFF)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF000647).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.notifications_active,
                                    color: Color(0xFF000647),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: appTextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: ColorRes.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        body,
                                        style: appTextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: ColorRes.black.withOpacity(0.7),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        timeStr,
                                        style: appTextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (cvUrl != null && (cvUrl as String).isNotEmpty) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    // Try to launch URL
                                    final uri = Uri.parse(cvUrl);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                                    } else {
                                      Get.snackbar('Error', 'Could not launch CV URL');
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF000647),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: const Icon(Icons.download, size: 16),
                                  label: const Text("Download CV"),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
