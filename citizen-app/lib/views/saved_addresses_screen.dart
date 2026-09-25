import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  final List<Map<String, dynamic>> _addresses = [
    {
      'id': 1,
      'tag': 'Home',
      'icon': Icons.home,
      'is_default': true,
      'recipient': 'Ramesh Mohapatra',
      'phone': '+91 94370 12345',
      'address': 'Plot 42, Saheed Nagar, Near Durga Mandap',
      'city': 'Bhubaneswar',
      'district': 'Khordha',
      'pincode': '751007',
      'instructions': '2nd Floor, White building with green gate. Dog in ground floor.',
    },
    {
      'id': 2,
      'tag': 'Parents\' Residence',
      'icon': Icons.elderly,
      'is_default': false,
      'recipient': 'Bishnu Charan Mohapatra (Father)',
      'phone': '+91 94371 99887',
      'address': 'Lane 4, CDA Sector 9, Near Biju Patnaik Park',
      'city': 'Cuttack',
      'district': 'Cuttack',
      'pincode': '753014',
      'instructions': 'Ground floor flat. Please ring calling bell twice.',
    },
    {
      'id': 3,
      'tag': 'Office / Studio',
      'icon': Icons.business,
      'is_default': false,
      'recipient': 'Ramesh Mohapatra',
      'phone': '+91 94370 12345',
      'address': 'Tower B, 3rd Floor, Fortune Tower, Chandrasekharpur',
      'city': 'Bhubaneswar',
      'district': 'Khordha',
      'pincode': '751023',
      'instructions': 'Security check required at main visitor desk. Call on arrival.',
    },
  ];

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
        backgroundColor: AppColors.background,
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
          title: Text(
            'Saved Addresses & Profiles',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: _showAddAddressDialog,
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Add New Address'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _addresses.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final addr = _addresses[index];
          final isDefault = addr['is_default'] == true;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDefault ? AppColors.primary : AppColors.borderLight,
                width: isDefault ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDefault
                            ? AppColors.primaryLight.withValues(alpha: 0.3)
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        addr['icon'] as IconData,
                        color: isDefault ? AppColors.primary : AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      addr['tag'] as String,
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    if (isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'DEFAULT',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      )
                    else
                      TextButton(
                        onPressed: () {
                          setState(() {
                            for (var a in _addresses) {
                              a['is_default'] = (a['id'] == addr['id']);
                            }
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${addr['tag']} set as default service address')),
                          );
                        },
                        child: const Text('Set as Default', style: TextStyle(fontSize: 12)),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${addr['recipient']} • ${addr['phone']}',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '${addr['address']}, ${addr['city']}, ${addr['district']} - ${addr['pincode']}',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                ),
                if ((addr['instructions'] as String).isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            addr['instructions'] as String,
                            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        context.go('/book-service');
                      },
                      icon: const Icon(Icons.flash_on, size: 16),
                      label: const Text('Book to this Address'),
                      style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

  void _showAddAddressDialog() {
    final tagCtrl = TextEditingController();
    final recipientCtrl = TextEditingController(text: 'Ramesh Mohapatra');
    final phoneCtrl = TextEditingController(text: '+91 94370 12345');
    final addressCtrl = TextEditingController();
    final pincodeCtrl = TextEditingController(text: '751001');
    final instructionsCtrl = TextEditingController();
    String district = 'Khordha';
    String city = 'Bhubaneswar';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Save New Address',
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: tagCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Address Label',
                    hintText: 'e.g. In-Laws Home / Beach House Puri',
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: district,
                        decoration: const InputDecoration(labelText: 'District'),
                        items: ['Khordha', 'Cuttack', 'Puri']
                            .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setSheetState(() {
                              district = val;
                              city = val == 'Khordha'
                                  ? 'Bhubaneswar'
                                  : val == 'Cuttack'
                                      ? 'Cuttack'
                                      : 'Puri';
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: pincodeCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Pincode'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: addressCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'House / Street / Landmark',
                    hintText: 'Plot No, Colony, Landmark',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: instructionsCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Entry Notes for Artisan',
                    hintText: 'Floor, gate color, elevator code',
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (addressCtrl.text.trim().isEmpty) return;
                      setState(() {
                        _addresses.add({
                          'id': _addresses.length + 1,
                          'tag': tagCtrl.text.trim().isEmpty ? 'Other' : tagCtrl.text.trim(),
                          'icon': Icons.location_on,
                          'is_default': false,
                          'recipient': recipientCtrl.text.trim(),
                          'phone': phoneCtrl.text.trim(),
                          'address': addressCtrl.text.trim(),
                          'city': city,
                          'district': district,
                          'pincode': pincodeCtrl.text.trim(),
                          'instructions': instructionsCtrl.text.trim(),
                        });
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Address added to your profile!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Save Address'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
