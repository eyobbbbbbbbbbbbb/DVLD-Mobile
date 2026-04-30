import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../home/home_screen.dart';
import 'package:intl/intl.dart';

class PaymentReceiptScreen extends StatelessWidget {
  final Map<String, dynamic>? receiptData;

  const PaymentReceiptScreen({super.key, this.receiptData});

  @override
  Widget build(BuildContext context) {
    // Fallback values if data is missing
    final String receiptNo = receiptData?['receiptNo'] ?? 'RCP-${DateFormat('yyyy-MM').format(DateTime.now())}-${(1000 + (DateTime.now().millisecond % 9000))}';
    final String transactionId = receiptData?['transactionId'] ?? 'TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
    final String dateStr = receiptData?['date'] ?? DateFormat('MMM d, yyyy — hh:mm a').format(DateTime.now());
    final String applicant = receiptData?['applicant'] ?? 'Current Driver';
    final String applicationId = receiptData?['applicationId'] ?? 'N/A';
    final String service = receiptData?['service'] ?? 'License Release';
    final String totalAmount = receiptData?['totalAmount'] ?? 'ETB 15.00';

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
                child: Icon(Icons.check_circle_rounded,
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
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: const BorderRadius.only(
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
                          _ReceiptRow(label: 'Receipt No.', value: receiptNo),
                          const SizedBox(height: 14),
                          _ReceiptRow(label: 'Transaction ID', value: transactionId),
                          const SizedBox(height: 14),
                          _ReceiptRow(label: 'Date', value: dateStr),
                          const SizedBox(height: 14),
                          _ReceiptRow(label: 'Applicant', value: applicant),
                          const SizedBox(height: 14),
                          _ReceiptRow(
                              label: 'Application ID', value: applicationId),
                          const SizedBox(height: 14),
                          _ReceiptRow(
                              label: 'Service', value: service),
                          const SizedBox(height: 14),
                          _ReceiptRow(label: 'Payment Method', value: 'Mobile Wallet'),
                          const SizedBox(height: 16),
                          Container(height: 1, color: AppColors.divider),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Paid',
                                  style: GoogleFonts.poppins(
                                      fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                              Text(totalAmount,
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
                          Text(receiptNo,
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
