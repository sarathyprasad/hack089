import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../localization/language_provider.dart';
import '../theme/accessibility_provider.dart';
import '../../providers/location_provider.dart';
import 'location_selection_modal.dart';

class GovAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;

  const GovAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBack = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();
    final accessProvider = context.watch<AccessibilityProvider>();
    final locProv = context.watch<LocationProvider>();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unsupp = locProv.unsupportedLocation;
    final selectedLoc = locProv.selectedLocation;

    return AppBar(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.primaryNavy,
      elevation: 1,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
              tooltip: 'Back',
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/');
                }
              },
            )
          : Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 24),
                tooltip: 'Open Sidebar Menu',
                onPressed: () {
                  final scaffold = Scaffold.of(ctx);
                  if (scaffold.hasDrawer) {
                    scaffold.openDrawer();
                  }
                },
              ),
            ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: AppColors.secondarySaffron,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  langProvider.translate('odisha_network'),
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // Interactive Location Pill
              InkWell(
                onTap: () => LocationSelectionModal.show(context),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: unsupp != null
                        ? AppColors.amber500
                        : Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 10,
                        color: unsupp != null ? Colors.black : Colors.white,
                      ),
                      const SizedBox(width: 2),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 110),
                        child: Text(
                          unsupp != null
                              ? '${unsupp.name} (Soon)'
                              : selectedLoc.shortName,
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                            color: unsupp != null ? Colors.black : Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 1),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 11,
                        color: unsupp != null ? Colors.black : Colors.white70,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      actions: [
        // 5-Language Selector Popup
        PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          icon: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.translate_rounded, color: Colors.white, size: 13),
                const SizedBox(width: 3),
                Text(
                  langProvider.currentLocale,
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
          tooltip: 'Select Language / ଭାଷା ବାଛନ୍ତୁ / भाषा चुनें',
          onSelected: (code) => langProvider.setLanguage(code),
          itemBuilder: (context) => [
            CheckedPopupMenuItem(
              value: 'EN',
              checked: langProvider.currentLocale == 'EN',
              child: const Text('English (EN)'),
            ),
            CheckedPopupMenuItem(
              value: 'OR',
              checked: langProvider.currentLocale == 'OR',
              child: const Text('ଓଡ଼ିଆ (Odia)'),
            ),
            CheckedPopupMenuItem(
              value: 'HI',
              checked: langProvider.currentLocale == 'HI',
              child: const Text('हिन्दी (Hindi)'),
            ),
            CheckedPopupMenuItem(
              value: 'BN',
              checked: langProvider.currentLocale == 'BN',
              child: const Text('বাংলা (Bengali)'),
            ),
            CheckedPopupMenuItem(
              value: 'TE',
              checked: langProvider.currentLocale == 'TE',
              child: const Text('తెలుగు (Telugu)'),
            ),
          ],
        ),

        // Dark / Light Theme Toggle
        IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          constraints: const BoxConstraints(),
          icon: Icon(
            accessProvider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_outlined,
            color: accessProvider.isDarkMode ? AppColors.secondarySaffron : Colors.white,
            size: 19,
          ),
          tooltip: accessProvider.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          onPressed: () => accessProvider.toggleDarkMode(),
        ),

        // Settings
        IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 19),
          tooltip: langProvider.translate('settings'),
          onPressed: () => context.push('/settings'),
        ),

        const SizedBox(width: 6),
        ...?actions,
      ],
    );
  }
}
