import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import 'exam_booking_screen.dart';

class MyExamsScreen extends StatelessWidget {
  const MyExamsScreen({super.key});

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
          'My Exams',
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
            Text('Exam Progress',
                style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text('Track your required tests for New Local Driving License.',
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 24),

            _buildExamCard(
              context,
              title: 'Vision Test',
              subtitle: 'Failed on Apr 5. Retest required.',
              icon: Icons.remove_red_eye_outlined,
              status: 'Failed',
              statusColor: AppColors.error,
              isLocked: false,
              actionLabel: 'Book Retest',
              onAction: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ExamBookingScreen(
                  ldlApplicationId: 0,
                  testTypeId: 1,
                  testTitle: 'Vision Test',
                )),
              ),
            ),
            
            const SizedBox(height: 16),
            
            _buildExamCard(
              context,
              title: 'Written Theory Test',
              subtitle: 'Requires Vision Test to be passed first.',
              icon: Icons.menu_book_rounded,
              status: 'Locked',
              statusColor: AppColors.textLight,
              isLocked: true,
              actionLabel: 'Book Exam',
              onAction: null,
            ),

            const SizedBox(height: 16),

            _buildExamCard(
              context,
              title: 'Practical Street Test',
              subtitle: 'Requires Written Test to be passed first.',
              icon: Icons.drive_eta_rounded,
              status: 'Locked',
              statusColor: AppColors.textLight,
              isLocked: true,
              actionLabel: 'Book Exam',
              onAction: null,
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
                  Icon(Icons.lightbulb_outline_rounded, color: AppColors.info, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You must pass tests in sequence. Booking a retest prioritizes your slot availability.',
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.blue[800]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String status,
    required Color statusColor,
    required bool isLocked,
    required String actionLabel,
    VoidCallback? onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isLocked ? AppColors.divider : statusColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isLocked ? AppColors.inputBg : statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: isLocked ? AppColors.textSecondary : statusColor, 
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
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isLocked ? AppColors.textSecondary : AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isLocked ? AppColors.inputBg : statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(status,
                          style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isLocked ? AppColors.textSecondary : statusColor)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(subtitle,
              style: GoogleFonts.poppins(
                  fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          if (!isLocked)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  actionLabel,
                  style: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            )
        ],
      ),
    );
  }
}
