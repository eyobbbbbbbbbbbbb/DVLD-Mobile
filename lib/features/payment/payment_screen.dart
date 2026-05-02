import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import 'payment_receipt_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedMethod = 0;
  bool _loading = false;

  final List<Map<String, dynamic>> _methods = [
    {'label': 'Credit / Debit Card', 'icon': Icons.credit_card_rounded},
    {'label': 'eFawateercom', 'icon': Icons.receipt_long_rounded},
    {'label': 'Cash at Branch', 'icon': Icons.account_balance_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Payment',
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
                  // Summary Banner
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Application Fee',
                                style: GoogleFonts.poppins(
                                    color: Colors.white70, fontSize: 13)),
                            Text('APP-2026-0041',
                                style: GoogleFonts.poppins(
                                    color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text('ETB 10.00',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                            )),
                        const SizedBox(height: 4),
                        Text('New License — Class B',
                            style: GoogleFonts.poppins(
                                color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Breakdown
                  Text('Fee Breakdown',
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  _FeeRow(label: 'Application Processing', amount: 'ETB 5.00'),
                  const Divider(height: 16),
                  _FeeRow(label: 'Vision Test Fee', amount: 'ETB 3.00'),
                  const Divider(height: 16),
                  _FeeRow(label: 'Administrative Fee', amount: 'ETB 2.00'),
                  const Divider(height: 16),
                  _FeeRow(label: 'Total', amount: 'ETB 10.00', isBold: true),

                  const SizedBox(height: 28),
                  Text('Payment Method',
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  ...List.generate(
                    _methods.length,
                    (i) => GestureDetector(
                      onTap: () => setState(() => _selectedMethod = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: _selectedMethod == i
                              ? AppColors.accentLight
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _selectedMethod == i
                                ? AppColors.primary
                                : AppColors.divider,
                            width: _selectedMethod == i ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(_methods[i]['icon'] as IconData,
                                color: _selectedMethod == i
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(_methods[i]['label'] as String,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: _selectedMethod == i
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: _selectedMethod == i
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                  )),
                            ),
                            if (_selectedMethod == i)
                              Icon(Icons.check_circle_rounded,
                                  color: AppColors.primary, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),

                  if (_selectedMethod == 0) ...[
                    const SizedBox(height: 20),
                    Text('Card Details',
                        style: GoogleFonts.poppins(
                            fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 12),
                    _buildCardInput('Card Number', '#### #### #### ####',
                        Icons.credit_card_rounded, TextInputType.number),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _buildCardInput(
                              'Expiry', 'MM / YY', Icons.date_range_rounded, TextInputType.number),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildCardInput(
                              'CVV', '•••', Icons.security_rounded, TextInputType.number),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildCardInput('Cardholder Name', 'Full name on card',
                        Icons.person_outline_rounded, TextInputType.name),
                  ],
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            color: AppColors.white,
            child: AppButton(
              label: 'Pay ETB 10.00',
              icon: Icons.lock_rounded,
              isLoading: _loading,
              onPressed: () async {
                setState(() => _loading = true);
                await Future.delayed(const Duration(seconds: 2));
                if (mounted) {
                  setState(() => _loading = false);
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (_) => const PaymentReceiptScreen()),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardInput(
      String label, String hint, IconData icon, TextInputType type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextFormField(
          keyboardType: type,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 18, color: AppColors.textLight),
            filled: true,
            fillColor: AppColors.inputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
            hintStyle: GoogleFonts.poppins(fontSize: 14, color: AppColors.textLight),
          ),
          style: GoogleFonts.poppins(fontSize: 14),
        ),
      ],
    );
  }
}

class _FeeRow extends StatelessWidget {
  final String label;
  final String amount;
  final bool isBold;

  const _FeeRow({required this.label, required this.amount, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
                color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
              )),
          Text(amount,
              style: GoogleFonts.poppins(
                fontSize: isBold ? 15 : 13,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                color: isBold ? AppColors.primary : AppColors.textPrimary,
              )),
        ],
      ),
    );
  }
}
