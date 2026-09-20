import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gov_app_bar.dart';
import '../../core/widgets/gov_loading_indicator.dart';
import '../../core/widgets/status_badge.dart';
import '../../providers/booking_provider.dart';

class CustomerBookingsScreen extends StatefulWidget {
  const CustomerBookingsScreen({super.key});

  @override
  State<CustomerBookingsScreen> createState() => _CustomerBookingsScreenState();
}

class _CustomerBookingsScreenState extends State<CustomerBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().fetchCustomerBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bProv = context.watch<BookingProvider>();

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
        backgroundColor: isDark ? const Color(0xFF0A0F24) : const Color(0xFFF8FAFC),
        appBar: const GovAppBar(title: 'My Service Orders', showBack: true),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/book-service'),
          backgroundColor: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
          foregroundColor: isDark ? Colors.black : Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Book New Service', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: Column(
          children: [
            Container(
              color: isDark ? const Color(0xFF131B38) : Colors.white,
              child: TabBar(
                controller: _tabController,
                indicatorColor: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
                labelColor: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
                unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                tabs: [
                  Tab(text: 'Active Orders (${bProv.activeBookings.length})'),
                  Tab(text: 'History (${bProv.completedBookings.length})'),
                ],
              ),
            ),
            Expanded(
              child: bProv.isLoading
                  ? const GovLoadingIndicator.card(
                      title: 'Synchronizing Booking Records...',
                      subtitle: 'Retrieving escrow transactions and service milestones',
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _bookingsList(bProv.activeBookings, 'No active orders in progress.', isDark),
                        _bookingsList(bProv.completedBookings, 'No past booking history.', isDark),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bookingsList(List bookings, String emptyMsg, bool isDark) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 48, color: isDark ? const Color(0xFF64748B) : AppColors.textMuted),
            const SizedBox(height: 12),
            Text(emptyMsg, style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary, fontSize: 13)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<BookingProvider>().fetchCustomerBookings(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final b = bookings[index];
          return Card(
            color: isDark ? const Color(0xFF131B38) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: isDark ? const Color(0xFF1E294B) : const Color(0xFFE2E8F0)),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => context.push('/customer/bookings/${b.id}'),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          b.bookingCode,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted),
                        ),
                        StatusBadge(status: b.status, isEmergency: b.isEmergency),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      b.serviceName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.person_outline, size: 14, color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          b.workerName != null ? '${b.workerName} (${b.workerTrade ?? "Artisan"})' : 'Pending artisan assignment',
                          style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 13, color: isDark ? const Color(0xFF64748B) : AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text('${b.scheduledDate} • ${b.scheduledTime}', style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF64748B) : AppColors.textMuted)),
                      ],
                    ),
                    Divider(height: 18, color: isDark ? const Color(0xFF1E294B) : const Color(0xFFE2E8F0)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${b.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.accentGreen),
                        ),
                        Row(
                          children: [
                            if (b.arrivalOtp != null && !b.arrivalOtpVerified) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text('Arrival OTP: ${b.arrivalOtp}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.infoBlue)),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              'View Tracking →',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
