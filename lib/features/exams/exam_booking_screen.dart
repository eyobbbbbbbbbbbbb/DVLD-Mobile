import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/api/api_client.dart';
import '../../core/services/user_session.dart';
import '../exams/exam_result_screen.dart';

class ExamBookingScreen extends StatefulWidget {
  final int ldlApplicationId;
  final int testTypeId;
  final String testTitle;

  const ExamBookingScreen({
    super.key,
    required this.ldlApplicationId,
    required this.testTypeId,
    required this.testTitle,
  });

  @override
  State<ExamBookingScreen> createState() => _ExamBookingScreenState();
}

class _ExamBookingScreenState extends State<ExamBookingScreen> {
  late String _selectedExam;
  String _selectedDate = '';
  String _selectedTime = '';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectedExam = widget.testTypeId.toString();
  }

  List<Map<String, dynamic>> get _filteredExamTypes {
    final all = [
      {
        'id': '1',
        'title': 'Vision Test',
        'desc': 'Eye sight and color recognition exam',
        'duration': '15 min',
        'fee': 'ETB 3',
        'icon': Icons.remove_red_eye_outlined,
        'color': const Color(0xFF3D5AFE),
      },
      {
        'id': '2',
        'title': 'Written Theory Test',
        'desc': 'Traffic laws and road signs exam',
        'duration': '45 min',
        'fee': 'ETB 5',
        'icon': Icons.menu_book_rounded,
        'color': const Color(0xFF8E24AA),
      },
      {
        'id': '3',
        'title': 'Street Driving Test',
        'desc': 'Practical on-road driving exam',
        'duration': '30 min',
        'fee': 'ETB 10',
        'icon': Icons.drive_eta_rounded,
        'color': const Color(0xFFFF6D00),
      },
    ];
    return all.where((e) => e['id'] == widget.testTypeId.toString()).toList();
  }

  final List<String> _availableDates = [
    'Mon, Apr 8',
    'Tue, Apr 9',
    'Wed, Apr 10',
    'Thu, Apr 11',
    'Sun, Apr 13',
    'Mon, Apr 14',
  ];

  final List<String> _availableTimes = [
    '8:00 AM',
    '9:00 AM',
    '10:00 AM',
    '11:00 AM',
    '1:00 PM',
    '2:00 PM',
    '3:00 PM',
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
        title: Text('Book Exam',
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
                  Text('Confirm Exam Selection',
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  ...List.generate(_filteredExamTypes.length, (i) {
                    final e = _filteredExamTypes[i];
                    final isSelected = _selectedExam == e['id'];
                    return Container(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (e['color'] as Color).withOpacity(0.06)
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? e['color'] as Color
                                : AppColors.divider,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (e['color'] as Color)
                                  .withOpacity(isSelected ? 0.08 : 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: (e['color'] as Color).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(e['icon'] as IconData,
                                  color: e['color'] as Color, size: 26),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e['title'] as String,
                                      style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary)),
                                  Text(e['desc'] as String,
                                      style: GoogleFonts.poppins(
                                          fontSize: 11, color: AppColors.textSecondary)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      _ExamTag(
                                          label: e['duration'] as String,
                                          icon: Icons.timer_outlined),
                                      const SizedBox(width: 8),
                                      _ExamTag(
                                          label: e['fee'] as String,
                                          icon: Icons.attach_money_rounded),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: e['color'] as Color,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 14),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 24),
                  Text('Select Date',
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 72,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _availableDates.length,
                      itemBuilder: (_, i) {
                        final d = _availableDates[i];
                        final isSelected = _selectedDate == d;
                        final parts = d.split(', ');
                        return GestureDetector(
                          onTap: () => setState(() => _selectedDate = d),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color:
                                  isSelected ? AppColors.primary : AppColors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.divider,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(parts[0],
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: isSelected
                                          ? Colors.white70
                                          : AppColors.textLight,
                                    )),
                                Text(parts[1],
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                    )),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),
                  Text('Select Time',
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _availableTimes.map((t) {
                      final isSelected = _selectedTime == t;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedTime = t),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color:
                                isSelected ? AppColors.primary : AppColors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.divider,
                            ),
                          ),
                          child: Text(t,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              )),
                        ),
                      );
                    }).toList(),
                  ),

                  if (_selectedDate.isNotEmpty && _selectedTime.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.accentLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.event_available_rounded,
                              color: AppColors.primary, size: 24),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Booking Summary',
                                  style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                              Text(
                                  '$_selectedDate  •  $_selectedTime',
                                  style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            color: AppColors.white,
            child: AppButton(
              label: 'Confirm Booking',
              icon: Icons.event_rounded,
              isLoading: _loading,
              onPressed:
                  _selectedDate.isEmpty || _selectedTime.isEmpty
                      ? null
                      : () async {
                          setState(() => _loading = true);
                          
                          // Format: YYYY-MM-DD + Time
                          final now = DateTime.now();
                          final dateStr = _selectedDate.contains('Apr 8') ? '2026-04-08' :
                                         _selectedDate.contains('Apr 9') ? '2026-04-09' :
                                         _selectedDate.contains('Apr 10') ? '2026-04-10' :
                                         _selectedDate.contains('Apr 11') ? '2026-04-11' :
                                         '2026-04-13';
                          
                          final timeStr = _selectedTime.contains('8:00') ? '08:00' :
                                         _selectedTime.contains('9:00') ? '09:00' :
                                         _selectedTime.contains('10:00') ? '10:00' :
                                         _selectedTime.contains('1:00') ? '13:00' :
                                         '15:00';

                          final appointmentDate = DateTime.parse('$dateStr $timeStr:00');

                          try {
                            final response = await ApiClient.post('/applications/schedule-test', {
                              'localDrivingLicenseApplicationID': widget.ldlApplicationId,
                              'testTypeID': widget.testTypeId,
                              'appointmentDate': appointmentDate.toIso8601String(),
                              'createdByUserID': UserSession.instance.userId,
                            });

                            if (mounted) {
                              setState(() => _loading = false);
                              if (response.statusCode == 200) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Test Scheduled Successfully!'), backgroundColor: AppColors.success),
                                );
                                Navigator.of(context).pop(); // Back to details
                              } else {
                                final error = jsonDecode(response.body);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(error['message'] ?? 'Failed to schedule test.'), backgroundColor: AppColors.error),
                                );
                              }
                            }
                          } catch (e) {
                            if (mounted) {
                              setState(() => _loading = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
                              );
                            }
                          }
                        },
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamTag extends StatelessWidget {
  final String label;
  final IconData icon;
  const _ExamTag({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textLight),
        const SizedBox(width: 3),
        Text(label,
            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textLight)),
      ],
    );
  }
}
