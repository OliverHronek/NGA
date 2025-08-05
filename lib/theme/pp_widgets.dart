// lib/widgets/app_widgets.dart - KORRIGIERTE VERSION
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// Custom Header Widget
class AppHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  
  const AppHeader({
    Key? key,
    required this.title,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
        border: const Border(
          top: BorderSide(color: AppColors.primaryOrange, width: 5),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🇦🇹 ', style: TextStyle(fontSize: 48)),
              Flexible(
                child: Text(
                  title,
                  style: AppTextStyles.logo,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 16),
            Text(
              subtitle!,
              style: AppTextStyles.tagline,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// Feature Card Widget - KORRIGIERT
class FeatureCard extends StatelessWidget {
  final String icon;
  final String title;
  final String description;
  final bool isAlternate;
  
  const FeatureCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    this.isAlternate = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: isAlternate ? AppColors.primaryOrange : AppColors.lightOrange,
            width: 4,
          ),
          left: BorderSide(
            color: isAlternate 
                ? AppColors.borderMedium 
                : AppColors.borderLight,
            width: 2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 56),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: AppTextStyles.featureTitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: AppTextStyles.featureText,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// CTA Section Widget - KORRIGIERT
class CTASection extends StatelessWidget {
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onPressed;
  final bool isGradient;
  
  const CTASection({
    Key? key,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onPressed,
    this.isGradient = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isGradient ? null : AppColors.white,
        gradient: isGradient 
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.primaryGradient,
              )
            : null,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isGradient 
                ? AppColors.primaryOrange.withOpacity(0.3)
                : AppColors.shadowLight,
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
        // KORRIGIERT: Border nur wenn nicht Gradient
        border: isGradient 
            ? null 
            : Border.all(color: AppColors.lightOrange, width: 3),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: isGradient 
                ? AppTextStyles.ctaTitle 
                : AppTextStyles.ctaTitle.copyWith(color: AppColors.primaryOrange),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: isGradient 
                ? AppTextStyles.ctaText 
                : AppTextStyles.ctaText.copyWith(color: AppColors.mediumGray),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: isGradient 
                  ? AppColors.white 
                  : AppColors.primaryOrange,
              foregroundColor: isGradient 
                  ? AppColors.primaryOrange 
                  : AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              textStyle: AppTextStyles.buttonWebApp,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(buttonText),
                const SizedBox(width: 8),
                Icon(isGradient ? Icons.web : Icons.download),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// App Button Widget
class AppButton extends StatelessWidget {
  final String text;
  final String icon;
  final VoidCallback onPressed;
  final bool isPrimary;
  
  const AppButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.isPrimary = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary 
              ? AppColors.primaryOrange 
              : AppColors.white,
          foregroundColor: isPrimary 
              ? AppColors.white 
              : AppColors.primaryOrange,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isPrimary ? 8 : 4,
          shadowColor: isPrimary 
              ? AppColors.primaryOrange.withOpacity(0.3)
              : AppColors.shadowLight,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              text,
              style: AppTextStyles.buttonPrimary.copyWith(
                color: isPrimary ? AppColors.white : AppColors.primaryOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Section Container
class SectionContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  
  const SectionContainer({
    Key? key,
    required this.child,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: padding ?? const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

// Features Grid
class FeaturesGrid extends StatelessWidget {
  final List<Map<String, String>> features;
  
  const FeaturesGrid({
    Key? key,
    required this.features,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return FeatureCard(
          icon: feature['icon']!,
          title: feature['title']!,
          description: feature['description']!,
          isAlternate: index.isOdd,
        );
      },
    );
  }
}