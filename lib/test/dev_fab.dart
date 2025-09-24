// lib/test/dev_fab.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:timeless/test/job_list_test_screen.dart';
import 'package:timeless/test/upload_cv_test_screen.dart';
import 'package:timeless/test/seed_jobs_from_asset.dart';
import 'package:timeless/dev/create_demo_jobs.dart';
import 'package:timeless/dev/demo_setup.dart';

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
                        await importJobsFromAsset(); // ⚡ appelle la fonction qu'on a créée
                        Get.snackbar('Import', 'Jobs imported successfully',
                            snackPosition: SnackPosition.BOTTOM);
                      } catch (e) {
                        Get.snackbar('Import error', e.toString(),
                            snackPosition: SnackPosition.BOTTOM);
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.work),
                    title: const Text('Create 10 Demo Jobs → /allPost'),
                    subtitle: const Text('Jobs avec candidature rapide'),
                    onTap: () async {
                      Navigator.pop(context);
                      try {
                        await createDemoJobs();
                        await createCategoryJobs();
                        Get.snackbar('Success', '10 demo jobs created successfully!',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green,
                            colorText: Colors.white);
                      } catch (e) {
                        Get.snackbar('Error', 'Unable to create jobs: $e',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white);
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Setup Complete Demo'),
                    subtitle: const Text('Complete demo configuration'),
                    onTap: () async {
                      Navigator.pop(context);
                      try {
                        await DemoSetup.setupCompleteDemo();
                        Get.snackbar('Configuration complète', 'Démonstration prête!',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green,
                            colorText: Colors.white);
                      } catch (e) {
                        Get.snackbar('Erreur de configuration', e.toString(),
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white);
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.analytics),
                    title: const Text('Show Job Stats'),
                    subtitle: const Text('Statistiques des collections'),
                    onTap: () async {
                      Navigator.pop(context);
                      try {
                        final stats = await DemoSetup.getJobStats();
                        final message = stats.entries
                            .map((e) => '${e.key}: ${e.value}')
                            .join('\n');
                        Get.dialog(
                          AlertDialog(
                            title: const Text('Statistiques Jobs'),
                            content: Text(message),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      } catch (e) {
                        Get.snackbar('Erreur', e.toString(),
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
