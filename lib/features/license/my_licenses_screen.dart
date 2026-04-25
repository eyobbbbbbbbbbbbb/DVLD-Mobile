import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/user_session.dart';
import '../license/services/license_service.dart';
import '../license/services/international_license_service.dart';
import '../license/digital_license_screen.dart';
import '../license/digital_international_license_screen.dart';
import 'release_detained_screen.dart';

class MyLicensesScreen extends StatefulWidget {
  const MyLicensesScreen({super.key});

  @override
  State<MyLicensesScreen> createState() => _MyLicensesScreenState();
}

class _MyLicensesScreenState extends State<MyLicensesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _loadingLocal = true;
  bool _loadingIntl = true;
  List<Map<String, dynamic>> _localLicenses = [];
  List<Map<String, dynamic>> _intlLicenses = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAllLicenses();
  }

  Future<void> _loadAllLicenses() async {
    _loadLocal();
    _loadIntl();
  }

  Future<void> _loadLocal() async {
    final data = await LicenseService.getPersonLicenses(UserSession.instance.personId);
    if (mounted) {
      setState(() {
        _localLicenses = data;
        _loadingLocal = false;
      });
    }
  }

  Future<void> _loadIntl() async {
    final data = await InternationalLicenseService.getPersonLicenses(UserSession.instance.personId);
    if (mounted) {
      setState(() {
        _intlLicenses = data;
        _loadingIntl = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('My Licenses',
            style: GoogleFonts.poppins(
                fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        backgroundColor: AppColors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
          tabs: const [
            Tab(text: 'Local'),
            Tab(text: 'International'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLocalList(),
          _buildIntlList(),
        ],
      ),
    );
  }

  Widget _buildLocalList() {
    if (_loadingLocal) return const Center(child: CircularProgressIndicator());
    if (_localLicenses.isEmpty) return _buildEmptyState('No local licenses found.');

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _localLicenses.length,
      itemBuilder: (context, i) => _buildLicenseCard(_localLicenses[i], isInternational: false),
    );
  }

  Widget _buildIntlList() {
    if (_loadingIntl) return const Center(child: CircularProgressIndicator());
    if (_intlLicenses.isEmpty) return _buildEmptyState('No international permits found.');

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _intlLicenses.length,
      itemBuilder: (context, i) => _buildLicenseCard(_intlLicenses[i], isInternational: true),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.credit_card_off_rounded, size: 64, color: AppColors.textLight.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(message, style: GoogleFonts.poppins(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildLicenseCard(Map<String, dynamic> lic, {required bool isInternational}) {
    final bool isDetained = lic['isDetained'] ?? false;
    final bool isActive = lic['isActive'] ?? true;
    final String title = isInternational ? 'International Permit' : lic['className'];
    final String idLabel = isInternational ? 'INTL#' : 'LIC#';
    final int id = isInternational ? lic['internationalLicenseID'] : lic['licenseID'];
    final Color activeColor = isInternational ? Colors.purple : (isDetained ? AppColors.error : AppColors.success);

    return GestureDetector(
      onTap: () async {
        if (isDetained) {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ReleaseDetainedScreen(licenseId: id)),
          );
          _loadAllLicenses();
        } else if (isInternational) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => DigitalInternationalLicenseScreen(license: lic)),
          );
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => DigitalLicenseScreen(licenseId: id)),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: activeColor.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
                color: isDetained ? AppColors.error.withOpacity(0.5) : (isActive ? activeColor.withOpacity(0.3) : AppColors.divider),
                width: isDetained ? 1.5 : 1
            )
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isDetained ? AppColors.error : (isActive ? activeColor : AppColors.textLight)).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                  isDetained ? Icons.lock_rounded : (isInternational ? Icons.public_rounded : Icons.credit_card_rounded),
                  color: isDetained ? AppColors.error : (isActive ? activeColor : AppColors.textLight), size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title,
                          style: GoogleFonts.poppins(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          )),
                      if (isDetained) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('DETAINED', style: GoogleFonts.poppins(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                        ),
                      ]
                    ],
                  ),
                  Text('$idLabel $id — Exp: ${lic['expirationDate'].toString().split('T').first}',
                      style: GoogleFonts.poppins(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      )),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textLight.withOpacity(0.5))
          ],
        ),
      ),
    );
  }
}
