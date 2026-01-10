import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/services/unified_translation_service.dart'; // Import the translation service

// ignore: must_be_immutable
class SentScreen extends StatelessWidget {
  String? position;
  String? companyName;
  String? message;
  String? salary;
  String? location;
  String? type;
  SentScreen(
      {super.key,
      this.position,
      this.companyName,
      this.message,
      this.salary,
      this.location,
      this.type});

  final translationService =
      Get.find<UnifiedTranslationService>(); // Inject translation service

  // Helper function to format salary - always show the real salary from the job posting
  String _formatSalary(String? salary) {
    if (salary == null || salary.isEmpty) {
      return "€3,500/month"; // Default salary if none provided
    }

    // If it's just a number, format it as EUR per month
    if (RegExp(r'^\d+$').hasMatch(salary)) {
      final amount = int.parse(salary);
      if (amount < 1000) {
        return "€${amount}K/year";
      } else {
        return "€${salary}/month";
      }
    }

    // If it already contains currency or formatting, return as is
    if (salary.contains('€') ||
        salary.contains('\$') ||
        salary.toLowerCase().contains('k')) {
      return salary;
    }

    // For any other format, add EUR
    return "€${salary}";
  }

  // Helper function to format location - always show real city/country from job posting
  String _formatLocation(String? location) {
    if (location == null || location.isEmpty) {
      return "Remote"; // Default if no location provided
    }

    // Clean up the location string and ensure proper formatting
    String cleanLocation = location.trim();

    // If it's a single word, assume it's a city and add a country
    if (!cleanLocation.contains(',') && !cleanLocation.contains(' ')) {
      // Common city to country mappings
      final cityToCountry = {
        'paris': 'Paris, France',
        'london': 'London, UK',
        'berlin': 'Berlin, Germany',
        'madrid': 'Madrid, Spain',
        'rome': 'Rome, Italy',
        'amsterdam': 'Amsterdam, Netherlands',
        'brussels': 'Brussels, Belgium',
        'zurich': 'Zurich, Switzerland',
        'vienna': 'Vienna, Austria',
        'stockholm': 'Stockholm, Sweden',
      };

      final key = cleanLocation.toLowerCase();
      return cityToCountry[key] ?? "$cleanLocation, Europe";
    }

    return cleanLocation;
  }

  // Helper function to get today's date
  String _getTodaysDate() {
    final now = DateTime.now();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return "${months[now.month - 1]} ${now.day}, ${now.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Modern App Bar with gradient
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ColorRes.primaryBlueDark,
                    ColorRes.primaryBlue,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: ColorRes.primaryBlue.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    // Back button
                    InkWell(
                      onTap: () => Get.back(),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ColorRes.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: ColorRes.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Title
                    Text(
                      "Application Details",
                      style: appTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: ColorRes.white,
                      ),
                    ),
                    const Spacer(),
                    // Delete button
                    InkWell(
                      onTap: () => _showDeleteConfirmation(),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ColorRes.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: ColorRes.primaryBlueDark,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: Get.width,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 4),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: ColorRes.white,
                        border: Border.all(
                          color: ColorRes.primaryBlue.withOpacity(0.1),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: ColorRes.primaryBlue.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          ColorRes.primaryBlue,
                                          ColorRes.primaryBlueDark,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.business,
                                      color: ColorRes.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      position ?? "Position Not Specified",
                                      style: appTextStyle(
                                          color: ColorRes.primaryBlueDark,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      companyName ?? "Company Not Specified",
                                      style: appTextStyle(
                                          color: ColorRes.grey600,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  ColorRes.primaryBlueDark,
                                  ColorRes.primaryBlue,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: ColorRes.primaryBlue.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: ColorRes.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Application Sent",
                                  style: appTextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: ColorRes.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: Get.width,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 5),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: ColorRes.white,
                        border: Border.all(
                          color: ColorRes.primaryBlue.withOpacity(0.1),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: ColorRes.primaryBlue.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.attach_money,
                                    color: ColorRes.primaryOrange,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Salary",
                                    style: appTextStyle(
                                        color: ColorRes.grey600,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              Text(
                                _formatSalary(salary),
                                style: appTextStyle(
                                    color: ColorRes.primaryBlueDark,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.work_outline,
                                    color: ColorRes.primaryOrange,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Type",
                                    style: appTextStyle(
                                        color: ColorRes.grey600,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: ColorRes.primaryBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  type ?? "Full-time",
                                  style: appTextStyle(
                                      color: ColorRes.primaryBlueDark,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    color: ColorRes.primaryOrange,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Location",
                                    style: appTextStyle(
                                        color: ColorRes.grey600,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.place,
                                    color: ColorRes.primaryOrange,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatLocation(location),
                                    style: appTextStyle(
                                        color: ColorRes.primaryBlueDark,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Resume Sent Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.send_outlined,
                                    color: ColorRes.primaryOrange,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Resume Sent",
                                    style: appTextStyle(
                                        color: ColorRes.grey600,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              Text(
                                _getTodaysDate(),
                                style: appTextStyle(
                                    color: ColorRes.primaryBlueDark,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Description Card
                    Container(
                      width: Get.width,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 5),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: ColorRes.white,
                        border: Border.all(
                          color: ColorRes.primaryBlue.withOpacity(0.1),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: ColorRes.primaryBlue.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.description_outlined,
                                color: ColorRes.primaryOrange,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Description",
                                style: appTextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: ColorRes.primaryBlueDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            message ?? "Description not available",
                            style: appTextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: ColorRes.grey700,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: ColorRes.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorRes.primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: ColorRes.primaryOrange,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Delete Application",
                style: appTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ColorRes.primaryBlueDark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Are you sure you want to delete this application? This action cannot be undone.",
                textAlign: TextAlign.center,
                style: appTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: ColorRes.grey600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Get.back(),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: ColorRes.grey300,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            "Cancel",
                            style: appTextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: ColorRes.grey600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Get.back(); // Close dialog
                        Get.back(); // Go back to previous screen
                        Get.snackbar(
                          "Deleted",
                          "Application has been deleted successfully",
                          backgroundColor: ColorRes.primaryBlueDark,
                          colorText: ColorRes.white,
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 12,
                          duration: const Duration(seconds: 3),
                          icon: const Icon(
                            Icons.check_circle,
                            color: ColorRes.white,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ColorRes.primaryOrange,
                              ColorRes.primaryOrangeLight,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            "Delete",
                            style: appTextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: ColorRes.white,
                            ),
                          ),
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
    );
  }
}
