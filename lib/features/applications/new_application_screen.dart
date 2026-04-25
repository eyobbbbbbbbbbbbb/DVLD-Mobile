import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/theme/app_theme.dart';
import '../../core/services/user_session.dart';
import '../../core/widgets/app_button.dart';
import '../../core/api/models/license_class.dart';
import '../../core/api/models/driving_institute.dart';
import '../../core/api/services/institute_service.dart';
import 'services/application_service.dart';
import 'services/ocr_service.dart';

class NewApplicationScreen extends StatefulWidget {
  const NewApplicationScreen({super.key});

  @override
  State<NewApplicationScreen> createState() => _NewApplicationScreenState();
}

class _NewApplicationScreenState extends State<NewApplicationScreen> {
  int _currentStep = 0;
  bool _loading = false;

  // AI Scan state
  bool _scanning = false;
  bool _scanDone = false;
  final ImagePicker _picker = ImagePicker();
  
  List<LicenseClass> _classes = [];
  LicenseClass? _selectedClass;
  
  List<DrivingInstitute> _institutes = [];
  DrivingInstitute? _selectedInstitute;
  
  List<String> _cities = [];
  List<String> _regions = [];
  String? _selectedCity;
  String? _selectedRegion;
  double _applicationFee = 15.0; // Default fallback

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _loading = true);
    final classes = await ApplicationService.getLicenseClasses();
    final filters = await InstituteService.getFilters();
    final institutes = await InstituteService.getAllInstitutes();
    final appFee = await ApplicationService.getApplicationFee(1); // 1 = New Local License
    
    setState(() {
      _classes = classes;
      _cities = filters['cities']!;
      _regions = filters['regions']!;
      _institutes = institutes;
      _applicationFee = appFee > 0 ? appFee : 15.0;
      
      // Auto-select Class 3 (Ordinary Motor Vehicle) if available
      try {
        _selectedClass = _classes.firstWhere((c) => c.id == 3);
      } catch (_) {
        if (_classes.isNotEmpty) _selectedClass = _classes.first;
      }
      
      _loading = false;
    });
  }

  Future<void> _updateInstitutes() async {
    setState(() => _loading = true);
    final institutes = await InstituteService.getAllInstitutes(
      city: _selectedCity,
      region: _selectedRegion,
    );
    setState(() {
      _institutes = institutes;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'New License',
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading && _classes.isEmpty 
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              _buildStepper(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _buildCurrentStepContent(),
                ),
              ),
              _buildBottomBar(),
            ],
          ),
    );
  }

  Widget _buildStepper() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Row(
        children: [
          _stepItem(0, 'Class', Icons.card_membership_rounded),
          _connector(0),
          _stepItem(1, 'School', Icons.school_rounded),
          _connector(1),
          _stepItem(2, 'Confirm', Icons.check_circle_rounded),
        ],
      ),
    );
  }

  Widget _stepItem(int index, String label, IconData icon) {
    bool isActive = _currentStep == index;
    bool isDone = _currentStep > index;
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone ? AppColors.success : isActive ? AppColors.primary : AppColors.inputBg,
            ),
            child: Icon(
              isDone ? Icons.check : icon,
              size: 18,
              color: isDone || isActive ? Colors.white : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? AppColors.primary : AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _connector(int index) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      color: _currentStep > index ? AppColors.success : AppColors.divider,
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0: return _buildClassSelection();
      case 1: return _buildInstituteSelection();
      case 2: return _buildSummary();
      default: return const SizedBox();
    }
  }

  // ── AI ID Scanner ────────────────────────────────────────────────
  Future<void> _scanIdCard(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 90,
      maxWidth: 1280,
    );
    if (picked == null) return;

    setState(() => _scanning = true);
    final result = await OcrService.scanIdCard(File(picked.path));
    setState(() => _scanning = false);

    if (result != null && mounted) {
      final hasData = result.values.any((v) => v != null && v.isNotEmpty);
      if (hasData) {
        setState(() => _scanDone = true);
        _showScanResultDialog(result);
      } else {
        _showScanErrorSnack();
      }
    } else {
      _showScanErrorSnack();
    }
  }

  void _showScanErrorSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Could not read the ID. Try better lighting or enter manually.',
            style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showScanResultDialog(Map<String, String?> result) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('ID Scanned!', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Extracted from your Ethiopian Digital ID:',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 14),
              if (result['fullName'] != null)    _scanResultRow(Icons.person_rounded,        'Full Name',    result['fullName']!),
              if (result['dateOfBirth'] != null) _scanResultRow(Icons.cake_rounded,          'Date of Birth', result['dateOfBirth']!),
              if (result['gender'] != null)      _scanResultRow(Icons.wc_rounded,            'Gender',       result['gender']!),
              if (result['nationalId'] != null)  _scanResultRow(Icons.badge_rounded,         'FAN (Nat. ID)', result['nationalId']!),
              if (result['phone'] != null)       _scanResultRow(Icons.phone_rounded,         'Phone',        result['phone']!),
              if (result['nationality'] != null) _scanResultRow(Icons.flag_rounded,          'Nationality',  result['nationality']!),
              if (result['address'] != null)     _scanResultRow(Icons.location_on_rounded,   'Address',      result['address']!),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.infoLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Please review these details before proceeding. You can still edit them manually.',
                  style: GoogleFonts.poppins(fontSize: 11, color: AppColors.info),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Looks Good ✓', style: GoogleFonts.poppins(
                color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _scanResultRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textLight)),
              Text(value, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
  // ── End AI Scanner ───────────────────────────────────────────────

  Widget _buildClassSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── AI ID Scan Banner ──────────────────────────────────────
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: _scanDone
                ? LinearGradient(colors: [AppColors.success.withOpacity(0.15), AppColors.success.withOpacity(0.05)])
                : LinearGradient(colors: [AppColors.primary.withOpacity(0.12), AppColors.primary.withOpacity(0.04)]),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _scanDone ? AppColors.success.withOpacity(0.4) : AppColors.primary.withOpacity(0.2),
            ),
          ),
          child: _scanning
              ? Row(
                  children: [
                    const SizedBox(width: 4),
                    const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5)),
                    const SizedBox(width: 14),
                    Text('Reading your ID card...',
                        style: GoogleFonts.poppins(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w500)),
                  ],
                )
              : Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: (_scanDone ? AppColors.success : AppColors.primary).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _scanDone ? Icons.check_circle_rounded : Icons.document_scanner_rounded,
                        color: _scanDone ? AppColors.success : AppColors.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _scanDone ? 'ID Scanned Successfully ✓' : 'Auto-fill with AI Scan',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _scanDone ? AppColors.success : AppColors.primary,
                            ),
                          ),
                          Text(
                            _scanDone
                                ? 'Your details have been extracted.'
                                : 'Snap your National ID to fill details instantly.',
                            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    if (!_scanDone)
                      PopupMenuButton<ImageSource>(
                        onSelected: _scanIdCard,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: ImageSource.camera,
                            child: Row(children: [
                              const Icon(Icons.camera_alt_rounded, size: 18),
                              const SizedBox(width: 10),
                              Text('Camera', style: GoogleFonts.poppins()),
                            ]),
                          ),
                          PopupMenuItem(
                            value: ImageSource.gallery,
                            child: Row(children: [
                              const Icon(Icons.photo_library_rounded, size: 18),
                              const SizedBox(width: 10),
                              Text('Gallery', style: GoogleFonts.poppins()),
                            ]),
                          ),
                        ],
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('Scan', style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () => setState(() => _scanDone = false),
                        child: Text('Re-scan', style: GoogleFonts.poppins(
                            fontSize: 12, color: AppColors.textLight, decoration: TextDecoration.underline)),
                      ),
                  ],
                ),
        ),
        // ── End Scan Banner ────────────────────────────────────────
        Text(
          'Select License Class',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose the type of vehicle you want to drive',
          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        ..._classes.map((c) {
          bool isSelected = _selectedClass?.id == c.id;
          return GestureDetector(
            onTap: () => setState(() => _selectedClass = c),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.05) : AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.divider,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      c.name.contains('Motorcycle') ? Icons.motorcycle_rounded : Icons.directions_car_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
                        Text(c.description, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  if (isSelected) const Icon(Icons.check_circle_rounded, color: AppColors.primary),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildInstituteSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Training School', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _filterDropdown('City', _selectedCity, _cities, (v) {
              setState(() => _selectedCity = v);
              _updateInstitutes();
            })),
            const SizedBox(width: 12),
            Expanded(child: _filterDropdown('Region', _selectedRegion, _regions, (v) {
              setState(() => _selectedRegion = v);
              _updateInstitutes();
            })),
          ],
        ),
        const SizedBox(height: 24),
        if (_loading) const Center(child: CircularProgressIndicator())
        else ..._institutes.map((inst) {
          bool isSelected = _selectedInstitute?.id == inst.id;
          return GestureDetector(
            onTap: () => setState(() => _selectedInstitute = inst),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accentLight : AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? AppColors.accent : AppColors.divider),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.inputBg,
                    child: Icon(Icons.school, size: 20, color: isSelected ? AppColors.accent : AppColors.textLight),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(inst.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 10, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text('${inst.city}, ${inst.region}', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text('Capacity: ${inst.capacity}', style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textLight, fontWeight: FontWeight.w500)),
                            const SizedBox(width: 8),
                            Text('Phone: ${inst.phone}', style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textLight)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isSelected) const Icon(Icons.check_circle, color: AppColors.accent),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _filterDropdown(String label, String? val, List<String> items, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: val,
          isExpanded: true,
          hint: Text(label, style: GoogleFonts.poppins(fontSize: 12)),
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: GoogleFonts.poppins(fontSize: 12)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            children: [
              const Icon(Icons.description_rounded, size: 48, color: AppColors.primary),
              const SizedBox(height: 16),
              Text('Application Summary', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
              const Divider(height: 40),
              _summaryRow('License Class', _selectedClass?.name ?? ''),
              _summaryRow('Training School', _selectedInstitute?.name ?? ''),
              _summaryRow('Location', _selectedInstitute?.address ?? ''),
              const Divider(height: 32),
              _summaryRow('Application Fee', '\$${_applicationFee.toStringAsFixed(2)}'),
              _summaryRow('Class Fees', '\$${_selectedClass?.fees.toStringAsFixed(2)}'),
              const Divider(height: 40),
              _summaryRow('Total to Pay', '\$${(_applicationFee + (_selectedClass?.fees ?? 0)).toStringAsFixed(2)}', isBold: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String val, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14)),
          Text(val, style: GoogleFonts.poppins(fontWeight: isBold ? FontWeight.w700 : FontWeight.w500, fontSize: 14, color: isBold ? AppColors.primary : AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    bool canProceed = (_currentStep == 0 && _selectedClass != null) || (_currentStep == 1 && _selectedInstitute != null) || (_currentStep == 2);
    
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      color: AppColors.white,
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(child: AppButton(label: 'Back', variant: AppButtonVariant.outline, onPressed: () => setState(() => _currentStep--))),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: AppButton(
              label: _currentStep == 2 ? 'Submit' : 'Next',
              onPressed: canProceed ? () {
                if (_currentStep < 2) {
                  setState(() => _currentStep++);
                } else {
                  _handleSubmit();
                }
              } : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    setState(() => _loading = true);
    final result = await ApplicationService.submitLocalApplication(
      personId: UserSession.instance.personId, 
      licenseClassId: _selectedClass!.id,
      instituteId: _selectedInstitute!.id,
    );

    if (mounted) {
      setState(() => _loading = false);
      if (result['success']) {
        _showSuccessDialog(result['data']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'])));
      }
    }
  }

  void _showSuccessDialog(dynamic data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 64),
                  const SizedBox(height: 16),
                  Text('Payment Successful!', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text('Your payment has been processed. A confirmation has been sent to your email.', 
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
                  ),
                  
                  // Official Receipt Card
                  Container(
                    margin: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: Column(
                      children: [
                        // Blue Header
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Color(0xFF1A45A0),
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 32),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Official Receipt', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                                  Text('Ministry of Interior — Traffic Dept.', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // Details
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                               _receiptRow('Receipt No.', 'RCP-2026-00${data['ApplicationID'] ?? '893'}'),
                              _receiptRow('Date', 'May 5, 2026 — 12:45 PM'),
                              _receiptRow('Applicant', UserSession.instance.fullName),
                              _receiptRow('Service', 'New License — ${_selectedClass?.name}'),
                              _receiptRow('Institute', _selectedInstitute?.name ?? ''),
                              _receiptRow('Payment Method', 'Credit Card'),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Divider(color: Color(0xFFEEEEEE)),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Total Paid', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF1A45A0))),
                                  Text('USD ${(_applicationFee + (_selectedClass?.fees ?? 0)).toStringAsFixed(2)}', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF1A45A0))),
                                ],
                              ),
                            ],
                          ),
                        ),
                              const SizedBox(height: 24),
                              
                              // Barcode area
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F9FB),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(20, (i) => Container(
                                        width: i % 3 == 0 ? 3 : 2,
                                        height: 32,
                                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                        color: const Color(0xFF1A45A0).withOpacity(i % 5 == 0 ? 0.3 : 0.8),
                                      )),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('RCP-2026-00${data['ApplicationID'] ?? '893'}', style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey, letterSpacing: 2)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Download Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text('Download Receipt'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1A45A0),
                        side: const BorderSide(color: Color(0xFF1A45A0)),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Text('Back to Home', style: GoogleFonts.poppins(color: Colors.grey, fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
  }

  Widget _receiptRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
          Text(val, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF1A45A0))),
        ],
      ),
    );
  }
}
