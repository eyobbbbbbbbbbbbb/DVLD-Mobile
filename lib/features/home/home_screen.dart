import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/user_session.dart';
import '../../core/widgets/app_card.dart';
import '../applications/applications_screen.dart';
import '../applications/new_application_screen.dart';
import '../applications/renewal_options_screen.dart';
import '../applications/international_application_screen.dart';
import '../applications/services/application_service.dart';
import '../license/driving_history_screen.dart';
import '../license/services/license_service.dart';
import '../exams/my_exams_screen.dart';
import '../training/training_status_screen.dart';
import '../license/release_detained_screen.dart';
import '../license/digital_license_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
import '../../core/api/services/message_service.dart';
import 'package:provider/provider.dart';
import '../../core/providers/notification_provider.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _HomeDashboard(),
    const ApplicationsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isActive: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavItem(
                  icon: Icons.folder_open_rounded,
                  label: 'Applications',
                  isActive: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  isActive: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accentLight : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: isActive ? AppColors.primary : AppColors.textLight,
                size: 22),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HomeDashboard extends StatefulWidget {
  const _HomeDashboard();

  @override
  State<_HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<_HomeDashboard> {
  bool _loading = true;
  Map<String, dynamic>? _activeLicense;
  List<Map<String, dynamic>> _recentApps = [];
  int _examCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _loading = true);
    
    final results = await Future.wait([
      LicenseService.getPersonLicenses(UserSession.instance.personId),
      ApplicationService.getApplicationStatus(UserSession.instance.personId),
    ]);

    final List<Map<String, dynamic>> licenses = results[0] as List<Map<String, dynamic>>;
    final List<Map<String, dynamic>> apps = results[1] as List<Map<String, dynamic>>;

    setState(() {
      // Get most recent active license
      _activeLicense = licenses.where((l) => l['isActive']).firstOrNull;
      
      // Get top 3 recent applications
      _recentApps = apps.take(3).toList();
      
      // Total exams passed across applications
      _examCount = apps.fold(0, (sum, app) => sum + (app['passedExamsCount'] as int));
      
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(34),
                  bottomRight: Radius.circular(34),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good Morning,',
                            style: GoogleFonts.poppins(
                              color: AppColors.white.withOpacity(0.75),
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            UserSession.instance.firstName,
                            style: GoogleFonts.poppins(
                              color: AppColors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _NotificationIcon(),
                          const SizedBox(width: 10),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.person_rounded,
                                color: AppColors.white, size: 22),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // License card
                  if (_activeLicense != null)
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => DigitalLicenseScreen(licenseId: _activeLicense!['licenseID'])),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.white.withOpacity(0.2), width: 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.credit_card_rounded,
                                color: AppColors.white, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Active License',
                                    style: GoogleFonts.poppins(
                                      color: AppColors.white.withOpacity(0.75),
                                      fontSize: 12,
                                    )),
                                Text('${_activeLicense!['className']} — Expires ${_activeLicense!['expirationDate'].toString().split('T').first}',
                                    style: GoogleFonts.poppins(
                                      color: AppColors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    )),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              'Active',
                              style: GoogleFonts.poppins(
                                color: AppColors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  else
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.white.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: AppColors.white70),
                          const SizedBox(width: 12),
                          Text('No active license found.', 
                            style: GoogleFonts.poppins(color: AppColors.white70, fontSize: 13)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Services
                  Text(
                    'Services',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.4,
                    children: [
                      _QuickAction(
                        icon: Icons.add_card_rounded,
                        label: 'New\nApplication',
                        color: const Color(0xFF3D5AFE),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const NewApplicationScreen()),
                        ),
                      ),
                      _QuickAction(
                        icon: Icons.autorenew_rounded,
                        label: 'Renew /\nReplace',
                        color: const Color(0xFF00C853),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const RenewalOptionsScreen()),
                        ),
                      ),
                      _QuickAction(
                        icon: Icons.event_note_rounded,
                        label: 'Book an\nExam',
                        color: const Color(0xFFFF6D00),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const MyExamsScreen()),
                        ),
                      ),
                      _QuickAction(
                        icon: Icons.lock_open_rounded,
                        label: 'Release\nDetained',
                        color: const Color(0xFFE53935),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) =>
                                  const ReleaseDetainedScreen()),
                        ),
                      ),
                      _QuickAction(
                        icon: Icons.public_rounded,
                        label: 'International\nLicense',
                        color: const Color(0xFF8E24AA),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const InternationalApplicationScreen()),
                        ),
                      ),
                      _QuickAction(
                        icon: Icons.school_rounded,
                        label: 'Training\nHub',
                        color: const Color(0xFFFBC02D),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const TrainingStatusScreen()),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Recent Applications
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Applications',
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text('See All',
                            style: GoogleFonts.poppins(
                              color: AppColors.accent,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._recentApps.map((app) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _RecentAppCard(
                      type: app['className'],
                      date: app['appliedDate'].toString().split('T').first,
                      status: app['status'],
                      statusColor: app['status'] == 'Completed' ? AppColors.success :
                                   app['status'] == 'Cancelled' ? AppColors.textLight :
                                   AppColors.info,
                      statusBg: app['status'] == 'Completed' ? AppColors.successLight :
                                 app['status'] == 'Cancelled' ? AppColors.divider :
                                 AppColors.infoLight,
                      icon: Icons.drive_eta_rounded,
                    ),
                  )),
                  if (_recentApps.isEmpty)
                    Text('No recent applications.', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textLight)),
                  const SizedBox(height: 18),

                  // Stats
                  Text(
                    'Your Overview',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                   Row(
                    children: [
                      Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const DrivingHistoryScreen()),
                            ),
                            child: _StatCard(
                                label: 'Applications',
                                value: _recentApps.length.toString(),
                                icon: Icons.folder_rounded,
                                color: AppColors.primary),
                          )),
                      const SizedBox(width: 12),
                      Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const DrivingHistoryScreen()),
                            ),
                            child: _StatCard(
                                label: 'Exams Passed',
                                value: _examCount.toString(),
                                icon: Icons.school_rounded,
                                color: AppColors.accent),
                          )),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _StatCard(
                              label: 'Violations',
                              value: '0',
                              icon: Icons.shield_rounded,
                              color: AppColors.success)),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.12),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentAppCard extends StatelessWidget {
  final String type;
  final String date;
  final String status;
  final Color statusColor;
  final Color statusBg;
  final IconData icon;

  const _RecentAppCard({
    required this.type,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.statusBg,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 3),
                Text(date,
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: AppColors.textLight)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              status,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 8),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 10, color: AppColors.textLight),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
class _NotificationIcon extends StatefulWidget {
  const _NotificationIcon();

  @override
  State<_NotificationIcon> createState() => _NotificationIconState();
}

class _NotificationIconState extends State<_NotificationIcon> {
  StreamSubscription? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    // Listen for new notifications to show the popup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<NotificationProvider>(context, listen: false);
      _notificationSubscription = provider.onNewNotification.listen((_) {
        _showNewNotificationAlert();
      });
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  void _showNewNotificationAlert() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('New Notification', 
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                  Text('You have a new update from DVLD.', 
                    style: GoogleFonts.poppins(fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 160,
          right: 20,
          left: 20,
        ),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'VIEW',
          textColor: AppColors.accent,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        final unreadCount = provider.unreadCount;
        
        return GestureDetector(
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            );
            provider.refreshManual();
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.notifications_outlined, color: AppColors.white, size: 22),
                if (unreadCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.warning,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Center(
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: GoogleFonts.poppins(
                            color: AppColors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
