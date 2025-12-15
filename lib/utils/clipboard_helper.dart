// lib/utils/clipboard_helper.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ClipboardHelper {
  /// Copy text to clipboard with feedback
  static Future<void> copyToClipboard(String text, {String? label}) async {
    await Clipboard.setData(ClipboardData(text: text));
    
    // Show feedback
    Get.snackbar(
      '✅ Copied!',
      '${label ?? 'Text'} copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.green,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  /// Paste text from clipboard
  static Future<String?> pasteFromClipboard() async {
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }

  /// Enhanced TextFormField that always supports copy/paste
  static Widget buildEnhancedTextField({
    required TextEditingController controller,
    InputDecoration? decoration,
    TextStyle? style,
    Function(String)? onChanged,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    int? maxLines = 1,
    int? minLines,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    bool enabled = true,
    FocusNode? focusNode,
    VoidCallback? onTap,
    bool readOnly = false,
    bool autofocus = false,
    bool showCopyButton = false,
    String? copyLabel,
  }) {
    return Stack(
      children: [
        TextFormField(
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
          // Guarantee copy/paste functionality
          enableInteractiveSelection: true,
          toolbarOptions: const ToolbarOptions(
            copy: true,
            cut: true,
            paste: true,
            selectAll: true,
          ),
        ),
        if (showCopyButton && controller.text.isNotEmpty)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: InkWell(
                onTap: () => copyToClipboard(
                  controller.text,
                  label: copyLabel,
                ),
                child: Icon(
                  Icons.copy,
                  size: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Quick action to enable copy/paste on existing TextFormField widgets
  static Map<String, dynamic> getCopyPasteProperties() {
    return {
      'enableInteractiveSelection': true,
      'toolbarOptions': const ToolbarOptions(
        copy: true,
        cut: true,
        paste: true,
        selectAll: true,
      ),
    };
  }

  /// Add copy button to any TextFormField decoration
  static InputDecoration addCopyButtonToDecoration({
    required InputDecoration decoration,
    required TextEditingController controller,
    String? label,
  }) {
    return decoration.copyWith(
      suffixIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (decoration.suffixIcon != null) decoration.suffixIcon!,
          IconButton(
            icon: const Icon(Icons.copy, size: 20),
            onPressed: () => copyToClipboard(
              controller.text,
              label: label,
            ),
            tooltip: 'Copy ${label ?? 'text'}',
          ),
        ],
      ),
    );
  }
}