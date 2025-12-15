import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/common/widgets/back_button.dart';
import 'package:timeless/common/widgets/common_loader.dart';
import 'package:timeless/common/widgets/common_text_field.dart';
import 'package:timeless/screen/job_detail_screen/job_detail_upload_cv_screen/upload_cv_controller.dart';
import 'package:timeless/screen/manager_section/auth_manager/Sign_in/sign_in_controller.dart';
import 'package:timeless/screen/auth/forgot_password/forgot_password_screen.dart';
import 'package:timeless/screen/manager_section/auth_manager/sign_up_new/sign_up_new_screen.dart';
import 'package:timeless/services/demo_data_service.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/asset_res.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/string.dart';

class SignInScreenM extends StatefulWidget {
  const SignInScreenM({super.key});

  @override
  State<SignInScreenM> createState() => _SignInScreenMState();
}

class _SignInScreenMState extends State<SignInScreenM> {
  SignInScreenControllerM controller = Get.put(SignInScreenControllerM());

  final formGlobalKey = GlobalKey<FormState>();

  JobDetailsUploadCvController jobDetailsUploadCvController =
      Get.put(JobDetailsUploadCvController());
  @override
  void initState() {
    controller.getRememberEmailDataManger();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    jobDetailsUploadCvController.init();
    return Scaffold(
        backgroundColor: ColorRes.backgroundColor,
        body: Obx(() {
          return Stack(children: [
            SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 50),
                      backButton(),
                      Center(
                        child: Container(
                          alignment: Alignment.center,
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            color: ColorRes.logoColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Image(
                            image: AssetImage(AssetRes.logo),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: Text(Strings.signInToYourAccount,
                            style: appTextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: ColorRes.black)),
                      ),
                      const SizedBox(height: 40),
                      
                      // Email field
                      Padding(
                        padding: const EdgeInsets.only(left: 15, bottom: 10),
                        child: Row(
                          children: [
                            Text(Strings.email,
                                style: appTextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: ColorRes.black.withOpacity(0.6))),
                            const Text(
                              '*',
                              style: TextStyle(
                                  fontSize: 15, color: ColorRes.royalBlue),
                            ),
                          ],
                        ),
                      ),
                      GetBuilder<SignInScreenControllerM>(
                        id: "showEmail",
                        builder: (controller) => Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      offset: const Offset(6, 6),
                                      color: ColorRes.royalBlue.withOpacity(0.12),
                                      spreadRadius: 0,
                                      blurRadius: 35),
                                ],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Material(
                                borderRadius: BorderRadius.circular(10),
                                child: commonTextFormField(
                                  onChanged: controller.onChanged,
                                  controller: controller.emailController,
                                  textDecoration: InputDecoration(
                                    contentPadding: const EdgeInsets.all(10),
                                    hintText: 'Email',
                                    fillColor: Colors.transparent,
                                    filled: true,
                                    hintStyle: appTextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: ColorRes.black.withOpacity(0.15)),
                                    border: controller.emailController.text.trim().isEmpty
                                        ? InputBorder.none
                                        : controller.emailError.isNotEmpty
                                            ? errorBorder()
                                            : enableBorder(),
                                    focusedBorder: controller.emailController.text.trim().isEmpty
                                        ? InputBorder.none
                                        : controller.emailError.isNotEmpty
                                            ? errorBorder()
                                            : enableBorder(),
                                    enabledBorder: controller.emailController.text.trim().isEmpty
                                        ? InputBorder.none
                                        : controller.emailError.isNotEmpty
                                            ? errorBorder()
                                            : enableBorder(),
                                  ),
                                ),
                              ),
                            ),
                            controller.emailError == ""
                                ? const SizedBox(height: 20)
                                : Container(
                                    margin: const EdgeInsets.all(10),
                                    width: 339,
                                    height: 28,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: ColorRes.invalidColor),
                                    padding: const EdgeInsets.only(left: 15),
                                    child: Row(
                                        children: [
                                          const Image(
                                            image: AssetImage(AssetRes.invalid),
                                            height: 14,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(controller.emailError,
                                              style: appTextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 9,
                                                  color: ColorRes.royalBlue))
                                        ]),
                                  ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Password field
                      Padding(
                        padding: const EdgeInsets.only(left: 15, bottom: 10),
                        child: Row(
                          children: [
                            Text(Strings.password,
                                style: appTextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: ColorRes.black.withOpacity(0.6))),
                            const Text(
                              '*',
                              style: TextStyle(
                                  fontSize: 15, color: ColorRes.royalBlue),
                            ),
                          ],
                        ),
                      ),
                      GetBuilder<SignInScreenControllerM>(
                        id: "showPassword",
                        builder: (controller) => Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      offset: const Offset(6, 6),
                                      color: ColorRes.royalBlue.withOpacity(0.13),
                                      spreadRadius: 0,
                                      blurRadius: 35),
                                ],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Material(
                                borderRadius: BorderRadius.circular(12),
                                child: commonTextFormField(
                                  onChanged: controller.onChanged,
                                  controller: controller.passwordController,
                                  obscureText: controller.show,
                                  textDecoration: InputDecoration(
                                    contentPadding: const EdgeInsets.all(10),
                                    hintText: 'Password',
                                    fillColor: Colors.transparent,
                                    suffixIcon: IconButton(
                                      icon: controller.show
                                          ? Icon(Icons.visibility_off,
                                              color: ColorRes.black.withOpacity(0.15))
                                          : Icon(Icons.visibility,
                                              color: ColorRes.black.withOpacity(0.15)),
                                      onPressed: controller.chang,
                                    ),
                                    filled: true,
                                    hintStyle: appTextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                        color: ColorRes.black.withOpacity(0.15)),
                                    border: controller.passwordController.text.trim().isEmpty
                                        ? InputBorder.none
                                        : controller.pwdError.isNotEmpty
                                            ? errorBorder()
                                            : enableBorder(),
                                    focusedBorder: controller.passwordController.text.trim().isEmpty
                                        ? InputBorder.none
                                        : controller.pwdError.isNotEmpty
                                            ? errorBorder()
                                            : enableBorder(),
                                    enabledBorder: controller.passwordController.text.trim().isEmpty
                                        ? InputBorder.none
                                        : controller.pwdError.isNotEmpty
                                            ? errorBorder()
                                            : enableBorder(),
                                  ),
                                ),
                              ),
                            ),
                            controller.pwdError == ""
                                ? const SizedBox(height: 20)
                                : Container(
                                    width: 339,
                                    height: 28,
                                    margin: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: ColorRes.invalidColor),
                                    padding: const EdgeInsets.only(left: 15),
                                    child: Row(
                                        children: [
                                          const Image(
                                            image: AssetImage(AssetRes.invalid),
                                            height: 14,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            controller.pwdError,
                                            style: appTextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w400,
                                                color: ColorRes.royalBlue),
                                          ),
                                        ]),
                                  ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 5),
                      
                      // Remember me
                      GetBuilder<SignInScreenControllerM>(
                          id: "remember_me",
                          builder: (controller) {
                            return InkWell(
                              onTap: () {
                                controller.rememberMe = !controller.rememberMe;
                                controller.update(["remember_me"]);
                              },
                              child: Row(
                                children: [
                                  Checkbox(
                                    activeColor: ColorRes.royalBlue,
                                    checkColor: ColorRes.black,
                                    side: const BorderSide(
                                        width: 1.2, color: ColorRes.royalBlue),
                                    value: controller.rememberMe,
                                    onChanged: controller.onRememberMeChange,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  Text(Strings.rememberMe,
                                      style: appTextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                          color: ColorRes.black))
                                ],
                              ),
                            );
                          }),
                      
                      const SizedBox(height: 25),
                      
                      
                      // Sign in button normal
                      GetBuilder<SignInScreenControllerM>(
                          id: "colorChange",
                          builder: (controller) {
                            return InkWell(
                              onTap: controller.onLoginBtnTap,
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.black,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2.0,
                                  ),
                                ),
                                child: Text(Strings.signIn,
                                    style: appTextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white)),
                              ),
                            );
                          }),
                      
                      const SizedBox(height: 18),
                      
                      // Forgot password
                      Center(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (con) => ForgotPasswordScreen()));
                          },
                          child: Text(Strings.forgotThePassword,
                              style: appTextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: ColorRes.royalBlue)),
                        ),
                      ),
                      
                      const SizedBox(height: 28),
                      
                      // Demo Data Button
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => AlertDialog(
                                  title: Text('Data Initialization'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(height: 16),
                                      Text('Creating demo employers and job postings...'),
                                    ],
                                  ),
                                ),
                              );
                              
                              // Create demo data
                              await DemoDataService.createAllDemoData();
                              
                              Navigator.pop(context); // Close progress dialog
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('✅ Demo data created successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } catch (e) {
                              Navigator.pop(context); // Close progress dialog
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('❌ Erreur: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          icon: Icon(Icons.dataset, color: Colors.white),
                          label: Text(
                            'Initialize demo data',
                            style: appTextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Or continue with
                      Center(
                        child: Text(Strings.orContinueWith,
                            style: appTextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: ColorRes.black)),
                      ),
                      
                      const SizedBox(height: 28),
                      
                      // Google Sign-In button (Facebook removed)
                      Center(
                        child: InkWell(
                          onTap: () {
                            controller.signWithGoogle();
                          },
                          child: Container(
                            height: 45,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFF000647), width: 2.0),
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Image(
                                  image: AssetImage(AssetRes.googleLogo),
                                  height: 20,
                                  width: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  Strings.google,
                                  style: appTextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      color: ColorRes.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 27),
                      
                      
                      // Sign up link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            Strings.donTHaveAccount,
                            style: appTextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                color: ColorRes.black),
                          ),
                          GetBuilder<SignInScreenControllerM>(
                            builder: (controller) => InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (con) => SignUpScreenM(),
                                  ),
                                ).then((value) => {
                                      controller.passwordController.clear(),
                                      controller.emailController.clear()
                                    });
                              },
                              child: Text(
                                Strings.signUp,
                                style: appTextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: ColorRes.royalBlue),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ]),
              ),
            ),
            controller.loading.isTrue
                ? const Center(
                    child: CommonLoader(),
                  )
                : const SizedBox(),
          ]);
        }));
  }

  OutlineInputBorder enableBorder() {
    return OutlineInputBorder(
      borderSide: const BorderSide(color: ColorRes.royalBlue),
      borderRadius: BorderRadius.circular(10),
    );
  }

  OutlineInputBorder errorBorder() {
    return OutlineInputBorder(
      borderSide: const BorderSide(color: ColorRes.royalBlue),
      borderRadius: BorderRadius.circular(10),
    );
  }
}