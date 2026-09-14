import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../domain/member_type.dart';
import 'auth_provider.dart';
import 'login_screen.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  final _nameFocus = FocusNode();
  final _mobileFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;

  UserRole _selectedRole = UserRole.admin;
  MemberType? _selectedMemberType;

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
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _nameFocus.dispose();
    _mobileFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _onSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == UserRole.member && _selectedMemberType == null) {
      setState(
          () => _errorMessage = 'Please select a member type.');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String? error;
    if (_selectedRole == UserRole.admin) {
      error = await ref.read(authProvider.notifier).signUpAdmin(
            name: _nameCtrl.text.trim(),
            mobileNo: _mobileCtrl.text.trim(),
            password: _passwordCtrl.text,
          );
    } else {
      error = await ref.read(authProvider.notifier).signUpMember(
            name: _nameCtrl.text.trim(),
            mobileNo: _mobileCtrl.text.trim(),
            password: _passwordCtrl.text,
            memberType: _selectedMemberType!,
          );
    }
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (error != null) {
      setState(() => _errorMessage = error);
    }
    // Router redirect handles navigation on success
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // ── Left Brand Panel ──────────────────────────────────────────────
          Expanded(
            flex: 5,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.landscape_rounded,
                              color: Colors.white, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Text('PAMZ PlotPro',
                            style: AppTypography.pageTitle.copyWith(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            )),
                      ],
                    ),
                    const Spacer(),
                    Text('Create Your\nAccount',
                        style: AppTypography.pageTitle.copyWith(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        )),
                    const SizedBox(height: 16),
                    Text(
                      'Set up your Admin or Member account\nto get started with PAMZ PlotPro.',
                      style: AppTypography.body.copyWith(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),

          // ── Right Sign-Up Form Panel ──────────────────────────────────────
          Expanded(
            flex: 5,
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 460),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 24),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Sign Up',
                              style: AppTypography.pageTitle.copyWith(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                              )),
                          const SizedBox(height: 6),
                          Text('Fill in your details to create an account',
                              style: AppTypography.secondary
                                  .copyWith(fontSize: 13.5)),
                          const SizedBox(height: 28),
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Role Selector
                                const AuthFieldLabel('Account Type'),
                                const SizedBox(height: 8),
                                _RoleSelector(
                                  selectedRole: _selectedRole,
                                  onChanged: (role) => setState(() {
                                    _selectedRole = role;
                                    _selectedMemberType = null;
                                  }),
                                ),
                                // Member sub-type dropdown — only for member
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 220),
                                  curve: Curves.easeOutCubic,
                                  child: _selectedRole == UserRole.member
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 16),
                                            const AuthFieldLabel('Member Type'),
                                            const SizedBox(height: 8),
                                            MemberTypeDropdown(
                                              value: _selectedMemberType,
                                              onChanged: (t) => setState(
                                                  () => _selectedMemberType = t),
                                            ),
                                          ],
                                        )
                                      : const SizedBox.shrink(),
                                ),
                                const SizedBox(height: 16),
                                const AuthFieldLabel('Full Name'),
                                const SizedBox(height: 6),
                                AuthTextField(
                                  controller: _nameCtrl,
                                  focusNode: _nameFocus,
                                  nextFocus: _mobileFocus,
                                  hintText: 'Enter your full name',
                                  prefixIcon: Icons.person_outline_rounded,
                                  validator: (v) => (v == null ||
                                          v.trim().isEmpty)
                                      ? 'Name is required'
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                const AuthFieldLabel('Mobile Number'),
                                const SizedBox(height: 6),
                                AuthTextField(
                                  controller: _mobileCtrl,
                                  focusNode: _mobileFocus,
                                  nextFocus: _passwordFocus,
                                  hintText: 'Enter your mobile number',
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  prefixIcon: Icons.phone_outlined,
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? 'Mobile number is required'
                                          : null,
                                ),
                                const SizedBox(height: 16),
                                const AuthFieldLabel('Password'),
                                const SizedBox(height: 6),
                                AuthTextField(
                                  controller: _passwordCtrl,
                                  focusNode: _passwordFocus,
                                  nextFocus: _confirmFocus,
                                  hintText: 'Minimum 6 characters',
                                  obscureText: _obscurePassword,
                                  prefixIcon: Icons.lock_outline_rounded,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      size: 18,
                                      color: AppColors.textMuted,
                                    ),
                                    onPressed: () => setState(() =>
                                        _obscurePassword = !_obscurePassword),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Password is required';
                                    }
                                    if (v.length < 6) {
                                      return 'Minimum 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                const AuthFieldLabel('Confirm Password'),
                                const SizedBox(height: 6),
                                AuthTextField(
                                  controller: _confirmCtrl,
                                  focusNode: _confirmFocus,
                                  hintText: 'Re-enter your password',
                                  obscureText: _obscureConfirm,
                                  prefixIcon: Icons.lock_outline_rounded,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirm
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      size: 18,
                                      color: AppColors.textMuted,
                                    ),
                                    onPressed: () => setState(() =>
                                        _obscureConfirm = !_obscureConfirm),
                                  ),
                                  onFieldSubmitted: (_) => _onSignUp(),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Please confirm your password';
                                    }
                                    if (v != _passwordCtrl.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),
                                if (_errorMessage != null) ...[
                                  const SizedBox(height: 12),
                                  AuthErrorBanner(message: _errorMessage!),
                                ],
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  height: 46,
                                  child: FilledButton(
                                    onPressed: _isLoading ? null : _onSignUp,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.accent,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text('Create Account',
                                            style: AppTypography.body.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            )),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Already have an account?',
                                        style: AppTypography.secondary
                                            .copyWith(fontSize: 13)),
                                    TextButton(
                                      onPressed: () =>
                                          context.go(AppRoutes.login),
                                      child: Text('Sign In',
                                          style: AppTypography.body.copyWith(
                                            color: AppColors.accent,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          )),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
}

// ── Role Selector ─────────────────────────────────────────────────────────────

class _RoleSelector extends StatelessWidget {
  final UserRole selectedRole;
  final ValueChanged<UserRole> onChanged;

  const _RoleSelector(
      {required this.selectedRole, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _RoleOption(
          role: UserRole.admin,
          icon: Icons.admin_panel_settings_outlined,
          label: 'Admin',
          subtitle: 'Full access',
          isSelected: selectedRole == UserRole.admin,
          onTap: () => onChanged(UserRole.admin),
        )),
        const SizedBox(width: 12),
        Expanded(
            child: _RoleOption(
          role: UserRole.member,
          icon: Icons.person_outline_rounded,
          label: 'Member',
          subtitle: 'Limited access',
          isSelected: selectedRole == UserRole.member,
          onTap: () => onChanged(UserRole.member),
        )),
      ],
    );
  }
}

class _RoleOption extends StatelessWidget {
  final UserRole role;
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleOption({
    required this.role,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentLight : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 18,
                color: isSelected ? AppColors.accent : AppColors.textMuted),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                        color: isSelected
                            ? AppColors.accent
                            : AppColors.textPrimary,
                      )),
                  Text(subtitle,
                      style: AppTypography.caption.copyWith(
                          fontSize: 11,
                          color: isSelected
                              ? AppColors.accentHover
                              : AppColors.textMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Member Type Dropdown ──────────────────────────────────────────────────────

class MemberTypeDropdown extends StatelessWidget {
  final MemberType? value;
  final ValueChanged<MemberType?> onChanged;

  const MemberTypeDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<MemberType>(
          value: value,
          isExpanded: true,
          hint: Text('Select member type',
              style: AppTypography.input.copyWith(
                  color: AppColors.textMuted, fontSize: 13.5)),
          items: MemberType.values.map((t) {
            return DropdownMenuItem<MemberType>(
              value: t,
              child: Row(
                children: [
                  Icon(_memberTypeIcon(t),
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 10),
                  Text(t.displayName,
                      style: AppTypography.body.copyWith(fontSize: 13.5)),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  IconData _memberTypeIcon(MemberType t) {
    switch (t) {
      case MemberType.customerBuyer:
        return Icons.people_outline;
      case MemberType.investor:
        return Icons.pie_chart_outline;
      case MemberType.landowner:
        return Icons.landscape_outlined;
      case MemberType.ca:
        return Icons.account_balance_outlined;
    }
  }
}
