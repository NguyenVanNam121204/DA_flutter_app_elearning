import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/result/result.dart';

class PaymentHistoryScreen extends ConsumerWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Result<List<Map<String, dynamic>>>>(
      future: ref.read(paymentFeatureViewModelProvider).paymentHistory(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final result = snapshot.data!;
        if (result case Failure(:final error)) {
          return Scaffold(body: Center(child: Text(error.message)));
        }
        final items = (result as Success<List<Map<String, dynamic>>>).value;
        return Scaffold(
          appBar: AppBar(title: const Text('Payment History')),
          body: items.isEmpty
              ? const Center(child: Text('Chua co giao dich nao'))
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final it = items[index];
                    final code = (it['orderCode'] ?? it['OrderCode'] ?? '').toString();
                    final amount = (it['amount'] ?? it['Amount'] ?? '').toString();
                    final status = (it['status'] ?? it['Status'] ?? '').toString();
                    final productType = (it['productType'] ?? it['ProductType'] ?? '').toString();
                    final createdAt = (it['createdAt'] ?? it['CreatedAt'] ?? '').toString();
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          status.toLowerCase().contains('success') || status == '2'
                              ? Icons.check_circle
                              : Icons.pending,
                          color: status.toLowerCase().contains('success') || status == '2'
                              ? Colors.green
                              : Colors.orange,
                        ),
                        title: Text('Order $code'),
                        subtitle: Text(
                          'Amount: $amount\nType: $productType • Status: $status\n$createdAt',
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
