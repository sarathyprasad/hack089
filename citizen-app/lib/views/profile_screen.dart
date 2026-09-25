import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController(text: 'Ramesh Chandra Mohapatra');
  final _phoneController = TextEditingController(text: '+91 94370 12345');
  final _emailController = TextEditingController(text: 'ramesh.mohapatra@odisha.gov.in');
  String _selectedDistrict = 'Khordha';
  String _preferredLanguage = 'Odia (ଓଡ଼ିଆ)';
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final u = auth.user;
      if (u != null && mounted) {
        if (u.name.isNotEmpty) _nameController.text = u.name;
        if (u.phone != null && u.phone!.isNotEmpty) _phoneController.text = u.phone!;
        if (u.email.isNotEmpty) _emailController.text = u.email;
        if (u.district != null && ['Khordha', 'Cuttack', 'Puri'].contains(u.district)) {
          _selectedDistrict = u.district!;
        }
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final name = _nameController.text;
    final phone = _phoneController.text;

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
            'My Citizen Profile',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          actions: [
            IconButton(
              icon: Icon(_isEditing ? Icons.check : Icons.edit_outlined),
              tooltip: _isEditing ? 'Save Changes' : 'Edit Profile',
              onPressed: () {
                setState(() => _isEditing = !_isEditing);
                if (!_isEditing) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppColors.primary,
                      content: Text('Profile updated successfully!'),
                    ),
                  );
                }
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Avatar & Member Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 39,
                          backgroundColor: AppColors.primaryLight.withValues(alpha: 0.3),
                          child: Text(
                            name.isNotEmpty ? name[0] : 'R',
                            style: GoogleFonts.outfit(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.verified, color: Colors.black, size: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    phone,
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.workspace_premium, color: AppColors.accent, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'VERIFIED CITIZEN MEMBER',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Cooperative Impact Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildImpactCard(
                    title: 'Services Taken',
                    value: '14',
                    subtitle: '100% Warrantied',
                    icon: Icons.task_alt,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildImpactCard(
                    title: 'Direct Savings',
                    value: '₹2,840',
                    subtitle: 'vs Private Portals',
                    icon: Icons.savings_outlined,
                    color: const Color(0xFF0D9488),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildImpactCard(
                    title: 'Welfare Contributed',
                    value: '₹410',
                    subtitle: 'To Shramik Nidhi',
                    icon: Icons.favorite_border,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Personal Information Fields
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PERSONAL INFORMATION',
                    style: GoogleFonts.outfit(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _nameController,
                    enabled: _isEditing,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneController,
                    enabled: _isEditing,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Mobile Phone',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _emailController,
                    enabled: _isEditing,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.mail_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedDistrict,
                    decoration: const InputDecoration(
                      labelText: 'Home District',
                      prefixIcon: Icon(Icons.location_city_outlined),
                    ),
                    items: ['Khordha', 'Cuttack', 'Puri'].map((d) {
                      return DropdownMenuItem(value: d, child: Text(d));
                    }).toList(),
                    onChanged: _isEditing ? (val) => setState(() => _selectedDistrict = val!) : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _preferredLanguage,
                    decoration: const InputDecoration(
                      labelText: 'Preferred App Language',
                      prefixIcon: Icon(Icons.language_outlined),
                    ),
                    items: ['Odia (ଓଡ଼ିଆ)', 'English (Standard)', 'Hindi (हिन्दी)'].map((l) {
                      return DropdownMenuItem(value: l, child: Text(l));
                    }).toList(),
                    onChanged: _isEditing ? (val) => setState(() => _preferredLanguage = val!) : null,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Quick Navigation Shortcuts
            _buildProfileNavTile(
              icon: Icons.location_on_outlined,
              title: 'Saved Addresses & Profiles',
              subtitle: 'Manage home, office, and family locations',
              onTap: () => context.go('/addresses'),
            ),
            const SizedBox(height: 10),
            _buildProfileNavTile(
              icon: Icons.card_giftcard_outlined,
              title: 'Coupons, Dividends & Rewards',
              subtitle: 'Redeem Prithvi Coins & seasonal discount vouchers',
              onTap: () => context.go('/rewards'),
            ),
            const SizedBox(height: 10),
            _buildProfileNavTile(
              icon: Icons.help_outline,
              title: 'Citizen Support & 24/7 Helpline',
              subtitle: 'FAQs, ticket status, and consumer rights',
              onTap: () => context.go('/help'),
            ),

            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await auth.logout();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logged out successfully')),
                    );
                    context.go('/login');
                  }
                },
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: const Text('Log Out from Prithvi Fix'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildImpactCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle,
            style: GoogleFonts.inter(fontSize: 9, color: AppColors.textMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileNavTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        title: Text(
          title,
          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
      ),
    );
  }
}
