import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeless/common/widgets/common_loader.dart';
import 'package:timeless/common/widgets/common_text_field.dart';
import 'package:timeless/screen/job_detail_screen/job_detail_upload_cv_screen/upload_cv_controller.dart';
import 'package:timeless/screen/manager_section/auth_manager/Sign_in/sign_in_controller.dart';
import 'package:timeless/screen/auth/forgot_password/forgot_password_screen.dart';
import 'package:timeless/screen/manager_section/auth_manager/sign_up_new/sign_up_new_screen.dart';
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
  JobDetailsUploadCvController jobDetailsUploadCvController = Get.put(JobDetailsUploadCvController());

  // Brand colors
  final Color _primaryBlue = const Color(0xFF000647);
  final Color _accentOrange = const Color(0xFFE67E22);

  @override
  void initState() {
    controller.getRememberEmailDataManger();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    jobDetailsUploadCvController.init();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _primaryBlue, // Dark background base
      body: Obx(() {
        return Stack(
          children: [
            // --- 1. Background Design ---
            // Gradient Background
            Container(
              height: size.height,
              width: size.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _primaryBlue,
                    Colors.black,
                  ],
                ),
              ),
            ),
            // Decorative Orange Circle (Top Right)
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _accentOrange.withOpacity(0.2),
                  boxShadow: [
                    BoxShadow(
                      color: _accentOrange.withOpacity(0.3),
                      blurRadius: 50,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
            
            // --- 2. Content ---
            Column(
              children: [
                // Top Section (Logo & Title)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back Button
                        InkWell(
                          onTap: () => Get.back(),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.2)),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(height: 30),
                        
                        // Header Text
                        Row(
                          children: [
                             Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: const Image(image: AssetImage(AssetRes.logo)),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Employer Space",
                                  style: GoogleFonts.inter(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  "Sign in to manage jobs",
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),

                // Bottom Section (White Card Form)
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          
                          // Email Field
                          _buildLabel(Strings.email),
                          const SizedBox(height: 8),
                          GetBuilder<SignInScreenControllerM>(
                            id: "showEmail",
                            builder: (controller) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: controller.emailError.isNotEmpty ? Colors.red : Colors.grey.shade200,
                                    ),
                                  ),
                                  child: commonTextFormField(
                                    onChanged: controller.onChanged,
                                    controller: controller.emailController,
                                    textDecoration: InputDecoration(
                                      hintText: 'pro@company.com',
                                      hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14),
                                      contentPadding: const EdgeInsets.all(20),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      prefixIcon: Icon(Icons.email_outlined, color: _primaryBlue.withOpacity(0.6)),
                                    ),
                                  ),
                                ),
                                if (controller.emailError.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6, left: 4),
                                    child: Text(
                                      controller.emailError,
                                      style: GoogleFonts.inter(color: Colors.red, fontSize: 12),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 20),

                          // Password Field
                          _buildLabel(Strings.password),
                          const SizedBox(height: 8),
                          GetBuilder<SignInScreenControllerM>(
                            id: "showPassword",
                            builder: (controller) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: controller.pwdError.isNotEmpty ? Colors.red : Colors.grey.shade200,
                                    ),
                                  ),
                                  child: commonTextFormField(
                                    onChanged: controller.onChanged,
                                    controller: controller.passwordController,
                                    obscureText: controller.show,
                                    textDecoration: InputDecoration(
                                      hintText: '••••••••',
                                      hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14),
                                      contentPadding: const EdgeInsets.all(20),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      prefixIcon: Icon(Icons.lock_outline, color: _primaryBlue.withOpacity(0.6)),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          controller.show ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                          color: Colors.grey[500],
                                        ),
                                        onPressed: controller.chang,
                                      ),
                                    ),
                                  ),
                                ),
                                if (controller.pwdError.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6, left: 4),
                                    child: Text(
                                      controller.pwdError,
                                      style: GoogleFonts.inter(color: Colors.red, fontSize: 12),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Remember Me & Forgot Password
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GetBuilder<SignInScreenControllerM>(
                                id: "remember_me",
                                builder: (controller) => InkWell(
                                  onTap: () {
                                    controller.rememberMe = !controller.rememberMe;
                                    controller.update(["remember_me"]);
                                  },
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: Checkbox(
                                          value: controller.rememberMe,
                                          onChanged: controller.onRememberMeChange,
                                          activeColor: _primaryBlue,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                          side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        Strings.rememberMe,
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (con) => ForgotPasswordScreen()),
                                  );
                                },
                                child: Text(
                                  Strings.forgotThePassword,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: _accentOrange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          // Sign In Button
                          GetBuilder<SignInScreenControllerM>(
                            id: "colorChange",
                            builder: (controller) => SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: controller.onLoginBtnTap,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _primaryBlue,
                                  elevation: 4,
                                  shadowColor: _primaryBlue.withOpacity(0.4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  Strings.signIn,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Divider
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.grey.shade200)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  "Or",
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.grey[400],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: Colors.grey.shade200)),
                            ],
                          ),

                          const SizedBox(height: 30),

                          // Google Sign In
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                controller.signWithGoogle();
                              },
                              icon: const Image(
                                image: AssetImage(AssetRes.googleLogo),
                                height: 24,
                                width: 24,
                              ),
                              label: Text(
                                Strings.google,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                backgroundColor: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          const SizedBox(height: 10),

                          // Sign Up Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                Strings.donTHaveAccount,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
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
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: _accentOrange,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Full Screen Loader
            controller.loading.isTrue
                ? Container(
                    height: size.height,
                    width: size.width,
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(child: CommonLoader()),
                  )
                : const SizedBox(),
          ],
        );
      }),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _primaryBlue,
      ),
    );
  }
}