import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_input.dart';

import '../../core/api/models/driving_institute.dart';
import '../../core/api/services/institute_service.dart';
import '../../core/api/models/country.dart';
import '../../core/api/services/country_service.dart';
import '../../core/api/api_client.dart';
import 'services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _loading = false;
  String _selectedGender = 'Male';
  final _dobController = TextEditingController(text: '1990-01-01');
  bool _termsAccepted = false;

  int _currentStep = 0;

  final List<String> _steps = [
    'Personal Info',
    'Account',
    'Documents'
  ];

  // Form Controllers
  final _firstNameController = TextEditingController();
  final _secondNameController = TextEditingController();
  final _thirdNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Institute & Country State
  List<String> _cities = [];
  List<String> _regions = [];
  List<DrivingInstitute> _institutes = [];
  List<Country> _countriesList = [];

  String? _selectedCity;
  String? _selectedRegion;
  DrivingInstitute? _selectedInstitute;
  Country? _selectedCountry;

  bool _loadingData = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _loadingData = true);
    try {
      final filters = await InstituteService.getFilters();
      final institutes = await InstituteService.getAllInstitutes();
      final countries = await CountryService.getAllCountries();
      
      setState(() {
        _cities = filters['cities']!;
        _regions = filters['regions']!;
        _institutes = institutes;
        _countriesList = countries;
        // Pre-select Jordan (ID 1) if found, or just pick the first
        _selectedCountry = _countriesList.firstWhere((c) => c.id == 1, orElse: () => _countriesList.first);
        _loadingData = false;
      });
    } catch (e) {
      setState(() => _loadingData = false);
    }
  }

  Future<void> _updateInstitutes() async {
    setState(() => _loadingData = true);
    final institutes = await InstituteService.getAllInstitutes(
      city: _selectedCity,
      region: _selectedRegion,
    );
    setState(() {
      _institutes = institutes;
      _loadingData = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Create Account',
          style: GoogleFonts.poppins(
              fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Step indicator
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
            child: Row(
              children: List.generate(_steps.length, (i) {
                final isActive = i == _currentStep;
                final isDone = i < _currentStep;
                return Expanded(
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDone
                                  ? AppColors.success
                                  : isActive
                                      ? AppColors.primary
                                      : AppColors.inputBg,
                              border: isActive
                                  ? Border.all(color: AppColors.primary, width: 2)
                                  : null,
                            ),
                            child: Center(
                              child: isDone
                                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                                  : Text(
                                      '${i + 1}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isActive
                                            ? AppColors.white
                                            : AppColors.textLight,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _steps[i],
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight:
                                  isActive ? FontWeight.w600 : FontWeight.w400,
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                      if (i < _steps.length - 1)
                        Expanded(
                          child: Container(
                            height: 2,
                            margin: const EdgeInsets.only(bottom: 20),
                            color: isDone ? AppColors.success : AppColors.divider,
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: IndexedStack(
                  index: _currentStep,
                  children: [
                    _buildPersonalInfo(),
                    _buildAccount(),
                    _buildDocuments(),
                  ],
                ),
              ),
            ),
          ),

          // Bottom buttons
          Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            color: AppColors.white,
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: AppButton(
                      label: 'Back',
                      variant: AppButtonVariant.outline,
                      onPressed: () => setState(() => _currentStep--),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: _currentStep < _steps.length - 1 ? 'Next' : 'Register',
                    isLoading: _loading,
                    onPressed: () async {
                      // Manual validation for each step
                      bool canProceed = false;
                      if (_currentStep == 0) {
                        // Personal Info Validation
                        if (_firstNameController.text.isNotEmpty && 
                            _lastNameController.text.isNotEmpty && 
                            _nationalIdController.text.isNotEmpty) {
                          canProceed = true;
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill all required personal info')),
                          );
                        }
                      } else if (_currentStep == 1) {
                        // Account Validation
                        if (_usernameController.text.isNotEmpty && 
                            _passwordController.text.length >= 8 &&
                            _passwordController.text == _confirmPasswordController.text) {
                          canProceed = true;
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please check your account details')),
                          );
                        }
                      } else {
                        canProceed = true;
                      }

                      if (canProceed) {
                        if (_currentStep < _steps.length - 1) {
                          setState(() => _currentStep++);
                        } else {
                          _handleRegister();
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRegister() async {
    setState(() => _loading = true);

    final result = await AuthService.register(
      firstName: _firstNameController.text,
      secondName: _secondNameController.text,
      thirdName: _thirdNameController.text,
      lastName: _lastNameController.text,
      nationalNo: _nationalIdController.text,
      username: _usernameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      dateOfBirth: DateTime.parse(_dobController.text),
      gender: _selectedGender == 'Male' ? 0 : 1,
      nationalityCountryId: _selectedCountry?.id ?? 1,
    );

    if (mounted) {
      setState(() => _loading = false);
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully! Please sign in.'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Registration failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildPersonalInfo() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AppInput(
                label: 'First Name',
                hint: 'First',
                prefixIcon: Icons.person_outline_rounded,
                controller: _firstNameController,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppInput(
                label: 'Second Name',
                hint: 'Second',
                prefixIcon: Icons.person_outline_rounded,
                controller: _secondNameController,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AppInput(
                label: 'Third Name',
                hint: 'Third',
                prefixIcon: Icons.person_outline_rounded,
                controller: _thirdNameController,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppInput(
                label: 'Last Name',
                hint: 'Last',
                prefixIcon: Icons.person_outline_rounded,
                controller: _lastNameController,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AppInput(
          label: 'National ID Number',
          hint: 'Enter your national ID',
          prefixIcon: Icons.badge_outlined,
          keyboardType: TextInputType.number,
          controller: _nationalIdController,
          validator: (v) => v!.isEmpty ? 'National ID is required' : null,
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date of Birth',
                style: GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime(1990),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  _dobController.text =
                      '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                  setState(() {});
                }
              },
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _dobController,
                  decoration: InputDecoration(
                    hintText: 'YYYY-MM-DD',
                    prefixIcon: Icon(Icons.calendar_today_outlined, size: 20, color: AppColors.textLight),
                    filled: true,
                    fillColor: AppColors.inputBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.inputBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.inputBorder),
                    ),
                  ),
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gender',
                style: GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Row(
              children: ['Male', 'Female'].map((g) {
                final isSelected = _selectedGender == g;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedGender = g),
                    child: Container(
                      margin: EdgeInsets.only(right: g == 'Male' ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.inputBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.inputBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            g == 'Male' ? Icons.male_rounded : Icons.female_rounded,
                            color: isSelected ? AppColors.white : AppColors.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            g,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? AppColors.white : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AppInput(
          label: 'Phone Number',
          hint: '+962 7X XXX XXXX',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          controller: _phoneController,
          validator: (v) => v!.isEmpty ? 'Phone is required' : null,
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nationality',
                style: GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Country>(
                  value: _selectedCountry,
                  isExpanded: true,
                  items: _countriesList.map((c) {
                    return DropdownMenuItem(
                      value: c,
                      child: Text(c.name, style: GoogleFonts.poppins(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCountry = val),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AppInput(
          label: 'Address',
          hint: 'Enter your home address',
          prefixIcon: Icons.location_on_outlined,
          maxLines: 2,
          controller: _addressController,
          validator: (v) => v!.isEmpty ? 'Address is required' : null,
        ),
      ],
    );
  }

  Widget _buildInstituteSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Training School',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose where you want to take your training',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),

        // Filter Row
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                label: 'City',
                value: _selectedCity,
                items: _cities,
                onChanged: (val) {
                  setState(() => _selectedCity = val);
                  _updateInstitutes();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdown(
                label: 'Region',
                value: _selectedRegion,
                items: _regions,
                onChanged: (val) {
                  setState(() => _selectedRegion = val);
                  _updateInstitutes();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Institute List
        if (_loadingData)
          const Center(child: CircularProgressIndicator())
        else if (_institutes.isEmpty)
          Center(
            child: Text('No schools found in this area',
                style: GoogleFonts.poppins(color: AppColors.textLight)),
          )
        else
          ..._institutes.map((inst) {
            final isSelected = _selectedInstitute?.id == inst.id;
            return GestureDetector(
              onTap: () => setState(() => _selectedInstitute = inst),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accentLight : AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.accent : AppColors.divider,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.school_outlined,
                          color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            inst.name,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${inst.city}, ${inst.region}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle,
                          color: AppColors.accent, size: 24),
                  ],
                ),
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.inputBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text('Select $label',
                  style: GoogleFonts.poppins(fontSize: 13)),
              items: [
                const DropdownMenuItem(value: null, child: Text('All')),
                ...items.map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(item, style: GoogleFonts.poppins(fontSize: 13)),
                    )),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccount() {
    return Column(
      children: [
        AppInput(
          label: 'Username',
          hint: 'Choose a login name',
          prefixIcon: Icons.alternate_email_rounded,
          controller: _usernameController,
          validator: (v) => v!.isEmpty ? 'Username is required' : null,
        ),
        const SizedBox(height: 16),
        AppInput(
          label: 'Email Address',
          hint: 'example@email.com',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          controller: _emailController,
          validator: (v) => v!.isEmpty ? 'Email is required' : null,
        ),
        const SizedBox(height: 16),
        AppInput(
          label: 'Password',
          hint: 'At least 8 characters',
          prefixIcon: Icons.lock_outline_rounded,
          suffixIcon: _obscurePassword
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          obscureText: _obscurePassword,
          controller: _passwordController,
          onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword),
          validator: (v) => v!.length < 8 ? 'Password too short' : null,
        ),
        const SizedBox(height: 16),
        AppInput(
          label: 'Confirm Password',
          hint: 'Re-enter your password',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: true,
          controller: _confirmPasswordController,
          validator: (v) =>
              v != _passwordController.text ? 'Passwords do not match' : null,
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: _termsAccepted,
              onChanged: (v) => setState(() => _termsAccepted = v ?? false),
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
                    children: [
                      const TextSpan(text: 'I agree to the '),
                      TextSpan(
                        text: 'Terms & Conditions',
                        style: GoogleFonts.poppins(
                            color: AppColors.accent, fontWeight: FontWeight.w500),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: GoogleFonts.poppins(
                            color: AppColors.accent, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDocuments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDocUpload(
          'National ID (Front)',
          Icons.badge_outlined,
          'Upload a clear photo of the front side',
        ),
        const SizedBox(height: 16),
        _buildDocUpload(
          'National ID (Back)',
          Icons.badge_outlined,
          'Upload a clear photo of the back side',
        ),
        const SizedBox(height: 16),
        _buildDocUpload(
          'Personal Photo',
          Icons.face_retouching_natural,
          'Upload a recent passport-style photo',
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.infoLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.info.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, color: AppColors.info, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Accepted formats: JPG, PNG, PDF. Max size: 5MB each.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.info,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocUpload(String title, IconData icon, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: GoogleFonts.poppins(
                fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {},
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(
              color: AppColors.inputBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.inputBorder,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accentLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tap to Upload',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textLight)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
