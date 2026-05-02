import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/user_session.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_input.dart';
import 'required_documents_screen.dart';

class ApplyLicenseScreen extends StatefulWidget {
  const ApplyLicenseScreen({super.key});

  @override
  State<ApplyLicenseScreen> createState() => _ApplyLicenseScreenState();
}

class _ApplyLicenseScreenState extends State<ApplyLicenseScreen> {
  String _selectedType = 'new';
  String _selectedClass = 'Class 3 - Ordinary driving license';
  String _selectedInstitute = 'Fenan Driving Institute';
  bool _loading = false;

  final List<Map<String, dynamic>> _licenseTypes = [
    {
      'id': 'new',
      'title': 'New License',
      'subtitle': 'First-time applicants',
      'icon': Icons.add_card_rounded,
      'color': const Color(0xFF3D5AFE),
    },
    {
      'id': 'renewal',
      'title': 'Renewal',
      'subtitle': 'Renew your current license',
      'icon': Icons.autorenew_rounded,
      'color': const Color(0xFF00C853),
    },
    {
      'id': 'replacement',
      'title': 'Replacement',
      'subtitle': 'Lost or damaged license',
      'icon': Icons.find_replace_rounded,
      'color': const Color(0xFFFF6D00),
    },
    {
      'id': 'international',
      'title': 'International',
      'subtitle': 'International driving permit',
      'icon': Icons.language_rounded,
      'color': const Color(0xFF8E24AA),
    },
  ];

  final List<String> _institutes = [
    'Fenan Driving Institute',
    'Geda Drivers Training Institute',
    'Beka Driving Training Center',
  ];

  final List<String> _licenseClasses = [
    'Class 1 - Small Motorcycle',
    'Class 2 - Heavy Motorcycle License',
    'Class 3 - Ordinary driving license',
    'Class 4 - Commercial',
    'Class 5 - Agricultural',
    'Class 6 - Small and medium bus',
    'Class 7 - Truck and heavy vehicle',
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
        title: Text(
          'New Application',
          style: GoogleFonts.poppins(
              fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selection Info
            Text('Application Details',
                style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text('Complete the information below to proceed.',
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 24),

            Text('Driving Institute',
                style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedInstitute,
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary),
                  style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary),
                  items: _institutes
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedInstitute = v ?? _selectedInstitute),
                ),
              ),
            ),

            const SizedBox(height: 24),
            Text('License Class',
                style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedClass,
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary),
                  style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary),
                  items: _licenseClasses
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedClass = v ?? _selectedClass),
                ),
              ),
            ),

            const SizedBox(height: 24),
            Text('Applicant Information',
                style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Container(
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
              child: Column(
                children: [
                  _InfoRow(label: 'Full Name', value: UserSession.instance.fullName),
                  const Divider(height: 24),
                  _InfoRow(label: 'National ID', value: UserSession.instance.maskedId),
                  const Divider(height: 24),
                  _InfoRow(label: 'Date of Birth', value: UserSession.instance.dateOfBirth.isNotEmpty ? UserSession.instance.dateOfBirth : 'Not provided'),
                  const Divider(height: 24),
                  _InfoRow(label: 'Phone', value: UserSession.instance.phone.isNotEmpty ? UserSession.instance.phone : 'Not provided'),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Text('Medical Fitness',
                style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            AppInput(
              label: 'Medical Certificate No.',
              hint: 'Enter certificate reference number',
              prefixIcon: Icons.medical_information_outlined,
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Application fee of ETB 10 will be charged. Vision test appointment will be scheduled automatically.',
                      style:
                          GoogleFonts.poppins(fontSize: 12, color: Colors.orange[800]),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
            AppButton(
              label: 'Proceed to Documents',
              icon: Icons.arrow_forward_rounded,
              isLoading: _loading,
              onPressed: () async {
                setState(() => _loading = true);
                await Future.delayed(const Duration(seconds: 1));
                if (mounted) {
                  setState(() => _loading = false);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const RequiredDocumentsScreen()),
                  );
                }
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
        Text(value,
            style: GoogleFonts.poppins(
                fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
      ],
    );
  }
}
