import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smarterp/core/constants/app_constants.dart';
import 'package:smarterp/core/extensions/context_extensions.dart';
import 'package:smarterp/core/extensions/string_extensions.dart';
import 'package:smarterp/core/routes/app_routes.dart';
import 'package:smarterp/core/widgets/app_button.dart';
import 'package:smarterp/core/widgets/app_text_field.dart';
import 'package:smarterp/modules/auth/providers/auth_provider.dart';

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

    if (hasError) {
      return;
    }

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
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildLogo(),
                    const SizedBox(height: 48),
                    _buildTitle(),
                    const SizedBox(height: 32),
                    _buildEmailField(),
                    const SizedBox(height: 16),
                    _buildPasswordField(),
                    const SizedBox(height: 32),
                    _buildLoginButton(),
                    const SizedBox(height: 24),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Icon(
      Icons.business,
      size: 80,
      color: context.colorScheme.primary,
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .scale(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          AppConstants.appName,
          style: context.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(delay: 300.ms, duration: 600.ms)
            .slideY(begin: -0.3, end: 0),
        const SizedBox(height: 8),
        Text(
          'Enterprise Resource Planning',
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(delay: 400.ms, duration: 600.ms)
            .slideY(begin: -0.3, end: 0),
      ],
    );
  }

  Widget _buildEmailField() {
    return AppTextField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      label: 'Email',
      hint: 'Enter your email',
      errorText: _emailError,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      prefixIcon: const Icon(Icons.email_outlined),
      onSubmitted: (_) {
        _passwordFocusNode.requestFocus();
      },
      onChanged: (_) {
        if (_emailError != null) {
          setState(() {
            _emailError = null;
          });
        }
      },
    )
        .animate()
        .fadeIn(delay: 500.ms, duration: 600.ms)
        .slideX(begin: -0.3, end: 0);
  }

  Widget _buildPasswordField() {
    return AppTextField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      label: 'Password',
      hint: 'Enter your password',
      errorText: _passwordError,
      obscureText: true,
      textInputAction: TextInputAction.done,
      prefixIcon: const Icon(Icons.lock_outlined),
      onSubmitted: (_) {
        _handleLogin();
      },
      onChanged: (_) {
        if (_passwordError != null) {
          setState(() {
            _passwordError = null;
          });
        }
      },
    )
        .animate()
        .fadeIn(delay: 600.ms, duration: 600.ms)
        .slideX(begin: -0.3, end: 0);
  }

  Widget _buildLoginButton() {
    return AppButton(
      text: 'Login',
      onPressed: _isSubmitting ? null : _handleLogin,
      isLoading: _isSubmitting,
      isFullWidth: true,
      icon: Icons.login,
    )
        .animate()
        .fadeIn(delay: 700.ms, duration: 600.ms)
        .scale(delay: 700.ms, duration: 400.ms);
  }

  Widget _buildFooter() {
    return Text(
      'Version ${AppConstants.appVersion}',
      style: context.textTheme.bodySmall?.copyWith(
        color: context.colorScheme.onSurface.withOpacity(0.5),
      ),
      textAlign: TextAlign.center,
    )
        .animate()
        .fadeIn(delay: 800.ms, duration: 600.ms);
  }
}
