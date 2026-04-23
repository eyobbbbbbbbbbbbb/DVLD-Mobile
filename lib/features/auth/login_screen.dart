import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/user_session.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_input.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);
      
      // Simulate network
      await Future.delayed(const Duration(seconds: 1));
      
      final input = _emailController.text;
      final mockUser = MockUsers.find(input);
      
      if (mockUser != null) {
        UserSession.instance.login(
          fullName: mockUser['fullName']!,
          nationalId: mockUser['nationalId']!,
          email: mockUser['email']!,
          phone: mockUser['phone']!,
          address: mockUser['address']!,
          dateOfBirth: mockUser['dateOfBirth']!,
          gender: mockUser['gender']!,
        );
      } else {
        // Fallback for demo if credentials don't match
        UserSession.instance.login(
          fullName: MockUsers.deriveDisplayName(input),
          nationalId: '1234567890',
          email: input.contains('@') ? input : '$input@demo.com',
          phone: '+962 79 000 0000',
        );
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(36),
                    bottomRight: Radius.circular(36),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(28, 52, 28, 40),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.directions_car_rounded,
                        color: AppColors.white,
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'DVLD',
                      style: GoogleFonts.poppins(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Driving License Department',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.white.withOpacity(0.75),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Welcome Back',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Sign in to continue',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      AppInput(
                        label: 'National ID / Email',
                        hint: 'Enter your ID or email',
                        prefixIcon: Icons.person_outline_rounded,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) =>
                            v!.isEmpty ? 'This field is required' : null,
                      ),
                      const SizedBox(height: 20),
                      AppInput(
                        label: 'Password',
                        hint: 'Enter your password',
                        prefixIcon: Icons.lock_outline_rounded,
                        suffixIcon: _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        obscureText: _obscurePassword,
                        controller: _passwordController,
                        onSuffixTap: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                        validator: (v) =>
                            v!.isEmpty ? 'Password is required' : null,
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.accent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      AppButton(
                        label: 'Sign In',
                        onPressed: _login,
                        isLoading: _loading,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'or',
                              style: GoogleFonts.poppins(
                                color: AppColors.textLight,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 20),
                      AppButton(
                        label: "Create an Account",
                        variant: AppButtonVariant.outline,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const RegisterScreen()),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          'Ministry of Interior — Traffic & Licensing Dept.',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.textLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
