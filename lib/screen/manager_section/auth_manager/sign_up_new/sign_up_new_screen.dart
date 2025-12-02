// lib/screen/manager_section/auth_manager/sign_up_new/sign_up_new_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:timeless/common/widgets/back_button.dart';
import 'package:timeless/common/widgets/common_loader.dart';
import 'package:timeless/common/widgets/common_text_field.dart';

import 'package:timeless/screen/auth/sign_up/widget/signup_bottom/country.dart';
import 'package:timeless/screen/manager_section/auth_manager/Sign_in/sign_in_screen.dart';
import 'package:timeless/screen/manager_section/auth_manager/sign_up_new/sign_up_new_controller.dart';

import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/asset_res.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/string.dart';

// ignore: must_be_immutable
class SignUpScreenM extends StatelessWidget {
  SignUpScreenM({super.key});
  final SignUpControllerM controller = Get.put(SignUpControllerM());

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: ColorRes.white,
      body: Obx(
        () => Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50),
                    backButton(),

                    // Logo
                    Center(
                      child: Container(
                        alignment: Alignment.center,
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: ColorRes.royalBlue,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Image(
                          image: AssetImage(AssetRes.logo),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Title
                    Center(
                      child: Text(
                        Strings.signUpForFree,
                        style: appTextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: ColorRes.black,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // First name
                    _label(Strings.firstName),
                    GetBuilder<SignUpControllerM>(
                      id: "showFirstname",
                      builder: (_) => Column(
                        children: [
                          _shadowField(
                            child: commonTextFormField(
                              onChanged: controller.onChanged,
                              controller: controller.firstnameController,
                              textDecoration: _decor(
                                context,
                                hint: 'First Name',
                                hasError: controller.firstError.isNotEmpty,
                                isEmpty: controller.firstnameController.text
                                    .trim()
                                    .isEmpty,
                              ),
                            ),
                          ),
                          controller.firstError.isEmpty
                              ? const SizedBox(height: 20)
                              : _errorChip(context, controller.firstError),
                        ],
                      ),
                    ),

                    // Last name
                    const SizedBox(height: 10),
                    _label(Strings.lastName),
                    GetBuilder<SignUpControllerM>(
                      id: "showLastname",
                      builder: (_) => Column(
                        children: [
                          _shadowField(
                            child: commonTextFormField(
                              onChanged: controller.onChanged,
                              controller: controller.lastnameController,
                              textDecoration: _decor(
                                context,
                                hint: 'Last Name',
                                hasError: controller.lastError.isNotEmpty,
                                isEmpty: controller.lastnameController.text
                                    .trim()
                                    .isEmpty,
                              ),
                            ),
                          ),
                          controller.lastError.isEmpty
                              ? const SizedBox(height: 20)
                              : _errorChip(context, controller.lastError),
                        ],
                      ),
                    ),

                    // Email
                    const SizedBox(height: 10),
                    _label(Strings.email),
                    GetBuilder<SignUpControllerM>(
                      id: "showEmail",
                      builder: (_) => Column(
                        children: [
                          _shadowField(
                            child: commonTextFormField(
                              onChanged: controller.onChanged,
                              controller: controller.emailController,
                              textDecoration: _decor(
                                context,
                                hint: 'Email',
                                hasError: controller.emailError.isNotEmpty,
                                isEmpty: controller.emailController.text
                                    .trim()
                                    .isEmpty,
                              ),
                            ),
                          ),
                          controller.emailError.isEmpty
                              ? const SizedBox(height: 20)
                              : _errorChip(context, controller.emailError),
                        ],
                      ),
                    ),

                    // Phone
                    const SizedBox(height: 10),
                    _label(Strings.phoneNumber),
                    GetBuilder<SignUpControllerM>(
                      id: "showPhoneNumber",
                      builder: (_) => Column(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 51,
                            padding: const EdgeInsets.only(left: 10),
                            decoration: BoxDecoration(
                              color: ColorRes.white,
                              border: Border.all(
                                color: controller.phoneController.text
                                        .trim()
                                        .isEmpty
                                    ? ColorRes.borderColor
                                    : controller.phoneError.isEmpty
                                        ? ColorRes.royalBlue
                                        : ColorRes.royalBlue,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  offset: const Offset(6, 6),
                                  color: ColorRes.royalBlue.withOpacity(0.10),
                                  spreadRadius: 0,
                                  blurRadius: 35,
                                ),
                              ],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                countryCodePicker(context, padding: 3),
                                const SizedBox(width: 8),

                                // ⬇️ Expanded pour empêcher l’overflow
                                Expanded(
                                  child: Material(
                                    shadowColor: ColorRes.royalBlue,
                                    borderRadius: BorderRadius.circular(12),
                                    child: TextFormField(
                                      onChanged: controller.onChanged,
                                      keyboardType: TextInputType.phone,
                                      controller: controller.phoneController,
                                      decoration: InputDecoration(
                                        hintText: 'Phone number',
                                        fillColor: ColorRes.white,
                                        filled: true,
                                        hintStyle: appTextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              ColorRes.black.withOpacity(0.15),
                                        ),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          controller.phoneError.isEmpty
                              ? SizedBox(height: Get.height * 0.0197)
                              : _errorChip(context, controller.phoneError),
                        ],
                      ),
                    ),

                    // Password
                    const SizedBox(height: 10),
                    _label(Strings.password),
                    GetBuilder<SignUpControllerM>(
                      id: "showPassword",
                      builder: (_) => Column(
                        children: [
                          _shadowField(
                            child: commonTextFormField(
                              onChanged: controller.onChanged,
                              controller: controller.passwordController,
                              obscureText: controller.show,
                              textDecoration: _decor(
                                context,
                                hint: 'Password',
                                hasError: controller.pwdError.isNotEmpty,
                                isEmpty: controller.passwordController.text
                                    .trim()
                                    .isEmpty,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  icon: controller.show
                                      ? Icon(Icons.visibility_off,
                                          color:
                                              ColorRes.black.withOpacity(0.15))
                                      : Icon(Icons.visibility,
                                          color:
                                              ColorRes.black.withOpacity(0.15)),
                                  onPressed: controller.chang,
                                ),
                              ),
                            ),
                          ),
                          controller.pwdError.isEmpty
                              ? const SizedBox(height: 20)
                              : _errorChip(context, controller.pwdError),
                        ],
                      ),
                    ),

                    // City
                    const SizedBox(height: 10),
                    _label(Strings.city),
                    GetBuilder<SignUpControllerM>(
                      id: "showCity",
                      builder: (_) => Column(
                        children: [
                          _shadowField(
                            child: commonTextFormField(
                              onChanged: controller.onChanged,
                              controller: controller.cityController,
                              textDecoration: _decor(
                                context,
                                hint: 'City',
                                hasError: controller.cityError.isNotEmpty,
                                isEmpty: controller.cityController.text
                                    .trim()
                                    .isEmpty,
                              ),
                            ),
                          ),
                          controller.cityError.isEmpty
                              ? const SizedBox(height: 20)
                              : _errorChip(context, controller.cityError),
                        ],
                      ),
                    ),

                    // State
                    const SizedBox(height: 10),
                    _label(Strings.state),
                    GetBuilder<SignUpControllerM>(
                      id: "showState",
                      builder: (_) => Column(
                        children: [
                          _shadowField(
                            child: commonTextFormField(
                              onChanged: controller.onChanged,
                              controller: controller.stateController,
                              textDecoration: _decor(
                                context,
                                hint: 'State',
                                hasError: controller.stateError.isNotEmpty,
                                isEmpty: controller.stateController.text
                                    .trim()
                                    .isEmpty,
                              ),
                            ),
                          ),
                          controller.stateError.isEmpty
                              ? const SizedBox(height: 20)
                              : _errorChip(context, controller.stateError),
                        ],
                      ),
                    ),

                    // Country
                    const SizedBox(height: 10),
                    _label(Strings.country),
                    GetBuilder<SignUpControllerM>(
                      id: "showCountry",
                      builder: (_) => Column(
                        children: [
                          _shadowField(
                            child: commonTextFormField(
                              onChanged: controller.onChanged,
                              controller: controller.countryController,
                              textDecoration: _decor(
                                context,
                                hint: 'Country',
                                hasError: controller.countryError.isNotEmpty,
                                isEmpty: controller.countryController.text
                                    .trim()
                                    .isEmpty,
                              ).copyWith(
                                suffixIcon: GetBuilder<SignUpControllerM>(
                                  id: "dropdown",
                                  builder: (_) {
                                    return DropdownButton<String>(
                                      iconSize: 28.0,
                                      iconEnabledColor: Colors.grey.shade400,
                                      iconDisabledColor: Colors.grey.shade400,
                                      underline: const SizedBox.shrink(),
                                      icon: const Icon(Icons.arrow_drop_down),
                                      items: controller.items1
                                          .map(
                                            (val) => DropdownMenuItem<String>(
                                              value: val,
                                              child: Text(val),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (val) =>
                                          controller.changeDropdwon(val: val!),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          controller.countryError.isEmpty
                              ? const SizedBox(height: 20)
                              : _errorChip(context, controller.countryError),
                        ],
                      ),
                    ),

                    // Remember me
                    GetBuilder<SignUpControllerM>(
                      id: "remember_me",
                      builder: (_) => InkWell(
                        onTap: () {
                          controller.rememberMe = !controller.rememberMe;
                          controller.update(["remember_me"]);
                        },
                        child: Row(
                          children: [
                            Checkbox(
                              activeColor: ColorRes.royalBlue,
                              checkColor: ColorRes.white,
                              side: const BorderSide(
                                  width: 1, color: ColorRes.royalBlue),
                              value: controller.rememberMe,
                              onChanged: controller.onRememberMeChange,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                            ),
                            Text(
                              Strings.rememberMe,
                              style: appTextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                                color: ColorRes.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Sign up button
                    GetBuilder<SignUpControllerM>(
                      id: "dark",
                      builder: (_) => InkWell(
                        onTap: controller.onSignUpBtnTap,
                        child: Container(
                          height: 50,
                          width: double.infinity,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                              colors: [
                                ColorRes.gradientColor,
                                ColorRes.royalBlue
                              ],
                            ),
                          ),
                          child: Text(
                            Strings.signUp,
                            style: appTextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: ColorRes.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 26),

                    // Or continue with
                    Center(
                      child: Text(
                        Strings.orContinueWith,
                        style: appTextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: ColorRes.black,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // SOCIAL ROW (Facebook removed) — only Google
                    Align(
                      alignment: Alignment.center,
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(maxWidth: width < 400 ? width : 360),
                        child: InkWell(
                          onTap: controller.SignUpWithGoogle,
                          child: Container(
                            height: 50,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: ColorRes.borderColor),
                              boxShadow: [
                                BoxShadow(
                                  offset: const Offset(6, 6),
                                  color: ColorRes.royalBlue.withOpacity(0.08),
                                  spreadRadius: 0,
                                  blurRadius: 35,
                                ),
                              ],
                              borderRadius: BorderRadius.circular(10),
                              color: ColorRes.white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Image(
                                  image: AssetImage(AssetRes.googleLogo),
                                  height: 24,
                                ),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Text(
                                    Strings.google,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: appTextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      color: ColorRes.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Already have account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          Strings.alreadyHaveAccount,
                          style: appTextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: ColorRes.black,
                          ),
                        ),
                        GetBuilder<SignUpControllerM>(
                          builder: (_) => InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (con) => const SignInScreenM()),
                              );
                            },
                            child: Text(
                              Strings.signIn,
                              style: appTextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: ColorRes.royalBlue,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Loader
            controller.loading.isTrue
                ? const Center(child: CommonLoader())
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

// ---------- UI helpers ----------

Widget _label(String text) {
  return Padding(
    padding: const EdgeInsets.only(left: 13, bottom: 10),
    child: Row(
      children: [
        Text(
          text,
          style: appTextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: ColorRes.black.withOpacity(0.6),
          ),
        ),
        Text('*', style: appTextStyle(fontSize: 15, color: ColorRes.royalBlue)),
      ],
    ),
  );
}

Widget _shadowField({required Widget child}) {
  return Container(
    height: 51,
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          offset: const Offset(6, 6),
          color: ColorRes.royalBlue.withOpacity(0.10),
          spreadRadius: 0,
          blurRadius: 35,
        ),
      ],
      borderRadius: BorderRadius.circular(12),
    ),
    child: Material(
      shadowColor: ColorRes.royalBlue,
      borderRadius: BorderRadius.circular(12),
      child: child,
    ),
  );
}

InputDecoration _decor(
  BuildContext context, {
  required String hint,
  required bool hasError,
  required bool isEmpty,
}) {
  OutlineInputBorder enabled = enableBorder();
  OutlineInputBorder error = errorBorder();

  return InputDecoration(
    hintText: hint,
    fillColor: Colors.transparent,
    filled: true,
    hintStyle: appTextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: ColorRes.black.withOpacity(0.15),
    ),
    border: isEmpty ? InputBorder.none : (hasError ? error : enabled),
    focusedBorder: isEmpty ? InputBorder.none : (hasError ? error : enabled),
    disabledBorder: isEmpty ? InputBorder.none : (hasError ? error : enabled),
    enabledBorder: isEmpty ? InputBorder.none : (hasError ? error : enabled),
    errorBorder: isEmpty ? InputBorder.none : (hasError ? error : enabled),
    focusedErrorBorder:
        isEmpty ? InputBorder.none : (hasError ? error : enabled),
  );
}

Widget _errorChip(BuildContext context, String message) {
  return Container(
    width: double.infinity,
    height: 28,
    margin: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(50),
      color: ColorRes.invalidColor,
    ),
    padding: const EdgeInsets.only(left: 15, right: 10),
    child: Row(
      children: [
        const Image(image: AssetImage(AssetRes.invalid), height: 14),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            message,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: appTextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 9,
              color: ColorRes.royalBlue,
            ),
          ),
        ),
      ],
    ),
  );
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
