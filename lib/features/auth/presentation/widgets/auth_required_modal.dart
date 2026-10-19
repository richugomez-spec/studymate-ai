import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

/// Interactive modal shown to guests attempting actions that require an authenticated account.
/// Allows fast sign-in (Google or Email) and dismisses cleanly so the user stays on the exact same page.
class AuthRequiredModal extends ConsumerStatefulWidget {
  final String title;
  final String message;
  final VoidCallback? onAuthenticated;

  const AuthRequiredModal({
    super.key,
    this.title = 'Sign in to continue your learning journey',
    this.message = 'Create an account or sign in to save your progress, upload notes, chat with AI, and generate quizzes.',
    this.onAuthenticated,
  });

  /// Static helper to trigger the modal from anywhere
  static Future<bool> show(
    BuildContext context, {
    String title = 'Sign in to continue your learning journey',
    String message = 'Create an account or sign in to save your progress, upload notes, chat with AI, and generate quizzes.',
    VoidCallback? onAuthenticated,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (ctx) => AuthRequiredModal(
        title: title,
        message: message,
        onAuthenticated: onAuthenticated,
      ),
    );
    return result == true;
  }

  @override
  ConsumerState<AuthRequiredModal> createState() => _AuthRequiredModalState();
}

class _AuthRequiredModalState extends ConsumerState<AuthRequiredModal> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isEmailMode = false;
  bool _isRegister = false;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final notifier = ref.read(authNotifierProvider.notifier);
    final error = await notifier.signInWithGoogle();

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      if (!error.toLowerCase().contains('cancel') && !error.toLowerCase().contains('popup-closed')) {
        setState(() => _errorMessage = error);
      }
    } else {
      widget.onAuthenticated?.call();
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _handleEmailSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final notifier = ref.read(authNotifierProvider.notifier);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    String? error;
    if (_isRegister) {
      error = await notifier.registerWithEmailPassword(
        email: email,
        password: password,
        displayName: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null,
      );
    } else {
      error = await notifier.signInWithEmailPassword(
        email: email,
        password: password,
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      setState(() => _errorMessage = error);
    } else {
      widget.onAuthenticated?.call();
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 440),
          decoration: BoxDecoration(
            color: const Color(0xFF13131A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 36,
                spreadRadius: 8,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: AppColors.electricViolet.withOpacity(0.15),
                blurRadius: 40,
                spreadRadius: -4,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Row: Brand pill & Close icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.electricViolet.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.electricViolet.withOpacity(0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome, size: 12, color: AppColors.electricVioletLight),
                            SizedBox(width: 5),
                            Text(
                              'STUDYMATE AI',
                              style: TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                                color: AppColors.electricVioletLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: Icon(Icons.close_rounded, size: 20, color: Colors.white.withOpacity(0.5)),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Title & Subtitle
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      color: Colors.white,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.message,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.6),
                      height: 1.45,
                    ),
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.error.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 16, color: AppColors.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 22),

                  // ── Mode 1: Fast Single-Click Google Sign In ─────────────────
                  if (!_isEmailMode) ...[
                    // Continue with Google Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleGoogleSignIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                  'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                                  width: 18,
                                  height: 18,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.g_mobiledata_rounded,
                                    size: 22,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Continue with Google',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                    ),

                    const SizedBox(height: 12),

                    // Continue with Email Button
                    OutlinedButton(
                      onPressed: () => setState(() {
                        _isEmailMode = true;
                        _isRegister = false;
                        _errorMessage = null;
                      }),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withOpacity(0.18)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.mail_outline_rounded, size: 18, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'Continue with Email',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Create account shortcut
                    TextButton(
                      onPressed: () => setState(() {
                        _isEmailMode = true;
                        _isRegister = true;
                        _errorMessage = null;
                      }),
                      child: Text(
                        'Don\'t have an account? Create one for free',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.electricVioletLight.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ] else ...[
                    // ── Mode 2: Email Form (Sign in or Register) ───────────────
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_isRegister) ...[
                            TextFormField(
                              controller: _nameController,
                              style: const TextStyle(color: Colors.white, fontSize: 13.5),
                              decoration: _inputDecoration('Full Name', Icons.person_outline),
                            ),
                            const SizedBox(height: 12),
                          ],
                          TextFormField(
                            controller: _emailController,
                            style: const TextStyle(color: Colors.white, fontSize: 13.5),
                            decoration: _inputDecoration('Email address', Icons.mail_outline),
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordController,
                            style: const TextStyle(color: Colors.white, fontSize: 13.5),
                            obscureText: !_isPasswordVisible,
                            decoration: _inputDecoration('Password', Icons.lock_outline).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                  size: 16,
                                  color: Colors.white38,
                                ),
                                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                              ),
                            ),
                            validator: (v) => (v == null || v.length < 6) ? 'At least 6 characters' : null,
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleEmailSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.electricViolet,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Text(
                                    _isRegister ? 'Create Account' : 'Sign In',
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () => setState(() => _isEmailMode = false),
                                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                                child: Text(
                                  '← Other options',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => setState(() => _isRegister = !_isRegister),
                                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                                child: Text(
                                  _isRegister ? 'Already have account?' : 'Create Account',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.electricVioletLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 220.ms).scaleXY(begin: 0.96, end: 1.0);
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 12.5,
        color: Colors.white.withOpacity(0.4),
      ),
      prefixIcon: Icon(icon, size: 18, color: Colors.white.withOpacity(0.4)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.04),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.electricViolet, width: 1.5),
      ),
    );
  }
}
