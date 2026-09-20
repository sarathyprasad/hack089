import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gov_app_bar.dart';
import '../../core/widgets/gov_loading_indicator.dart';
import '../../core/widgets/tariff_breakdown_card.dart';
import '../../core/widgets/status_badge.dart';
import '../../models/service_model.dart';
import '../../models/worker_model.dart';
import '../../providers/service_provider.dart';
import '../../providers/worker_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../shared/guest_auth_prompt_dialog.dart';

class BookServiceScreen extends StatefulWidget {
  final int? initialServiceId;
  final int? initialWorkerId;

  const BookServiceScreen({super.key, this.initialServiceId, this.initialWorkerId});

  @override
  State<BookServiceScreen> createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  int _currentStep = 0;

  // Step 1: Service
  ServiceModel? _selectedService;

  // Step 2: Location
  String _selectedDistrict = 'Khordha';
  String _selectedCity = 'Bhubaneswar';
  final _addressController = TextEditingController(text: 'Patia, Plot 42, Near KIIT Campus');
  final _pincodeController = TextEditingController(text: '751024');

  // Step 3: Schedule & Emergency
  DateTime _selectedDate = DateTime.now();
  String _selectedTimeSlot = '10:00 AM - 12:00 PM';
  bool _isEmergency = false;
  int _squadSize = 1;
  final _notesController = TextEditingController(text: 'Main switchboard tripping repeatedly');

  // Step 4: Worker Selection & Match
  WorkerModel? _selectedWorker;
  List<WorkerModel> _recommendedWorkers = [];

  final List<String> _districts = ['Khordha', 'Cuttack', 'Puri'];
  final List<String> _timeSlots = [
    '08:00 AM - 10:00 AM',
    '10:00 AM - 12:00 PM',
    '02:00 PM - 04:00 PM',
    '04:00 PM - 06:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final sProv = context.read<ServiceProvider>();
      await sProv.fetchServices();
      if (widget.initialServiceId != null) {
        final match = sProv.services.where((s) => s.id == widget.initialServiceId).firstOrNull;
        if (match != null) {
          setState(() => _selectedService = match);
        }
      } else if (sProv.services.isNotEmpty) {
        setState(() => _selectedService = sProv.services.first);
      }
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _pincodeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchSmartRecommendations() async {
    if (_selectedService == null) return;
    final wProv = context.read<WorkerProvider>();
    final workers = await wProv.recommendWorkers(
      serviceId: _selectedService!.id,
      district: _selectedDistrict,
      city: _selectedCity,
      isEmergency: _isEmergency,
    );
    setState(() {
      _recommendedWorkers = workers;
      if (workers.isNotEmpty) {
        _selectedWorker = workers.first;
      }
    });
  }

  Future<void> _confirmBooking() async {
    if (_selectedService == null) return;

    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated || auth.isGuest) {
      GuestAuthPromptDialog.show(
        context,
        actionDescription: 'place and confirm this service order',
      );
      return;
    }

    final bookingProv = context.read<BookingProvider>();
    final data = {
      'serviceId': _selectedService!.id,
      'workerId': _selectedWorker?.id ?? 1,
      'scheduledDate': _selectedDate.toString().split(' ')[0],
      'scheduledTime': _isEmergency ? 'Immediate Dispatch (<15m)' : _selectedTimeSlot,
      'locationAddress': _addressController.text.trim(),
      'locationCity': _selectedCity,
      'locationDistrict': _selectedDistrict,
      'locationPincode': _pincodeController.text.trim(),
      'notes': _notesController.text.trim(),
      'isEmergency': _isEmergency,
      'squad_size': _squadSize,
      'squadSize': _squadSize,
    };

    final newBooking = await bookingProv.createBooking(data);
    if (!mounted) return;

    if (newBooking != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.accentGreen,
          content: Text('Booking ${newBooking.bookingCode} confirmed successfully!'),
        ),
      );
      context.go('/customer/bookings/${newBooking.id}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.emergencyRed,
          content: Text(bookingProv.errorMessage ?? 'Booking could not be placed.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final sProv = context.watch<ServiceProvider>();
    final bProv = context.watch<BookingProvider>();

    return Scaffold(
      appBar: const GovAppBar(title: 'Service Booking Wizard'),
      body: Column(
        children: [
          if (auth.isGuest)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkAmberBg.withValues(alpha: 0.6) : const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isDark ? AppColors.darkAmberFg.withValues(alpha: 0.5) : const Color(0xFFF59E0B)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: isDark ? AppColors.darkAmberFg : const Color(0xFFB45309), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Guest Mode: You are exploring the booking flow. Sign in is required to place an order.',
                      style: TextStyle(
                        fontSize: 12, 
                        fontWeight: FontWeight.w600, 
                        color: isDark ? AppColors.darkAmberFg : const Color(0xFF92400E),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Sign In', 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: isDark ? AppColors.darkAmberFg : const Color(0xFF92400E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Stepper(
              type: StepperType.horizontal,
              currentStep: _currentStep,
              onStepTapped: (step) => setState(() => _currentStep = step),
              onStepContinue: () {
                if (_currentStep == 0 && _selectedService == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a service')),
                  );
                  return;
                }
                if (_currentStep == 2) {
                  _fetchSmartRecommendations();
                }
                if (_currentStep < 3) {
                  setState(() => _currentStep++);
                } else {
                  _confirmBooking();
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep--);
                }
              },
              controlsBuilder: (context, details) {
                final isLast = _currentStep == 3;
                final buttonText = isLast
                    ? (auth.isGuest ? 'Sign In to Confirm Order' : 'Confirm Service Order')
                    : 'Continue →';
                return Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: bProv.isLoading ? null : details.onStepContinue,
                          child: bProv.isLoading
                              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text(buttonText),
                        ),
                      ),
                      if (_currentStep > 0) ...[
                        const SizedBox(width: 10),
                        OutlinedButton(
                          onPressed: details.onStepCancel,
                          child: const Text('Back'),
                        ),
                      ],
                    ],
                  ),
                );
              },
        steps: [
          // Step 1: Select Service
          Step(
            title: const Text('Service', style: TextStyle(fontSize: 11)),
            isActive: _currentStep >= 0,
            state: _selectedService != null ? StepState.complete : StepState.indexed,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step 1: Choose Trade Service', 
                  style: TextStyle(
                    fontSize: 15, 
                    fontWeight: FontWeight.bold, 
                    color: isDark ? AppColors.darkTextPrimary : AppColors.primaryNavy,
                  ),
                ),
                const SizedBox(height: 8),
                if (sProv.isLoading)
                  const GovLoadingIndicator.card(
                    title: 'Loading Regulated Services...',
                    subtitle: 'Fetching statutory rates & trade categories',
                    size: 40,
                  )
                else
                  DropdownButtonFormField<int>(
                    initialValue: _selectedService?.id,
                    decoration: const InputDecoration(labelText: 'Select Regulated Service'),
                    items: sProv.services.map((s) => DropdownMenuItem(value: s.id, child: Text('${s.name} (₹${s.basePrice.toStringAsFixed(0)})', style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (id) {
                      final s = sProv.services.where((item) => item.id == id).firstOrNull;
                      setState(() => _selectedService = s);
                    },
                  ),
                if (_selectedService != null) ...[
                  const SizedBox(height: 12),
                  TariffBreakdownCard(totalAmount: _selectedService!.basePrice),
                ],
              ],
            ),
          ),

          // Step 2: Location
          Step(
            title: const Text('Location', style: TextStyle(fontSize: 11)),
            isActive: _currentStep >= 1,
            state: _addressController.text.isNotEmpty ? StepState.complete : StepState.indexed,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step 2: Service Location', 
                  style: TextStyle(
                    fontSize: 15, 
                    fontWeight: FontWeight.bold, 
                    color: isDark ? AppColors.darkTextPrimary : AppColors.primaryNavy,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedDistrict,
                  decoration: const InputDecoration(labelText: 'District Federation *'),
                  items: _districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: (v) => setState(() {
                    _selectedDistrict = v ?? 'Khordha';
                    _selectedCity = _selectedDistrict == 'Khordha' ? 'Bhubaneswar' : _selectedDistrict;
                  }),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Street Address & Landmark *',
                    prefixIcon: Icon(
                      Icons.location_on_outlined, 
                      color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _pincodeController,
                  decoration: const InputDecoration(labelText: 'Postal Pincode *'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),

          // Step 3: Scheduling & Emergency
          Step(
            title: const Text('Slot', style: TextStyle(fontSize: 11)),
            isActive: _currentStep >= 2,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step 3: Dispatch & Scheduling', 
                  style: TextStyle(
                    fontSize: 15, 
                    fontWeight: FontWeight.bold, 
                    color: isDark ? AppColors.darkTextPrimary : AppColors.primaryNavy,
                  ),
                ),
                const SizedBox(height: 12),

                // 24/7 Priority Emergency Toggle Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isEmergency 
                        ? (isDark ? AppColors.emergencyRed.withValues(alpha: 0.18) : AppColors.redLight) 
                        : (isDark ? AppColors.darkCard : const Color(0xFFF8FAFC)),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isEmergency 
                          ? AppColors.emergencyRed 
                          : (isDark ? AppColors.darkBorder : AppColors.borderLight), 
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bolt, color: AppColors.emergencyRed, size: 28),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '24/7 Priority Emergency Squad',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.emergencyRed),
                            ),
                            Text(
                              'Dispatched in <15 minutes. Government standardized rate (Zero surge pricing).',
                              style: TextStyle(
                                fontSize: 10, 
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isEmergency,
                        activeThumbColor: AppColors.emergencyRed,
                        onChanged: (val) => setState(() => _isEmergency = val),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),
                if (!_isEmergency) ...[
                  ListTile(
                    tileColor: isDark ? AppColors.darkCard : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), 
                      side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
                    ),
                    leading: Icon(
                      Icons.calendar_today, 
                      color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy, 
                      size: 20,
                    ),
                    title: Text(
                      'Date: ${_selectedDate.toString().split(' ')[0]}', 
                      style: TextStyle(
                        fontSize: 13, 
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    trailing: Text(
                      'Change', 
                      style: TextStyle(
                        color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy, 
                        fontWeight: FontWeight.bold, 
                        fontSize: 12,
                      ),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (picked != null) setState(() => _selectedDate = picked);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedTimeSlot,
                    decoration: const InputDecoration(labelText: 'Preferred Time Slot'),
                    items: _timeSlots.map((slot) => DropdownMenuItem(value: slot, child: Text(slot, style: const TextStyle(fontSize: 12)))).toList(),
                    onChanged: (v) => setState(() => _selectedTimeSlot = v ?? _selectedTimeSlot),
                  ),
                  const SizedBox(height: 12),
                ],

                // Squad Size Selector
                Text(
                  'Artisan Squad Size (Headcount):', 
                  style: TextStyle(
                    fontSize: 12, 
                    fontWeight: FontWeight.bold, 
                    color: isDark ? AppColors.darkTextPrimary : AppColors.primaryNavy,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    for (final size in [1, 2, 3, 4])
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: size < 4 ? 6 : 0),
                          child: InkWell(
                            onTap: () => setState(() => _squadSize = size),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: _squadSize == size
                                    ? (isDark ? AppColors.primaryNavy : AppColors.primaryNavy)
                                    : (isDark ? AppColors.darkCard : const Color(0xFFF1F5F9)),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _squadSize == size
                                      ? (isDark ? AppColors.secondarySaffron : AppColors.primaryNavy)
                                      : (isDark ? AppColors.darkBorder : AppColors.borderLight),
                                  width: _squadSize == size ? 1.5 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    size == 1 ? 'Solo' : '$size Crew',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: _squadSize == size ? Colors.white : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                                    ),
                                  ),
                                  Text(
                                    size == 1 ? '1 Worker' : '$size Workers',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: _squadSize == size ? AppColors.secondarySaffron : (isDark ? AppColors.darkTextSecondary : AppColors.textMuted),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'Repair Problem Description / Notes'),
                  maxLines: 2,
                ),
              ],
            ),
          ),

          // Step 4: Smart Matching & Tariff Review
          Step(
            title: const Text('Match', style: TextStyle(fontSize: 11)),
            isActive: _currentStep >= 3,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step 4: Smart Matching & Review', 
                  style: TextStyle(
                    fontSize: 15, 
                    fontWeight: FontWeight.bold, 
                    color: isDark ? AppColors.darkTextPrimary : AppColors.primaryNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Algorithmic composite score: 50% Skill + 30% Proximity + 20% Availability',
                  style: TextStyle(
                    fontSize: 11, 
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 12),

                if (_recommendedWorkers.isNotEmpty) ...[
                  Text(
                    'Top Recommended Verified Artisan:', 
                    style: TextStyle(
                      fontSize: 12, 
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Card(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: isDark 
                                ? AppColors.secondarySaffron.withValues(alpha: 0.2) 
                                : AppColors.primaryNavy.withValues(alpha: 0.1),
                            child: Icon(
                              Icons.engineering, 
                              color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      _recommendedWorkers.first.name, 
                                      style: TextStyle(
                                        fontSize: 14, 
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const StatusBadge(status: 'VERIFIED'),
                                  ],
                                ),
                                Text(
                                  '${_recommendedWorkers.first.primaryTrade} • ${_recommendedWorkers.first.experienceYears} Yrs Exp',
                                  style: TextStyle(
                                    fontSize: 11, 
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${(_recommendedWorkers.first.matchScore ?? 94).toStringAsFixed(0)}% Match',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accentGreen),
                              ),
                              Text(
                                '${(_recommendedWorkers.first.distanceKm ?? 1.8).toStringAsFixed(1)} km away',
                                style: TextStyle(
                                  fontSize: 10, 
                                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 12),
                if (_selectedService != null)
                  TariffBreakdownCard(totalAmount: _selectedService!.basePrice * _squadSize),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFBBF7D0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shield_outlined, size: 16, color: AppColors.accentGreen),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Doorstep Transit Protection Guarantee: In case of post-dispatch cancellation, ₹50 transit fee is compensated directly to the dispatched artisan.',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? AppColors.darkTextSecondary : const Color(0xFF166534),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ],
),
    );
  }
}
