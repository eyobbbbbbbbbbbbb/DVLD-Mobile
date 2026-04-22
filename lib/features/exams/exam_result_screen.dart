import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import 'exam_booking_screen.dart';

class ExamResultScreen extends StatelessWidget {
  const ExamResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulated result — passed
    const bool passed = true;
    const int score = 82;
    const int passMark = 70;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Exam Result',
            style: GoogleFonts.poppins(
                fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Result badge
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: passed ? AppColors.successLight : AppColors.errorLight,
                border: Border.all(
                  color: passed ? AppColors.success : AppColors.error,
                  width: 4,
                ),
              ),
              child: Icon(
                passed ? Icons.emoji_events_rounded : Icons.close_rounded,
                color: passed ? AppColors.success : AppColors.error,
                size: 54,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              passed ? 'Congratulations!' : 'Not Passed',
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: passed ? AppColors.success : AppColors.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              passed
                  ? 'You successfully passed the Written Theory Test.'
                  : 'Unfortunately you did not pass this time. You may retake the exam.',
              style: GoogleFonts.poppins(
                  fontSize: 14, color: AppColors.textSecondary, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Score card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: passed ? AppColors.successGradient : const LinearGradient(colors: [AppColors.error, Color(0xFFEF5350)]),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  Text('Your Score',
                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('$score',
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 64,
                              fontWeight: FontWeight.w800,
                              height: 1)),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text('/100',
                            style: GoogleFonts.poppins(
                                color: Colors.white60, fontSize: 22)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Score bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: LinearProgressIndicator(
                      value: score / 100,
                      backgroundColor: Colors.white30,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Pass Mark: $passMark / 100',
                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Details card
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _ResultRow(label: 'Exam Type', value: 'Written Theory Test'),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _ResultRow(label: 'Date', value: 'Apr 10, 2026'),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _ResultRow(label: 'Time', value: '10:00 AM'),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _ResultRow(label: 'Application', value: 'APP-2026-0041'),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _ResultRow(label: 'Result', value: passed ? 'PASS' : 'FAIL',
                      valueColor: passed ? AppColors.success : AppColors.error),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Section scores
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Section Breakdown',
                      style: GoogleFonts.poppins(
                          fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  _SectionBar(label: 'Traffic Signs', score: 18, total: 20),
                  const SizedBox(height: 12),
                  _SectionBar(label: 'Road Rules', score: 22, total: 30),
                  const SizedBox(height: 12),
                  _SectionBar(label: 'First Aid', score: 14, total: 20),
                  const SizedBox(height: 12),
                  _SectionBar(label: 'Driving Safety', score: 28, total: 30),
                ],
              ),
            ),
            const SizedBox(height: 28),

            if (!passed) ...[
              AppButton(
                label: 'Retake Exam',
                icon: Icons.refresh_rounded,
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const ExamBookingScreen()),
                ),
              ),
              const SizedBox(height: 12),
            ],
            AppButton(
              label: 'Download Certificate',
              variant: passed ? AppButtonVariant.outline : AppButtonVariant.ghost,
              icon: Icons.download_rounded,
              onPressed: passed ? () {} : null,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _ResultRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _SectionBar extends StatelessWidget {
  final String label;
  final int score;
  final int total;
  const _SectionBar(
      {required this.label, required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = score / total;
    final color = pct >= 0.7 ? AppColors.success : AppColors.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textPrimary)),
            Text('$score/$total',
                style: GoogleFonts.poppins(
                    fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: AppColors.inputBg,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
