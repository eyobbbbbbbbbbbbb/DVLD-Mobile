import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/user_session.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_input.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Edit Profile',
            style: GoogleFonts.poppins(
                fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        backgroundColor: AppColors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textLight,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
          unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w400, fontSize: 13),
          tabs: const [
            Tab(text: 'Personal Info'),
            Tab(text: 'Documents'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPersonalTab(),
          _buildDocumentsTab(),
        ],
      ),
    );
  }

  Widget _buildPersonalTab() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Avatar change
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: AppColors.accentLight,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.divider, width: 2),
                        ),
                        child: Icon(Icons.person_rounded,
                            color: AppColors.primary, size: 50),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt_rounded,
                              color: Colors.white, size: 15),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text('Change Photo',
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: AppColors.accent, fontWeight: FontWeight.w500)),
                const SizedBox(height: 28),
                AppInput(
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  prefixIcon: Icons.person_outline_rounded,
                  initialValue: UserSession.instance.fullName,
                ),
                const SizedBox(height: 16),
                AppInput(
                  label: 'Phone Number',
                  hint: '+962 7X XXX XXXX',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  initialValue: UserSession.instance.phone,
                ),
                const SizedBox(height: 16),
                AppInput(
                  label: 'Email Address',
                  hint: 'example@email.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  initialValue: UserSession.instance.email,
                ),
                const SizedBox(height: 16),
                AppInput(
                  label: 'Address',
                  hint: 'Enter your address',
                  prefixIcon: Icons.location_on_outlined,
                  maxLines: 2,
                  initialValue: UserSession.instance.address,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline_rounded,
                          color: AppColors.warning, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'National ID and Date of Birth cannot be changed. Contact the branch for corrections.',
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.orange[800]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          color: AppColors.white,
          child: AppButton(
            label: 'Save Changes',
            icon: Icons.save_rounded,
            isLoading: _loading,
            onPressed: () async {
              setState(() => _loading = true);
              await Future.delayed(const Duration(seconds: 2));
              if (mounted) {
                setState(() => _loading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Profile updated successfully!',
                        style: GoogleFonts.poppins()),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsTab() {
    final docs = [
      {
        'title': 'National ID (Front)',
        'status': 'Verified',
        'date': 'Apr 4, 2026',
        'icon': Icons.badge_outlined,
        'isVerified': true,
      },
      {
        'title': 'National ID (Back)',
        'status': 'Verified',
        'date': 'Apr 4, 2026',
        'icon': Icons.badge_outlined,
        'isVerified': true,
      },
      {
        'title': 'Personal Photo',
        'status': 'Verified',
        'date': 'Apr 4, 2026',
        'icon': Icons.face_retouching_natural,
        'isVerified': true,
      },
      {
        'title': 'Medical Certificate',
        'status': 'Pending Review',
        'date': 'Apr 3, 2026',
        'icon': Icons.medical_information_outlined,
        'isVerified': false,
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Uploaded Documents',
              style: GoogleFonts.poppins(
                  fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          ...docs.map((d) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: (d['isVerified'] as bool)
                            ? AppColors.successLight
                            : AppColors.warningLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(d['icon'] as IconData,
                          color: (d['isVerified'] as bool)
                              ? AppColors.success
                              : AppColors.warning,
                          size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d['title'] as String,
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary)),
                          Text('Uploaded: ${d['date']}',
                              style: GoogleFonts.poppins(
                                  fontSize: 11, color: AppColors.textLight)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (d['isVerified'] as bool)
                                ? AppColors.successLight
                                : AppColors.warningLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(d['status'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: (d['isVerified'] as bool)
                                    ? AppColors.success
                                    : AppColors.warning,
                              )),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () {},
                          child: Text('Replace',
                              style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 20),
          Text('Upload New Document',
              style: GoogleFonts.poppins(
                  fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.accentLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.cloud_upload_rounded,
                          color: AppColors.primary, size: 30),
                  ),
                  const SizedBox(height: 12),
                  Text('Tap to Upload',
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary)),
                  Text('JPG, PNG, PDF — Max 5MB',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppColors.textLight)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
