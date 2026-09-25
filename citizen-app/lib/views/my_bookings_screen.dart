import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_endpoints.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  List<dynamic> _bookings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      final res = await ApiClient().get(ApiEndpoints.bookings);
      if (res is Map && res['bookings'] is List) {
        setState(() => _bookings = res['bookings']);
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  Color _statusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'REQUESTED': return AppColors.requested;
      case 'MATCHED': return AppColors.matched;
      case 'ACCEPTED': return AppColors.accepted;
      case 'IN_PROGRESS': return AppColors.inProgress;
      case 'COMPLETED': return AppColors.completed;
      default: return AppColors.textMuted;
    }
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
          title: const Text('My Bookings'),
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
        ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _bookings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inbox_rounded, size: 64, color: AppColors.textMuted),
                      const SizedBox(height: 16),
                      const Text('No bookings yet', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: () => context.go('/services'), child: const Text('Browse Services')),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _bookings.length,
                  itemBuilder: (context, i) {
                    final b = _bookings[i];
                    final status = b['status']?.toString() ?? 'REQUESTED';
                    return GestureDetector(
                      onTap: () => context.push('/my-bookings/${b['id']}'),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(child: Text(b['service_name']?.toString() ?? 'Service', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600))),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: _statusColor(status).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                                  child: Text(status.replaceAll('_', ' '), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor(status))),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (b['worker_name'] != null)
                              Text('Worker: ${b['worker_name']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            Text('₹${b['total_amount'] ?? b['quoted_price'] ?? '—'}', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
