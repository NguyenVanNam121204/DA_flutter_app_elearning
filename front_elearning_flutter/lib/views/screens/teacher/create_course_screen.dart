import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';

class CreateCourseScreen extends ConsumerStatefulWidget {
  const CreateCourseScreen({super.key});

  @override
  ConsumerState<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends ConsumerState<CreateCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _maxStudent = TextEditingController(text: '0');
  final _imageUrl = TextEditingController();

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(teacherCreateCourseViewModelProvider.notifier);
    final maxStudent = int.tryParse(_maxStudent.text.trim()) ?? 0;
    final msg = await notifier.createCourse(
      title: _title.text.trim(),
      description: _description.text.trim(),
      maxStudent: maxStudent,
      imageUrl: _imageUrl.text.trim(),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    if (msg == 'Tao khoa hoc thanh cong') context.pop();
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _maxStudent.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teacherCreateCourseViewModelProvider);
    final notifier = ref.read(teacherCreateCourseViewModelProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Tao lop hoc moi')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Ten lop hoc',
                hintText: 'VD: IELTS Intensive 6.5+',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Vui long nhap ten lop hoc';
                if (v.trim().length < 3) return 'Ten qua ngan';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _maxStudent,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Hoc vien toi da',
                hintText: '0 - theo goi dich vu',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                final n = int.tryParse((v ?? '').trim());
                if (n == null || n < 0) return 'Gia tri khong hop le';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _imageUrl,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Link anh bia (tu chon)',
                hintText: 'https://...',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                final s = (v ?? '').trim();
                if (s.isEmpty) return null;
                if (!s.startsWith('http://') && !s.startsWith('https://')) {
                  return 'URL khong hop le';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Mo ta lop hoc', style: TextStyle(fontWeight: FontWeight.w700)),
                TextButton(
                  onPressed: notifier.togglePreview,
                  child: Text(state.preview ? 'Sua' : 'Xem truoc'),
                ),
              ],
            ),
            if (state.preview)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.shade50,
                ),
                child: Text(
                  _description.text.trim().isEmpty ? 'Chua co noi dung mo ta' : _description.text.trim(),
                ),
              )
            else
              TextFormField(
                controller: _description,
                minLines: 5,
                maxLines: 10,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Gioi thieu muc tieu, lo trinh, doi tuong hoc...',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Vui long nhap mo ta';
                  return null;
                },
              ),
            const SizedBox(height: 8),
            Text(
              '${_description.text.trim().length} ky tu',
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: state.saving ? null : _create,
              icon: state.saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add),
              label: Text(state.saving ? 'Dang tao...' : 'Tao lop hoc ngay'),
            ),
          ],
        ),
      ),
    );
  }
}
