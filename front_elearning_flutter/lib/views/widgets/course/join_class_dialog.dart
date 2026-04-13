import 'package:flutter/material.dart';

class JoinClassDialog extends StatefulWidget {
  const JoinClassDialog({super.key});

  @override
  State<JoinClassDialog> createState() => _JoinClassDialogState();
}

class _JoinClassDialogState extends State<JoinClassDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final code = _controller.text.trim();
    if (code.isEmpty) {
      setState(() {
        _errorText = 'Vui lòng nhập mã lớp học';
      });
      return;
    }
    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nhập mã lớp học'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Ví dụ: 11111',
          errorText: _errorText,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Tham gia')),
      ],
    );
  }
}
