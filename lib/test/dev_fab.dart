// lib/test/dev_fab.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:timeless/test/job_list_test_screen.dart';
import 'package:timeless/test/upload_cv_test_screen.dart';
import 'package:timeless/test/seed_jobs_from_asset.dart';

class DevFab extends StatelessWidget {
  const DevFab({super.key});

  @override
  Widget build(BuildContext context) {
    // Rien en release → pas de risque pour ta démo
    if (!kDebugMode) return const SizedBox.shrink();

    return FloatingActionButton(
      heroTag: 'dev_fab',
      child: const Icon(Icons.bug_report),
      onPressed: () {
        Get.bottomSheet(
          SafeArea(
            child: Material(
              color: Colors.white,
              child: Wrap(
                children: [
                  const ListTile(
                    title: Text('Dev shortcuts'),
                    subtitle: Text('Quick tests (debug only)'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.list),
                    title: const Text('Test Firestore: jobs list'),
                    onTap: () {
                      Get.back();
                      Get.to(() => const JobListTestScreen());
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.upload_file),
                    title: const Text('Test Storage: upload CV'),
                    onTap: () {
                      Get.back();
                      Get.to(() => const UploadCvTestScreen());
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.upload),
                    title: const Text('Import jobs.json asset → /jobs'),
                    onTap: () async {
                      Navigator.pop(context); // ferme la modal
                      try {
                        await importJobsFromAsset(); // ⚡ appelle la fonction qu’on a créée
                        Get.snackbar('Import', 'Jobs imported successfully',
                            snackPosition: SnackPosition.BOTTOM);
                      } catch (e) {
                        Get.snackbar('Import error', e.toString(),
                            snackPosition: SnackPosition.BOTTOM);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
