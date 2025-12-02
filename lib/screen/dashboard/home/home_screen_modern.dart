import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/screen/dashboard/home/tipsforyou_screen.dart';
import 'package:timeless/screen/dashboard/home/widgets/appbar.dart';
import 'package:timeless/utils/app_res.dart';
import 'package:timeless/utils/app_theme.dart';
import 'package:timeless/services/translation_service.dart';
import 'package:timeless/services/accessibility_service.dart';
import 'package:timeless/common/widgets/language_switcher.dart';

// ignore: must_be_immutable
class HomeScreenModern extends StatelessWidget {
  const HomeScreenModern({super.key});

  @override
  Widget build(BuildContext context) {
    final TranslationService translationService = Get.find<TranslationService>();
    final AccessibilityService accessibilityService = Get.find<AccessibilityService>();

    return Obx(() => Scaffold(
      backgroundColor: accessibilityService.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // AppBar modernisée
                homeAppBar(),
                
                // Contenu principal
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingRegular),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppTheme.spacingSmall),
                          
                          // --- Tips section modernisée ---
                          _buildTipsSection(context, translationService, accessibilityService),
                          
                          const SizedBox(height: AppTheme.spacingLarge),

                          // --- Actions principales ---
                          _buildMainActions(translationService, accessibilityService),
                          
                          const SizedBox(height: AppTheme.spacingXXLarge),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Floating Language Switcher
            const Positioned(
              top: 16,
              right: 16,
              child: LanguageSwitcher(isCompact: true),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildTipsSection(BuildContext context, TranslationService translationService, AccessibilityService accessibilityService) {
    return accessibilityService.buildAccessibleWidget(
      semanticLabel: 'Tips section',
      onTap: () {
        accessibilityService.triggerHapticFeedback();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (con) => const TipsForYouScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryOrange.withOpacity(0.1),
              AppTheme.secondaryGold.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(
            color: AppTheme.primaryOrange.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: AppTheme.shadowLight,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingSmall),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusRegular),
              ),
              child: Icon(
                Icons.lightbulb_outline,
                color: AppTheme.primaryOrange,
                size: 24,
              ),
            ),
            const SizedBox(width: AppTheme.spacingRegular),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tips for You',
                    style: accessibilityService.getAccessibleTextStyle(
                      fontSize: AppTheme.fontSizeLarge,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryRed,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Discover personalized career advice',
                    style: accessibilityService.getAccessibleTextStyle(
                      fontSize: AppTheme.fontSizeRegular,
                      color: accessibilityService.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.primaryOrange,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainActions(TranslationService translationService, AccessibilityService accessibilityService) {
    return Column(
      children: [
        // Bouton principal "See Jobs" modernisé
        
        AppTheme.primaryButton(
          text: translationService.getText('see_jobs'),
          onPressed: () {
            accessibilityService.triggerHapticFeedback();
            Get.toNamed(AppRes.jobRecommendationScreen);
          },
          width: double.infinity,
        ),
        
        const SizedBox(height: AppTheme.spacingRegular),
        
        // Actions secondaires en grid
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.bookmark_outline,
                title: 'Saved Jobs',
                subtitle: 'View saved',
                onTap: () => accessibilityService.triggerHapticFeedback(),
                accessibilityService: accessibilityService,
              ),
            ),
            const SizedBox(width: AppTheme.spacingRegular),
            Expanded(
              child: _buildActionCard(
                icon: Icons.analytics_outlined,
                title: 'Applications',
                subtitle: 'Track status',
                onTap: () => accessibilityService.triggerHapticFeedback(),
                accessibilityService: accessibilityService,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required AccessibilityService accessibilityService,
  }) {
    return accessibilityService.buildAccessibleWidget(
      semanticLabel: '$title. $subtitle',
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        decoration: AppTheme.containerDecoration.copyWith(
          color: accessibilityService.cardBackgroundColor,
          border: Border.all(
            color: accessibilityService.borderColor,
            width: accessibilityService.isHighContrastMode.value ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: accessibilityService.primaryColor,
              size: 28,
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            Text(
              title,
              style: accessibilityService.getAccessibleTextStyle(
                fontSize: AppTheme.fontSizeMedium,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: accessibilityService.getAccessibleTextStyle(
                fontSize: AppTheme.fontSizeSmall,
                color: accessibilityService.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

}