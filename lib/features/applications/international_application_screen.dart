import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/user_session.dart';
import '../../core/widgets/app_button.dart';
import '../license/services/license_service.dart';
import '../license/services/international_license_service.dart';
import '../license/digital_international_license_screen.dart';
import '../applications/services/application_service.dart';
import 'package:intl/intl.dart';

class InternationalApplicationScreen extends StatefulWidget {
  const InternationalApplicationScreen({super.key});

  @override
  State<InternationalApplicationScreen> createState() => _InternationalApplicationScreenState();
}

class _InternationalApplicationScreenState extends State<InternationalApplicationScreen> {
  bool _loading = true;
  Map<String, dynamic>? _localLicense;
  double _applicationFee = 50.0;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _checkEligibility();
  }

  Future<void> _checkEligibility() async {
    final licenses = await LicenseService.getPersonLicenses(UserSession.instance.personId);
    final fee = await ApplicationService.getApplicationFee(6); // 6 = New International License
    
    setState(() {
      // Find an active Class 3 license
      try {
        _localLicense = licenses.firstWhere((l) => l['isActive'] == true && l['licenseClass'] == 3);
      } catch (_) {
        _localLicense = null;
      }
      _applicationFee = fee > 0 ? fee : 50.0;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('International License',
            style: GoogleFonts.poppins(
                fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusHeader(),
                  const SizedBox(height: 24),
                  if (_localLicense != null) _buildLicenseDetails(),
                  if (_localLicense != null) const SizedBox(height: 24),
                  _buildFeeCard(),
                  const SizedBox(height: 32),
                  _buildSubmitButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusHeader() {
    bool eligible = _localLicense != null;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: eligible ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: eligible ? AppColors.success.withOpacity(0.3) : AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            eligible ? Icons.check_circle_rounded : Icons.error_rounded,
            color: eligible ? AppColors.success : AppColors.error,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eligible ? 'Eligible for Application' : 'Not Eligible',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700, fontSize: 16, color: eligible ? AppColors.success : AppColors.error),
                ),
                Text(
                  eligible
                      ? 'We found an active Ordinary driving license.'
                      : 'You must have an active Class 3 (Ordinary) local license to apply.',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLicenseDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Local License Details',
            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            children: [
              _detailRow('License ID', '${_localLicense!['licenseID']}'),
              const Divider(height: 24),
              _detailRow('Class', _localLicense!['className']),
              const Divider(height: 24),
              _detailRow('Expiry Date', _localLicense!['expirationDate'].toString().split('T').first),
            ],
          ),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
        Text(val, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildFeeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Application Fee', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
              Text('USD ${_applicationFee.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(15)),
            child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return AppButton(
      label: 'Apply & Pay Now',
      isLoading: _submitting,
      onPressed: _localLicense == null ? null : _handleSubmit,
    );
  }

  Future<void> _handleSubmit() async {
    setState(() => _submitting = true);
    
    final result = await InternationalLicenseService.issueLicense(
      localLicenseId: _localLicense!['licenseID'],
      userId: 1, // Default system user
    );

    if (mounted) {
      setState(() => _submitting = false);
      if (result != null) {
        _showSuccess(result);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to issue license. Please check if you already have an active one.')));
      }
    }
  }

  void _showSuccess(Map<String, dynamic> data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 64),
            const SizedBox(height: 16),
            Text('Congratulations!', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Your International License has been issued successfully.', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            AppButton(
              label: 'View Permit',
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => DigitalInternationalLicenseScreen(license: data)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
