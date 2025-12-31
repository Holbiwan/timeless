import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart';
import 'package:timeless/widgets/language_selector.dart';
import 'package:timeless/utils/color_res.dart';

class LanguageTestWidget extends StatelessWidget {
  const LanguageTestWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.translate, color: ColorRes.primaryBlueDark),
              const SizedBox(width: 8),
              Text(
                context.tr("language_test"),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              LanguageSelector(isCompact: true, showTitle: false),
            ],
          ),
          const SizedBox(height: 16),
          _buildTestItem(context, "welcome"),
          _buildTestItem(context, "my_profile"),
          _buildTestItem(context, "settings"),
          _buildTestItem(context, "sign_in_candidate"),
          _buildTestItem(context, "create_candidate_account"),
          const SizedBox(height: 16),
          Center(
            child: Text(
              context.tr("current_language") + ": ${context.locale.languageCode.toUpperCase()}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ColorRes.primaryBlueDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestItem(BuildContext context, String key) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              key,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              context.tr(key),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}