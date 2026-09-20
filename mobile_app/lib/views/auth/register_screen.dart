import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gov_app_bar.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedRole = 'CUSTOMER';
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  final _pincodeController = TextEditingController();
  
  // Worker-specific
  String _selectedTrade = 'Electrical';
  final _experienceController = TextEditingController(text: '3');
  final _itiCertController = TextEditingController(text: 'SKILL-OD-2024-8842');
  String _selectedDistrict = 'Khordha';

  final List<String> _districts = ['Khordha', 'Cuttack', 'Puri', 'Ganjam', 'Sundargarh'];
  final List<String> _trades = [
    'Electrical',
    'Plumbing',
    'Carpentry',
    'Painting',
    'Cleaning',
    'Gardening',
    'Caregiving',
    'Driving',
    'Appliance Repair',
    'Domestic',
    'IT/CCTV',
    'Emergency',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _pincodeController.dispose();
    _experienceController.dispose();
    _itiCertController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final payload = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'password': _passwordController.text.trim(),
      'role': _selectedRole,
      'district': _selectedDistrict,
      'city': _selectedDistrict == 'Khordha' ? 'Bhubaneswar' : _selectedDistrict,
      'address': _addressController.text.trim(),
      'pincode': _pincodeController.text.trim(),
      if (_selectedRole == 'WORKER') ...{
        'primaryTrade': _selectedTrade,
        'experienceYears': int.tryParse(_experienceController.text.trim()) ?? 1,
        'skills': [_selectedTrade, 'Standard Diagnostic', 'Safety Compliance'],
        'itiCertificateNo': _itiCertController.text.trim(),
        'cooperativeId': 1,
      }
    };

    final success = await auth.register(payload);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.accentGreen,
          content: Text('Registration successful! Access granted.'),
        ),
      );
      if (_selectedRole == 'WORKER') {
        context.go('/worker/dashboard');
      } else {
        context.go('/customer/bookings');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.emergencyRed,
          content: Text(auth.errorMessage ?? 'Registration failed. Please check inputs.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.backgroundLight,
      appBar: const GovAppBar(title: 'Statutory Registration'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enroll in Odisha Labour Cooperative Federation',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.primaryNavy),
              ),
              const SizedBox(height: 4),
              Text(
                'Direct member registration under Odisha Cooperative Societies Act.',
                style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
              ),
              const SizedBox(height: 16),

              // Role Selector Chips
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: Center(child: Text(
                        '👤 Citizen / Customer',
                        style: TextStyle(
                          color: _selectedRole == 'CUSTOMER'
                              ? (isDark ? Colors.black : Colors.white)
                              : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                        ),
                      )),
                      selected: _selectedRole == 'CUSTOMER',
                      selectedColor: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
                      backgroundColor: isDark ? AppColors.darkCard : null,
                      side: _selectedRole == 'CUSTOMER' ? null : BorderSide(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
                      onSelected: (val) => setState(() => _selectedRole = 'CUSTOMER'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: Center(child: Text(
                        '👷 Skilled Artisan',
                        style: TextStyle(
                          color: _selectedRole == 'WORKER'
                              ? (isDark ? Colors.black : Colors.white)
                              : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                        ),
                      )),
                      selected: _selectedRole == 'WORKER',
                      selectedColor: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
                      backgroundColor: isDark ? AppColors.darkCard : null,
                      side: _selectedRole == 'WORKER' ? null : BorderSide(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
                      onSelected: (val) => setState(() => _selectedRole = 'WORKER'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Card(
                color: isDark ? AppColors.darkCard : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
                        decoration: const InputDecoration(labelText: 'Full Legal Name *'),
                        validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
                        decoration: const InputDecoration(labelText: 'Email Address *'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v?.contains('@') != true ? 'Valid email required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
                        decoration: const InputDecoration(labelText: 'Mobile Number (+91) *'),
                        keyboardType: TextInputType.phone,
                        validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
                        decoration: const InputDecoration(labelText: 'Password (min 6 chars) *'),
                        obscureText: true,
                        validator: (v) => (v?.length ?? 0) < 6 ? 'Min 6 characters' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedDistrict,
                        dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                        style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
                        decoration: const InputDecoration(labelText: 'Registered District *'),
                        items: _districts.map((d) => DropdownMenuItem(value: d, child: Text(d, style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary)))).toList(),
                        onChanged: (v) => setState(() => _selectedDistrict = v ?? 'Khordha'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _addressController,
                        style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
                        decoration: const InputDecoration(labelText: 'Residential Street / Locality *'),
                        validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _pincodeController,
                        style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
                        decoration: const InputDecoration(labelText: 'Postal Pincode *'),
                        keyboardType: TextInputType.number,
                        validator: (v) => v?.trim().length != 6 ? '6-digit pincode' : null,
                      ),
                    ],
                  ),
                ),
              ),

              if (_selectedRole == 'WORKER') ...[
                const SizedBox(height: 16),
                Text(
                  'Artisan Trade & Statutory Accreditation',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.primaryNavy),
                ),
                const SizedBox(height: 8),
                Card(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: _selectedTrade,
                          dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                          style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
                          decoration: const InputDecoration(labelText: 'Primary Trade Specialization *'),
                          items: _trades.map((t) => DropdownMenuItem(value: t, child: Text(t, style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary)))).toList(),
                          onChanged: (v) => setState(() => _selectedTrade = v ?? 'Electrical'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _experienceController,
                          style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
                          decoration: const InputDecoration(labelText: 'Years of Experience *'),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _itiCertController,
                          style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
                          decoration: const InputDecoration(
                            labelText: 'Trade Skill Certificate No.',
                            helperText: 'Enables verified badge and dispatch priority',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: auth.isLoading ? null : _handleRegister,
                child: auth.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Complete Statutory Registration'),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(
                    'Already registered? Sign In here',
                    style: TextStyle(color: isDark ? AppColors.secondarySaffron : null),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
