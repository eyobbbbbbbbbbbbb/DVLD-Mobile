import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class DrivingHistoryScreen extends StatelessWidget {
  const DrivingHistoryScreen({super.key});

  final List<Map<String, dynamic>> _history = const [
    {
      'type': 'License Issued',
      'details': 'Class B — New License Issued',
      'date': 'Jan 10, 2022',
      'branch': 'Amman — 3rd Circle',
      'category': 'license',
    },
    {
      'type': 'Theory Exam Passed',
      'details': 'Written Theory Test — Score: 88/100',
      'date': 'Jan 7, 2022',
      'branch': 'Exam Hall A',
      'category': 'exam',
    },
    {
      'type': 'Street Test Passed',
      'details': 'Practical Driving Test — Score: Pass',
      'date': 'Jan 5, 2022',
      'branch': 'Training Ground 2',
      'category': 'exam',
    },
    {
      'type': 'Vision Test Passed',
      'details': 'Vision & Colour Test — Clear',
      'date': 'Dec 28, 2021',
      'branch': 'Medical Unit A',
      'category': 'exam',
    },
    {
      'type': 'Application Submitted',
      'details': 'New License Application — Class B',
      'date': 'Dec 20, 2021',
      'branch': 'Online Portal',
      'category': 'application',
    },
    {
      'type': 'License Renewed',
      'details': 'Class B — Renewal (2017–2022)',
      'date': 'Jan 10, 2017',
      'branch': 'Amman — 5th Circle',
      'category': 'license',
    },
    {
      'type': 'License Issued',
      'details': 'Class B — First License',
      'date': 'Jan 10, 2012',
      'branch': 'Amman — City Branch',
      'category': 'license',
    },
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
        title: Text('Driving History',
            style: GoogleFonts.poppins(
                fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        backgroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary bar
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Row(
              children: [
                _SumCard(label: 'Total Records', value: '${_history.length}', color: AppColors.primary),
                const SizedBox(width: 12),
                _SumCard(label: 'Licenses', value: '3', color: AppColors.success),
                const SizedBox(width: 12),
                _SumCard(label: 'Exams', value: '3', color: AppColors.accent),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _history.length,
              itemBuilder: (context, i) {
                final h = _history[i];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline column
                    Column(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: _catColor(h['category']).withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(_catIcon(h['category']),
                              color: _catColor(h['category']), size: 18),
                        ),
                        if (i < _history.length - 1)
                          Container(
                            width: 2,
                            height: 60,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: AppColors.divider,
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(h['type'] as String,
                                        style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary)),
                                  ),
                                  Text(h['date'] as String,
                                      style: GoogleFonts.poppins(
                                          fontSize: 11, color: AppColors.textLight)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(h['details'] as String,
                                  style: GoogleFonts.poppins(
                                      fontSize: 12, color: AppColors.textSecondary)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.place_rounded,
                                      size: 12, color: AppColors.textLight),
                                  const SizedBox(width: 4),
                                  Text(h['branch'] as String,
                                      style: GoogleFonts.poppins(
                                          fontSize: 11, color: AppColors.textLight)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _catColor(String cat) {
    switch (cat) {
      case 'license':
        return AppColors.primary;
      case 'exam':
        return AppColors.success;
      case 'application':
        return AppColors.accent;
      default:
        return AppColors.textLight;
    }
  }

  IconData _catIcon(String cat) {
    switch (cat) {
      case 'license':
        return Icons.credit_card_rounded;
      case 'exam':
        return Icons.school_rounded;
      case 'application':
        return Icons.assignment_rounded;
      default:
        return Icons.circle_rounded;
    }
  }
}

class _SumCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SumCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.w700, color: color)),
            Text(label,
                style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
