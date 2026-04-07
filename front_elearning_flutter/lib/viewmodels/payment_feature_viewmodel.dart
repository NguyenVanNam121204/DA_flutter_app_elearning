import '../core/result/result.dart';
import 'api_data_viewmodel.dart';

class PaymentFeatureViewModel {
  PaymentFeatureViewModel(this._api);

  final ApiDataViewModel _api;

  Future<Result<Map<String, dynamic>>> createPaymentAndLink({
    required int productId,
    required int typeProduct,
  }) async {
    final process = await _api.post(
      '/api/user/payments/process',
      body: {
        'ProductId': productId,
        'typeproduct': typeProduct,
        'IdempotencyKey': DateTime.now().millisecondsSinceEpoch.toString(),
      },
    );
    if (process case Failure(:final error)) return Failure(error);
    final processMap = _asMap((process as Success<dynamic>).value);
    final paymentId = (processMap['paymentId'] ?? processMap['PaymentId'] ?? '').toString();
    if (paymentId.isEmpty) return const Success({});
    final link = await _api.post('/api/user/payments/payos/create-link/$paymentId');
    if (link case Failure(:final error)) return Failure(error);
    final linkMap = _asMap((link as Success<dynamic>).value);
    return Success({
      'paymentId': paymentId,
      'checkoutUrl': (linkMap['checkoutUrl'] ?? linkMap['CheckoutUrl'] ?? linkMap['url'] ?? '').toString(),
    });
  }

  Future<Result<void>> confirmPayment(String paymentId) async {
    final res = await _api.post('/api/user/payments/payos/confirm/$paymentId');
    return switch (res) {
      Success() => const Success(null),
      Failure(:final error) => Failure(error),
    };
  }

  Future<Result<List<Map<String, dynamic>>>> paymentHistory() async {
    final res = await _api.get('/api/user/payments/history', query: {'pageNumber': 1, 'pageSize': 20});
    return switch (res) {
      Success(:final value) => Success(_asList(value)),
      Failure(:final error) => Failure(error),
    };
  }

  Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final data = raw['data'] ?? raw['Data'] ?? raw;
      if (data is Map<String, dynamic>) return data;
      return raw;
    }
    return const {};
  }

  List<Map<String, dynamic>> _asList(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final data = raw['data'] ?? raw['Data'];
      if (data is Map<String, dynamic>) {
        final items = data['items'] ?? data['Items'];
        if (items is List) return items.whereType<Map<String, dynamic>>().toList();
      }
      if (data is List) return data.whereType<Map<String, dynamic>>().toList();
    }
    return const [];
  }
}

