import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/common/widgets/back_button.dart';
import 'package:timeless/screen/create_vacancies/create_vacancies_controller.dart';
import 'package:timeless/screen/profile/profile_controller.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/asset_res.dart';
import 'package:timeless/utils/color_res.dart';



// ignore: must_be_immutable
class EditProfileScreen extends StatelessWidget {
  EditProfileScreen({super.key});
  final controller = Get.find<ProfileController>(); // Utilise le même contrôleur

  CreateVacanciesController getCreate = Get.put(CreateVacanciesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.backgroundColor,
      body: Column(
        children: [
          const SizedBox(height: 60),
          Row(children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: InkWell(
                onTap: () {
                  Get.back();
                },
                child: backButton(),
              ),
            ),
            const Spacer(),
            Center(
              child: Text(
                'Edit Profile',
                style: appTextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    height: 1,
                    color: ColorRes.black),
              ),
            ),
            const Spacer(),
            Container(
              margin: const EdgeInsets.all(15),
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ]),
          Expanded(
            child: SingleChildScrollView(
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          GetBuilder<ProfileController>(
                              id: "image",
                              builder: (profileController) {
                                ImageProvider imageProvider;
                                
                                // Priority: local image > remote URL > default asset
                                if (profileController.image != null) {
                                  imageProvider = FileImage(profileController.image!);
                                } else if (profileController.profileImageUrl.value.isNotEmpty) {
                                  imageProvider = NetworkImage(profileController.profileImageUrl.value);
                                } else {
                                  imageProvider = const AssetImage(AssetRes.roundAirbnb);
                                }
                                
                                return Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              }),
                          Positioned(
                            bottom: 0,
                            right: 10,
                            child: InkWell(
                              onTap: () {
                                _showPhotoSelectionModal(context);
                              },
                              child: const CircleAvatar(
                                radius: 10,
                                backgroundColor: ColorRes.containerColor,
                                child: Icon(
                                  Icons.edit,
                                  size: 11,
                                  color: ColorRes.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(() => Text(
                              controller.displayName.isNotEmpty 
                                ? controller.displayName 
                                : controller.fullNameController.text.isNotEmpty
                                  ? controller.fullNameController.text
                                  : 'Votre Nom',
                              style: appTextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: ColorRes.black),
                              overflow: TextOverflow.ellipsis,
                            )),
                            const SizedBox(height: 2),
                            Obx(() => Text(
                              controller.displayEmail.isNotEmpty 
                                ? controller.displayEmail 
                                : controller.emailController.text.isNotEmpty
                                  ? controller.emailController.text
                                  : 'Email',
                              style: appTextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: ColorRes.black.withOpacity(0.6)),
                              overflow: TextOverflow.ellipsis,
                            )),
                            const SizedBox(height: 2),
                            Obx(() {
                              String locationText = '';
                              final city = controller.displayCity.isNotEmpty 
                                ? controller.displayCity 
                                : controller.cityController.text;
                              final country = controller.displayCountry.isNotEmpty 
                                ? controller.displayCountry 
                                : controller.countryController.text;
                              
                              if (city.isNotEmpty && country.isNotEmpty) {
                                locationText = '$city, $country';
                              } else if (city.isNotEmpty) {
                                locationText = city;
                              } else if (country.isNotEmpty) {
                                locationText = country;
                              } else {
                                locationText = 'Localisation';
                              }
                              
                              return Text(
                                locationText,
                                style: appTextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: ColorRes.black.withOpacity(0.6)),
                                overflow: TextOverflow.ellipsis,
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(children: [
                    // Nom complet
                    _buildTextField(
                      label: "Nom complet",
                      controller: controller.fullNameController,
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 15),
                    
                    // Email
                    _buildTextField(
                      label: "Email",
                      controller: controller.emailController,
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 15),
                    
                    // Téléphone
                    _buildTextField(
                      label: "Téléphone",
                      controller: controller.phoneController,
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 15),
                    
                    // Ville
                    _buildTextField(
                      label: "Ville",
                      controller: controller.cityController,
                      icon: Icons.location_city,
                    ),
                    const SizedBox(height: 15),
                    
                    // Pays
                    _buildTextField(
                      label: "Pays",
                      controller: controller.countryController,
                      icon: Icons.public,
                    ),
                    const SizedBox(height: 15),
                    
                    // Occupation
                    _buildTextField(
                      label: "Occupation",
                      controller: controller.occupationController,
                      icon: Icons.work,
                    ),
                    const SizedBox(height: 15),
                    
                    // Bio
                    _buildTextField(
                      label: "Biographie",
                      controller: controller.bioController,
                      icon: Icons.description,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 15),
                    
                    // Date de naissance
                    _buildTextField(
                      label: "Date de Naissance",
                      controller: controller.dateController,
                      icon: Icons.calendar_today,
                      keyboardType: TextInputType.datetime,
                    ),
                    const SizedBox(height: 15),
                    
                    // Poste 
                    _buildTextField(
                      label: "Poste",
                      controller: controller.jobPositionController,
                      icon: Icons.badge,
                    ),
                    const SizedBox(height: 15),
                    
                    // Skills
                    _buildTextField(
                      label: "Skills",
                      controller: controller.skillsController,
                      icon: Icons.star,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 15),
                    
                    // Salaire Min
                    _buildTextField(
                      label: "Salary Range Min",
                      controller: controller.salaryMinController,
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 15),
                    
                    // Salaire Max
                    _buildTextField(
                      label: "Salary Range Max",
                      controller: controller.salaryMaxController,
                      icon: Icons.money,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    
                    // Save button - Plus compact et fonctionnel
                    GetBuilder<ProfileController>(
                          id: "save_button",
                          builder: (con) {
                            return Container(
                              width: double.infinity,
                              height: 45,
                              child: ElevatedButton(
                                onPressed: con.isLoading.value 
                                    ? null 
                                    : () => con.onTapSubmit(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF000647),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 2,
                                ),
                                child: con.isLoading.value
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        "Save Changes",
                                        style: appTextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            );
                          }),
                      const SizedBox(height: 15),
                    ]),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: appTextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: ColorRes.black,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: appTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: ColorRes.black.withOpacity(0.6),
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF000647),
            size: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  void _showPhotoSelectionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: 280,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Column(
            children: [
              // Barre de drag
              Container(
                margin: const EdgeInsets.only(top: 15),
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              const SizedBox(height: 25),
              
              // Titre
              Text(
                'Changer votre photo de profil',
                style: appTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ColorRes.black,
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Option Caméra
              _buildPhotoOption(
                icon: Icons.camera_alt,
                title: "Prendre une photo",
                onTap: () {
                  Get.back();
                  controller.onTapImage();
                },
              ),
              
              const SizedBox(height: 20),
              
              // Option Galerie
              _buildPhotoOption(
                icon: Icons.photo_library,
                title: "Choisir dans la galerie",
                onTap: () {
                  Get.back();
                  controller.onTapGallery1();
                },
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhotoOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF000647).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF000647).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF000647),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 15),
              Text(
                title,
                style: appTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: ColorRes.black,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}