import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../payment/payment_screen.dart';
import '../exams/exam_booking_screen.dart';

class ApplicationDetailsScreen extends StatelessWidget {
  const ApplicationDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Application Details',
            style: GoogleFonts.poppins(
                fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        backgroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header card
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.drive_eta_rounded,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('New License — Class B',
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text('APP-2026-0041',
                                style: GoogleFonts.poppins(
                                    color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.info,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text('In Progress',
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _HeaderStat(label: 'Submitted', value: 'Apr 3, 2026'),
                      _HeaderStat(label: 'Fee Paid', value: 'ETB 10'),
                      _HeaderStat(label: 'Est. Completion', value: 'Apr 17'),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress timeline
                  Text('Application Progress',
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  _Timeline(),

                  const SizedBox(height: 28),
                  Text('Application Info',
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  _InfoCard(rows: const [
                    {'label': 'Applicant', 'value': 'Ahmad Al-Rashid'},
                    {'label': 'National ID', 'value': '9-8765-4321'},
                    {'label': 'License Type', 'value': 'New'},
                    {'label': 'License Class', 'value': 'Class B – Passenger Car'},
                    {'label': 'Medical Cert.', 'value': 'MC-2026-1104'},
                    {'label': 'Branch', 'value': 'Amman – 3rd Circle'},
                  ]),

                  const SizedBox(height: 28),
                  Text('Exam Schedule',
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  _ExamRow(
                    examType: 'Vision Test',
                    date: 'Apr 6, 2026',
                    time: '9:00 AM',
                    status: 'Passed',
                    isPass: true,
                  ),
                  const SizedBox(height: 10),
                  _ExamRow(
                    examType: 'Written Theory Test',
                    date: 'Apr 10, 2026',
                    time: '10:00 AM',
                    status: 'Scheduled',
                    isPass: null,
                  ),
                  const SizedBox(height: 10),
                  _ExamRow(
                    examType: 'Street Driving Test',
                    date: 'TBD',
                    time: '--',
                    status: 'Pending',
                    isPass: null,
                  ),

                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'Book Exam',
                          variant: AppButtonVariant.outline,
                          icon: Icons.event_note_rounded,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const ExamBookingScreen()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          label: 'Pay Fees',
                          icon: Icons.payment_rounded,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const PaymentScreen()),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String label;
  final String value;
  const _HeaderStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.poppins(color: Colors.white60, fontSize: 11)),
          Text(value,
              style: GoogleFonts.poppins(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final steps = [
      {'label': 'Application Submitted', 'date': 'Apr 3, 2026', 'done': true},
      {'label': 'Documents Verified', 'date': 'Apr 4, 2026', 'done': true},
      {'label': 'Fee Paid', 'date': 'Apr 4, 2026', 'done': true},
      {'label': 'Vision Test', 'date': 'Apr 6, 2026 — Passed', 'done': true},
      {'label': 'Theory Test', 'date': 'Apr 10, 2026 — Scheduled', 'done': false, 'active': true},
      {'label': 'Street Driving Test', 'date': 'TBD', 'done': false},
      {'label': 'License Issued', 'date': 'TBD', 'done': false},
    ];

    return Container(
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
        children: List.generate(steps.length, (i) {
          final s = steps[i];
          final isDone = s['done'] as bool;
          final isActive = (s['active'] ?? false) as bool;
          final isLast = i == steps.length - 1;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone
                          ? AppColors.success
                          : isActive
                              ? AppColors.info
                              : AppColors.inputBg,
                      border: isActive
                          ? Border.all(color: AppColors.info, width: 2)
                          : null,
                    ),
                    child: Icon(
                      isDone
                          ? Icons.check_rounded
                          : isActive
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_unchecked_rounded,
                      color: isDone
                          ? Colors.white
                          : isActive
                              ? AppColors.info
                              : AppColors.textLight,
                      size: 16,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 42,
                      color: isDone ? AppColors.success.withOpacity(0.3) : AppColors.divider,
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s['label'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight:
                              isDone || isActive ? FontWeight.w600 : FontWeight.w400,
                          color: isDone || isActive
                              ? AppColors.textPrimary
                              : AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        s['date'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: isDone
                              ? AppColors.success
                              : isActive
                                  ? AppColors.info
                                  : AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Map<String, String>> rows;
  const _InfoCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        children: List.generate(rows.length, (i) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
                const Divider(height: 1, indent: 18, endIndent: 18),
            ],
          );
        }),
      ),
    );
  }
}

class _ExamRow extends StatelessWidget {
  final String examType;
  final String date;
  final String time;
  final String status;
  final bool? isPass;

  const _ExamRow({
    required this.examType,
    required this.date,
    required this.time,
    required this.status,
    required this.isPass,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Color statusBg;
    if (isPass == true) {
      statusColor = AppColors.success;
      statusBg = AppColors.successLight;
    } else if (isPass == false) {
      statusColor = AppColors.error;
      statusBg = AppColors.errorLight;
    } else if (status == 'Scheduled') {
      statusColor = AppColors.info;
      statusBg = AppColors.infoLight;
    } else {
      statusColor = AppColors.textLight;
      statusBg = AppColors.inputBg;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.assignment_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(examType,
                    style: GoogleFonts.poppins(
                        fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text('$date  •  $time',
                    style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textLight)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(status,
                style: GoogleFonts.poppins(
                    fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
          ),
        ],
      ),
    );
  }
}
