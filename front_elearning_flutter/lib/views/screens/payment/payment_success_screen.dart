import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router/route_paths.dart';
import '../../../core/result/result.dart';

class PaymentSuccessScreen extends ConsumerStatefulWidget {
  const PaymentSuccessScreen({required this.paymentId, this.courseId = '', this.orderCode = '', super.key});
  final String paymentId;
  final String courseId;
  final String orderCode;

  @override
  ConsumerState<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends ConsumerState<PaymentSuccessScreen> {
  bool _loading = true;
  bool _enrolled = false;
  bool _isPackage = false;
  String _resolvedCourseId = '';
  String _error = '';

  @override
  void initState() {
    super.initState();
    _confirm();
  }

  Future<void> _confirm() async {
    if (widget.paymentId.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Khong tim thay thong tin thanh toan';
      });
      return;
    }
    final confirm = await ref.read(paymentFeatureViewModelProvider).confirmPayment(widget.paymentId);
    if (confirm case Failure(:final error)) {
      setState(() {
        _loading = false;
        _error = error.message;
      });
      return;
    }
    final detail = await ref.read(paymentFeatureViewModelProvider).paymentHistory();
    if (detail case Success(:final value)) {
      final found = value.firstWhere(
            (e) => (e['paymentId'] ?? e['PaymentId'] ?? '').toString() == widget.paymentId,
            orElse: () => <String, dynamic>{},
          );
        final productType = found['productType'] ?? found['ProductType'];
        final productId = (found['productId'] ?? found['ProductId'] ?? '').toString();
        if (productType == 2 || productType?.toString() == '2') {
          _isPackage = true;
        }
        if ((productType == 1 || productType?.toString() == '1') && productId.isNotEmpty) {
          _resolvedCourseId = productId;
          final enroll =
              await ref.read(apiDataViewModelProvider).post('/api/user/enrollments', body: {'CourseId': productId});
          _enrolled = enroll is Success<dynamic>;
        }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Payment Success')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 64),
                const SizedBox(height: 12),
                Text(_error, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(onPressed: () => context.go(RoutePaths.mainApp), child: const Text('Ve trang chu')),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Success')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 12),
            Text('PaymentId: ${widget.paymentId}'),
            const SizedBox(height: 8),
            const Text('Thanh toan thanh cong'),
            if (widget.orderCode.isNotEmpty) Text('Ma giao dich: ${widget.orderCode}'),
            if (_isPackage) const Text('Goi giao vien da duoc kich hoat'),
            if (_enrolled) const Text('Ban da duoc dang ky vao khoa hoc!'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                final cid = widget.courseId.isNotEmpty ? widget.courseId : _resolvedCourseId;
                if (cid.isNotEmpty) {
                  context.go('${RoutePaths.courseDetail}?courseId=$cid');
                } else if (_isPackage) {
                  context.go(RoutePaths.mainApp);
                } else {
                  context.go(RoutePaths.mainApp);
                }
              },
              child: Text(_enrolled ? 'Xem khoa hoc' : (_isPackage ? 'Den trang ca nhan' : 'Ve trang chu')),
            ),
          ],
        ),
      ),
    );
  }
}
