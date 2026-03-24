import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/router/route_paths.dart';
import '../widgets/auth/auth_message_banner.dart';
import '../widgets/auth/auth_shell.dart';
import '../widgets/auth/otp_verifier_form.dart';

class VerifyEmailOtpScreen extends ConsumerStatefulWidget {
  const VerifyEmailOtpScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<VerifyEmailOtpScreen> createState() =>
      _VerifyEmailOtpScreenState();
}

class _VerifyEmailOtpScreenState extends ConsumerState<VerifyEmailOtpScreen> {
  String? _successMessage;

  Future<void> _submit(String otpCode) async {
    final ok = await ref
        .read(authViewModelProvider.notifier)
        .verifyEmailOtp(email: widget.email, otpCode: otpCode);

    if (!mounted) {
      return;
    }

    if (ok) {
      setState(() {
        _successMessage = 'Xác thực email thành công. Mời bạn đăng nhập.';
      });
      context.go(RoutePaths.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    if (widget.email.isEmpty) {
      return Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () => context.go(RoutePaths.register),
            child: const Text('Email không hợp lệ. Quay lại đăng ký'),
          ),
        ),
      );
    }

    return AuthShell(
      title: 'Xác thực email',
      subtitle: 'Nhập mã OTP 6 số đã gửi đến ${widget.email}',
      headerIcon: Icons.mark_email_unread_outlined,
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
          OtpVerifierForm(
            loading: authState.isLoading,
            onVerify: _submit,
            verifyLabel: 'Xác minh',
          ),
          TextButton(
            onPressed: () => context.go(RoutePaths.register),
            child: const Text('Không nhận được mã? Đăng ký lại'),
          ),
        ],
      ),
    );
  }
}

