import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeless/screen/dashboard/dashboard_controller.dart';
import 'package:timeless/screen/looking_for_screen/looking_for_screen.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/services/google_auth_service.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/utils/string.dart';
import 'package:timeless/utils/app_theme.dart';

class SettingsScreenU extends StatelessWidget {
  const SettingsScreenU({super.key});

  @override
  Widget build(BuildContext context) {
    DashBoardController controller = Get.put(DashBoardController());
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
                      Get.offAllNamed('/dashboard');
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
                      Strings.settings,
                      style: appTextStyle(
                          color: ColorRes.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            /*  InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (con) => const NotificationScreenU()));
              },
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
                            color: ColorRes.logoColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.notifications,
                            color: ColorRes.containerColor,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Text(
                          Strings.notification,
                          style: appTextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: ColorRes.black),
                        ),
                      ],
                    ),
                    const Image(
                      image: AssetImage(AssetRes.settingaArrow),
                      height: 15,
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
            const SizedBox(height: 10),*/
            // InkWell(
            //   onTap: () {
            //     Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //             builder: (con) => const SecurityScreenU()));
            //   },
            //   child: Padding(
            //     padding: const EdgeInsets.all(12.0),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         Row(
            //           children: [
            //             Container(
            //               height: 55,
            //               width: 55,
            //               decoration: BoxDecoration(
            //                 color: ColorRes.logoColor,
            //                 borderRadius: BorderRadius.circular(15),
            //               ),
            //               child: const Icon(
            //                 Icons.lock,
            //                 color: ColorRes.containerColor,
            //               ),
            //             ),
            //             const SizedBox(width: 15),
            //             Text(
            //               Strings.security,
            //               style: appTextStyle(
            //                   fontWeight: FontWeight.w500,
            //                   fontSize: 14,
            //                   color: ColorRes.black),
            //             ),
            //           ],
            //         ),
            //         const Image(
            //           image: AssetImage(AssetRes.settingaArrow),
            //           height: 15,
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 3),
            // Container(
            //   margin: const EdgeInsets.symmetric(horizontal: 10),
            //   color: ColorRes.lightGrey.withOpacity(0.8),
            //   height: 1,
            // ),
            const SizedBox(height: 10),
            // Modifier le nom/email
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
                            Icons.edit,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Text(
                          "Modifier le profil",
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
                          "Modifier le mot de passe",
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
                          "Supprimer le compte",
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

            // const SizedBox(height: 10),
            /* InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (con) => const HelpScreenU()));
              },
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
                            color: ColorRes.logoColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(17.0),
                            child: Image(
                              image: AssetImage(AssetRes.settingHelp),
                              width: 20,
                              color: ColorRes.containerColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Text(
                          Strings.help,
                          style: appTextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: ColorRes.black),
                        ),
                      ],
                    ),
                    const Image(
                      image: AssetImage(AssetRes.settingaArrow),
                      height: 15,
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
            */

            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: InkWell(
                onTap: () => _showLogoutConfirmation(context, controller),
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

  settingModalBottomSheet(context) async {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext bc) {
          return Container(
            height: 265,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(45),
                topRight: Radius.circular(45),
              ),
              border: Border.all(color: AppTheme.buttonBorderColor, width: 2.0),
            ),
            child: Column(
              children: [
                const SizedBox(height: 50),
                const Icon(
                  Icons.logout,
                  color: ColorRes.starColor,
                  size: 48,
                ),
                const SizedBox(height: 20),
                Text(
                  "Are you sure want to logout?",
                  style: appTextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: ColorRes.black.withOpacity(0.8)),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          height: 50,
                          width: 160,
                          decoration: BoxDecoration(
                              color: ColorRes.white,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              border:
                                  Border.all(color: ColorRes.containerColor)),
                          child: Center(
                              child: Text(
                            "Cancel",
                            style: appTextStyle(
                              color: ColorRes.containerColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          )),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () async {
                        final GoogleSignIn googleSignIn = GoogleSignIn();
                        if (await googleSignIn.isSignedIn()) {
                          await googleSignIn.signOut();
                        }
                        PreferencesService.clear();
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const LookingForScreen(),
                            ),
                            (route) => false);
                      },
                      child: Container(
                        height: 50,
                        width: 160,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [
                            ColorRes.gradientColor,
                            ColorRes.containerColor,
                          ]),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Center(
                          child: Text(
                            "Yes, Logout",
                            style: appTextStyle(
                              color: ColorRes.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          );
        });
  }

  // Nouvelle fonction de déconnexion améliorée
  void _showLogoutConfirmation(BuildContext context, DashBoardController controller) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          side: BorderSide(color: AppTheme.buttonBorderColor, width: 2.0),
        ),
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.orange[600], size: 24),
            const SizedBox(width: 8),
            Text(
              'Déconnexion',
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
              'Êtes-vous sûr de vouloir vous déconnecter ?',
              style: appTextStyle(
                fontSize: 14,
                color: ColorRes.black.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vous devrez vous reconnecter pour accéder à votre compte.',
              style: appTextStyle(
                fontSize: 12,
                color: ColorRes.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Annuler',
              style: appTextStyle(
                color: ColorRes.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Se déconnecter',
              style: appTextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Réinitialiser l'onglet actuel
        controller.currentTab = 0;
        controller.update(["bottom_bar"]);

        // Déconnexion Firebase
        await FirebaseAuth.instance.signOut();
        
        // Déconnexion Google avec notre service amélioré
        await GoogleAuthService.signOut();

        // Nettoyer toutes les préférences
        await _clearAllPreferences();

        // Afficher un message de confirmation
        Get.snackbar(
          "Déconnexion réussie",
          "À bientôt sur Timeless !",
          backgroundColor: const Color(0xFF000647),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        // Navigation vers l'écran de démarrage
        Get.offAllNamed('/');

      } catch (e) {
        AppTheme.showStandardSnackBar(
          title: "Erreur de déconnexion",
          message: "Une erreur s'est produite lors de la déconnexion",
          isError: true,
        );
      }
    }
  }

  Future<void> _clearAllPreferences() async {
    // Nettoyer toutes les données utilisateur
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
    ];

    for (String key in keysToRemove) {
      PreferencesService.setValue(key, "");
    }
  }

  // Fonction pour modifier le profil
  void _showEditProfile(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(bottom: 80), // Marge pour éviter la barre de navigation
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
            Text(
              "Modifier le profil",
              style: appTextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ColorRes.black,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF000647)),
              title: Text("Modifier le nom", style: appTextStyle(fontSize: 16, color: ColorRes.black)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Get.back();
                _showEditNameDialog(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.email, color: Color(0xFF000647)),
              title: Text("Modifier l'email", style: appTextStyle(fontSize: 16, color: ColorRes.black)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Get.back();
                _showEditEmailDialog(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.photo_camera, color: Color(0xFF000647)),
              title: Text("Photo de profil", style: appTextStyle(fontSize: 16, color: ColorRes.black)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Get.back();
                Get.snackbar(
                  "Photo de profil",
                  "Fonctionnalité en développement",
                  backgroundColor: const Color(0xFF000647),
                  colorText: Colors.white,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Fonction pour changer le mot de passe
  void _showChangePassword(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(bottom: 80), // Marge pour éviter la barre de navigation
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
            Text(
              "Modifier le mot de passe",
              style: appTextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ColorRes.black,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Un email avec les instructions sera envoyé à votre adresse",
              textAlign: TextAlign.center,
              style: appTextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Get.back();
                _sendPasswordResetEmail();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF000647),
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Envoyer les instructions",
                style: appTextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fonction pour supprimer le compte
  void _showDeleteAccount(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red[600], size: 24),
            const SizedBox(width: 8),
            Text(
              'Supprimer le compte',
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
          children: [
            Text(
              'Cette action est irréversible !',
              style: appTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toutes vos données seront définitivement supprimées.',
              style: appTextStyle(
                fontSize: 14,
                color: ColorRes.black.withOpacity(0.8),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Annuler',
              style: appTextStyle(
                color: ColorRes.textSecondary,
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
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Supprimer',
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

  // Fonction pour modifier le nom
  void _showEditNameDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    nameController.text = PreferencesService.getString(PrefKeys.fullName);
    
    Get.dialog(
      AlertDialog(
        title: Text("Modifier le nom", style: appTextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: "Nom complet",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Annuler", style: appTextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                try {
                  // Sauvegarder localement
                  PreferencesService.setValue(PrefKeys.fullName, newName);
                  
                  // Sauvegarder dans Firestore
                  final userId = PreferencesService.getString(PrefKeys.userId);
                  if (userId.isNotEmpty) {
                    await FirebaseFirestore.instance
                        .collection("Auth")
                        .doc("User")
                        .collection("register")
                        .doc(userId)
                        .update({"fullName": newName});
                  }
                  
                  Get.back();
                  Get.snackbar(
                    "Succès",
                    "Nom modifié et synchronisé avec succès",
                    backgroundColor: const Color(0xFF000647),
                    colorText: Colors.white,
                  );
                } catch (e) {
                  Get.snackbar(
                    "Erreur",
                    "Erreur lors de la sauvegarde: $e",
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              } else {
                Get.snackbar(
                  "Erreur",
                  "Le nom ne peut pas être vide",
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF000647)),
            child: Text("Sauvegarder", style: appTextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Fonction pour modifier l'email
  void _showEditEmailDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    emailController.text = PreferencesService.getString(PrefKeys.email);
    
    Get.dialog(
      AlertDialog(
        title: Text("Modifier l'email", style: appTextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: "Adresse email",
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Annuler", style: appTextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newEmail = emailController.text.trim();
              if (newEmail.isNotEmpty && newEmail.contains('@')) {
                try {
                  // Sauvegarder localement
                  PreferencesService.setValue(PrefKeys.email, newEmail);
                  
                  // Sauvegarder dans Firestore
                  final userId = PreferencesService.getString(PrefKeys.userId);
                  if (userId.isNotEmpty) {
                    await FirebaseFirestore.instance
                        .collection("Auth")
                        .doc("User")
                        .collection("register")
                        .doc(userId)
                        .update({"email": newEmail});
                  }
                  
                  Get.back();
                  Get.snackbar(
                    "Succès",
                    "Email modifié et synchronisé avec succès",
                    backgroundColor: const Color(0xFF000647),
                    colorText: Colors.white,
                  );
                } catch (e) {
                  Get.snackbar(
                    "Erreur",
                    "Erreur lors de la sauvegarde: $e",
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              } else {
                Get.snackbar(
                  "Erreur",
                  "Veuillez entrer un email valide",
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF000647)),
            child: Text("Sauvegarder", style: appTextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Fonction pour envoyer l'email de réinitialisation
  void _sendPasswordResetEmail() {
    final email = PreferencesService.getString(PrefKeys.email);
    if (email.isNotEmpty) {
      // Utiliser Firebase pour envoyer l'email de réinitialisation
      FirebaseAuth.instance.sendPasswordResetEmail(email: email).then((_) {
        Get.snackbar(
          "Email envoyé",
          "Un lien de réinitialisation a été envoyé à $email",
          backgroundColor: const Color(0xFF000647),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }).catchError((error) {
        Get.snackbar(
          "Erreur",
          "Erreur lors de l'envoi de l'email: $error",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      });
    } else {
      Get.snackbar(
        "Erreur",
        "Aucun email trouvé dans le profil",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Fonction pour confirmer la suppression du compte
  void _confirmDeleteAccount() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red[600], size: 24),
            const SizedBox(width: 8),
            Text(
              'Confirmer la suppression',
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
          children: [
            Text(
              'Êtes-vous absolument sûr ?',
              style: appTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cette action supprimera définitivement votre compte et toutes vos données. Cette action est irréversible.',
              style: appTextStyle(
                fontSize: 14,
                color: ColorRes.black.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tapez "SUPPRIMER" pour confirmer :',
              style: appTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ColorRes.black,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Tapez SUPPRIMER",
              ),
              onChanged: (value) {
                // Store the value for validation
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Annuler',
              style: appTextStyle(
                color: ColorRes.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Pour l'instant, on simule
              Get.back(result: false);
              Get.snackbar(
                "Information",
                "Pour votre sécurité, contactez le support pour supprimer votre compte",
                backgroundColor: Colors.orange,
                colorText: Colors.white,
                duration: const Duration(seconds: 4),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Supprimer définitivement',
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
}
