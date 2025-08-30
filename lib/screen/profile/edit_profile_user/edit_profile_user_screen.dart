import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/asset_res.dart';
import 'package:timeless/common/widgets/common_text_field.dart';
import 'package:timeless/common/widgets/common_error_box.dart';

// ⚠️ Importe bien le controller depuis Profile/ (P majuscule)
import 'package:timeless/screen/manager_section/Profile/manager_profile_controller.dart';

class EditProfileUserScreen extends StatelessWidget {
  EditProfileUserScreen({super.key});

  final ManagerProfileController controller =
      Get.isRegistered<ManagerProfileController>()
          ? Get.find<ManagerProfileController>()
          : Get.put(ManagerProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.backgroundColor,
      appBar: AppBar(
        title: const Text('Edit profile'),
        backgroundColor: ColorRes.containerColor,
      ),
      body: Obx(
        () => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // -------- Avatar --------
              Center(
                child: Stack(
                  children: [
                    _buildAvatar(),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Row(
                        children: [
                          _smallFab(
                            icon: Icons.photo_camera,
                            onTap: () => controller.ontap(), // camera
                          ),
                          const SizedBox(width: 8),
                          _smallFab(
                            icon: Icons.photo_library_outlined,
                            onTap: () => controller.ontapGallery(), // gallery
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // -------- Form minimal (exemple) --------
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Display name', style: appTextStyle(fontSize: 14)),
              ),
              const SizedBox(height: 8),
              commonTextFormField(
                textDecoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Your name',
                ),
                controller: TextEditingController(), // brancher ton vrai controller si besoin
              ),
              const SizedBox(height: 12),
              // Exemple erreur
              // commonErrorBox("Please enter a valid name"),

              const SizedBox(height: 24),

              // -------- Save button --------
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: controller.EditTap,
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all(ColorRes.containerColor),
                  ),
                  child: Text(
                    'Save',
                    style: appTextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Build avatar in priority:
  /// 1) fbImageUrl (Network)
  /// 2) image local File
  /// 3) placeholder Asset
  Widget _buildAvatar() {
    final hasFb = controller.fbImageUrl.value.isNotEmpty;
    final hasLocal = controller.image != null;

    DecorationImage? img;
    if (hasFb) {
      img = DecorationImage(
        image: NetworkImage(controller.fbImageUrl.value),
        fit: BoxFit.cover,
      );
    } else if (hasLocal) {
      img = DecorationImage(
        image: FileImage(File(controller.image!.path)),
        fit: BoxFit.cover,
      );
    } else {
      img = const DecorationImage(
        image: AssetImage(AssetRes.userImage),
        fit: BoxFit.cover,
      );
    }

    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ColorRes.black,
        image: img,
      ),
    );
  }

  Widget _smallFab({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(
          color: ColorRes.logoColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(blurRadius: 4, offset: Offset(0, 2), color: Colors.black12)
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
