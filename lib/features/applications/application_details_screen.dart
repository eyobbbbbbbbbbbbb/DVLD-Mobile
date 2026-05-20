import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/services/user_session.dart';
import 'services/application_service.dart';
import '../license/services/license_service.dart';
import '../payment/payment_screen.dart';
import '../exams/exam_booking_screen.dart';
import '../license/digital_license_screen.dart';

class ApplicationDetailsScreen extends StatefulWidget {
  final int applicationId;
  final int ldlApplicationId;

  const ApplicationDetailsScreen({
    super.key,
    required this.applicationId,
    required this.ldlApplicationId,
  });

  @override
  State<ApplicationDetailsScreen> createState() => _ApplicationDetailsScreenState();
}

class _ApplicationDetailsScreenState extends State<ApplicationDetailsScreen> {
  bool _loading = true;
  Map<String, dynamic>? _details;
  List<Map<String, dynamic>> _testHistory = [];
  Map<String, dynamic>? _nextTest;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    
    // Fetch all needed data in parallel
    final results = await Future.wait([
      ApplicationService.getApplicationStatus(UserSession.instance.personId),
      ApplicationService.getTestHistory(widget.ldlApplicationId),
      ApplicationService.getNextTest(widget.ldlApplicationId),
    ]);

    final List<Map<String, dynamic>> apps = results[0] as List<Map<String, dynamic>>;
    final details = apps.firstWhere((a) => a['applicationID'] == widget.applicationId);

    setState(() {
      _details = details;
      _testHistory = results[1] as List<Map<String, dynamic>>;
      _nextTest = results[2] as Map<String, dynamic>?;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final String status = _details?['status'] ?? 'New';

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
                            Text(_details?['className'] ?? 'New License',
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text('APP-${widget.applicationId}',
                                style: GoogleFonts.poppins(
                                    color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _statusColor(status),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(status,
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
                      _HeaderStat(label: 'Submitted', value: _details?['appliedDate'].toString().split('T').first ?? '--'),
                      _HeaderStat(label: 'Tests Passed', value: '${_details?['passedExamsCount']}/3'),
                      _HeaderStat(label: 'Status', value: status),
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
                   _Timeline(
                    passedCount: _details?['passedExamsCount'] ?? 0,
                    status: status,
                    appliedDate: _details?['appliedDate'].toString().split('T').first ?? '--',
                  ),

                  const SizedBox(height: 28),
                  Text('Application Info',
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  _InfoCard(rows: [
                    {'label': 'Applicant', 'value': UserSession.instance.fullName},
                    {'label': 'National ID', 'value': UserSession.instance.nationalId},
                    {'label': 'License Type', 'value': 'New Local License'},
                    {'label': 'License Class', 'value': _details?['className'] ?? '--'},
                    {'label': 'Application ID', 'value': 'APP-${widget.applicationId}'},
                    {'label': 'LDL App ID', 'value': 'LDL-${widget.ldlApplicationId}'},
                  ]),

                  const SizedBox(height: 28),
                  ..._testHistory.map((test) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ExamRow(
                      examType: test['testType'],
                      date: test['date'].toString().split('T').first,
                      time: test['date'].toString().split('T').last.substring(0, 5),
                      status: test['result'],
                      isPass: test['result'] == 'Pass',
                    ),
                  )),
                  if (_testHistory.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text('No exam attempts yet.', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textLight)),
                    ),

                  const SizedBox(height: 28),
                  if (_nextTest != null && _nextTest!['nextTestTypeID'] != 0) ...[
                    Text('Next Action',
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.accentLight,
                            child: Icon(Icons.notification_important_rounded, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _nextTest!['isScheduled'] ? 'Waiting for Test' : 'Needs Scheduling',
                                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  _nextTest!['isScheduled'] 
                                    ? 'You have an active appointment for ${_nextTest!['nextTestTitle']}.'
                                    : 'You are eligible to book your ${_nextTest!['nextTestTitle']}.',
                                  style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (_nextTest != null && _nextTest!['nextTestTypeID'] != 0 && !_nextTest!['isScheduled'])
                    AppButton(
                      label: 'Book ${_nextTest!['nextTestTitle']}',
                      icon: Icons.event_note_rounded,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ExamBookingScreen(
                            ldlApplicationId: widget.ldlApplicationId,
                            testTypeId: _nextTest!['nextTestTypeID'],
                            testTitle: _nextTest!['nextTestTitle'],
                          ),
                        ),
                      ).then((_) => _loadData()), // Reload when coming back
                    ),
                  
                  if (status == 'Approved' && (_details?['passedExamsCount'] ?? 0) == 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: AppButton(
                        label: 'Issue Driving License',
                        icon: Icons.card_membership_rounded,
                        isLoading: _loading,
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text('Issue License', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                              content: Text('Are you sure you want to issue the license for this application?', style: GoogleFonts.poppins()),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: GoogleFonts.poppins(color: AppColors.textLight))),
                                TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Issue', style: GoogleFonts.poppins(color: AppColors.primary, fontWeight: FontWeight.w600))),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            setState(() => _loading = true);
                            final result = await LicenseService.issueLicense(
                              ldlApplicationId: widget.ldlApplicationId,
                              notes: 'Issued via Mobile App',
                              userId: UserSession.instance.userId,
                            );
                            
                            if (mounted) {
                              setState(() => _loading = false);
                              if (result['success']) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('License Issued Successfully!'), backgroundColor: AppColors.success),
                                );
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (_) => DigitalLicenseScreen(licenseId: result['data']['licenseID'])),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(result['message']), backgroundColor: AppColors.error),
                                );
                              }
                            }
                          }
                        },
                      ),
                    ),

                  if (status == 'New' && _testHistory.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: AppButton(
                        label: 'Cancel Application',
                        variant: AppButtonVariant.outline,
                        icon: Icons.close_rounded,
                        onPressed: () {}, // Implementation later
                      ),
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

  Color _statusColor(String status) {
    switch (status) {
      case 'Approved':
      case 'Completed':
        return AppColors.success;
      case 'Rejected':
        return AppColors.error;
      case 'Cancelled':
        return AppColors.textLight;
      default:
        return AppColors.info;
    }
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
  final int passedCount;
  final String status;
  final String appliedDate;

  const _Timeline({
    required this.passedCount,
    required this.status,
    required this.appliedDate,
  });

  @override
  Widget build(BuildContext context) {
    final steps = [
      {'label': 'Application Submitted', 'date': appliedDate, 'done': true},
      {'label': 'Payment & Verification', 'date': 'Completed', 'done': true},
      {'label': 'Vision Test', 'date': passedCount >= 1 ? 'Passed' : 'Pending', 'done': passedCount >= 1, 'active': passedCount == 0 && status != 'Completed'},
      {'label': 'Theory Test', 'date': passedCount >= 2 ? 'Passed' : 'Pending', 'done': passedCount >= 2, 'active': passedCount == 1},
      {'label': 'Street Driving Test', 'date': passedCount >= 3 ? 'Passed' : 'Pending', 'done': passedCount >= 3, 'active': passedCount == 2},
      {'label': 'License Issued', 'date': status == 'Completed' ? 'Issued' : 'TBD', 'done': status == 'Completed', 'active': passedCount == 3 && status != 'Completed'},
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
