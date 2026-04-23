import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/user_session.dart';
import 'services/driver_service.dart';
import 'package:intl/intl.dart';

class DrivingHistoryScreen extends StatefulWidget {
  const DrivingHistoryScreen({super.key});

  @override
  State<DrivingHistoryScreen> createState() => _DrivingHistoryScreenState();
}

class _DrivingHistoryScreenState extends State<DrivingHistoryScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final data = await DriverService.getDriverHistory(UserSession.instance.personId);
    setState(() {
      _history = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final int licenseCount = _history.where((h) => h['category'] == 'license').length;
    final int examCount = _history.where((h) => h['category'] == 'exam').length;

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
      ),
      body: _history.isEmpty 
          ? Center(child: Text('No history records found.', style: GoogleFonts.poppins()))
          : Column(
        children: [
          // Summary bar
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Row(
              children: [
                _SumCard(label: 'Total Records', value: '${_history.length}', color: AppColors.primary),
                const SizedBox(width: 12),
                _SumCard(label: 'Licenses', value: '$licenseCount', color: AppColors.success),
                const SizedBox(width: 12),
                _SumCard(label: 'Exams', value: '$examCount', color: AppColors.accent),
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
                                  Text(DateFormat('MMM d, yyyy').format(DateTime.parse(h['date'])),
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
