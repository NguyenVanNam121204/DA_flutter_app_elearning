import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/router/route_paths.dart';
import '../widgets/auth/auth_message_banner.dart';
import '../widgets/auth/auth_primary_button.dart';
import '../widgets/auth/auth_shell.dart';
import '../widgets/auth/auth_switch_link.dart';
import '../widgets/auth/auth_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _dateOfBirth;
  String? _dateOfBirthError;
  String _gender = 'male';
  String? _successMessage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    bool isValid = _formKey.currentState!.validate();

    if (_dateOfBirth == null) {
      setState(() {
        _dateOfBirthError = 'Vui lòng chọn ngày sinh';
      });
      isValid = false;
    }

    if (!isValid) {
      return;
    }

    final ok = await ref
        .read(authViewModelProvider.notifier)
        .register(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          isMale: _gender == 'male',
          dateOfBirth: _dateOfBirth,
        );

    if (!mounted) {
      return;
    }

    if (ok) {
      setState(() {
        _successMessage =
            'Đăng ký thành công. Vui lòng nhập mã OTP để xác thực email.';
      });
      final email = Uri.encodeComponent(_emailController.text.trim());
      context.go('${RoutePaths.verifyEmailOtp}?email=$email');
    }
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 18),
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _dateOfBirth = selected;
      _dateOfBirthError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    return AuthShell(
      title: 'Tạo tài khoản của bạn',
      subtitle: 'Bắt đầu hành trình học tiếng Anh ngay hôm nay.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_successMessage != null) ...[
              AuthMessageBanner(message: _successMessage!, isError: false),
              const SizedBox(height: 14),
            ],
            if (authState.errorMessage != null) ...[
              AuthMessageBanner(message: authState.errorMessage!),
              const SizedBox(height: 14),
            ],
            Row(
              children: [
                Expanded(
                  child: AuthTextField(
                    controller: _firstNameController,
                    label: 'Họ',
                    hint: 'Nguyen',
                    prefixIcon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nhập họ';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AuthTextField(
                    controller: _lastNameController,
                    label: 'Tên',
                    hint: 'Van A',
                    prefixIcon: Icons.badge_outlined,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nhập tên';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
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
                if (!RegExp(pattern).hasMatch(value.trim())) {
                  return 'Email không hợp lệ';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            AuthTextField(
              controller: _passwordController,
              label: 'Mật khẩu',
              hint: 'Tối thiểu 6 ký tự, có chữ hoa và ký tự đặc biệt',
              obscureText: true,
              prefixIcon: Icons.lock_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mật khẩu';
                }
                if (value.length < 6) {
                  return 'Mật khẩu phải có ít nhất 6 ký tự';
                }
                final hasUpper = value.contains(RegExp(r'[A-Z]'));
                final hasSpecial = value.contains(RegExp(r'[^a-zA-Z0-9]'));
                if (!hasUpper || !hasSpecial) {
                  return 'Mật khẩu cần có chữ hoa và ký tự đặc biệt';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            AuthTextField(
              controller: _confirmPasswordController,
              label: 'Xác nhận mật khẩu',
              hint: 'Nhập lại mật khẩu',
              obscureText: true,
              prefixIcon: Icons.verified_user_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng xác nhận mật khẩu';
                }
                if (value.trim() != _passwordController.text.trim()) {
                  return 'Mật khẩu không khớp';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            AuthTextField(
              controller: _phoneController,
              label: 'Số điện thoại',
              hint: '0xxxxxxxxx',
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
              validator: (value) {
                final input = value?.trim() ?? '';
                if (input.isEmpty) {
                  return 'Vui lòng nhập số điện thoại';
                }
                if (!RegExp(r'^0\d{9}$').hasMatch(input)) {
                  return 'Số điện thoại phải gồm 10 số, bắt đầu bằng 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            Text(
              'Ngày sinh',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _pickDateOfBirth,
              style: _dateOfBirthError != null
                  ? OutlinedButton.styleFrom(
                      side: BorderSide(color: Theme.of(context).colorScheme.error),
                    )
                  : null,
              icon: Icon(
                Icons.calendar_month_outlined,
                color: _dateOfBirthError != null ? Theme.of(context).colorScheme.error : null,
              ),
              label: Text(
                _dateOfBirth == null
                    ? 'Chọn ngày sinh'
                    : '${_dateOfBirth!.day.toString().padLeft(2, '0')}/${_dateOfBirth!.month.toString().padLeft(2, '0')}/${_dateOfBirth!.year}',
                style: _dateOfBirthError != null
                    ? TextStyle(color: Theme.of(context).colorScheme.error)
                    : null,
              ),
            ),
            if (_dateOfBirthError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 16.0),
                child: Text(
                  _dateOfBirthError!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 14),
            Text(
              'Giới tính',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            RadioGroup<String>(
              groupValue: _gender,
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _gender = value;
                });
              },
              child: Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Nam'),
                      value: 'male',
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Nữ'),
                      value: 'female',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            AuthPrimaryButton(
              label: 'Đăng ký',
              isLoading: authState.isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: 12),
            AuthSwitchLink(
              question: 'Đã có tài khoản?',
              actionLabel: 'Đăng nhập',
              onTap: () => context.go(RoutePaths.login),
            ),
          ],
        ),
      ),
    );
  }
}

