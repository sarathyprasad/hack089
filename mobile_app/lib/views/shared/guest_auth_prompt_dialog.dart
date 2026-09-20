import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class GuestAuthPromptDialog extends StatelessWidget {
  final String actionTitle;
  const GuestAuthPromptDialog({super.key, this.actionTitle = 'Book Verified Artisans'});

  static Future<void> show(
    BuildContext context, {
    String? actionTitle,
    String? actionDescription,
  }) {
    final title = actionDescription ?? actionTitle ?? 'Book Verified Artisans';
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => GuestAuthPromptDialog(actionTitle: title),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Lock Icon Badge
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryNavy.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_person_rounded, size: 36, color: AppColors.primaryNavy),
          ),
          const SizedBox(height: 14),

          // Title & Description
          const Text(
            'Customer Sign-In Required',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'You are currently in Guest Mode (Monitor Only). To $actionTitle, verify arrival OTPs, and generate statutory tax invoices, please sign in or create an account.',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // 1. Sign In Button
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              context.push('/login?role=customer');
            },
            icon: const Icon(Icons.login, size: 18),
            label: const Text('Sign In as Customer', style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryNavy,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(46),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 10),

          // 2. Register Button
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/register');
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryNavy,
              minimumSize: const Size.fromHeight(44),
              side: const BorderSide(color: AppColors.primaryNavy),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Create New Account'),
          ),
          const SizedBox(height: 6),

          // 3. Stay in Guest Mode
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Stay in Guest Mode (Monitor)', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
