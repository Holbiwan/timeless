import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/utils/asset_res.dart';
import 'package:timeless/utils/color_res.dart';

// Default back button used in the app
Widget backButton({VoidCallback? onTap}) {
  return universalBackButton(onTap: onTap);
}

// Reusable universal back button with optional text
Widget universalBackButton({
  VoidCallback? onTap,
  String? text,
  bool showText = false,
}) {
  return Builder(
    builder: (context) => InkWell(
      // Go back if possible, else redirect to dashboard
      onTap: onTap ?? () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          Get.offAllNamed('/dashboard');
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: showText ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8) : null,
        height: showText ? null : 36,
        width: showText ? null : 36,
        decoration: BoxDecoration(
          color: ColorRes.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: ColorRes.primaryBlue,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: ColorRes.primaryBlue.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: showText
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.arrow_back,
                    color: ColorRes.black,
                    size: 18,
                  ),
                  if (text != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      text,
                      style: const TextStyle(
                        color: ColorRes.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              )
            : const Icon(
                Icons.arrow_back,
                color: ColorRes.black,
                size: 18,
              ),
      ),
    ),
  );
}

// widget to display the app logo
Widget logo() {
  return Container(
    alignment: Alignment.center,
    height: 40,
    width: 40,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(13),
    ),
    child: const Image(
      image: AssetImage(AssetRes.logo),
    ),
  );
}
