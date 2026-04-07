import '../core/result/result.dart';
import '../repositories/api_data_repository.dart';

class ApiDataViewModel {
  ApiDataViewModel(this._repository);

  final ApiDataRepository _repository;

  Future<Result<dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) {
    return _repository.get(path, query: query);
  }

  Future<Result<dynamic>> post(
    String path, {
    dynamic body,
    Map<String, dynamic>? query,
  }) {
    return _repository.post(path, body: body, query: query);
  }

  Future<Result<dynamic>> put(
    String path, {
    dynamic body,
    Map<String, dynamic>? query,
  }) {
    return _repository.put(path, body: body, query: query);
  }
}

