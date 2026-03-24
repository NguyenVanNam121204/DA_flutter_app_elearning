import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/router/route_paths.dart';
import '../widgets/auth/auth_message_banner.dart';
import '../widgets/auth/auth_primary_button.dart';
import '../widgets/auth/auth_shell.dart';
import '../widgets/auth/auth_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  String? _successMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _successMessage = null;
    });

    final ok = await ref
        .read(authViewModelProvider.notifier)
        .forgotPassword(_emailController.text.trim());

    if (!mounted) {
      return;
    }

    if (ok) {
      setState(() {
        _successMessage =
            'OTP đã được gửi đến email của bạn. Vui lòng nhập mã xác minh.';
      });
      final email = Uri.encodeComponent(_emailController.text.trim());
      context.go('${RoutePaths.verifyResetOtp}?email=$email');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    return AuthShell(
      title: 'Quên mật khẩu',
      subtitle: 'Nhập email để nhận hướng dẫn đặt lại mật khẩu.',
      headerIcon: Icons.lock_reset,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (authState.errorMessage != null) ...[
              AuthMessageBanner(message: authState.errorMessage!),
              const SizedBox(height: 12),
            ],
            if (_successMessage != null) ...[
              AuthMessageBanner(message: _successMessage!, isError: false),
              const SizedBox(height: 12),
            ],
            AuthTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'example@gmail.com',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập email';
                }

                const pattern = r'^[^\s@]+@[^\s@]+\.[^\s@]+$';
                if (!RegExp(pattern).hasMatch(value)) {
                  return 'Email không hợp lệ';
                }

                return null;
              },
            ),
            const SizedBox(height: 20),
            AuthPrimaryButton(
              label: 'Gửi mã OTP',
              isLoading: authState.isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go(RoutePaths.login),
              child: const Text('Quay lại đăng nhập'),
            ),
          ],
        ),
      ),
    );
  }
}


