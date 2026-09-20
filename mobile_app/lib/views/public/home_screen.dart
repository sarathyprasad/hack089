import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gov_app_bar.dart';
import '../../core/widgets/gov_drawer.dart';
import '../../core/widgets/tariff_breakdown_card.dart';
import '../../core/widgets/location_selection_modal.dart';
import '../../core/localization/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_provider.dart';
import '../../providers/worker_provider.dart';
import '../../providers/review_provider.dart';
import '../../providers/location_provider.dart';
import '../shared/ai_chatbot_sheet.dart';
import '../shared/guest_auth_prompt_dialog.dart';
import 'widgets/home_reviews_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? _lastBackPressTime;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().fetchServices();
      context.read<WorkerProvider>().fetchWorkers(verified: true);
      context.read<ReviewProvider>().fetchFeaturedReviews();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final lang = context.watch<LanguageProvider>();
    final serviceProv = context.watch<ServiceProvider>();
    final workerProv = context.watch<WorkerProvider>();
    final locProv = context.watch<LocationProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final unsupp = locProv.unsupportedLocation;
    final selectedLoc = locProv.selectedLocation;

    final List<Map<String, dynamic>> tradeCategories = [
      {'name': 'Electrical', 'icon': Icons.bolt_rounded, 'color': const Color(0xFFD97706), 'base': 149},
      {'name': 'Plumbing', 'icon': Icons.plumbing_rounded, 'color': const Color(0xFF2563EB), 'base': 149},
      {'name': 'Carpentry', 'icon': Icons.carpenter_rounded, 'color': const Color(0xFFB45309), 'base': 199},
      {'name': 'Painting', 'icon': Icons.format_paint_rounded, 'color': const Color(0xFF7C3AED), 'base': 299},
      {'name': 'Appliance', 'icon': Icons.kitchen_rounded, 'color': const Color(0xFFDC2626), 'base': 249},
      {'name': 'Cleaning', 'icon': Icons.cleaning_services_rounded, 'color': const Color(0xFF0D9488), 'base': 199},
      {'name': 'Gardening', 'icon': Icons.yard_rounded, 'color': const Color(0xFF16A34A), 'base': 149},
      {'name': 'Caregiving', 'icon': Icons.elderly_rounded, 'color': const Color(0xFFDB2777), 'base': 349},
      {'name': 'Driving', 'icon': Icons.drive_eta_rounded, 'color': const Color(0xFF4F46E5), 'base': 299},
      {'name': 'Domestic', 'icon': Icons.home_repair_service_rounded, 'color': const Color(0xFF0891B2), 'base': 149},
      {'name': 'IT/CCTV', 'icon': Icons.videocam_rounded, 'color': const Color(0xFF475569), 'base': 249},
      {'name': 'Emergency', 'icon': Icons.emergency_rounded, 'color': AppColors.emergencyRed, 'base': 299},
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final now = DateTime.now();
        if (_lastBackPressTime == null || now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
          _lastBackPressTime = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(lang.translate('press_back_again')),
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }
        SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.slate50,
        appBar: GovAppBar(title: lang.translate('app_title'), showBack: false),
        drawer: const GovDrawer(),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.slate900,
          foregroundColor: Colors.white,
          elevation: 3,
          icon: const Icon(Icons.smart_toy_outlined, color: AppColors.secondarySaffron, size: 20),
          label: const Text('AI Sahayak', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (ctx) => const AIChatBotSheet(),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await serviceProv.fetchServices();
            await workerProv.fetchWorkers(verified: true);
            if (context.mounted) {
              await context.read<ReviewProvider>().fetchFeaturedReviews();
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. OUT OF COVERAGE / BERHAMPUR NOTICE (If active)
                if (unsupp != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkAmberBg : AppColors.amber50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? AppColors.darkAmberFg.withValues(alpha: 0.4) : AppColors.amber200,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.access_time_filled_rounded, color: AppColors.amber600, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${lang.translate('coming_soon_banner')}: ${unsupp.name}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: AppColors.amber700,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => locProv.clearUnsupportedLocation(),
                              child: const Icon(Icons.close_rounded, size: 16, color: AppColors.amber700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          lang.translate('coming_soon_sub'),
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? AppColors.slate300 : AppColors.slate700,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: () => locProv.changeLocation(1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.slate900,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  lang.translate('browse_bhubaneswar'),
                                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_forward_rounded, size: 13, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // 2. MODERN MINIMALIST HERO
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.slate900,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Active Location Capsule
                      InkWell(
                        onTap: () => LocationSelectionModal.show(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: unsupp != null
                                ? AppColors.amber500
                                : Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 13,
                                color: unsupp != null ? Colors.black : AppColors.secondarySaffron,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                unsupp != null
                                    ? '📍 ${unsupp.name} (Coming Soon)'
                                    : '📍 ${selectedLoc.shortName} (${selectedLoc.label})',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: unsupp != null ? Colors.black : Colors.white,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 14,
                                color: unsupp != null ? Colors.black : Colors.white70,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        lang.translate('welcome_title'),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        lang.translate('welcome_subtitle'),
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.white.withValues(alpha: 0.75),
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Minimalist Search Capsule
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (query) {
                            if (query.trim().isNotEmpty) {
                              serviceProv.search(query.trim());
                              context.push('/services');
                            }
                          },
                          decoration: InputDecoration(
                            hintText: lang.translate('search_services_hint'),
                            hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.slate400),
                            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.slate600, size: 20),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18, color: AppColors.slate400),
                                    onPressed: () => _searchController.clear(),
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              key: const ValueKey('home_book_service_btn'),
                              onPressed: () {
                                if (auth.isGuest) {
                                  GuestAuthPromptDialog.show(
                                    context,
                                    actionDescription: 'book a certified artisan service',
                                  );
                                } else {
                                  context.push('/book-service');
                                }
                              },
                              icon: const Icon(Icons.bolt_rounded, size: 16, color: Colors.black),
                              label: Text(
                                lang.translate('book_service_btn'),
                                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 13),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondarySaffron,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 11),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              key: const ValueKey('home_rate_card_btn'),
                              onPressed: () => context.push('/rate-card'),
                              icon: const Icon(Icons.receipt_long_rounded, size: 15, color: Colors.white),
                              label: Text(
                                lang.translate('rate_card_btn'),
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                                padding: const EdgeInsets.symmetric(vertical: 11),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // 3. FOUR KEY TRUST METRICS RIBBON (2x2 Minimalist Grid)
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.3,
                  children: [
                    _buildTrustCard(
                      icon: Icons.money_off_rounded,
                      title: lang.translate('trust_zero_brokerage'),
                      subtitle: lang.translate('trust_zero_brokerage_desc'),
                      color: AppColors.emerald600,
                      isDark: isDark,
                    ),
                    _buildTrustCard(
                      icon: Icons.account_balance_wallet_rounded,
                      title: lang.translate('trust_93_worker'),
                      subtitle: lang.translate('trust_93_worker_desc'),
                      color: AppColors.blue600,
                      isDark: isDark,
                    ),
                    _buildTrustCard(
                      icon: Icons.verified_user_rounded,
                      title: lang.translate('trust_police_verified'),
                      subtitle: lang.translate('trust_police_verified_desc'),
                      color: const Color(0xFFD97706),
                      isDark: isDark,
                    ),
                    _buildTrustCard(
                      icon: Icons.speed_rounded,
                      title: lang.translate('trust_45min_sla'),
                      subtitle: lang.translate('trust_45min_sla_desc'),
                      color: const Color(0xFF7C3AED),
                      isDark: isDark,
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // 4. STANDARDIZED TRADE SERVICES
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      lang.translate('popular_trades'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.slate900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/services'),
                      child: Text(
                        lang.translate('view_all_trades'),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tradeCategories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.95,
                  ),
                  itemBuilder: (context, index) {
                    final cat = tradeCategories[index];
                    final base = cat['base'] as int;
                    final areaPrice = locProv.calculateAreaPrice(base);

                    return InkWell(
                      onTap: () {
                        serviceProv.selectCategory(cat['name']);
                        context.push('/services');
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.slate200,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: (cat['color'] as Color).withValues(alpha: isDark ? 0.25 : 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(cat['icon'] as IconData, color: cat['color'] as Color, size: 22),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              cat['name'],
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : AppColors.slate900,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'From ₹$areaPrice',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.slate500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 22),

                // 5. 93-2-5 ESCROW EXPLAINER
                const TariffBreakdownCard(totalAmount: 249.0),

                const SizedBox(height: 22),

                // 6. VERIFIED CITIZEN REVIEWS (CONDENSED & CLEAN)
                const HomeReviewsSection(),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrustCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.slate200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.25 : 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.slate900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: AppColors.slate500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
