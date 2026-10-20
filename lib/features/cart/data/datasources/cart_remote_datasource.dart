import 'package:dio/dio.dart';

/// Submits a simulated order via POST /carts/add.
class CartRemoteDataSource {
  CartRemoteDataSource(this._dio);
  final Dio _dio;

  /// Sends a cart order to DummyJSON.
  /// [userId] defaults to 1 for demo purposes.
  Future<Map<String, dynamic>> checkout({
    required List<Map<String, dynamic>> products,
    int userId = 1,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/carts/add',
      data: {'userId': userId, 'products': products},
    );
    return response.data ?? {};
  }
}
