import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gov_loading_indicator.dart';
import '../../../models/review_model.dart';
import '../../../providers/review_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../shared/guest_auth_prompt_dialog.dart';

class HomeReviewsSection extends StatelessWidget {
  const HomeReviewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final reviewProv = context.watch<ReviewProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Community Reviews & Testimonials',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.primaryNavy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Dual perspectives from citizens and cooperative artisans',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF064E3B) : AppColors.greenLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified, size: 14, color: isDark ? const Color(0xFF34D399) : AppColors.accentGreen),
                  const SizedBox(width: 4),
                  Text('100% VERIFIED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF34D399) : AppColors.accentGreen)),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // 1. High-Trust Metrics Ribbon
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricItem('4.9 ★', 'Citizen Rating', Colors.amber.shade800, isDark),
              _buildDivider(isDark),
              _buildMetricItem('98.6%', 'Worker Morale', isDark ? const Color(0xFF34D399) : AppColors.accentGreen, isDark),
              _buildDivider(isDark),
              _buildMetricItem('93-2-5', 'Direct Payout', isDark ? const Color(0xFF38BDF8) : AppColors.primaryNavy, isDark),
              _buildDivider(isDark),
              _buildMetricItem('100%', 'Skill Verified', AppColors.secondarySaffron, isDark),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 2. Perspective Switcher Tabs (All, Citizens, Artisans)
        Row(
          children: [
            _buildTabButton(context, '🌟 All', 'ALL', reviewProv.activeTab, isDark, () => reviewProv.setActiveTab('ALL')),
            const SizedBox(width: 8),
            _buildTabButton(context, '🏠 Citizens', 'CUSTOMER', reviewProv.activeTab, isDark, () => reviewProv.setActiveTab('CUSTOMER')),
            const SizedBox(width: 8),
            _buildTabButton(context, '🛠️ Artisans', 'WORKER', reviewProv.activeTab, isDark, () => reviewProv.setActiveTab('WORKER')),
          ],
        ),

        const SizedBox(height: 10),

        // 3. Trade Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(context, 'All Trades', 'all', reviewProv.selectedTrade, () => reviewProv.setSelectedTrade('all')),
              const SizedBox(width: 6),
              _buildFilterChip(context, '⚡ Electrical & AC', 'electrical', reviewProv.selectedTrade, () => reviewProv.setSelectedTrade('electrical')),
              const SizedBox(width: 6),
              _buildFilterChip(context, '🚰 Plumbing', 'plumbing', reviewProv.selectedTrade, () => reviewProv.setSelectedTrade('plumbing')),
              const SizedBox(width: 6),
              _buildFilterChip(context, '🔨 Carpentry & Home', 'carpentry', reviewProv.selectedTrade, () => reviewProv.setSelectedTrade('carpentry')),
            ],
          ),
        ),

        // 4. Content Cards List
        if (reviewProv.isLoading)
          const GovLoadingIndicator.card(
            title: 'Loading Citizen & Artisan Reviews...',
            subtitle: 'Retrieving authentic 5-star ratings & verified feedback',
            size: 48,
          )
        else ...[
          if (reviewProv.activeTab == 'ALL' || reviewProv.activeTab == 'CUSTOMER') ...[
            if (reviewProv.activeTab == 'ALL')
              Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 4),
                child: Text(
                  'Citizen & Household Feedback',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.primaryNavy,
                  ),
                ),
              ),
            ...reviewProv.filteredCustomerReviews.take(reviewProv.activeTab == 'ALL' ? 2 : 5).map((r) => _buildCustomerReviewCard(context, r)),
          ],

          if (reviewProv.activeTab == 'ALL' || reviewProv.activeTab == 'WORKER') ...[
            if (reviewProv.activeTab == 'ALL')
              Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 12),
                child: Text(
                  'Artisan Voices & Living Wage Testimonials',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.primaryNavy,
                  ),
                ),
              ),
            ...reviewProv.filteredWorkerReviews.take(reviewProv.activeTab == 'ALL' ? 2 : 5).map((w) => _buildWorkerReviewCard(context, w)),
          ],
        ],

        const SizedBox(height: 14),

        // 5. Dual Call to Action Banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF111C38), const Color(0xFF1E2D4A)]
                  : const [AppColors.navyDark, AppColors.primaryNavy],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isDark ? const Color(0xFF2A3B5C) : Colors.transparent),
          ),
          child: Column(
            children: [
              const Text(
                'Experience Fair Wages & Guaranteed Skills',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              const Text(
                'Join thousands of satisfied households and empowered artisans across Odisha.',
                style: TextStyle(fontSize: 11, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final auth = context.read<AuthProvider>();
                        if (auth.isGuest) {
                          GuestAuthPromptDialog.show(context, actionTitle: 'Book Verified Artisans');
                        } else {
                          context.push('/book-service');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondarySaffron,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text('Book Artisan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.push('/register'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text('Join Network', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildMetricItem(String val, String label, Color color, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(val, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color)),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  static Widget _buildDivider(bool isDark) {
    return Container(height: 24, width: 1, color: isDark ? AppColors.darkBorder : AppColors.borderLight);
  }

  static Widget _buildTabButton(BuildContext context, String title, String tabKey, String activeTab, bool isDark, VoidCallback onTap) {
    final bool isSelected = activeTab == tabKey;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.secondarySaffron : AppColors.primaryNavy)
                : (isDark ? AppColors.darkCard : Colors.white),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? (isDark ? AppColors.secondarySaffron : AppColors.primaryNavy)
                  : (isDark ? AppColors.darkBorder : AppColors.borderLight),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? (isDark ? Colors.black : Colors.white)
                  : (isDark ? const Color(0xFFCBD5E1) : AppColors.textPrimary),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildFilterChip(BuildContext context, String title, String key, String currentKey, VoidCallback onTap) {
    final bool isSelected = currentKey == key;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondarySaffron.withValues(alpha: isDark ? 0.25 : 0.2)
              : (isDark ? AppColors.darkCard : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.secondarySaffron
                : (isDark ? AppColors.darkBorder : AppColors.borderLight),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? (isDark ? AppColors.secondarySaffron : AppColors.primaryNavy)
                : (isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  static Widget _buildCustomerReviewCard(BuildContext context, CustomerReview r) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: isDark
                    ? const Color(0xFF1E294B)
                    : AppColors.primaryNavy.withValues(alpha: 0.1),
                child: Text(
                  r.name.isNotEmpty ? r.name[0] : 'C',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      '${r.role} • ${r.location}',
                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (i) => Icon(Icons.star, size: 12, color: i < r.rating.round() ? Colors.amber : (isDark ? Colors.white24 : Colors.grey.shade300))),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E294B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${r.serviceName} • 30-Day Warranty Protected',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFF38BDF8) : AppColors.primaryNavy,
              ),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            '“${r.comment}”',
            style: TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              height: 1.35,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
            ),
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Serviced By: ${r.servicedBy}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFF34D399) : AppColors.accentGreen,
                ),
              ),
              Text(
                r.date,
                style: TextStyle(fontSize: 9, color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted),
              ),
            ],
          ),

          if (r.workerReply != null && r.workerReply!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E294B) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(6),
                border: const Border(left: BorderSide(color: AppColors.secondarySaffron, width: 3)),
              ),
              child: Text(
                'Worker Reply: “${r.workerReply}”',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? const Color(0xFFCBD5E1) : AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Widget _buildWorkerReviewCard(BuildContext context, WorkerReview w) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: isDark
                    ? const Color(0xFF064E3B)
                    : AppColors.accentGreen.withValues(alpha: 0.15),
                child: Text(
                  w.name.isNotEmpty ? w.name[0] : 'W',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFF34D399) : AppColors.accentGreen,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          w.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF064E3B) : AppColors.greenLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'SKILL CERTIFIED',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFF34D399) : AppColors.accentGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${w.trade} • ${w.cooperative}',
                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.secondarySaffron.withValues(alpha: 0.2)
                      : AppColors.secondarySaffron.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  w.monthlyIncome,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            w.highlight,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.primaryNavy,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            '“${w.comment}”',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
              height: 1.35,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🛡️ ${w.welfare}',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? const Color(0xFF34D399) : AppColors.accentGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${w.completedJobs} • ${w.artisanRating}',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
