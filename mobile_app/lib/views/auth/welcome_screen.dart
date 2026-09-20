import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/language_provider.dart';
import '../../providers/auth_provider.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar with Language Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.secondarySaffron,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      lang.translate('odisha_network'),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (code) => lang.setLanguage(code),
                    tooltip: 'Select Language / ଭାଷା ବାଛନ୍ତୁ / भाषा चुनें',
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCardAlt : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.translate, size: 14, color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy),
                          const SizedBox(width: 4),
                          Text(
                            lang.supportedLanguages[lang.currentLocale] ?? 'English',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.primaryNavy),
                          ),
                          Icon(Icons.arrow_drop_down, size: 14, color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy),
                        ],
                      ),
                    ),
                    itemBuilder: (context) => [
                      CheckedPopupMenuItem(
                        value: 'EN',
                        checked: lang.currentLocale == 'EN',
                        child: const Text('English (EN)'),
                      ),
                      CheckedPopupMenuItem(
                        value: 'OR',
                        checked: lang.currentLocale == 'OR',
                        child: const Text('ଓଡ଼ିଆ (Odia)'),
                      ),
                      CheckedPopupMenuItem(
                        value: 'HI',
                        checked: lang.currentLocale == 'HI',
                        child: const Text('हिन्दी (Hindi)'),
                      ),
                    ],
                  ),
                ],
              ),

              const Spacer(flex: 1),

              // Cooperative Brand Emblem
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo_emblem.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Title & State Tagline
              Center(
                child: Column(
                  children: [
                    Text(
                      lang.translate('app_title').toUpperCase(),
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: isDark ? Colors.white : AppColors.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      lang.translate('welcome_title'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkGreenFg : AppColors.accentGreen,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      lang.translate('welcome_subtitle'),
                      style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Three Visual Value Pills
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPill(Icons.shield_outlined, '93-2-5', lang.translate('worker_take_home').split(' ').first, isDark),
                    Container(height: 24, width: 1, color: isDark ? AppColors.darkBorder : AppColors.borderLight),
                    _buildPill(Icons.verified_outlined, 'Skill', lang.translate('iti_certified').split(' ').last, isDark),
                    Container(height: 24, width: 1, color: isDark ? AppColors.darkBorder : AppColors.borderLight),
                    _buildPill(Icons.lock_clock_outlined, '₹0 Surge', lang.translate('zero_surge').split(' ').first, isDark),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // 1. Primary: Sign In Button
              ElevatedButton.icon(
                onPressed: () => context.push('/login'),
                icon: const Icon(Icons.login, size: 18),
                label: Text(
                  lang.translate('welcome_signin'),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 1.5,
                ),
              ),

              const SizedBox(height: 12),

              // 2. Secondary: Explore as Guest Card
              InkWell(
                onTap: () {
                  context.read<AuthProvider>().continueAsGuest();
                  context.go('/');
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.primaryNavy.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCardAlt : AppColors.primaryNavy.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.visibility_outlined, color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lang.translate('welcome_explore_guest'),
                              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.primaryNavy),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              lang.translate('signin_citizen_desc'),
                              style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 3. Tertiary: Register Action
              OutlinedButton(
                onPressed: () => context.push('/register'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? Colors.white : AppColors.primaryNavy,
                  minimumSize: const Size.fromHeight(46),
                  side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  lang.translate('welcome_create'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),

              const Spacer(flex: 1),

              // Footer Disclaimer
              Text(
                'Odisha Cooperative Societies Act • Digital Public Goods',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: isDark ? AppColors.darkTextMuted : AppColors.textMuted, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildPill(IconData icon, String title, String sub, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy, size: 16),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.primaryNavy)),
        Text(sub, style: TextStyle(fontSize: 9, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
      ],
    );
  }
}
