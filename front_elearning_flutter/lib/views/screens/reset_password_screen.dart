import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/router/route_paths.dart';
import '../widgets/auth/auth_message_banner.dart';
import '../widgets/auth/auth_primary_button.dart';
import '../widgets/auth/auth_shell.dart';
import '../widgets/auth/auth_text_field.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.otpCode,
  });

  final String email;
  final String otpCode;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _successMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final ok = await ref
        .read(authViewModelProvider.notifier)
        .setNewPassword(
          email: widget.email,
          otpCode: widget.otpCode,
          newPassword: _passwordController.text.trim(),
          confirmPassword: _confirmController.text.trim(),
        );

    if (!mounted) {
      return;
    }

    if (ok) {
      setState(() {
        _successMessage = 'Đặt lại mật khẩu thành công. Mời bạn đăng nhập lại.';
      });
      context.go(RoutePaths.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    if (widget.email.isEmpty || widget.otpCode.isEmpty) {
      return Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () => context.go(RoutePaths.forgotPassword),
            child: const Text('Thông tin reset không hợp lệ. Quay lại.'),
          ),
        ),
      );
    }

    return AuthShell(
      title: 'Đặt lại mật khẩu',
      subtitle: 'Tạo mật khẩu mới cho tài khoản ${widget.email}',
      headerIcon: Icons.lock_open,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_successMessage != null) ...[
              AuthMessageBanner(message: _successMessage!, isError: false),
              const SizedBox(height: 12),
            ],
            if (authState.errorMessage != null) ...[
              AuthMessageBanner(message: authState.errorMessage!),
              const SizedBox(height: 12),
            ],
            AuthTextField(
              controller: _passwordController,
              label: 'Mật khẩu mới',
              hint: 'Tối thiểu 8 ký tự, có chữ hoa và ký tự đặc biệt',
              obscureText: true,
              prefixIcon: Icons.lock_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mật khẩu mới';
                }
                if (value.length < 8) {
                  return 'Mật khẩu phải có ít nhất 8 ký tự';
                }
                final hasUpper = value.contains(RegExp(r'[A-Z]'));
                final hasLower = value.contains(RegExp(r'[a-z]'));
                final hasNumber = value.contains(RegExp(r'\d'));
                final hasSpecial = value.contains(RegExp(r'[^\da-zA-Z]'));
                if (!(hasUpper && hasLower && hasNumber && hasSpecial)) {
                  return 'Cần chữ hoa, chữ thường, số và ký tự đặc biệt';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            AuthTextField(
              controller: _confirmController,
              label: 'Xác nhận mật khẩu',
              hint: 'Nhập lại mật khẩu mới',
              obscureText: true,
              prefixIcon: Icons.verified_user_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng xác nhận mật khẩu';
                }
                if (value != _passwordController.text.trim()) {
                  return 'Mật khẩu xác nhận không khớp';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            AuthPrimaryButton(
              label: 'Đặt lại mật khẩu',
              isLoading: authState.isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
