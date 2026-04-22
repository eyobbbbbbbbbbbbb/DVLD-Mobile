import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_input.dart';
import '../payment/payment_screen.dart';

class ReleaseDetainedScreen extends StatefulWidget {
  const ReleaseDetainedScreen({super.key});

  @override
  State<ReleaseDetainedScreen> createState() => _ReleaseDetainedScreenState();
}

class _ReleaseDetainedScreenState extends State<ReleaseDetainedScreen> {
  bool _acknowledged = false;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
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
                                  'Your license has been detained due to unpaid traffic fines.',
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
                  _DetailCard(rows: const [
                    {'label': 'License Number', 'value': 'JO-B-2022-87456'},
                    {'label': 'Detained Date', 'value': 'Mar 15, 2026'},
                    {'label': 'Detaining Authority', 'value': 'Traffic Police — Amman'},
                    {'label': 'Detention Reason', 'value': 'Traffic Fines'},
                    {'label': 'Case Reference', 'value': 'DET-2026-00394'},
                  ]),

                  const SizedBox(height: 24),

                  // Fines
                  Text('Outstanding Fines',
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  ...const [
                    {
                      'no': '1',
                      'violation': 'Speeding (60 in 40 Zone)',
                      'date': 'Feb 12, 2026',
                      'amount': 'ETB 30'
                    },
                    {
                      'no': '2',
                      'violation': 'Red Light Violation',
                      'date': 'Mar 1, 2026',
                      'amount': 'ETB 50'
                    },
                    {
                      'no': '3',
                      'violation': 'Illegal Parking',
                      'date': 'Mar 8, 2026',
                      'amount': 'ETB 20'
                    },
                  ].map((f) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.error.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.errorLight,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(f['no']!,
                                    style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.error)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(f['violation']!,
                                      style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary)),
                                  Text(f['date']!,
                                      style: GoogleFonts.poppins(
                                          fontSize: 11, color: AppColors.textLight)),
                                ],
                              ),
                            ),
                            Text(f['amount']!,
                                style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.error)),
                          ],
                        ),
                      )),

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
                        Text('Total Fine Amount',
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.error)),
                        Text('ETB 100.00',
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
                              'I acknowledge that all fines must be paid to release my license. I agree to the terms and conditions of this request.',
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
                  label: 'Pay Fines & Submit Request',
                  icon: Icons.payment_rounded,
                  variant: AppButtonVariant.danger,
                  isLoading: _loading,
                  onPressed: !_acknowledged
                      ? null
                      : () async {
                          setState(() => _loading = true);
                          await Future.delayed(const Duration(milliseconds: 500));
                          if (mounted) {
                            setState(() => _loading = false);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const PaymentScreen()),
                            );
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
