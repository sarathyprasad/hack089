import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gov_app_bar.dart';
import '../../core/widgets/gov_loading_indicator.dart';
import '../../providers/booking_provider.dart';

class TaxInvoiceScreen extends StatefulWidget {
  final int bookingId;
  const TaxInvoiceScreen({super.key, required this.bookingId});

  @override
  State<TaxInvoiceScreen> createState() => _TaxInvoiceScreenState();
}

class _TaxInvoiceScreenState extends State<TaxInvoiceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().fetchInvoice(widget.bookingId);
    });
  }

  Future<void> _printInvoice() async {
    final inv = context.read<BookingProvider>().currentInvoice;
    if (inv == null) return;

    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('GOVERNMENT OF ODISHA', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                          pw.Text('Department of Cooperation — Labour Cooperative Federation', style: const pw.TextStyle(fontSize: 10)),
                          pw.Text('FORM IV: STATUTORY TAX INVOICE & ESCROW CERTIFICATE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                        ],
                      ),
                      pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: 'https://prithvifix.odisha.gov.in/verify/${inv.invoiceNumber}',
                        width: 60,
                        height: 60,
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Invoice No: ${inv.invoiceNumber}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Date: ${inv.date}'),
                  ],
                ),
                pw.Text('Booking Code: ${inv.bookingCode}'),
                pw.Text('Txn Ref: ${inv.transactionId ?? "TXN-DEMO-2026"}'),
                pw.Divider(),
                pw.SizedBox(height: 10),
                pw.Text('Citizen Customer: ${inv.customerName}'),
                pw.Text('Address: ${inv.customerAddress}'),
                pw.SizedBox(height: 8),
                pw.Text('Assigned Artisan: ${inv.workerName} (${inv.workerTrade})'),
                pw.SizedBox(height: 16),
                pw.TableHelper.fromTextArray(
                  headers: ['Item / Component', 'Rate Split', 'Amount (INR)'],
                  data: [
                    [inv.serviceName, 'Base Tariff', 'Rs. ${inv.basePrice.toStringAsFixed(2)}'],
                    ['93% Artisan Living Wage', 'Direct Escrow Release', 'Rs. ${inv.workerWage.toStringAsFixed(2)}'],
                    ['5% State Welfare Contribution', 'ESIC & Mini-PF', 'Rs. ${inv.cooperativeWelfare.toStringAsFixed(2)}'],
                    ['2% Cooperative Maintenance', 'Platform Upkeep', 'Rs. ${inv.platformFee.toStringAsFixed(2)}'],
                    if (inv.partsTotal > 0) ['Locked Approved Parts', 'Replaced Components', 'Rs. ${inv.partsTotal.toStringAsFixed(2)}'],
                  ],
                ),
                pw.SizedBox(height: 16),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('TOTAL SETTLED AMOUNT:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
                    pw.Text('Rs. ${inv.totalAmount.toStringAsFixed(2)} [PAID]', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
                  ],
                ),
                pw.SizedBox(height: 30),
                pw.Text('Authorized Digital Signature — Khordha District Labour Cooperative Federation', style: const pw.TextStyle(fontSize: 9)),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bProv = context.watch<BookingProvider>();
    final inv = bProv.currentInvoice;

    return Scaffold(
      appBar: GovAppBar(
        title: 'Form IV Tax Invoice',
        actions: [
          if (inv != null)
            IconButton(
              icon: const Icon(Icons.print, color: Colors.white),
              tooltip: 'Print / Download PDF',
              onPressed: _printInvoice,
            ),
        ],
      ),
      body: inv == null
          ? const GovLoadingIndicator.fullScreen(
              title: 'Generating Statutory Tax Invoice (Form IV)...',
              subtitle: 'Rendering cooperative GST ledger entries and digital QR verification signature',
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: isDark ? AppColors.darkCard : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Form IV Official Header
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.navyLight : AppColors.primaryNavy, 
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('GOVERNMENT OF ODISHA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Department of Cooperation — District Federation', 
                              style: TextStyle(
                                fontSize: 11, 
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'FORM IV: STATUTORY TAX INVOICE',
                              style: TextStyle(
                                fontSize: 14, 
                                fontWeight: FontWeight.bold, 
                                color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 24),

                      // Meta details
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Invoice: ${inv.invoiceNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text('Date: ${inv.date}', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Booking Code: ${inv.bookingCode}', style: const TextStyle(fontSize: 12)),
                      Text(
                        'Txn Ref: ${inv.transactionId ?? "TXN-DEMO-2026"}', 
                        style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                      ),

                      const Divider(height: 20),

                      // Customer & Worker info
                      Text('Billed To: ${inv.customerName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text(
                        inv.customerAddress, 
                        style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Text('Assigned Artisan: ${inv.workerName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text(
                        'Trade: ${inv.workerTrade}', 
                        style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                      ),

                      const Divider(height: 20),

                      // Itemized Table
                      Text(
                        'Itemized Tariff Breakdown (93-2-5 Model)', 
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 13, 
                          color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _invoiceRow('Base Service Tariff (${inv.serviceName})', '₹${inv.basePrice.toStringAsFixed(2)}', isDark: isDark),
                      _invoiceRow('• 93% Artisan Direct Living Wage', '₹${inv.workerWage.toStringAsFixed(2)}', color: AppColors.accentGreen, isDark: isDark),
                      _invoiceRow('• 5% ESIC Accident & Mini-PF Welfare Levy', '₹${inv.cooperativeWelfare.toStringAsFixed(2)}', color: AppColors.warningAmber, isDark: isDark),
                      _invoiceRow('• 2% Cooperative Infrastructure Fee', '₹${inv.platformFee.toStringAsFixed(2)}', color: AppColors.infoBlue, isDark: isDark),
                      if (inv.partsTotal > 0)
                        _invoiceRow('• Approved Locked Spare Parts', '₹${inv.partsTotal.toStringAsFixed(2)}', color: Colors.purple, isDark: isDark),

                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Amount Paid (INR):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(
                            '₹${inv.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.accentGreen),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // QR Seal (Wrapped in white pill container for universal optical readability)
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
                              ),
                              child: QrImageView(
                                data: 'PRITHVI-FIX-VERIFIED-INVOICE:${inv.invoiceNumber}',
                                version: QrVersions.auto,
                                size: 100,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Digitally Verified Escrow Seal', 
                              style: TextStyle(fontSize: 10, color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      ElevatedButton.icon(
                        onPressed: _printInvoice,
                        icon: const Icon(Icons.download, size: 18),
                        label: const Text('Download / Print Statutory PDF'),
                        style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(42)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _invoiceRow(String title, String amount, {Color? color, required bool isDark}) {
    final defaultColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(title, style: TextStyle(fontSize: 12, color: color ?? defaultColor))),
          Text(amount, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color ?? defaultColor)),
        ],
      ),
    );
  }
}
