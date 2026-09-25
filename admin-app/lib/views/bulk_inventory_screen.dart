import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

class BulkInventoryScreen extends StatefulWidget {
  const BulkInventoryScreen({super.key});

  @override
  State<BulkInventoryScreen> createState() => _BulkInventoryScreenState();
}

class _BulkInventoryScreenState extends State<BulkInventoryScreen> {
  final List<Map<String, dynamic>> _warehouseStock = [
    {
      'id': 'SKU-ELEC-01',
      'name': 'Havells 2.5 sq mm FR Copper Wire (90m Roll)',
      'category': 'Electrical',
      'warehouse_qty': 450,
      'wholesale_price': 1480.0,
      'market_mrp': 2350.0,
      'discount_percent': '37% Co-op Discount',
      'isi_certified': true,
      'status': 'IN_STOCK',
    },
    {
      'id': 'SKU-ELEC-02',
      'name': 'Schneider Electric 32A Double Pole MCB',
      'category': 'Electrical',
      'warehouse_qty': 280,
      'wholesale_price': 340.0,
      'market_mrp': 580.0,
      'discount_percent': '41% Co-op Discount',
      'isi_certified': true,
      'status': 'IN_STOCK',
    },
    {
      'id': 'SKU-PLUMB-01',
      'name': 'Supreme 1-inch CPVC Brass Concealed Stop Cock',
      'category': 'Plumbing',
      'warehouse_qty': 190,
      'wholesale_price': 420.0,
      'market_mrp': 690.0,
      'discount_percent': '39% Co-op Discount',
      'isi_certified': true,
      'status': 'IN_STOCK',
    },
    {
      'id': 'SKU-APPL-01',
      'name': 'Dual Run Capacitor 45uF + 5uF for AC Compressors',
      'category': 'Appliance',
      'warehouse_qty': 65,
      'wholesale_price': 210.0,
      'market_mrp': 450.0,
      'discount_percent': '53% Co-op Discount',
      'isi_certified': true,
      'status': 'LOW_STOCK',
    },
  ];

  final List<Map<String, dynamic>> _requisitions = [
    {
      'req_id': 'REQ-KH-089',
      'society': 'Utkal Skilled Craftsmen Co-op (Khordha)',
      'items': '50x Havells 2.5mm Wire, 30x Dual Capacitors',
      'total_value': 80300.0,
      'urgency': 'URGENT_RESTOCK',
      'status': 'PENDING_DISPATCH',
    },
    {
      'req_id': 'REQ-CTC-042',
      'society': 'Barabati Artisans Welfare (Cuttack)',
      'items': '40x CPVC Stop Cocks, 25x MCB 32A',
      'total_value': 25300.0,
      'urgency': 'NORMAL',
      'status': 'APPROVED',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: Text(
          'Bulk Procurement & Supply Chain',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wholesale Savings Header
            _buildWarehouseSavingsHero(),

            const SizedBox(height: 16),

            // Pending Society Requisitions
            Text(
              'PRIMARY SOCIETY RESTOCK REQUISITIONS (${_requisitions.length})',
              style: GoogleFonts.dmSans(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _requisitions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final req = _requisitions[index];
                final isPending = req['status'] == 'PENDING_DISPATCH';

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isPending ? AppColors.primary : AppColors.borderDark,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            req['req_id'] as String,
                            style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isPending ? AppColors.warningBg : AppColors.successBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              (req['status'] as String).replaceAll('_', ' '),
                              style: GoogleFonts.dmSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: isPending ? AppColors.warning : AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        req['society'] as String,
                        style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        'Items: ${req['items']}',
                        style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Wholesale Value: ₹${(req['total_value'] as num).toInt()}',
                            style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accent),
                          ),
                          if (isPending)
                            ElevatedButton(
                              onPressed: () {
                                setState(() => req['status'] = 'DISPATCHED_TO_SOCIETY');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppColors.success,
                                    content: Text('Order ${req['req_id']} approved and dispatched to ${req['society']}!'),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                textStyle: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              child: const Text('Approve & Dispatch'),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Central Warehouse Inventory
            Text(
              'CENTRAL STATE COOPERATIVE WAREHOUSE STOCK',
              style: GoogleFonts.dmSans(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _warehouseStock.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _warehouseStock[index];
                final isLowStock = item['status'] == 'LOW_STOCK';

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.inventory_2, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'] as String,
                                  style: GoogleFonts.dmSans(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                Text(
                                  'SKU: ${item['id']} • Category: ${item['category']}',
                                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isLowStock ? AppColors.errorBg : AppColors.successBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${item['warehouse_qty']} in stock',
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isLowStock ? AppColors.error : AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurfaceAlt,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('CO-OP WHOLESALE PRICE', style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textMuted)),
                                Text('₹${(item['wholesale_price'] as num).toInt()}', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('MARKET RETAIL MRP', style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textMuted)),
                                Text('₹${(item['market_mrp'] as num).toInt()}', style: GoogleFonts.dmSans(fontSize: 14, decoration: TextDecoration.lineThrough, color: AppColors.textMuted)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item['discount_percent'] as String,
                                style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.success),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarehouseSavingsHero() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warehouse, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'STATEWIDE COOPERATIVE PROCUREMENT HUB',
                style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '₹4,82,000 Saved for Odisha Households via Direct OEM Sourcing',
            style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            'Procured directly from Havells, Schneider & Supreme to protect citizens from counterfeit parts and middleman inflation.',
            style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
