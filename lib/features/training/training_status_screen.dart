import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/user_session.dart';
import './services/training_service.dart';
import './institutes_list_screen.dart';
import 'package:intl/intl.dart';

class TrainingStatusScreen extends StatefulWidget {
  const TrainingStatusScreen({super.key});

  @override
  State<TrainingStatusScreen> createState() => _TrainingStatusScreenState();
}

class _TrainingStatusScreenState extends State<TrainingStatusScreen> {
  final TrainingService _trainingService = TrainingService();
  bool _loading = true;
  Map<String, dynamic>? _status;
  List<Map<String, dynamic>> _announcements = [];
  List<Map<String, dynamic>> _attendance = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final personId = UserSession.instance.personId;
      if (personId == null) return;

      // 1. Load Status
      final status = await _trainingService.getStudentStatus(personId);
      
      if (status != null) {
        final instituteId = status['instituteID'];
        final batch = status['batch'];

        // 2. Load Announcements
        final announcements = await _trainingService.getAnnouncements(
          instituteId,
          batchId: batch != null ? batch['batchID'] : null,
        );

        // 3. Load Attendance (if batch exists)
        List<Map<String, dynamic>> attendance = [];
        if (batch != null) {
          attendance = await _trainingService.getAttendanceHistory(batch['batchID']);
        }

        setState(() {
          _status = status;
          _announcements = announcements;
          _attendance = attendance;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      print('Error loading training data: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Training Hub'),
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _status == null
              ? _buildNoEnrollment()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInstituteCard(),
                        const SizedBox(height: 24),
                        if (_status!['batch'] != null) ...[
                          _buildBatchCard(),
                          const SizedBox(height: 24),
                        ],
                        _buildAnnouncementsSection(),
                        const SizedBox(height: 24),
                        if (_status!['batch'] != null) _buildAttendanceSection(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildNoEnrollment() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 80, color: AppColors.textLight),
            const SizedBox(height: 24),
            Text(
              'Not Enrolled Yet',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You are not currently enrolled in any driving institute. Please choose an institute to start your training.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const InstitutesListScreen()),
                );
                if (result == true) {
                  _loadData();
                }
              },
              icon: const Icon(Icons.search_rounded),
              label: const Text('Browse Institutes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstituteCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.business_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assigned Institute',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _status!['instituteName'],
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn('Status', _status!['status'], Colors.white),
              _buildInfoColumn(
                'Joined On',
                DateFormat('MMM dd, yyyy').format(DateTime.parse(_status!['enrollmentDate'])),
                Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBatchCard() {
    final batch = _status!['batch'];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.groups_rounded, color: AppColors.accent, size: 24),
              const SizedBox(width: 12),
              Text(
                'Training Batch',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            batch['batchName'],
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                '${DateFormat('MMM dd').format(DateTime.parse(batch['startDate']))} - ${DateFormat('MMM dd, yyyy').format(DateTime.parse(batch['endDate']))}',
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Broadcasts',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            if (_announcements.isNotEmpty)
              Text(
                'Latest first',
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textLight),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (_announcements.isEmpty)
          _buildEmptyState('No announcements from school yet.', Icons.notifications_off_outlined)
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _announcements.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = _announcements[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.infoLight.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item['title'],
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.info,
                            ),
                          ),
                        ),
                        Text(
                          DateFormat('MMM dd').format(DateTime.parse(item['dateCreated'])),
                          style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textLight),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['content'],
                      style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildAttendanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attendance History',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        if (_attendance.isEmpty)
          _buildEmptyState('No attendance marked yet.', Icons.fact_check_outlined)
        else
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.divider),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _attendance.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.divider),
              itemBuilder: (context, index) {
                final item = _attendance[index];
                final bool isPresent = item['isPresent'] ?? false;
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isPresent ? AppColors.successLight : AppColors.errorLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPresent ? Icons.check_rounded : Icons.close_rounded,
                      size: 16,
                      color: isPresent ? AppColors.success : AppColors.error,
                    ),
                  ),
                  title: Text(
                    DateFormat('EEEE, MMM dd').format(DateTime.parse(item['date'])),
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  trailing: Text(
                    isPresent ? 'PRESENT' : 'ABSENT',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isPresent ? AppColors.success : AppColors.error,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(String msg, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, style: BorderStyle.none),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.textLight.withOpacity(0.5), size: 40),
          const SizedBox(height: 12),
          Text(
            msg,
            style: GoogleFonts.poppins(color: AppColors.textLight, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: color.withOpacity(0.7),
            fontSize: 11,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
