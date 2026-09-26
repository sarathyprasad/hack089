import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../providers/location_provider.dart';
import '../widgets/location_selection_sheet.dart';

class BookServiceScreen extends StatefulWidget {
  final int? initialServiceId;
  const BookServiceScreen({super.key, this.initialServiceId});

  @override
  State<BookServiceScreen> createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  int _currentStep = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;

  List<dynamic> _services = [];
  Map<String, dynamic>? _selectedService;

  // Form selections
  String _selectedDistrict = 'Khordha';
  String _selectedCity = 'Bhubaneswar';
  final _addressController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _notesController = TextEditingController();
  bool _initializedLocation = false;

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTimeSlot = '10:00 AM - 12:00 PM';
  bool _isEmergency = false;
  int _squadSize = 1;
  String _paymentMethod = 'CASH_ON_SERVICE';

  final List<String> _districts = [
    'Khordha',
    'Cuttack',
    'Puri',
    'Sundargarh',
    'Ganjam',
    'Sambalpur',
    'Balasore'
  ];
  final List<String> _timeSlots = [
    '08:00 AM - 10:00 AM',
    '10:00 AM - 12:00 PM',
    '02:00 PM - 04:00 PM',
    '04:00 PM - 06:00 PM',
    '06:00 PM - 08:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedLocation) {
      final locProvider = context.read<LocationProvider>();
      final loc = locProvider.selectedLocation;
      if (_districts.contains(loc.district)) {
        _selectedDistrict = loc.district;
      }
      _selectedCity = loc.city;
      _pincodeController.text = loc.pincode;
      _addressController.text = '${loc.name}, Near Landmark';
      _initializedLocation = true;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _pincodeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchServices() async {
    try {
      final res = await ApiClient().get(ApiEndpoints.services);
      if (res is List && mounted) {
        setState(() {
          _services = res;
          if (widget.initialServiceId != null) {
            _selectedService = _services.firstWhere(
              (s) => s['id'] == widget.initialServiceId,
              orElse: () => _services.isNotEmpty ? _services.first : null,
            );
          } else if (_services.isNotEmpty) {
            _selectedService = _services.first;
          }
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}

    // Fallback services
    if (mounted) {
      setState(() {
        _services = [
          {'id': 1, 'name': 'Electrical Diagnostic & Switchboard Repair', 'base_price': 299, 'category': 'Electrical', 'duration_minutes': 60},
          {'id': 2, 'name': 'Sanitary Plumbing & Leakage Overhaul', 'base_price': 349, 'category': 'Plumbing', 'duration_minutes': 60},
          {'id': 3, 'name': 'Split AC Deep Foam Jet Servicing', 'base_price': 599, 'category': 'Appliance', 'duration_minutes': 90},
          {'id': 4, 'name': 'Furniture Repair & Hinge Alignment', 'base_price': 399, 'category': 'Carpentry', 'duration_minutes': 60},
        ];
        _selectedService = _services.first;
        _isLoading = false;
      });
    }
  }

  double get _basePrice {
    final p = _selectedService != null ? (double.tryParse(_selectedService!['base_price'].toString()) ?? 299.0) : 299.0;
    return p * _squadSize;
  }

  double get _emergencySurge => _isEmergency ? 150.0 : 0.0;
  double get _totalPrice => _basePrice + _emergencySurge;

  // Cooperative 93-2-5 Split
  double get _workerWage => _totalPrice * 0.93;
  double get _welfareFund => _totalPrice * 0.05;
  double get _platformFee => _totalPrice * 0.02;

  Future<void> _submitBooking() async {
    if (_selectedService == null) return;
    setState(() => _isSubmitting = true);

    final payload = {
      'serviceId': _selectedService!['id'],
      'location_district': _selectedDistrict,
      'location_city': _selectedCity,
      'location_address': _addressController.text.trim(),
      'location_pincode': _pincodeController.text.trim(),
      'scheduled_date': DateFormat('yyyy-MM-dd').format(_selectedDate),
      'scheduled_time': _selectedTimeSlot,
      'is_emergency': _isEmergency,
      'squad_size': _squadSize,
      'notes': _notesController.text.trim(),
      'payment_method': _paymentMethod,
    };

    try {
      final res = await ApiClient().post(ApiEndpoints.bookings, data: payload);
      int bookingId = 1;
      if (res is Map && res['booking'] != null && res['booking']['id'] != null) {
        bookingId = int.tryParse(res['booking']['id'].toString()) ?? 1;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.success,
            content: Text('Booking Confirmed! Certified Cooperative Artisan Dispatched.'),
          ),
        );
        context.go('/booking/$bookingId');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primary,
            content: Text('Booking registered (Demo Mode): ${e.toString()}'),
          ),
        );
        context.go('/bookings');
      }
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
            'Book Cooperative Service',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                // Step Progress Indicator
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      _StepBadge(num: 1, label: 'Service', isActive: _currentStep == 0, isDone: _currentStep > 0),
                      _StepDivider(isDone: _currentStep > 0),
                      _StepBadge(num: 2, label: 'Schedule', isActive: _currentStep == 1, isDone: _currentStep > 1),
                      _StepDivider(isDone: _currentStep > 1),
                      _StepBadge(num: 3, label: 'Address', isActive: _currentStep == 2, isDone: _currentStep > 2),
                      _StepDivider(isDone: _currentStep > 2),
                      _StepBadge(num: 4, label: 'Review', isActive: _currentStep == 3, isDone: _currentStep > 3),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: [
                      _buildStep1Service(),
                      _buildStep2Schedule(),
                      _buildStep3Address(),
                      _buildStep4Review(),
                    ][_currentStep],
                  ),
                ),

                // Bottom Action Button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: AppColors.borderLight)),
                  ),
                  child: Row(
                    children: [
                      if (_currentStep > 0) ...[
                        OutlinedButton(
                          onPressed: () => setState(() => _currentStep--),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          ),
                          child: const Text('Back'),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () {
                                  if (_currentStep < 3) {
                                    setState(() => _currentStep++);
                                  } else {
                                    _submitBooking();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Text(
                                  _currentStep < 3 ? 'Continue to Next Step' : 'Confirm & Book (₹${_totalPrice.toInt()})',
                                  style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildStep1Service() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Service from Cooperative Catalog',
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._services.map((s) {
          final isSelected = _selectedService?['id'] == s['id'];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.borderLight,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: ListTile(
              onTap: () => setState(() => _selectedService = s),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isSelected ? AppColors.primary : AppColors.borderMedium).withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  s['category'] == 'Electrical' ? Icons.electrical_services : Icons.build_circle_outlined,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
              title: Text(
                s['name'],
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: Text(
                '${s['duration_minutes'] ?? 60} mins • 30-Day Guarantee',
                style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
              ),
              trailing: Text(
                '₹${s['base_price']}',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        // Emergency toggle
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _isEmergency ? AppColors.warningBg.withAlpha(20) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _isEmergency ? AppColors.warning : AppColors.borderLight,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.bolt, color: AppColors.warning, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency Dispatch (< 30 Mins)',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      'Immediate priority dispatch with standby artisan (+₹150)',
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isEmergency,
                activeThumbColor: AppColors.warning,
                onChanged: (val) => setState(() => _isEmergency = val),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep2Schedule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Service Date', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          children: List.generate(4, (index) {
            final day = DateTime.now().add(Duration(days: index));
            final isSelected = DateFormat('yyyy-MM-dd').format(_selectedDate) == DateFormat('yyyy-MM-dd').format(day);
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedDate = day),
                child: Container(
                  margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      Text(
                        index == 0 ? 'Today' : DateFormat('E').format(day),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: isSelected ? Colors.white70 : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('d').format(day),
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 24),
        Text('Select Convenient Time Slot', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ..._timeSlots.map((slot) {
          final isSelected = _selectedTimeSlot == slot;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.borderLight,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: ListTile(
              dense: true,
              onTap: () => setState(() => _selectedTimeSlot = slot),
              leading: Icon(
                Icons.access_time,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 20,
              ),
              title: Text(
                slot,
                style: GoogleFonts.inter(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primary, size: 20) : null,
            ),
          );
        }),
      ],
    );
  }

  List<String> _getCitiesForDistrict(String district) {
    switch (district) {
      case 'Khordha':
        return ['Bhubaneswar', 'Jatni', 'Khordha Town'];
      case 'Cuttack':
        return ['Cuttack', 'Choudwar', 'Banki'];
      case 'Puri':
        return ['Puri', 'Konark', 'Pipili', 'Brahmagiri'];
      case 'Sundargarh':
        return ['Rourkela', 'Panposh', 'Sundargarh Town'];
      case 'Ganjam':
        return ['Berhampur', 'Chhatrapur', 'Gopalpur'];
      case 'Sambalpur':
        return ['Sambalpur', 'Burla', 'Hirakud'];
      case 'Balasore':
        return ['Balasore', 'Remuna', 'Soro'];
      default:
        return ['Bhubaneswar'];
    }
  }

  Widget _buildStep3Address() {
    final availableCities = _getCitiesForDistrict(_selectedDistrict);
    if (!availableCities.contains(_selectedCity)) {
      _selectedCity = availableCities.first;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Service Location & Details', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        // Active Cluster Banner
        Consumer<LocationProvider>(
          builder: (context, locProv, _) {
            final loc = locProv.selectedLocation;
            final isGps = locProv.isUsingGps;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isGps ? const Color(0xFFF0FDF4) : const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isGps ? const Color(0xFF86EFAC) : const Color(0xFFBAE6FD),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isGps ? const Color(0xFF059669) : AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isGps ? Icons.gps_fixed_rounded : Icons.location_on_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                loc.name,
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13.5),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isGps) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'GPS',
                                  style: GoogleFonts.inter(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF15803D),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          '${loc.city}, ${loc.district} • PIN ${loc.pincode} • ${loc.rateMultiplierText}',
                          style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      await LocationSelectionSheet.show(context);
                      final newLoc = locProv.selectedLocation;
                      setState(() {
                        if (_districts.contains(newLoc.district)) {
                          _selectedDistrict = newLoc.district;
                        }
                        final cities = _getCitiesForDistrict(_selectedDistrict);
                        _selectedCity = cities.contains(newLoc.city) ? newLoc.city : cities.first;
                        _pincodeController.text = newLoc.pincode;
                        _addressController.text = '${newLoc.name}, Near Landmark';
                      });
                    },
                    icon: const Icon(Icons.edit_location_alt_rounded, size: 14),
                    label: const Text('Change', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        ),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _selectedDistrict,
                  decoration: const InputDecoration(labelText: 'District'),
                  items: _districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedDistrict = val;
                        final cities = _getCitiesForDistrict(val);
                        _selectedCity = cities.first;
                      });
                    }
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCity,
                  decoration: const InputDecoration(labelText: 'City / Municipality'),
                  items: availableCities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCity = val);
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<int>(
                  initialValue: _squadSize,
                  decoration: const InputDecoration(labelText: 'Artisan Deployment Squad'),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('1 Master Artisan (Standard)')),
                    DropdownMenuItem(value: 2, child: Text('2 Artisans (Heavy / Fast Turnaround)')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _squadSize = val);
                  },
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _addressController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Complete Street Address / House No.',
                    hintText: 'Plot No, Landmark, Sector',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _pincodeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Pincode',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Specific Instructions (Optional)',
                    hintText: 'e.g. Please bring ladder / extra wire',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep4Review() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Review & Tariff Transparency', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        // Service Summary Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedService?['name'] ?? '',
                style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Scheduled for: ${DateFormat('EEE, d MMM').format(_selectedDate)} at $_selectedTimeSlot',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
              ),
              Text(
                'Address: ${_addressController.text.trim()}, $_selectedDistrict',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Tariff Transparency Card (Unique to Prithvi Fix cooperative model)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, AppColors.primary.withAlpha(15)],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withAlpha(60)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.shield_outlined, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'FAIR TARIFF FORMULA (NO MIDDLEMAN)',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _TariffRow(label: 'Direct Worker Wage (93%)', val: '₹${_workerWage.toStringAsFixed(1)}', isHighlight: true),
              const SizedBox(height: 6),
              _TariffRow(label: 'Worker Welfare & ESIC/EPFO (5%)', val: '₹${_welfareFund.toStringAsFixed(1)}'),
              const SizedBox(height: 6),
              _TariffRow(label: 'Cooperative Tech Platform (2%)', val: '₹${_platformFee.toStringAsFixed(1)}'),
              if (_isEmergency) ...[
                const SizedBox(height: 6),
                _TariffRow(label: 'Emergency Response Standby', val: '₹150.0'),
              ],
              const Divider(height: 18, color: AppColors.borderLight),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Payable',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    '₹${_totalPrice.toInt()}',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Payment Method Choice
        Text('Payment Preference', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => setState(() => _paymentMethod = 'CASH_ON_SERVICE'),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _paymentMethod == 'CASH_ON_SERVICE' ? AppColors.primary : AppColors.borderLight,
                width: _paymentMethod == 'CASH_ON_SERVICE' ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.payments_outlined, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pay After Service via UPI / Cash',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        'Pay only when satisfied. 30-day rework guarantee included.',
                        style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _paymentMethod == 'CASH_ON_SERVICE' ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: _paymentMethod == 'CASH_ON_SERVICE' ? AppColors.primary : AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => setState(() => _paymentMethod = 'ONLINE_UPI_ESCROW'),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _paymentMethod == 'ONLINE_UPI_ESCROW' ? AppColors.primary : AppColors.borderLight,
                width: _paymentMethod == 'ONLINE_UPI_ESCROW' ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cooperative Escrow UPI (Pre-Auth)',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        'Held safely in Cooperative Escrow; disbursed only upon Completion OTP.',
                        style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _paymentMethod == 'ONLINE_UPI_ESCROW' ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: _paymentMethod == 'ONLINE_UPI_ESCROW' ? AppColors.primary : AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StepBadge extends StatelessWidget {
  final int num;
  final String label;
  final bool isActive;
  final bool isDone;

  const _StepBadge({
    required this.num,
    required this.label,
    required this.isActive,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: isDone ? AppColors.primary : (isActive ? AppColors.primaryLight : AppColors.borderLight),
          child: Text(
            isDone ? '✓' : '$num',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDone || isActive ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _StepDivider extends StatelessWidget {
  final bool isDone;
  const _StepDivider({required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 12),
        color: isDone ? AppColors.primary : AppColors.borderLight,
      ),
    );
  }
}

class _TariffRow extends StatelessWidget {
  final String label;
  final String val;
  final bool isHighlight;

  const _TariffRow({
    required this.label,
    required this.val,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
            color: isHighlight ? AppColors.primaryDark : AppColors.textSecondary,
          ),
        ),
        Text(
          val,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
            color: isHighlight ? AppColors.primaryDark : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
