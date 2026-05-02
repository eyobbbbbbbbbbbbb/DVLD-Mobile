import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../payment/payment_screen.dart';

class RequiredDocumentsScreen extends StatefulWidget {
  const RequiredDocumentsScreen({super.key});

  @override
  State<RequiredDocumentsScreen> createState() => _RequiredDocumentsScreenState();
}

class _RequiredDocumentsScreenState extends State<RequiredDocumentsScreen> {
  bool _loading = false;
  
  // Track upload status
  bool _idUploaded = false;
  bool _medicalUploaded = false;
  bool _photoUploaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Required Documents',
          style: GoogleFonts.poppins(
              fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Upload Documents',
                style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text('Please upload the required documents for your new application.',
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 24),

            _buildUploadCard(
              title: 'ID Card / Passport',
              subtitle: 'Clear front and back photos',
              icon: Icons.badge_rounded,
              isUploaded: _idUploaded,
              onTap: () {
                setState(() => _idUploaded = !_idUploaded);
              },
            ),
            
            const SizedBox(height: 16),
            
            _buildUploadCard(
              title: 'Medical Certificate',
              subtitle: 'Recent eye test and fitness certificate',
              icon: Icons.medical_information_rounded,
              isUploaded: _medicalUploaded,
              onTap: () {
                setState(() => _medicalUploaded = !_medicalUploaded);
              },
            ),

            const SizedBox(height: 16),

            _buildUploadCard(
              title: 'Passport Size Photo',
              subtitle: 'Recent photo with white background',
              icon: Icons.person_pin_rounded,
              isUploaded: _photoUploaded,
              onTap: () {
                setState(() => _photoUploaded = !_photoUploaded);
              },
            ),

            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.infoLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.info.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: AppColors.info, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ensure all documents are clearly visible. Blurry images may result in application rejection.',
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.blue[800]),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
            AppButton(
              label: 'Continue to Payment',
              icon: Icons.payment_rounded,
              isLoading: _loading,
              onPressed: (!_idUploaded || !_medicalUploaded || !_photoUploaded)
                  ? null
                  : () async {
                      setState(() => _loading = true);
                      await Future.delayed(const Duration(seconds: 1));
                      if (mounted) {
                         setState(() => _loading = false);
                         Navigator.of(context).push(
                           MaterialPageRoute(
                               builder: (_) => const PaymentScreen()),
                         );
                      }
                    },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isUploaded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUploaded ? AppColors.success : AppColors.inputBorder,
            width: isUploaded ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isUploaded 
                    ? AppColors.successLight 
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isUploaded ? AppColors.success : AppColors.primary, 
                size: 26
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  Text(subtitle,
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            if (isUploaded)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Upload',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
