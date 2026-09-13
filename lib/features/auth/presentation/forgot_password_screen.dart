import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'auth_provider.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _mobileCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _success = false;
  String? _errorMessage;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _mobileCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final error =
        await ref.read(authProvider.notifier).resetPasswordByMobile(
              mobileNo: _mobileCtrl.text.trim(),
              newPassword: _newPasswordCtrl.text,
            );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (error != null) {
      setState(() => _errorMessage = error);
    } else {
      setState(() => _success = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 440),
              padding: const EdgeInsets.all(40),
              margin: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: AppShadows.dialog,
              ),
              child: _success ? _SuccessView(onLogin: () => context.go(AppRoutes.login)) : _FormView(
                formKey: _formKey,
                mobileCtrl: _mobileCtrl,
                newPasswordCtrl: _newPasswordCtrl,
                confirmCtrl: _confirmCtrl,
                obscureNew: _obscureNew,
                obscureConfirm: _obscureConfirm,
                isLoading: _isLoading,
                errorMessage: _errorMessage,
                onToggleNew: () => setState(() => _obscureNew = !_obscureNew),
                onToggleConfirm: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                onSubmit: _onSubmit,
                onBack: () => context.go(AppRoutes.login),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController mobileCtrl;
  final TextEditingController newPasswordCtrl;
  final TextEditingController confirmCtrl;
  final bool obscureNew;
  final bool obscureConfirm;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onToggleNew;
  final VoidCallback onToggleConfirm;
  final VoidCallback onSubmit;
  final VoidCallback onBack;

  const _FormView({
    required this.formKey,
    required this.mobileCtrl,
    required this.newPasswordCtrl,
    required this.confirmCtrl,
    required this.obscureNew,
    required this.obscureConfirm,
    required this.isLoading,
    required this.errorMessage,
    required this.onToggleNew,
    required this.onToggleConfirm,
    required this.onSubmit,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_back_rounded,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text('Back to Login',
                    style: AppTypography.secondary.copyWith(fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.warningBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.warningBorder),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.lock_reset_rounded,
                size: 24, color: AppColors.warning),
          ),
          const SizedBox(height: 20),
          Text('Reset Password',
              style: AppTypography.pageTitle.copyWith(
                  fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
            'Enter your registered mobile number and set a new password.',
            style: AppTypography.secondary.copyWith(fontSize: 13.5, height: 1.5),
          ),
          const SizedBox(height: 28),

          // Mobile
          const AuthFieldLabel('Registered Mobile Number'),
          const SizedBox(height: 6),
          AuthTextField(
            controller: mobileCtrl,
            hintText: 'Enter your mobile number',
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            prefixIcon: Icons.phone_outlined,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Mobile number is required' : null,
          ),
          const SizedBox(height: 16),

          // New password
          const AuthFieldLabel('New Password'),
          const SizedBox(height: 6),
          AuthTextField(
            controller: newPasswordCtrl,
            hintText: 'Minimum 6 characters',
            obscureText: obscureNew,
            prefixIcon: Icons.lock_outline_rounded,
            suffixIcon: IconButton(
              icon: Icon(
                obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 18, color: AppColors.textMuted,
              ),
              onPressed: onToggleNew,
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              if (v.length < 6) return 'Minimum 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Confirm password
          const AuthFieldLabel('Confirm New Password'),
          const SizedBox(height: 6),
          AuthTextField(
            controller: confirmCtrl,
            hintText: 'Re-enter new password',
            obscureText: obscureConfirm,
            prefixIcon: Icons.lock_outline_rounded,
            suffixIcon: IconButton(
              icon: Icon(
                obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 18, color: AppColors.textMuted,
              ),
              onPressed: onToggleConfirm,
            ),
            onFieldSubmitted: (_) => onSubmit(),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please confirm your password';
              if (v != newPasswordCtrl.text) return 'Passwords do not match';
              return null;
            },
          ),

          if (errorMessage != null) ...[
            const SizedBox(height: 12),
            AuthErrorBanner(message: errorMessage!),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: FilledButton(
              onPressed: isLoading ? null : onSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text('Reset Password',
                      style: AppTypography.body.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final VoidCallback onLogin;
  const _SuccessView({required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.successBg,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.successBorder),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.check_rounded, size: 32, color: AppColors.success),
        ),
        const SizedBox(height: 20),
        Text('Password Reset!',
            style: AppTypography.pageTitle.copyWith(
                fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(
          'Your password has been reset successfully.\nYou can now sign in with your new password.',
          textAlign: TextAlign.center,
          style: AppTypography.secondary.copyWith(fontSize: 13.5, height: 1.6),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: FilledButton(
            onPressed: onLogin,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Back to Sign In',
                style: AppTypography.body.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15)),
          ),
        ),
      ],
    );
  }
}
