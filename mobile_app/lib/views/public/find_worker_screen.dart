import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gov_app_bar.dart';
import '../../core/widgets/gov_loading_indicator.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/localization/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/worker_provider.dart';
import '../shared/guest_auth_prompt_dialog.dart';

class FindWorkerScreen extends StatefulWidget {
  const FindWorkerScreen({super.key});

  @override
  State<FindWorkerScreen> createState() => _FindWorkerScreenState();
}

class _FindWorkerScreenState extends State<FindWorkerScreen> {
  String _selectedTrade = 'ALL';
  String _selectedDistrict = 'ALL';

  final List<String> _districts = ['ALL', 'Khordha', 'Cuttack', 'Puri'];
  final List<String> _trades = [
    'ALL',
    'Electrical',
    'Plumbing',
    'Carpentry',
    'Painting',
    'Cleaning',
    'Gardening',
    'Caregiving',
    'Driving',
    'Appliance Repair',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkerProvider>().fetchWorkers();
    });
  }

  void _onFilterChanged() {
    context.read<WorkerProvider>().setFilter(
      district: _selectedDistrict,
      trade: _selectedTrade,
    );
  }

  @override
  Widget build(BuildContext context) {
    final workerProv = context.watch<WorkerProvider>();
    final lang = context.watch<LanguageProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/');
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.backgroundLight,
        appBar: GovAppBar(title: lang.translate('find_worker')),
        body: Column(
          children: [
            // Filter Bars
            Container(
              color: isDark ? AppColors.darkCard : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedTrade,
                      dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.white : AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Trade',
                        labelStyle: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        filled: true,
                        fillColor: isDark ? AppColors.darkBackground : Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy, width: 2),
                        ),
                      ),
                      items: _trades.map((t) => DropdownMenuItem(value: t, child: Text(t, style: TextStyle(fontSize: 12, color: isDark ? Colors.white : AppColors.textPrimary)))).toList(),
                      onChanged: (val) {
                        setState(() => _selectedTrade = val ?? 'ALL');
                        _onFilterChanged();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedDistrict,
                      dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.white : AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'District',
                        labelStyle: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        filled: true,
                        fillColor: isDark ? AppColors.darkBackground : Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy, width: 2),
                        ),
                      ),
                      items: _districts.map((d) => DropdownMenuItem(value: d, child: Text(d, style: TextStyle(fontSize: 12, color: isDark ? Colors.white : AppColors.textPrimary)))).toList(),
                      onChanged: (val) {
                        setState(() => _selectedDistrict = val ?? 'ALL');
                        _onFilterChanged();
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Worker Directory List
            Expanded(
              child: workerProv.isLoading
                  ? const GovLoadingIndicator.card(
                      title: 'Finding Verified Guild Artisans...',
                      subtitle: 'Scanning district registries and live dispatch availability',
                    )
                  : workerProv.workers.isEmpty
                      ? Center(
                          child: Text(
                            'No verified workers found in this district/trade.',
                            style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: workerProv.workers.length,
                          itemBuilder: (context, index) {
                            final w = workerProv.workers[index];
                            return Card(
                              color: isDark ? AppColors.darkCard : Colors.white,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 24,
                                          backgroundColor: isDark
                                              ? AppColors.darkCardAlt
                                              : AppColors.primaryNavy.withValues(alpha: 0.1),
                                          child: Text(
                                            w.name.isNotEmpty ? w.name[0] : 'A',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      w.name,
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.bold,
                                                        color: isDark ? Colors.white : AppColors.primaryNavy,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  StatusBadge(status: w.verificationStatus),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${w.primaryTrade} • ${w.experienceYears} Yrs Exp',
                                                style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${w.city}, ${w.district} • ${w.cooperativeName ?? "District Federation"}',
                                                style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    // Skills Tags
                                    if (w.skills.isNotEmpty)
                                      Wrap(
                                        spacing: 4,
                                        runSpacing: 4,
                                        children: w.skills
                                            .take(4)
                                            .map((s) => Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: isDark ? AppColors.darkCardAlt : const Color(0xFFF1F5F9),
                                                    borderRadius: BorderRadius.circular(4),
                                                    border: isDark ? Border.all(color: AppColors.darkBorder) : null,
                                                  ),
                                                  child: Text(s, style: TextStyle(fontSize: 10, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
                                                ))
                                            .toList(),
                                      ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${w.rating} (${w.totalReviews} reviews)',
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary),
                                        ),
                                        const SizedBox(width: 12),
                                        Icon(Icons.task_alt, color: isDark ? AppColors.darkGreenFg : AppColors.accentGreen, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${w.completedJobs} jobs done',
                                          style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                                        ),
                                        const Spacer(),
                                        ElevatedButton(
                                          onPressed: () {
                                            final auth = context.read<AuthProvider>();
                                            if (auth.isGuest) {
                                              GuestAuthPromptDialog.show(
                                                context,
                                                actionDescription: 'book ${w.name}',
                                              );
                                            } else {
                                              context.push('/book-service?workerId=${w.id}');
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          child: const Text('Book', style: TextStyle(fontSize: 12)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
