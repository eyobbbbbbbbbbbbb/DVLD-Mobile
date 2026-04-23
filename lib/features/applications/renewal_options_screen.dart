import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/user_session.dart';
import '../license/services/license_service.dart';
import '../license/digital_license_screen.dart';
import '../payment/payment_screen.dart';

class RenewalOptionsScreen extends StatefulWidget {
  const RenewalOptionsScreen({super.key});

  @override
  State<RenewalOptionsScreen> createState() => _RenewalOptionsScreenState();
}

class _RenewalOptionsScreenState extends State<RenewalOptionsScreen> {
  bool _loading = true;
  Map<String, dynamic>? _activeLicense;

  @override
  void initState() {
    super.initState();
    _loadActiveLicense();
  }

  Future<void> _loadActiveLicense() async {
    final licenses = await LicenseService.getPersonLicenses(UserSession.instance.personId);
    setState(() {
      _activeLicense = licenses.where((l) => l['isActive']).firstOrNull;
      _loading = false;
    });
  }

  Future<void> _handleAction(String type, {int? replacementReason}) async {
    if (_activeLicense == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(type == 'renew' ? 'Renew License' : 'Replace License', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('Are you sure you want to proceed with this request? Standard fees will apply.', style: GoogleFonts.poppins()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: GoogleFonts.poppins(color: AppColors.textLight))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Proceed', style: GoogleFonts.poppins(color: AppColors.primary, fontWeight: FontWeight.w600))),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _loading = true);
    
    Map<String, dynamic> result;
    if (type == 'renew') {
      result = await LicenseService.renewLicense(
        licenseId: _activeLicense!['licenseID'],
        notes: 'Renewed via Mobile App',
        userId: UserSession.instance.userId,
      );
    } else {
      result = await LicenseService.replaceLicense(
        licenseId: _activeLicense!['licenseID'],
        reason: replacementReason!,
        notes: 'Replaced via Mobile App',
        userId: UserSession.instance.userId,
      );
    }

    if (mounted) {
      setState(() => _loading = false);
      if (result['success']) {
        final data = result['data'];
        final serviceName = type == 'renew' 
            ? 'License Renewal' 
            : (replacementReason == 3 ? 'Replace (Damaged)' : 'Replace (Lost)');
            
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request Processed Successfully!'), backgroundColor: AppColors.success),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => PaymentReceiptScreen(
            receiptData: {
              'applicationId': 'APP-${data['applicationID']}',
              'service': serviceName,
              'totalAmount': 'ETB ${data['paidFees']}.00',
              'applicant': UserSession.instance.fullName,
            },
          )),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message']), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'License Renewal/Replacement',
          style: GoogleFonts.poppins(
              fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_activeLicense == null) ...[
              const Spacer(),
              Center(
                child: Column(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 64, color: AppColors.textLight.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    Text('No active license found to renew or replace.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const Spacer(flex: 2),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.accentLight,
                      child: Icon(Icons.credit_card_rounded, color: AppColors.primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Target License', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                          Text('${_activeLicense!['className']} (LIC# ${_activeLicense!['licenseID']})', 
                               style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Select Service',
                  style: GoogleFonts.poppins(
                      fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              _OptionCard(
                title: 'Renew License',
                subtitle: 'Renew your expired or soon-to-expire license.',
                icon: Icons.history_rounded,
                color: const Color(0xFF00C853),
                onTap: () => _handleAction('renew'),
              ),
              const SizedBox(height: 14),
              _OptionCard(
                title: 'Replace for Damaged',
                subtitle: 'Apply for a replacement if your card is damaged.',
                icon: Icons.broken_image_outlined,
                color: const Color(0xFFE53935),
                onTap: () => _handleAction('replace', replacementReason: 3),
              ),
              const SizedBox(height: 14),
              _OptionCard(
                title: 'Replace for Lost',
                subtitle: 'Apply for a replacement if your card is lost.',
                icon: Icons.find_replace_rounded,
                color: const Color(0xFFFF6D00),
                onTap: () => _handleAction('replace', replacementReason: 4),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _OptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: AppColors.textLight.withOpacity(0.5), size: 16),
          ],
        ),
      ),
    );
  }
}
