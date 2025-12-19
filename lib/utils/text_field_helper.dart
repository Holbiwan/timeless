// lib/utils/text_field_helper.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldHelper {
  // Ensures TextFormField always allows copy/paste interactions
  static InputDecoration ensureCopyPasteEnabled(InputDecoration decoration) {
    return decoration;
  }

  // Configuration to ensure copy/paste always works
  static Map<String, dynamic> getCopyPasteEnabledConfig() {
    return {
      'enableInteractiveSelection': true,
      'canRequestFocus': true,
      // Removed complex contextMenuBuilder - using default Flutter behavior
    };
  }

  // Universal TextFormField with guaranteed copy/paste support
  static Widget buildCopyPasteEnabledTextField({
    required TextEditingController controller,
    InputDecoration? decoration,
    TextStyle? style,
    Function(String)? onChanged,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    int? maxLines,
    int? minLines,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    bool enabled = true,
    String? initialValue,
    FocusNode? focusNode,
    VoidCallback? onTap,
    bool readOnly = false,
    bool autofocus = false,
    bool autocorrect = true,
    bool enableSuggestions = true,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: (decoration ?? const InputDecoration()).copyWith(
        suffixIcon: suffixIcon,
      ),
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
      initialValue: initialValue,
      focusNode: focusNode,
      onTap: onTap,
      readOnly: readOnly,
      autofocus: autofocus,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      // Ensure copy/paste is always enabled
      enableInteractiveSelection: true,
      canRequestFocus: true,
    );
  }

  // Add copy button to any text field
  static Widget addCopyButton({
    required TextEditingController controller,
    required String label,
    Color? iconColor,
    VoidCallback? onCopied,
  }) {
    return IconButton(
      tooltip: 'Copy $label',
      onPressed: () async {
        await Clipboard.setData(
          ClipboardData(text: controller.text),
        );
        if (onCopied != null) {
          onCopied();
        }
      },
      icon: Icon(
        Icons.copy,
        color: iconColor ?? Colors.grey[600],
        size: 20,
      ),
    );
  }
}
