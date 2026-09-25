import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_endpoints.dart';
import '../widgets/location_bar.dart';

class FindWorkerScreen extends StatefulWidget {
  const FindWorkerScreen({super.key});

  @override
  State<FindWorkerScreen> createState() => _FindWorkerScreenState();
}

class _FindWorkerScreenState extends State<FindWorkerScreen> {
  List<dynamic> _workers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkers();
  }

  Future<void> _loadWorkers() async {
    try {
      final res = await ApiClient().get(ApiEndpoints.workers);
      if (res is Map && res['workers'] is List) {
        setState(() => _workers = res['workers']);
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/home');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Back',
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
          title: const Text('Find a Worker'),
        ),
        body: Column(
          children: [
            const LocationBar(compact: true, margin: EdgeInsets.fromLTRB(16, 10, 16, 4)),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : _workers.isEmpty
                      ? const Center(child: Text('No workers found'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _workers.length,
                  itemBuilder: (context, i) {
                    final w = _workers[i];
                    final verified = w['verification_status']?.toString() == 'VERIFIED';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                            child: Text(
                              (w['name']?.toString() ?? 'W')[0].toUpperCase(),
                              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(child: Text(w['name']?.toString() ?? '', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600))),
                                    if (verified) ...[
                                      const SizedBox(width: 6),
                                      const Icon(Icons.verified, size: 16, color: AppColors.primary),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${w['trade_category']?.toString().replaceAll('_', ' ') ?? ''} • ${w['district'] ?? ''}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                                if (w['avg_rating'] != null) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, size: 14, color: AppColors.accent),
                                      const SizedBox(width: 4),
                                      Text((w['avg_rating'] as num).toStringAsFixed(1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: verified ? AppColors.successBg : AppColors.warningBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              verified ? 'Verified' : 'Pending',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: verified ? AppColors.success : AppColors.warning),
                            ),
                          ),
                        ],
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
