import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gov_app_bar.dart';
import '../../core/widgets/gov_loading_indicator.dart';
import '../../core/widgets/status_badge.dart';
import '../../models/booking_model.dart';
import '../../providers/worker_portal_provider.dart';
import '../../providers/auth_provider.dart';

class WorkerDashboardScreen extends StatefulWidget {
  const WorkerDashboardScreen({super.key});

  @override
  State<WorkerDashboardScreen> createState() => _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends State<WorkerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkerPortalProvider>().fetchDashboard();
    });
  }

  void _showOtpInputDialog(int bookingId, String type) {
    final otpCtrl = TextEditingController();
    final isArrival = type == 'arrival';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isArrival ? 'Enter Citizen Arrival OTP' : 'Enter Citizen Completion OTP', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArrival
                  ? 'Ask citizen for their 4-digit Arrival OTP to start service work order.'
                  : 'Ask citizen for their 4-digit Completion OTP after inspecting repair.',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: otpCtrl,
              decoration: const InputDecoration(labelText: '4-Digit OTP', hintText: '••••'),
              keyboardType: TextInputType.number,
              maxLength: 4,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final otp = otpCtrl.text.trim();
              if (otp.length != 4) return;
              Navigator.pop(ctx);

              final wp = context.read<WorkerPortalProvider>();
              await wp.handleJobAction(bookingId, isArrival ? 'START' : 'COMPLETE');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.accentGreen,
                    content: Text(isArrival ? 'Arrival verified! Status: IN PROGRESS' : 'Work order completed! 93% earnings credited.'),
                  ),
                );
              }
            },
            child: const Text('Verify & Proceed'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wp = context.watch<WorkerPortalProvider>();
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

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
        appBar: const GovAppBar(title: 'Artisan Dispatch Portal', showBack: true),
        body: wp.isLoading && wp.activeOrders.isEmpty && wp.incomingQueue.isEmpty
            ? const GovLoadingIndicator.fullScreen(
                title: 'Synchronizing Dispatch Feeds...',
                subtitle: 'Connecting to cooperative guild beacon and active work orders',
              )
            : RefreshIndicator(
                onRefresh: () => wp.fetchDashboard(),
                child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Worker Identity Banner & Duty Switch
                Card(
                  color: isDark ? const Color(0xFF131B38) : AppColors.primaryNavy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: isDark ? const Color(0xFF1E294B) : Colors.transparent),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.secondarySaffron,
                              child: Text(
                                user?.name.isNotEmpty == true ? user!.name[0] : 'R',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.name ?? 'Ramesh Kumar',
                                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const Text(
                                    'Master Electrician • Gold Skill Certified',
                                    style: TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: AppColors.accentGreen, borderRadius: BorderRadius.circular(4)),
                              child: const Text('ACCREDITED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white24, height: 24),
                        // Availability Toggle Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: wp.isAvailable ? AppColors.accentGreen : Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Duty Status: ${wp.availability}',
                                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Switch(
                              value: wp.isAvailable,
                              activeTrackColor: AppColors.secondarySaffron,
                              activeThumbColor: Colors.black,
                              onChanged: (val) => wp.updateAvailability(val ? 'AVAILABLE' : 'OFFLINE'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Earnings & Stats Grid
                Row(
                  children: [
                    _metricCard('93% NET WAGE', '₹${wp.totalEarnings.toStringAsFixed(0)}', Icons.account_balance_wallet, AppColors.accentGreen, isDark),
                    const SizedBox(width: 10),
                    _metricCard('COMPLETED JOBS', '${wp.completedTasks}', Icons.task_alt, isDark ? AppColors.secondarySaffron : AppColors.primaryNavy, isDark),
                    const SizedBox(width: 10),
                    _metricCard('CITIZEN RATING', '${wp.averageRating} ★', Icons.star, Colors.amber.shade700, isDark),
                  ],
                ),

                const SizedBox(height: 20),

                // Incoming Broadcast Dispatch Queue
                Row(
                  children: [
                    const Icon(Icons.radar, color: AppColors.emergencyRed, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      'Incoming Broadcast Dispatch Queue',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.primaryNavy),
                    ),
                    const Spacer(),
                    if (wp.incomingQueue.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.redLight, borderRadius: BorderRadius.circular(10)),
                        child: Text('${wp.incomingQueue.length} New Orders', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.emergencyRed)),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                if (wp.incomingQueue.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF131B38) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? const Color(0xFF1E294B) : AppColors.borderLight),
                    ),
                    child: Center(
                      child: Text(
                        'Listening for nearby customer dispatch orders...',
                        style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted),
                      ),
                    ),
                  )
                else
                  ...wp.incomingQueue.map((order) => _incomingOrderCard(order, wp, isDark)),

                const SizedBox(height: 20),

                // Active Work Orders Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Active Accepted Work Orders',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.primaryNavy),
                    ),
                    TextButton.icon(
                      onPressed: () => context.push('/worker/welfare'),
                      icon: const Icon(Icons.health_and_safety_outlined, size: 16),
                      label: const Text('Welfare Centre →'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (wp.activeOrders.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF131B38) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? const Color(0xFF1E294B) : AppColors.borderLight),
                    ),
                    child: Center(
                      child: Text(
                        'No active work orders currently in execution.',
                        style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted),
                      ),
                    ),
                  )
                else
                  ...wp.activeOrders.map((job) => _activeJobCard(job, wp, isDark)),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _metricCard(String title, String value, IconData icon, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131B38) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? const Color(0xFF1E294B) : AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(title, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _incomingOrderCard(BookingModel order, WorkerPortalProvider wp, bool isDark) {
    final netWage = order.totalAmount * 0.93;

    return Card(
      color: isDark ? const Color(0xFF131B38) : Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.secondarySaffron, width: 1.5)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.bookingCode, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted)),
                StatusBadge(status: 'BROADCAST', isEmergency: order.isEmergency),
              ],
            ),
            const SizedBox(height: 4),
            Text(order.serviceName, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.primaryNavy)),
            const SizedBox(height: 4),
            Text('Citizen: ${order.customerName} • ${order.locationAddress}, ${order.locationCity}', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : AppColors.greenLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Guaranteed 93% Net Payout:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accentGreen)),
                  Text('₹${netWage.toStringAsFixed(2)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.accentGreen)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => wp.handleJobAction(order.id, 'ACCEPT'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentGreen),
                    child: const Text('✓ Accept Work Order', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => wp.handleJobAction(order.id, 'DECLINE'),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.emergencyRed, side: const BorderSide(color: AppColors.emergencyRed)),
                  child: const Text('Decline'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _activeJobCard(BookingModel job, WorkerPortalProvider wp, bool isDark) {
    final isAccepted = job.status == 'ACCEPTED';
    final isInProgress = job.status == 'IN_PROGRESS';

    return Card(
      color: isDark ? const Color(0xFF131B38) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDark ? const Color(0xFF1E294B) : const Color(0xFFE2E8F0)),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(job.bookingCode, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted)),
                StatusBadge(status: job.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(job.serviceName, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.primaryNavy)),
            Text('Location: ${job.locationAddress}, ${job.locationCity}', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary)),
            Divider(height: 20, color: isDark ? const Color(0xFF1E294B) : const Color(0xFFE2E8F0)),

            if (isAccepted)
              ElevatedButton.icon(
                onPressed: () => _showOtpInputDialog(job.id, 'arrival'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  minimumSize: const Size.fromHeight(40),
                ),
                icon: const Icon(Icons.key, size: 16),
                label: const Text('Arrived On-Site (Enter Arrival OTP)'),
              ),

            if (isInProgress)
              ElevatedButton.icon(
                onPressed: () => _showOtpInputDialog(job.id, 'completion'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentGreen, minimumSize: const Size.fromHeight(40)),
                icon: const Icon(Icons.check_circle_outline, size: 16),
                label: const Text('Complete Work (Enter Completion OTP)'),
              ),
          ],
        ),
      ),
    );
  }
}
