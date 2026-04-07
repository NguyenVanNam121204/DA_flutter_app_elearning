import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router/route_paths.dart';
import '../../../viewmodels/payment_screen_viewmodel.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({
    required this.paymentId,
    this.courseId = '',
    this.courseTitle = '',
    this.packageId = '',
    this.packageName = '',
    this.price = '',
    super.key,
  });
  final String paymentId;
  final String courseId;
  final String courseTitle;
  final String packageId;
  final String packageName;
  final String price;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final TextEditingController _productIdController = TextEditingController();
  late final PaymentScreenArgs _args;

  @override
  void initState() {
    super.initState();
    _args = PaymentScreenArgs(
      paymentId: widget.paymentId,
      courseId: widget.courseId,
      packageId: widget.packageId,
    );
    _productIdController.addListener(() {
      ref
          .read(
            paymentScreenViewModelProvider(_args).notifier,
          )
          .setProductIdInput(_productIdController.text);
    });
  }

  @override
  void dispose() {
    _productIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentScreenViewModelProvider(_args));
    final notifier = ref.read(paymentScreenViewModelProvider(_args).notifier);
    if (_productIdController.text != state.productIdInput) {
      _productIdController.text = state.productIdInput;
    }
    ref.listen(paymentScreenViewModelProvider(_args), (prev, next) {
      final becameSuccess = prev?.status != 'Thanh toan thanh cong' &&
          next.status == 'Thanh toan thanh cong' &&
          next.paymentId.isNotEmpty;
      if (becameSuccess) {
        context.push(
          '${RoutePaths.paymentSuccess}?paymentId=${next.paymentId}&orderCode=${next.paymentId}',
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            if (widget.courseTitle.isNotEmpty || widget.packageName.isNotEmpty)
              Card(
                child: ListTile(
                  title: Text(widget.courseTitle.isNotEmpty ? widget.courseTitle : widget.packageName),
                  subtitle: Text(widget.price.isNotEmpty ? 'Gia: ${widget.price}' : 'San pham thanh toan'),
                ),
              ),
            if (widget.courseTitle.isNotEmpty || widget.packageName.isNotEmpty)
              const SizedBox(height: 12),
            TextField(
              controller: _productIdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Product Id',
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1, label: Text('Course')),
                ButtonSegment(value: 2, label: Text('TeacherPackage')),
              ],
              selected: {state.typeProduct},
              onSelectionChanged: (s) => notifier.setTypeProduct(s.first),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: state.isLoading ? null : notifier.createPayment,
              child: Text(state.isLoading ? 'Dang tao don...' : 'Tao thanh toan'),
            ),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: (state.isConfirming || state.paymentId.isEmpty)
                  ? null
                  : notifier.confirmPayment,
              child: Text(
                state.isConfirming
                    ? 'Dang kiem tra giao dich...'
                    : 'Kiem tra trang thai thanh toan',
              ),
            ),
            if (state.status.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(state.status),
            ],
            if (state.payUrl.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Link thanh toan:'),
              const SizedBox(height: 8),
              SelectableText(state.payUrl),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: state.payUrl));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Da copy link')));
                },
                child: const Text('Copy link'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: state.paymentId.isEmpty
                          ? null
                          : () => context.push(
                                '${RoutePaths.paymentSuccess}?paymentId=${state.paymentId}&orderCode=${state.paymentId}',
                              ),
                      child: const Text('Test Success'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          context.push('${RoutePaths.paymentFailed}?reason=Thanh+toan+khong+thanh+cong'),
                      child: const Text('Test Failed'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
