import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../home/home_screen.dart';

class PaymentReceiptScreen extends StatelessWidget {
  const PaymentReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Success icon
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 54),
              ),
              const SizedBox(height: 20),
              Text('Payment Successful!',
                  style: GoogleFonts.poppins(
                      fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text('Your payment has been processed. A confirmation\nhas been sent to your email.',
                  style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
                  textAlign: TextAlign.center),

              const SizedBox(height: 32),

              // Receipt card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(22),
                          topRight: Radius.circular(22),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.receipt_long_rounded,
                              color: Colors.white, size: 28),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Official Receipt',
                                  style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700)),
                              Text('Ministry of Interior — Traffic Dept.',
                                  style: GoogleFonts.poppins(
                                      color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Dashed divider
                    Row(
                      children: List.generate(30, (i) {
                        return Expanded(
                          child: Container(
                            height: 1,
                            color: i.isEven ? AppColors.divider : Colors.transparent,
                          ),
                        );
                      }),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _ReceiptRow(label: 'Receipt No.', value: 'RCP-2026-00893'),
                          const SizedBox(height: 14),
                          _ReceiptRow(label: 'Transaction ID', value: 'TXN-4872563'),
                          const SizedBox(height: 14),
                          _ReceiptRow(label: 'Date', value: 'Apr 4, 2026 — 11:23 AM'),
                          const SizedBox(height: 14),
                          _ReceiptRow(label: 'Applicant', value: 'Ahmad Al-Rashid'),
                          const SizedBox(height: 14),
                          _ReceiptRow(
                              label: 'Application', value: 'APP-2026-0041'),
                          const SizedBox(height: 14),
                          _ReceiptRow(
                              label: 'Service', value: 'New License — Class B'),
                          const SizedBox(height: 14),
                          _ReceiptRow(label: 'Payment Method', value: 'Credit Card'),
                          const SizedBox(height: 16),
                          Container(height: 1, color: AppColors.divider),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Paid',
                                  style: GoogleFonts.poppins(
                                      fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                              Text('ETB 10.00',
                                  style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Barcode placeholder
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.inputBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(30, (i) {
                              return Container(
                                width: i.isEven ? 3 : 1.5,
                                height: 50,
                                color: i.isEven
                                    ? AppColors.textPrimary
                                    : AppColors.inputBorder,
                              );
                            }),
                          ),
                          const SizedBox(height: 8),
                          Text('RCP-2026-00893',
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  letterSpacing: 2,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              AppButton(
                label: 'Download Receipt',
                variant: AppButtonVariant.outline,
                icon: Icons.download_rounded,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Receipt downloaded to your device.',
                          style: GoogleFonts.poppins()),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              AppButton(
                label: 'Back to Home',
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (_) => false,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  const _ReceiptRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary),
              textAlign: TextAlign.end),
        ),
      ],
    );
  }
}
