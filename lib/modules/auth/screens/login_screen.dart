import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:SmartERP/core/constants/app_constants.dart';
import 'package:SmartERP/core/extensions/context_extensions.dart';
import 'package:SmartERP/core/extensions/string_extensions.dart';
import 'package:SmartERP/core/routes/app_routes.dart';
import 'package:SmartERP/core/widgets/app_button.dart';
import 'package:SmartERP/core/widgets/app_text_field.dart';
import 'package:SmartERP/modules/auth/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isSubmitting = false;
  String? _emailError;
  String? _passwordError;
  bool _sessionMessageShown = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isSubmitting) return;

    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    bool hasError = false;

    if (email.isEmpty) {
      setState(() {
        _emailError = 'Email is required';
      });
      hasError = true;
    } else if (!email.isValidEmail) {
      setState(() {
        _emailError = 'Please enter a valid email';
      });
      hasError = true;
    }

    if (password.isEmpty) {
      setState(() {
        _passwordError = 'Password is required';
      });
      hasError = true;
    }

    if (hasError) return;

    setState(() {
      _isSubmitting = true;
    });

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(email, password);

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      context.go(AppRoutes.dashboard);
    } else {
      if (authProvider.errorMessage != null) {
        if (authProvider.errorMessage!.toLowerCase().contains('email')) {
          setState(() {
            _emailError = authProvider.errorMessage;
          });
        } else if (authProvider.errorMessage!.toLowerCase().contains('password')) {
          setState(() {
            _passwordError = authProvider.errorMessage;
          });
        } else {
          context.showSnackBar(
            authProvider.errorMessage!,
            isError: true,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_sessionMessageShown && mounted) {
        final authProvider = context.read<AuthProvider>();
        final msg = authProvider.sessionExpiredMessage;
        if (msg != null) {
          _sessionMessageShown = true;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
          authProvider.clearSessionExpiredMessage();
        }
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          // ── Decorative background blobs ──
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4F6EF7).withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4F6EF7).withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            top: 180,
            left: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7C3AED).withOpacity(0.05),
              ),
            ),
          ),

          // ── Main content ──
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 40),
                        _buildCard(),
                        const SizedBox(height: 20),
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header: logo + titles ──────────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      children: [
        // Logo container
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4F6EF7), Color(0xFF7C3AED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4F6EF7).withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.business_rounded, size: 38, color: Colors.white),
        )
            .animate()
            .fadeIn(duration: 600.ms)
            .scale(delay: 200.ms, duration: 400.ms, curve: Curves.easeOutBack),

        const SizedBox(height: 20),

        Text(
          AppConstants.appName,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: Color(0xFF111827),
          ),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(delay: 300.ms, duration: 600.ms)
            .slideY(begin: -0.25, end: 0, curve: Curves.easeOut),

        const SizedBox(height: 6),

        Text(
          'Enterprise Resource Planning',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF6B7280),
            letterSpacing: 0.2,
          ),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(delay: 400.ms, duration: 600.ms)
            .slideY(begin: -0.2, end: 0, curve: Curves.easeOut),
      ],
    );
  }

  // ── White card ─────────────────────────────────────────────────────────────
  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E2A6E).withOpacity(0.07),
            blurRadius: 30,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.9),
            blurRadius: 1,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section label
          const Text(
            'Welcome back 👋',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          )
              .animate()
              .fadeIn(delay: 450.ms, duration: 500.ms)
              .slideX(begin: -0.2, end: 0),

          const SizedBox(height: 4),

          const Text(
            'Sign in to your account to continue',
            style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
          )
              .animate()
              .fadeIn(delay: 500.ms, duration: 500.ms),

          const SizedBox(height: 28),

          // ── Email field ──
          _buildLabel('Email address'),
          const SizedBox(height: 6),
          _buildStyledTextField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            label: 'Email',
            hint: 'you@company.com',
            errorText: _emailError,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            prefixIcon: const Icon(Icons.email_outlined, size: 20, color: Color(0xFF9CA3AF)),
            onSubmitted: (_) => _passwordFocusNode.requestFocus(),
            onChanged: (_) {
              if (_emailError != null) setState(() => _emailError = null);
            },
          )
              .animate()
              .fadeIn(delay: 550.ms, duration: 500.ms)
              .slideX(begin: -0.2, end: 0),

          const SizedBox(height: 18),

          // ── Password field ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLabel('Password'),
              GestureDetector(
                onTap: () {}, // hook up forgot password if needed
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4F6EF7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _buildStyledTextField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            label: 'Password',
            hint: '••••••••',
            errorText: _passwordError,
            obscureText: true,
            textInputAction: TextInputAction.done,
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: Color(0xFF9CA3AF)),
            onSubmitted: (_) => _handleLogin(),
            onChanged: (_) {
              if (_passwordError != null) setState(() => _passwordError = null);
            },
          )
              .animate()
              .fadeIn(delay: 650.ms, duration: 500.ms)
              .slideX(begin: -0.2, end: 0),

          const SizedBox(height: 28),

          // ── Login button ──
          _buildLoginButton(),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: 700.ms)
        .slideY(begin: 0.15, end: 0, curve: Curves.easeOut);
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF374151),
      ),
    );
  }

  /// Wraps your existing AppTextField with a custom container so the outer
  /// decoration (border-radius, shadow) is richer while AppTextField handles
  /// the inner logic unchanged.
  Widget _buildStyledTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    String? errorText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    Widget? prefixIcon,
    ValueChanged<String>? onSubmitted,
    ValueChanged<String>? onChanged,
  }) {
    return AppTextField(
      controller: controller,
      focusNode: focusNode,
      label: label,
      hint: hint,
      errorText: errorText,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      prefixIcon: prefixIcon,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
    );
  }

  Widget _buildLoginButton() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: _isSubmitting
            ? null
            : const LinearGradient(
                colors: [Color(0xFF4F6EF7), Color(0xFF7C3AED)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
        color: _isSubmitting ? const Color(0xFFE5E7EB) : null,
        borderRadius: BorderRadius.circular(14),
        boxShadow: _isSubmitting
            ? []
            : [
                BoxShadow(
                  color: const Color(0xFF4F6EF7).withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: AppButton(
        text: 'Sign In',
        onPressed: _isSubmitting ? null : _handleLogin,
        isLoading: _isSubmitting,
        isFullWidth: true,
        icon: Icons.arrow_forward_rounded,
      ),
    )
        .animate()
        .fadeIn(delay: 750.ms, duration: 500.ms)
        .scale(delay: 750.ms, duration: 400.ms, curve: Curves.easeOutBack);
  }

  // ── Footer ─────────────────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Text(
      'Version ${AppConstants.appVersion}  •  Secure Login',
      style: const TextStyle(
        fontSize: 11,
        color: Color(0xFFD1D5DB),
        letterSpacing: 0.3,
      ),
      textAlign: TextAlign.center,
    )
        .animate()
        .fadeIn(delay: 900.ms, duration: 600.ms);
  }
}
