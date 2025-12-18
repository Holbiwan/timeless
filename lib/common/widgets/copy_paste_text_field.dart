// lib/common/widgets/copy_paste_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CopyPasteTextField extends StatelessWidget {
  final TextEditingController controller;
  final InputDecoration? decoration;
  final TextStyle? style;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool autofocus;
  final bool autocorrect;
  final bool enableSuggestions;

  const CopyPasteTextField({
    super.key,
    required this.controller,
    this.decoration,
    this.style,
    this.onChanged,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.enabled = true,
    this.focusNode,
    this.onTap,
    this.readOnly = false,
    this.autofocus = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: decoration,
      style: style,
      onChanged: onChanged,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      enabled: enabled,
      focusNode: focusNode,
      onTap: onTap,
      readOnly: readOnly,
      autofocus: autofocus,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      // ALWAYS enable copy/paste functionality
      enableInteractiveSelection: true,
      toolbarOptions: const ToolbarOptions(
        copy: true,
        cut: true,
        paste: true,
        selectAll: true,
      ),
    );
  }
}

// Enhanced TextField with copy/paste guarantee
class CopyPasteField extends StatelessWidget {
  final TextEditingController controller;
  final InputDecoration? decoration;
  final TextStyle? style;
  final Function(String)? onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLines;
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onTap;

  const CopyPasteField({
    super.key,
    required this.controller,
    this.decoration,
    this.style,
    this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: decoration,
      style: style,
      onChanged: onChanged,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      enabled: enabled,
      readOnly: readOnly,
      onTap: onTap,
      // ALWAYS enable copy/paste functionality
      enableInteractiveSelection: true,
      toolbarOptions: const ToolbarOptions(
        copy: true,
        cut: true,
        paste: true,
        selectAll: true,
      ),
    );
  }
}

// Utility to show copy success message
void showCopySuccessMessage({String? label}) {
  Get.snackbar(
    '✅ Copied!',
    '${label ?? 'Text'} copied to clipboard',
    snackPosition: SnackPosition.BOTTOM,
    duration: const Duration(seconds: 2),
    backgroundColor: Colors.green,
    colorText: Colors.white,
    margin: const EdgeInsets.all(8),
    borderRadius: 8,
  );
}

// Copy text to clipboard with visual feedback
Future<void> copyTextToClipboard(String text, {String? label}) async {
  await Clipboard.setData(ClipboardData(text: text));
  showCopySuccessMessage(label: label);
}
