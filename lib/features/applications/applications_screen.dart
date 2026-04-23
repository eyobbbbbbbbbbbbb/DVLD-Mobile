import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/user_session.dart';
import 'services/application_service.dart';
import 'application_details_screen.dart';
import 'apply_license_screen.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;
  bool _loading = true;
  List<Map<String, dynamic>> _applications = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() => _selectedTab = _tabController.index));
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    setState(() => _loading = true);
    final apps = await ApplicationService.getApplicationStatus(UserSession.instance.personId);
    setState(() {
      _applications = apps;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        automaticallyImplyLeading: false,
        title: Text(
          'My Applications',
          style: GoogleFonts.poppins(
              fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        actions: [
          TextButton.icon(
            icon: Icon(Icons.add_rounded, color: AppColors.primary),
            label: Text('Apply',
                style: GoogleFonts.poppins(
                    color: AppColors.primary, fontWeight: FontWeight.w600)),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ApplyLicenseScreen()),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textLight,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle:
              GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w400),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(_applications),
                _buildList(_applications
                    .where((a) => a['status'] == 'New' || a['status'] == 'Approved')
                    .toList()),
                _buildList(_applications
                    .where((a) => a['status'] == 'Completed' || a['status'] == 'Rejected' || a['status'] == 'Cancelled')
                    .toList()),
              ],
            ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open_rounded, size: 60, color: AppColors.textLight),
            const SizedBox(height: 16),
            Text('No applications found',
                style: GoogleFonts.poppins(color: AppColors.textLight, fontSize: 15)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, i) => _AppItem(
        data: items[i],
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ApplicationDetailsScreen(
              applicationId: items[i]['applicationID'],
              ldlApplicationId: items[i]['ldlApplicationID'],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppItem extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const _AppItem({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusData = _statusData(data['status']);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.06),
              blurRadius: 12,
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
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                data['className'].toString().contains('Motorcycle') ? Icons.motorcycle_rounded : Icons.drive_eta_rounded, 
                color: AppColors.primary, 
                size: 26
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['className'] ?? 'New License',
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.tag_rounded, size: 12, color: AppColors.textLight),
                          const SizedBox(width: 3),
                          Text('APP-${data['applicationID']}',
                              style: GoogleFonts.poppins(
                                  fontSize: 11, color: AppColors.textLight)),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              size: 12, color: AppColors.textLight),
                          const SizedBox(width: 3),
                          Text(data['appliedDate'].toString().split('T').first,
                              style: GoogleFonts.poppins(
                                  fontSize: 11, color: AppColors.textLight)),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.fact_check_rounded,
                              size: 12, color: AppColors.textLight),
                          const SizedBox(width: 3),
                          Text('${data['passedExamsCount']}/3 Tests',
                              style: GoogleFonts.poppins(
                                  fontSize: 11, color: AppColors.textLight)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusData['bg'],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    statusData['label'],
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusData['color'],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 13, color: AppColors.textLight),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _statusData(String status) {
    switch (status) {
      case 'approved':
        return {
          'label': 'Approved',
          'color': AppColors.success,
          'bg': AppColors.successLight
        };
      case 'inProgress':
        return {
          'label': 'In Progress',
          'color': AppColors.info,
          'bg': AppColors.infoLight
        };
      case 'completed':
        return {
          'label': 'Completed',
          'color': AppColors.success,
          'bg': AppColors.successLight
        };
      case 'rejected':
        return {
          'label': 'Rejected',
          'color': AppColors.error,
          'bg': AppColors.errorLight
        };
      default:
        return {
          'label': 'Pending',
          'color': AppColors.warning,
          'bg': AppColors.warningLight
        };
    }
  }
}
