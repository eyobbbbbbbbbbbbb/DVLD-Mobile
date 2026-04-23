import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_input.dart';
import '../payment/payment_screen.dart';
import '../payment/payment_receipt_screen.dart';

import '../license/services/detain_service.dart';
import '../../core/services/user_session.dart';
import '../license/services/license_service.dart';

class ReleaseDetainedScreen extends StatefulWidget {
  final int? licenseId;
  const ReleaseDetainedScreen({super.key, this.licenseId});

  @override
  State<ReleaseDetainedScreen> createState() => _ReleaseDetainedScreenState();
}

class _ReleaseDetainedScreenState extends State<ReleaseDetainedScreen> {
  bool _acknowledged = false;
  bool _loading = true;
  bool _submitting = false;
  Map<String, dynamic>? _detainInfo;
  Map<String, dynamic>? _licenseInfo;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    int? targetId = widget.licenseId;
    
    if (targetId == null) {
      // Find the first detained license for the user
      final licenses = await LicenseService.getPersonLicenses(UserSession.instance.personId);
      final detained = licenses.firstWhere((l) => l['isDetained'] == true, orElse: () => {});
      if (detained.isNotEmpty) {
        targetId = detained['licenseID'];
      }
    }

    if (targetId != null) {
      final results = await Future.wait([
        DetainService.getDetainInfo(targetId!),
        LicenseService.getLicenseDetails(targetId),
      ]);
      setState(() {
        _detainInfo = results[0];
        _licenseInfo = results[1];
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_detainInfo == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Release License')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline_rounded, size: 64, color: AppColors.success),
              const SizedBox(height: 16),
              Text('No detained license found.', style: GoogleFonts.poppins()),
            ],
          ),
        ),
      );
    }

    final double fine = (_detainInfo!['fineFees'] as num).toDouble();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Release Detained License',
            style: GoogleFonts.poppins(
                fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Warning Banner
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.lock_rounded,
                              color: AppColors.error, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('License Detained',
                                  style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.error)),
                              const SizedBox(height: 4),
                              Text(
                                  'Your license has been detained due to administrative or traffic violations.',
                                  style: GoogleFonts.poppins(
                                      fontSize: 12, color: AppColors.error.withOpacity(0.8))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Detention Info
                  Text('Detention Details',
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  _DetailCard(rows: [
                    {'label': 'License ID', 'value': '#${_detainInfo!['licenseID']}'},
                    {'label': 'Class', 'value': _licenseInfo?['className'] ?? 'Driving License'},
                    {'label': 'Detained Date', 'value': DateFormat('MMM d, yyyy').format(DateTime.parse(_detainInfo!['detainDate']))},
                    {'label': 'Detain Place', 'value': _detainInfo!['detainPlace'] ?? 'DVLD Office'},
                    {'label': 'Reason', 'value': _detainInfo!['detainReason'] ?? 'Not specified'},
                  ]),

                  const SizedBox(height: 24),

                  // Fines
                  Text('Outstanding Fees',
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Detention Fine', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
                            Text('ETB ${fine.toStringAsFixed(2)}', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.error)),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Release App Fee', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
                            Text('ETB 15.00', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  // Total
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.error.withOpacity(0.25)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Amount Due',
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.error)),
                        Text('ETB ${(fine + 15).toStringAsFixed(2)}',
                            style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.error)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  Text('Release Request',
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  AppInput(
                    label: 'Additional Notes (Optional)',
                    hint: 'Enter any additional information...',
                    prefixIcon: Icons.notes_rounded,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Acknowledgement
                  GestureDetector(
                    onTap: () => setState(() => _acknowledged = !_acknowledged),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _acknowledged,
                          onChanged: (v) =>
                              setState(() => _acknowledged = v ?? false),
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              'I acknowledge that all fines and application fees must be paid to release my license. I agree to the terms and conditions.',
                              style: GoogleFonts.poppins(
                                  fontSize: 13, color: AppColors.textSecondary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            color: AppColors.white,
            child: Column(
              children: [
                AppButton(
                  label: 'Pay & Release License',
                  icon: Icons.payment_rounded,
                  variant: AppButtonVariant.danger,
                  isLoading: _submitting,
                  onPressed: !_acknowledged
                      ? null
                      : () async {
                          setState(() => _submitting = true);
                          final result = await DetainService.releaseLicense(
                            _detainInfo!['licenseID'],
                            UserSession.instance.userId,
                          );
                          
                          if (mounted) {
                            setState(() => _submitting = false);
                            if (result != null) {
                               Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (_) => PaymentReceiptScreen(
                                      receiptData: {
                                        'applicationId': 'APP-${result['releaseApplicationID']}',
                                        'service': 'License Release',
                                        'totalAmount': 'ETB ${(fine + 15).toStringAsFixed(2)}',
                                        'applicant': UserSession.instance.fullName,
                                      },
                                    )),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to release license. Please try again.')),
                              );
                            }
                          }
                        },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final List<Map<String, String>> rows;
  const _DetailCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: List.generate(rows.length, (i) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(rows[i]['label']!,
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: AppColors.textSecondary)),
                    Text(rows[i]['value']!,
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary)),
                  ],
                ),
              ),
              if (i < rows.length - 1)
                const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          );
        }),
      ),
    );
  }
}
