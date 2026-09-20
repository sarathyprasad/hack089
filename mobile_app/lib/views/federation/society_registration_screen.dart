import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gov_app_bar.dart';
import '../../providers/society_provider.dart';

class SocietyRegistrationScreen extends StatefulWidget {
  const SocietyRegistrationScreen({super.key});

  @override
  State<SocietyRegistrationScreen> createState() => _SocietyRegistrationScreenState();
}

class _SocietyRegistrationScreenState extends State<SocietyRegistrationScreen> {
  int _currentStep = 0;

  // Step 1: General Info
  final _nameController = TextEditingController(text: 'Khordha Artisan Labour Cooperative Society');
  String _district = 'Khordha';
  final _blockController = TextEditingController(text: 'Bhubaneswar Sadar');
  final _contactPersonController = TextEditingController(text: 'Bikram Keshari Jena');
  final _contactPhoneController = TextEditingController(text: '9876543210');

  // Step 2: Promoter Committee
  int _membersCount = 12;

  // Step 3: Capital & Bylaws
  final _capitalController = TextEditingController(text: '150000');
  final _shareValueController = TextEditingController(text: '500');

  @override
  void dispose() {
    _nameController.dispose();
    _blockController.dispose();
    _contactPersonController.dispose();
    _contactPhoneController.dispose();
    _capitalController.dispose();
    _shareValueController.dispose();
    super.dispose();
  }

  Future<void> _submitApplication(bool isDark) async {
    final sProv = context.read<SocietyProvider>();
    final data = {
      'name': _nameController.text.trim(),
      'district': _district,
      'blockPanchayat': _blockController.text.trim(),
      'contactPerson': _contactPersonController.text.trim(),
      'contactPhone': _contactPhoneController.text.trim(),
      'membersCount': _membersCount,
      'authorizedCapital': double.tryParse(_capitalController.text.trim()) ?? 100000,
      'shareValue': double.tryParse(_shareValueController.text.trim()) ?? 500,
    };

    final trackingId = await sProv.registerSociety(data);
    if (!mounted) return;

    if (trackingId != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Text(
            'Application Submitted Successfully', 
            style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold, 
              color: isDark ? AppColors.darkTextPrimary : AppColors.primaryNavy,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your official statutory cooperative tracking ID is:'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkInfoBg.withValues(alpha: 0.4) : const Color(0xFFEFF6FF), 
                  borderRadius: BorderRadius.circular(8),
                  border: isDark ? Border.all(color: AppColors.darkInfoFg.withValues(alpha: 0.3)) : null,
                ),
                child: Text(
                  trackingId,
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.w900, 
                    color: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy, 
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Submitted to the Assistant Registrar of Cooperative Societies (ARCS) for scrutiny under Section 7 of the Odisha Cooperative Societies Act.',
                style: TextStyle(
                  fontSize: 11, 
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.go('/society/timeline?track=$trackingId');
              },
              child: const Text('Track Timeline Progress →'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sProv = context.watch<SocietyProvider>();

    return Scaffold(
      appBar: const GovAppBar(title: 'Register Cooperative Society'),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepTapped: (step) => setState(() => _currentStep = step),
        onStepContinue: () {
          if (_currentStep < 3) {
            setState(() => _currentStep++);
          } else {
            _submitApplication(isDark);
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) setState(() => _currentStep--);
        },
        controlsBuilder: (context, details) {
          final isLast = _currentStep == 3;
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: sProv.isLoading ? null : details.onStepContinue,
                  child: sProv.isLoading
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(isLast ? 'Submit to ARCS' : 'Next Step →'),
                ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: 10),
                  OutlinedButton(onPressed: details.onStepCancel, child: const Text('Back')),
                ],
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('General Information', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Name, district, and administrative block'),
            isActive: _currentStep >= 0,
            content: Column(
              children: [
                TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Proposed Society Legal Name *')),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: _district,
                  decoration: const InputDecoration(labelText: 'District Registration Circle *'),
                  items: ['Khordha', 'Cuttack', 'Puri'].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: (v) => setState(() => _district = v ?? 'Khordha'),
                ),
                const SizedBox(height: 10),
                TextField(controller: _blockController, decoration: const InputDecoration(labelText: 'Administrative Block / Municipality *')),
                const SizedBox(height: 10),
                TextField(controller: _contactPersonController, decoration: const InputDecoration(labelText: 'Chief Promoter Full Name *')),
                const SizedBox(height: 10),
                TextField(controller: _contactPhoneController, decoration: const InputDecoration(labelText: 'Promoter Mobile Number *'), keyboardType: TextInputType.phone),
              ],
            ),
          ),
          Step(
            title: const Text('Promoter Committee', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Minimum 10 verified artisan promoters required'),
            isActive: _currentStep >= 1,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Promoter Member Count:'),
                    Text('$_membersCount Members', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.accentGreen)),
                  ],
                ),
                Slider(
                  value: _membersCount.toDouble(),
                  min: 10,
                  max: 50,
                  divisions: 40,
                  label: '$_membersCount',
                  activeColor: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
                  onChanged: (v) => setState(() => _membersCount = v.round()),
                ),
                const Text(
                  '✓ Statutory requirement met: Section 6 requires minimum 10 founding artisans.',
                  style: TextStyle(fontSize: 11, color: AppColors.accentGreen, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Share Capital & By-laws', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Authorized share capital and face value'),
            isActive: _currentStep >= 2,
            content: Column(
              children: [
                TextField(controller: _capitalController, decoration: const InputDecoration(labelText: 'Authorized Share Capital (₹) *'), keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                TextField(controller: _shareValueController, decoration: const InputDecoration(labelText: 'Face Value per Share (₹) *'), keyboardType: TextInputType.number),
              ],
            ),
          ),
          Step(
            title: const Text('Statutory Dossier Review', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Confirm and generate official tracking code'),
            isActive: _currentStep >= 3,
            content: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCardAlt : const Color(0xFFF8FAFC), 
                borderRadius: BorderRadius.circular(8),
                border: isDark ? Border.all(color: AppColors.darkBorder) : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Application Ready for Submission', 
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 13, 
                      color: isDark ? AppColors.darkTextPrimary : AppColors.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '1. Model By-laws approved by Directorate of Cooperatives\n2. KYC copies of 12 promoters attached\n3. First general body formation resolution drafted', 
                    style: TextStyle(
                      fontSize: 12, 
                      height: 1.4,
                      color: isDark ? AppColors.darkTextSecondary : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
