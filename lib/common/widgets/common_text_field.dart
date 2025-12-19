import 'package:flutter/material.dart';
import 'package:timeless/utils/color_res.dart';

// Reusable text field used across the app
Widget commonTextFormField({
  InputDecoration? textDecoration,
  TextEditingController? controller,
  VoidCallback? onTap,
  Function(String)? onChanged,
  TextInputType? type,
  bool? readOnly,
  Color? color,
  bool? obscureText,
}) {
  return Container(
    height: 50,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color ?? ColorRes.borderColor),
    ),
    child: TextField(
      keyboardType: type ?? TextInputType.text,
      controller: controller,
      decoration: textDecoration,
      style: const TextStyle(fontWeight: FontWeight.bold),
      onTap: onTap ?? () {},
      onChanged: onChanged ?? (value) {},
      obscureText: obscureText ?? false,
      readOnly: readOnly ?? false,
      // Enable copy / paste on all devices
      enableInteractiveSelection: true,
    ),
  );
}
