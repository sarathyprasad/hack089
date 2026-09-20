import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/booking_provider.dart';

class PaymentBottomSheet extends StatefulWidget {
  final int bookingId;
  final double totalAmount;

  const PaymentBottomSheet({super.key, required this.bookingId, required this.totalAmount});

  @override
  State<PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<PaymentBottomSheet> {
  String _selectedMethod = 'UPI';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bProv = context.watch<BookingProvider>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cooperative Escrow Payment',
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold, 
                  color: isDark ? AppColors.darkTextPrimary : AppColors.primaryNavy,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: isDark ? AppColors.darkTextPrimary : null), 
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Total Payable: ₹${widget.totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.accentGreen),
          ),
          const SizedBox(height: 14),

          // Payment Methods Tabs
          Row(
            children: [
              _methodChip('UPI', Icons.qr_code, isDark),
              const SizedBox(width: 8),
              _methodChip('RuPay / Card', Icons.credit_card, isDark),
              const SizedBox(width: 8),
              _methodChip('Net Banking', Icons.account_balance, isDark),
            ],
          ),
          const SizedBox(height: 16),

          if (_selectedMethod == 'UPI') ...[
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
                ),
                child: QrImageView(
                  data: 'upi://pay?pa=odisha.coop@sbi&pn=PrithviFix&am=${widget.totalAmount}&cu=INR',
                  version: QrVersions.auto,
                  size: 140,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Scan using any UPI App (GPay, PhonePe, Paytm, BHIM)',
                style: TextStyle(
                  fontSize: 11, 
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                ),
              ),
            ),
          ] else if (_selectedMethod == 'RuPay / Card') ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCardAlt : const Color(0xFFF8FAFC), 
                borderRadius: BorderRadius.circular(8),
                border: isDark ? Border.all(color: AppColors.darkBorder) : null,
              ),
              child: const Column(
                children: [
                  TextField(decoration: InputDecoration(labelText: 'Card Number', hintText: '•••• •••• •••• 8821')),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: TextField(decoration: InputDecoration(labelText: 'Expiry MM/YY', hintText: '12/28'))),
                      SizedBox(width: 8),
                      Expanded(child: TextField(decoration: InputDecoration(labelText: 'CVV', hintText: '•••'))),
                    ],
                  ),
                ],
              ),
            ),
          ] else ...[
            ListTile(
              leading: Icon(
                Icons.account_balance, 
                color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
              ),
              title: Text(
                'State Bank of India / Odisha State Cooperative Bank', 
                style: TextStyle(
                  fontSize: 13, 
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : null,
                ),
              ),
              subtitle: Text(
                'Instant escrow settlement gateway', 
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.darkTextSecondary : null,
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: bProv.isLoading
                ? null
                : () async {
                    final success = await bProv.processPayment(
                      bookingId: widget.bookingId,
                      paymentMethod: _selectedMethod,
                      amount: widget.totalAmount,
                    );
                    if (context.mounted && success) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(backgroundColor: AppColors.accentGreen, content: Text('Payment Successful! Form IV Tax Invoice generated.')),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGreen,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: bProv.isLoading
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('Authorize ₹${widget.totalAmount.toStringAsFixed(2)} Escrow Payment', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _methodChip(String method, IconData icon, bool isDark) {
    final isSelected = _selectedMethod == method;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedMethod = method),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected 
                ? (isDark ? AppColors.secondarySaffron : AppColors.primaryNavy) 
                : (isDark ? AppColors.darkCardAlt : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            children: [
              Icon(
                icon, 
                size: 16, 
                color: isSelected 
                    ? (isDark ? AppColors.navyDark : Colors.white) 
                    : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                method,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected 
                      ? (isDark ? AppColors.navyDark : Colors.white) 
                      : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
