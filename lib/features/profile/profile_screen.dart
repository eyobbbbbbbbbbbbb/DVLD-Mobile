import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/user_session.dart';
import '../../core/services/theme_service.dart';
import '../license/license_details_screen.dart';
import '../license/driving_history_screen.dart';
import 'edit_profile_screen.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(34),
                  bottomRight: Radius.circular(34),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 58, 24, 32),
              child: Column(
                children: [
                  // Avatar
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(Icons.person_rounded,
                            color: Colors.white, size: 48),
                      ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.edit_rounded,
                            color: Colors.white, size: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(UserSession.instance.fullName,
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('National ID: ${UserSession.instance.maskedId}',
                      style: GoogleFonts.poppins(
                          color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text('Verified Account',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ProfileStat(label: 'Applications', value: '4'),
                      Container(width: 1, height: 36, color: Colors.white24),
                      _ProfileStat(label: 'Licenses', value: '2'),
                      Container(width: 1, height: 36, color: Colors.white24),
                      _ProfileStat(label: 'Violations', value: '0'),
                    ],
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
                  // Personal Info
                  Text('Personal Information',
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  _InfoCard(children: [
                    _InfoTile(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: UserSession.instance.phone.isNotEmpty ? UserSession.instance.phone : 'Not provided'),
                    _InfoTile(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: UserSession.instance.email),
                    _InfoTile(
                        icon: Icons.cake_outlined,
                        label: 'Date of Birth',
                        value: UserSession.instance.dateOfBirth.isNotEmpty ? UserSession.instance.dateOfBirth : 'Not provided'),
                    _InfoTile(
                        icon: Icons.location_on_outlined,
                        label: 'Address',
                        value: UserSession.instance.address.isNotEmpty ? UserSession.instance.address : 'Not provided',
                        isLast: true),
                  ]),
                  const SizedBox(height: 24),

                  Text('License & History',
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  _MenuCard(children: [
                    _MenuItem(
                      icon: Icons.credit_card_rounded,
                      iconColor: AppColors.primary,
                      label: 'License Details',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const LicenseDetailsScreen()),
                      ),
                    ),
                    _MenuItem(
                      icon: Icons.history_rounded,
                      iconColor: AppColors.accent,
                      label: 'Driving History',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const DrivingHistoryScreen()),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 16),
                  Text('Account Settings',
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  _MenuCard(children: [
                    _MenuItem(
                      icon: Icons.edit_outlined,
                      iconColor: const Color(0xFF8E24AA),
                      label: 'Edit Profile & Documents',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const EditProfileScreen()),
                      ),
                    ),
                    _MenuItem(
                      icon: Icons.notifications_outlined,
                      iconColor: AppColors.warning,
                      label: 'Notification Preferences',
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.lock_outline_rounded,
                      iconColor: AppColors.info,
                      label: 'Change Password',
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.language_outlined,
                      iconColor: Colors.teal,
                      label: 'Language',
                      trailing: Text('English',
                          style: GoogleFonts.poppins(
                              fontSize: 13, color: AppColors.textSecondary)),
                      onTap: () {},
                    ),
                    ValueListenableBuilder(
                      valueListenable: ThemeService.instance.isDarkModeNotifier,
                      builder: (context, isDark, _) {
                        return _MenuItem(
                          icon: isDark
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          iconColor: Colors.indigo,
                          label: 'Dark Mode',
                          trailing: Switch.adaptive(
                            value: isDark,
                            onChanged: (_) => ThemeService.instance.toggleTheme(),
                            activeColor: AppColors.accent,
                          ),
                          onTap: () => ThemeService.instance.toggleTheme(),
                        );
                      },
                    ),
                  ]),

                  const SizedBox(height: 16),
                  _MenuCard(children: [
                    _MenuItem(
                      icon: Icons.logout_rounded,
                      iconColor: AppColors.error,
                      label: 'Sign Out',
                      labelColor: AppColors.error,
                      onTap: () {
                        UserSession.instance.logout();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                          (_) => false,
                        );
                      },
                    ),
                  ]),
                  const SizedBox(height: 30),
                  Center(
                    child: Text('DVLD App v1.0.0',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: AppColors.textLight)),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;
  const _ProfileStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.poppins(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
        Text(label,
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

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
      child: Column(children: children),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;
  const _InfoTile(
      {required this.icon,
      required this.label,
      required this.value,
      this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: AppColors.textLight)),
                  Text(value,
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary)),
                ],
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, indent: 48),
      ],
    );
  }
}

class _MenuCard extends StatelessWidget {
  final List<Widget> children;
  const _MenuCard({required this.children});

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
      child: Column(children: children),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Color? labelColor;
  final Widget? trailing;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.labelColor,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 19),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: labelColor ?? AppColors.textPrimary,
                ),
              ),
            ),
            trailing ??
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}
