import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/router/route_paths.dart';
import '../widgets/auth/auth_message_banner.dart';
import '../widgets/auth/auth_shell.dart';
import '../widgets/auth/otp_verifier_form.dart';

class VerifyResetOtpScreen extends ConsumerStatefulWidget {
  const VerifyResetOtpScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<VerifyResetOtpScreen> createState() =>
      _VerifyResetOtpScreenState();
}

class _VerifyResetOtpScreenState extends ConsumerState<VerifyResetOtpScreen> {
  String? _successMessage;

  Future<void> _verify(String code) async {
    final ok = await ref
        .read(authViewModelProvider.notifier)
        .verifyResetOtp(email: widget.email, otpCode: code);

    if (!mounted) {
      return;
    }

    if (ok) {
      final email = Uri.encodeComponent(widget.email);
      final otpCode = Uri.encodeComponent(code);
      context.go('${RoutePaths.resetPassword}?email=$email&otpCode=$otpCode');
      return;
    }
  }

  Future<void> _resend() async {
    final ok = await ref
        .read(authViewModelProvider.notifier)
        .forgotPassword(widget.email);

    if (!mounted) {
      return;
    }

    setState(() {
      _successMessage = ok ? 'Đã gửi lại mã OTP mới.' : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    if (widget.email.isEmpty) {
      return Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () => context.go(RoutePaths.forgotPassword),
            child: const Text('Email không hợp lệ. Quay lại quên mật khẩu'),
          ),
        ),
      );
    }

    return AuthShell(
      title: 'Xác thực OTP',
      subtitle: 'Nhập mã OTP đã gửi đến ${widget.email} để đặt lại mật khẩu.',
      headerIcon: Icons.pin_outlined,
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
            onVerify: _verify,
            onResend: _resend,
            verifyLabel: 'Tiếp tục',
          ),
        ],
      ),
    );
  }
}

