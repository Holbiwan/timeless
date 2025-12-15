// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeless/controllers/employer_profile_controller.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/services/google_auth_service.dart';
import 'package:timeless/services/auth_service.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/utils/string.dart';

class EmployerSettingsScreen extends StatefulWidget {
  const EmployerSettingsScreen({super.key});

  @override
  State<EmployerSettingsScreen> createState() => _EmployerSettingsScreenState();
}

class _EmployerSettingsScreenState extends State<EmployerSettingsScreen> {
  late EmployerProfileController employerProfileController;
  late AuthService authService;

  @override
  void initState() {
    super.initState();
    employerProfileController = Get.put(EmployerProfileController());
    authService = Get.put(AuthService());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.backgroundColor,
      body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Get.back();
                    }
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    margin: const EdgeInsets.only(left: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF000647), width: 2.0),
                    ),
                    child: const Align(
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Center(
                    child: Text(
                      "Employer Settings",
                      style: appTextStyle(
                          color: ColorRes.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),

            // Modifier le profil employeur
            InkWell(
              onTap: () => _showEditProfile(context),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 55,
                          width: 55,
                          decoration: BoxDecoration(
                            color: const Color(0xFF000647),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.business,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Text(
                          "Edit company profile",
                          style: appTextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: ColorRes.black),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                      size: 15,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 3),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              color: ColorRes.lightGrey.withOpacity(0.8),
              height: 1,
            ),
            const SizedBox(height: 10),

            // Modifier le mot de passe
            InkWell(
              onTap: () => _showChangePassword(context),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 55,
                          width: 55,
                          decoration: BoxDecoration(
                            color: const Color(0xFF000647),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.lock_reset,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Text(
                          "Change password",
                          style: appTextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: ColorRes.black),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                      size: 15,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 3),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              color: ColorRes.lightGrey.withOpacity(0.8),
              height: 1,
            ),
            const SizedBox(height: 10),

            // Valider SIRET
            InkWell(
              onTap: () => _showValidateSiret(context),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 55,
                          width: 55,
                          decoration: BoxDecoration(
                            color: const Color(0xFF000647),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.verified_user,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Text(
                          "Validate SIRET",
                          style: appTextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: ColorRes.black),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Obx(() => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: employerProfileController.isVerified.value 
                                ? Colors.green[100] 
                                : Colors.orange[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            employerProfileController.isVerified.value ? "Verified" : "Not verified",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: employerProfileController.isVerified.value 
                                  ? Colors.green[700] 
                                  : Colors.orange[700],
                            ),
                          ),
                        )),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey,
                          size: 15,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 3),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              color: ColorRes.lightGrey.withOpacity(0.8),
              height: 1,
            ),
            const SizedBox(height: 10),

            // Supprimer le compte
            InkWell(
              onTap: () => _showDeleteAccount(context),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 55,
                          width: 55,
                          decoration: BoxDecoration(
                            color: const Color(0xFF000647),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.delete_forever,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Text(
                          "Delete account",
                          style: appTextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: ColorRes.black),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                      size: 15,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 3),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              color: ColorRes.lightGrey.withOpacity(0.8),
              height: 1,
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: InkWell(
                onTap: () => _showLogoutConfirmation(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 55,
                          width: 55,
                          decoration: BoxDecoration(
                            color: const Color(0xFF000647),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.logout,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Text(
                          Strings.logout,
                          style: appTextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: ColorRes.black),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                      size: 15,
                    ),
                  ],
                ),
              ),
            ),
          ]),
    );
  }

  // Fonction pour modifier le profil employeur avec mise à jour temps réel
  void _showEditProfile(BuildContext context) {
    
    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header fixe
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                children: [
                  Icon(Icons.business, color: const Color(0xFF000647), size: 24),
                  const SizedBox(width: 8),
                  Text(
                    "Edit company profile",
                    style: appTextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: ColorRes.black,
                    ),
                  ),
                ],
              ),
            ),
            
            // Contenu scrollable
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    // Edit Company Name
                    ListTile(
                      leading: const Icon(Icons.business, color: Color(0xFF000647)),
                      title: Text("Company name", style: appTextStyle(fontSize: 15, color: ColorRes.black)),
                      subtitle: Obx(() => Text(
                        employerProfileController.companyName.value.isEmpty ? 'No company name set' : employerProfileController.companyName.value,
                        style: appTextStyle(fontSize: 13, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Get.back();
                        _showEditCompanyNameDialog(context);
                      },
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    
                    // Edit Email
                    ListTile(
                      leading: const Icon(Icons.email, color: Color(0xFF000647)),
                      title: Text("Email", style: appTextStyle(fontSize: 15, color: ColorRes.black)),
                      subtitle: Obx(() => Text(
                        employerProfileController.email.value.isEmpty ? 'No email set' : employerProfileController.email.value,
                        style: appTextStyle(fontSize: 13, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Get.back();
                        _showEditEmailDialog(context);
                      },
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    
                    // Edit Phone
                    ListTile(
                      leading: const Icon(Icons.phone, color: Color(0xFF000647)),
                      title: Text("Phone", style: appTextStyle(fontSize: 15, color: ColorRes.black)),
                      subtitle: Obx(() => Text(
                        employerProfileController.phoneNumber.value.isEmpty ? 'No phone set' : employerProfileController.phoneNumber.value,
                        style: appTextStyle(fontSize: 13, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Get.back();
                        _showEditPhoneDialog(context);
                      },
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    
                    // Edit Website
                    ListTile(
                      leading: const Icon(Icons.language, color: Color(0xFF000647)),
                      title: Text("Website", style: appTextStyle(fontSize: 15, color: ColorRes.black)),
                      subtitle: Obx(() => Text(
                        employerProfileController.website.value.isEmpty ? 'No website set' : employerProfileController.website.value,
                        style: appTextStyle(fontSize: 13, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Get.back();
                        _showEditWebsiteDialog(context);
                      },
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    
                    // Edit Location
                    ListTile(
                      leading: const Icon(Icons.location_on, color: Color(0xFF000647)),
                      title: Text("Location", style: appTextStyle(fontSize: 15, color: ColorRes.black)),
                      subtitle: Obx(() => Text(
                        employerProfileController.location.value.isEmpty ? 'No location set' : employerProfileController.location.value,
                        style: appTextStyle(fontSize: 13, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Get.back();
                        _showEditLocationDialog(context);
                      },
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    
                    // Company Logo
                    ListTile(
                      leading: const Icon(Icons.image, color: Color(0xFF000647)),
                      title: Text("Company logo", style: appTextStyle(fontSize: 15, color: ColorRes.black)),
                      subtitle: Obx(() => Text(
                        employerProfileController.hasProfileImage() ? 'Logo set' : 'No logo',
                        style: appTextStyle(fontSize: 13, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Get.back();
                        _showEditCompanyLogoDialog(context);
                      },
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    ),
                    
                    // Espace en bas pour éviter le débordement
                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // Fonctions d'édition pour chaque champ
  void _showEditCompanyNameDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    nameController.text = employerProfileController.companyName.value;
    
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.business, color: const Color(0xFF000647), size: 24),
            const SizedBox(width: 8),
            Text("Edit company name", style: appTextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Company name",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: const Color(0xFF000647), width: 2),
                ),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            Text(
              "This will update your company name across the entire application",
              style: appTextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel", style: appTextStyle(color: Colors.grey, fontSize: 14)),
          ),
          Obx(() => ElevatedButton(
            onPressed: employerProfileController.isLoading.value ? null : () async {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty && newName != employerProfileController.companyName.value) {
                try {
                  employerProfileController.isLoading.value = true;
                  employerProfileController.companyNameController.text = newName;
                  await employerProfileController.onTapSubmit();
                  Get.back();
                  Get.snackbar(
                    "Success",
                    "Company name updated successfully!",
                    backgroundColor: const Color(0xFF000647),
                    colorText: Colors.white,
                    duration: const Duration(seconds: 3),
                  );
                } catch (e) {
                  Get.snackbar(
                    "Error",
                    "Failed to update company name: $e",
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                } finally {
                  employerProfileController.isLoading.value = false;
                }
              } else if (newName.isEmpty) {
                Get.snackbar(
                  "Error",
                  "Company name cannot be empty",
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              } else {
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF000647),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: const Size(0, 36),
            ),
            child: employerProfileController.isLoading.value 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text("Save", style: appTextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
          )),
        ],
      ),
    );
  }

  void _showEditEmailDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    emailController.text = employerProfileController.email.value;
    
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.email, color: const Color(0xFF000647), size: 24),
            const SizedBox(width: 8),
            Text("Edit email", style: appTextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email address",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: const Color(0xFF000647), width: 2),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel", style: appTextStyle(color: Colors.grey, fontSize: 14)),
          ),
          Obx(() => ElevatedButton(
            onPressed: employerProfileController.isLoading.value ? null : () async {
              final newEmail = emailController.text.trim();
              if (newEmail.isNotEmpty && newEmail.contains('@') && newEmail != employerProfileController.email.value) {
                try {
                  employerProfileController.isLoading.value = true;
                  employerProfileController.emailController.text = newEmail;
                  await employerProfileController.onTapSubmit();
                  Get.back();
                  Get.snackbar(
                    "Success",
                    "Email updated successfully!",
                    backgroundColor: const Color(0xFF000647),
                    colorText: Colors.white,
                  );
                } catch (e) {
                  Get.snackbar(
                    "Error",
                    "Failed to update email: $e",
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                } finally {
                  employerProfileController.isLoading.value = false;
                }
              } else if (newEmail.isEmpty || !newEmail.contains('@')) {
                Get.snackbar(
                  "Error",
                  "Please enter a valid email address",
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              } else {
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF000647),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: const Size(0, 36),
            ),
            child: employerProfileController.isLoading.value 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text("Save", style: appTextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
          )),
        ],
      ),
    );
  }

  void _showEditPhoneDialog(BuildContext context) {
    final TextEditingController phoneController = TextEditingController();
    phoneController.text = employerProfileController.phoneNumber.value;
    
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.phone, color: const Color(0xFF000647), size: 24),
            const SizedBox(width: 8),
            Text("Edit phone", style: appTextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
        content: TextField(
          controller: phoneController,
          decoration: InputDecoration(
            labelText: "Phone number",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: const Color(0xFF000647), width: 2),
            ),
          ),
          keyboardType: TextInputType.phone,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel", style: appTextStyle(color: Colors.grey, fontSize: 14)),
          ),
          Obx(() => ElevatedButton(
            onPressed: employerProfileController.isLoading.value ? null : () async {
              final newPhone = phoneController.text.trim();
              if (newPhone != employerProfileController.phoneNumber.value) {
                try {
                  employerProfileController.isLoading.value = true;
                  employerProfileController.phoneController.text = newPhone;
                  await employerProfileController.onTapSubmit();
                  Get.back();
                  Get.snackbar(
                    "Success",
                    "Phone number updated successfully!",
                    backgroundColor: const Color(0xFF000647),
                    colorText: Colors.white,
                  );
                } catch (e) {
                  Get.snackbar(
                    "Error",
                    "Failed to update phone number: $e",
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                } finally {
                  employerProfileController.isLoading.value = false;
                }
              } else {
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF000647),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: const Size(0, 36),
            ),
            child: employerProfileController.isLoading.value 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text("Save", style: appTextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
          )),
        ],
      ),
    );
  }

  void _showEditWebsiteDialog(BuildContext context) {
    final TextEditingController websiteController = TextEditingController();
    websiteController.text = employerProfileController.website.value;
    
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.language, color: const Color(0xFF000647), size: 24),
            const SizedBox(width: 8),
            Text("Edit website", style: appTextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
        content: TextField(
          controller: websiteController,
          decoration: InputDecoration(
            labelText: "Website URL",
            hintText: "https://www.example.com",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: const Color(0xFF000647), width: 2),
            ),
          ),
          keyboardType: TextInputType.url,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel", style: appTextStyle(color: Colors.grey, fontSize: 14)),
          ),
          Obx(() => ElevatedButton(
            onPressed: employerProfileController.isLoading.value ? null : () async {
              final newWebsite = websiteController.text.trim();
              if (newWebsite != employerProfileController.website.value) {
                try {
                  employerProfileController.isLoading.value = true;
                  employerProfileController.websiteController.text = newWebsite;
                  await employerProfileController.onTapSubmit();
                  Get.back();
                  Get.snackbar(
                    "Success",
                    "Website updated successfully!",
                    backgroundColor: const Color(0xFF000647),
                    colorText: Colors.white,
                  );
                } catch (e) {
                  Get.snackbar(
                    "Error",
                    "Failed to update website: $e",
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                } finally {
                  employerProfileController.isLoading.value = false;
                }
              } else {
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF000647),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: const Size(0, 36),
            ),
            child: employerProfileController.isLoading.value 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text("Save", style: appTextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
          )),
        ],
      ),
    );
  }

  void _showEditLocationDialog(BuildContext context) {
    final TextEditingController locationController = TextEditingController();
    locationController.text = employerProfileController.location.value;
    
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.location_on, color: const Color(0xFF000647), size: 24),
            const SizedBox(width: 8),
            Text("Edit location", style: appTextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
        content: TextField(
          controller: locationController,
          decoration: InputDecoration(
            labelText: "Company location",
            hintText: "Paris, France",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: const Color(0xFF000647), width: 2),
            ),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel", style: appTextStyle(color: Colors.grey, fontSize: 14)),
          ),
          Obx(() => ElevatedButton(
            onPressed: employerProfileController.isLoading.value ? null : () async {
              final newLocation = locationController.text.trim();
              if (newLocation != employerProfileController.location.value) {
                try {
                  employerProfileController.isLoading.value = true;
                  employerProfileController.locationController.text = newLocation;
                  await employerProfileController.onTapSubmit();
                  Get.back();
                  Get.snackbar(
                    "Success",
                    "Location updated successfully!",
                    backgroundColor: const Color(0xFF000647),
                    colorText: Colors.white,
                  );
                } catch (e) {
                  Get.snackbar(
                    "Error",
                    "Failed to update location: $e",
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                } finally {
                  employerProfileController.isLoading.value = false;
                }
              } else {
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF000647),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: const Size(0, 36),
            ),
            child: employerProfileController.isLoading.value 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text("Save", style: appTextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
          )),
        ],
      ),
    );
  }

  void _showEditCompanyLogoDialog(BuildContext context) {
    
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.image, color: const Color(0xFF000647), size: 24),
                const SizedBox(width: 8),
                Text(
                  "Company Logo",
                  style: appTextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: ColorRes.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF000647)),
              title: Text("Take a photo", style: appTextStyle(fontSize: 16, color: ColorRes.black)),
              onTap: () async {
                Get.back();
                await employerProfileController.onTapImage();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF000647)),
              title: Text("Choose from gallery", style: appTextStyle(fontSize: 16, color: ColorRes.black)),
              onTap: () async {
                Get.back();
                await employerProfileController.onTapGallery1();
              },
            ),
            if (employerProfileController.hasProfileImage()) ...[
              const Divider(),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red[600]),
                title: Text("Remove logo", style: appTextStyle(fontSize: 16, color: Colors.red[600])),
                onTap: () async {
                  Get.back();
                  employerProfileController.profileImageUrl.value = '';
                  await employerProfileController.onTapSubmit();
                  Get.snackbar(
                    "Success",
                    "Company logo removed",
                    backgroundColor: const Color(0xFF000647),
                    colorText: Colors.white,
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showChangePassword(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(bottom: 80),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.lock_reset, color: const Color(0xFF000647), size: 24),
                const SizedBox(width: 8),
                Text(
                  "Change password",
                  style: appTextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: ColorRes.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                children: [
                  Icon(Icons.email_outlined, color: Colors.blue[600], size: 32),
                  const SizedBox(height: 12),
                  Text(
                    "Password Reset Email",
                    style: appTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() => Text(
                    "We'll send instructions to:\n${employerProfileController.email.value}",
                    textAlign: TextAlign.center,
                    style: appTextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  )),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      side: BorderSide(color: Colors.grey[400]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      minimumSize: const Size(0, 40),
                    ),
                    child: Text(
                      "Cancel",
                      style: appTextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      _sendPasswordResetEmail();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF000647),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      minimumSize: const Size(0, 40),
                    ),
                    child: Text(
                      "Send Instructions",
                      style: appTextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _sendPasswordResetEmail() async {
    final email = employerProfileController.email.value;
    
    if (email.isNotEmpty) {
      try {
        final success = await authService.resetPassword(email);
        
        if (success) {
          Get.dialog(
            AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mark_email_read, color: Colors.green[600], size: 48),
                  const SizedBox(height: 16),
                  Text(
                    "Email Sent!",
                    style: appTextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "A password reset link has been sent to:",
                    style: appTextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      email,
                      style: appTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF000647),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF000647),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Got it!",
                    style: appTextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      } catch (error) {
        Get.snackbar(
          "Error",
          "Failed to send password reset email: $error",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      Get.snackbar(
        "Error",
        "No email address found in your profile",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showValidateSiret(BuildContext context) {
    final TextEditingController siretController = TextEditingController();
    siretController.text = employerProfileController.siretCode.value;
    
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.verified_user, color: const Color(0xFF000647), size: 24),
            const SizedBox(width: 8),
            Text("Validate SIRET", style: appTextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: siretController,
              decoration: InputDecoration(
                labelText: "SIRET Number",
                hintText: "14 digits",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: const Color(0xFF000647), width: 2),
                ),
              ),
              keyboardType: TextInputType.number,
              maxLength: 14,
            ),
            const SizedBox(height: 8),
            Text(
              "Enter your 14-digit SIRET number to verify your company",
              style: appTextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel", style: appTextStyle(color: Colors.grey, fontSize: 14)),
          ),
          Obx(() => ElevatedButton(
            onPressed: employerProfileController.isLoading.value ? null : () async {
              final siret = siretController.text.trim();
              if (siret.length == 14) {
                try {
                  employerProfileController.isLoading.value = true;
                  employerProfileController.siretController.text = siret;
                  final isValid = await employerProfileController.validateSiretCode();
                  
                  if (isValid) {
                    await employerProfileController.onTapSubmit();
                    Get.back();
                  }
                } catch (e) {
                  // Error handled in validateSiretCode
                } finally {
                  employerProfileController.isLoading.value = false;
                }
              } else {
                Get.snackbar(
                  "Invalid SIRET",
                  "SIRET must contain exactly 14 digits",
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF000647),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: const Size(0, 36),
            ),
            child: employerProfileController.isLoading.value 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text("Validate", style: appTextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
          )),
        ],
      ),
    );
  }

  void _showDeleteAccount(BuildContext context) {
    
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red[600], size: 28),
            const SizedBox(width: 8),
            Text(
              'Delete Account',
              style: appTextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.red[600],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action is irreversible!',
                      style: appTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.red[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'The following data will be permanently deleted:',
              style: appTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ColorRes.black,
              ),
            ),
            const SizedBox(height: 8),
            _buildDeleteItem('• Company profile information'),
            _buildDeleteItem('• Posted job offers'),
            _buildDeleteItem('• Job applications received'),
            _buildDeleteItem('• All account data and settings'),
            const SizedBox(height: 12),
            Obx(() => Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Company: ${employerProfileController.companyName.value}\nEmail: ${employerProfileController.email.value}',
                style: appTextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: appTextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _confirmDeleteAccount();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: const Size(0, 36),
            ),
            child: Text(
              'Continue to Delete',
              style: appTextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDeleteItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: appTextStyle(
          fontSize: 13,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  void _confirmDeleteAccount() async {
    final TextEditingController confirmController = TextEditingController();
    final RxBool canDelete = false.obs;
    
    confirmController.addListener(() {
      canDelete.value = confirmController.text.trim().toUpperCase() == 'DELETE';
    });
    
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            Icon(Icons.dangerous, color: Colors.red[700], size: 28),
            const SizedBox(width: 8),
            Text(
              'Final Confirmation',
              style: appTextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Colors.red[700],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[300]!, width: 2),
              ),
              child: Column(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red[700], size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'LAST WARNING',
                    style: appTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'This action cannot be undone!',
                    style: appTextStyle(
                      fontSize: 12,
                      color: Colors.red[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Type "DELETE" to confirm (case sensitive):',
              style: appTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ColorRes.black,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: confirmController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.red[600]!, width: 2),
                ),
                hintText: "Type DELETE here",
                hintStyle: appTextStyle(color: Colors.grey[500]),
              ),
              style: appTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Cancel',
              style: appTextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Obx(() => ElevatedButton(
            onPressed: canDelete.value ? () {
              Get.back(result: true);
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canDelete.value ? Colors.red[700] : Colors.grey[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Delete Forever',
              style: appTextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          )),
        ],
      ),
    );
    
    if (confirmed == true) {
      await _performAccountDeletion();
    }
  }
  
  Future<void> _performAccountDeletion() async {
    
    try {
      Get.dialog(
        AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFF000647)),
              const SizedBox(height: 16),
              Text(
                'Deleting employer account...',
                style: appTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        barrierDismissible: false,
      );
      
      await employerProfileController.clearEmployerProfileData();
      
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete();
      }
      
      await GoogleAuthService.signOut();
      await _clearAllPreferences();
      
      Get.back();
      
      Get.dialog(
        AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green[600], size: 48),
              const SizedBox(height: 16),
              Text(
                'Account Deleted',
                style: appTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your employer account has been permanently deleted.',
                style: appTextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.offAllNamed('/');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF000647),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Continue',
                style: appTextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        barrierDismissible: false,
      );
      
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      Get.snackbar(
        "Deletion Error",
        "Failed to delete account: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 6),
      );
    }
  }

  void _showLogoutConfirmation(BuildContext context) async {
    
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.logout_rounded, color: Colors.orange[600], size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'Logout',
              style: appTextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: ColorRes.black,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to log out of your employer account?',
              style: appTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: ColorRes.black,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() => Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFF000647),
                    child: Text(
                      employerProfileController.getInitials(),
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employerProfileController.companyName.value.isEmpty ? 'Employer' : employerProfileController.companyName.value,
                          style: appTextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          employerProfileController.email.value,
                          style: appTextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              'Cancel',
              style: appTextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF000647),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              minimumSize: const Size(0, 32),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.logout_rounded, size: 18, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  'Logout',
                  style: appTextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _performLogout();
    }
  }
  
  Future<void> _performLogout() async {
    try {
      Get.dialog(
        AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFF000647)),
              const SizedBox(height: 16),
              Text(
                'Signing out...',
                style: appTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        barrierDismissible: false,
      );
      
      await authService.signOut();
      await employerProfileController.clearEmployerProfileData();
      await _clearAllPreferences();
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      Get.back();
      
      Get.dialog(
        AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle_outline, color: Colors.green[600], size: 48),
              ),
              const SizedBox(height: 16),
              Text(
                'Logout Successful!',
                style: appTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Thank you for using Timeless Pro.\nSee you soon!',
                style: appTextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.offAllNamed('/');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF000647),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(double.infinity, 45),
              ),
              child: Text(
                'Continue to Welcome Screen',
                style: appTextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        barrierDismissible: false,
      );
      
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      Get.snackbar(
        "Logout Error",
        "An error occurred during logout: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _clearAllPreferences() async {
    final keysToRemove = [
      PrefKeys.password,
      PrefKeys.rememberMe,
      PrefKeys.registerToken,
      PrefKeys.userId,
      PrefKeys.country,
      PrefKeys.email,
      PrefKeys.totalPost,
      PrefKeys.phoneNumber,
      PrefKeys.city,
      PrefKeys.state,
      PrefKeys.fullName,
      PrefKeys.rol,
      PrefKeys.companyName,
      PrefKeys.company,
    ];

    for (String key in keysToRemove) {
      PreferencesService.setValue(key, "");
    }
  }
}