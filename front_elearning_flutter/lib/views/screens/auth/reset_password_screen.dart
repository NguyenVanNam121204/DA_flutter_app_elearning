import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router/route_paths.dart';
import '../../widgets/auth/auth_message_banner.dart';
import '../../widgets/auth/auth_primary_button.dart';
import '../../widgets/auth/auth_shell.dart';
import '../../widgets/auth/auth_text_field.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, required this.email, required this.otpCode});
  final String email;
  final String otpCode;

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(authViewModelProvider.notifier).setNewPassword(
          email: widget.email,
          otpCode: widget.otpCode,
          newPassword: _passwordController.text.trim(),
          confirmPassword: _confirmController.text.trim(),
        );
    if (!mounted || !ok) return;
    context.go(RoutePaths.login);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    return AuthShell(
      title: 'Dat lai mat khau',
      subtitle: 'Tao mat khau moi cho tai khoan ${widget.email}',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (authState.errorMessage != null) ...[
              AuthMessageBanner(message: authState.errorMessage!),
              const SizedBox(height: 12),
            ],
            AuthTextField(
              controller: _passwordController,
              label: 'Mat khau moi',
              hint: 'Nhap mat khau moi',
              obscureText: true,
              validator: (value) {
                final v = (value ?? '').trim();
                if (v.isEmpty) return 'Vui long nhap mat khau';
                if (v.length < 8) return 'Mat khau toi thieu 8 ky tu';
                return null;
              },
            ),
            const SizedBox(height: 14),
            AuthTextField(
              controller: _confirmController,
              label: 'Xac nhan mat khau',
              hint: 'Nhap lai mat khau',
              obscureText: true,
              validator: (value) {
                final v = (value ?? '').trim();
                if (v.isEmpty) return 'Vui long nhap lai mat khau';
                if (v != _passwordController.text.trim()) return 'Mat khau xac nhan khong khop';
                return null;
              },
            ),
            const SizedBox(height: 20),
            AuthPrimaryButton(
              label: 'Dat lai mat khau',
              isLoading: authState.isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
