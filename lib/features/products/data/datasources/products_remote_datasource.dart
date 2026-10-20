import 'package:dio/dio.dart';

import '../../data/models/product_models.dart';

class ProductsRemoteDataSource {
  ProductsRemoteDataSource(this._dio);
  final Dio _dio;

  Future<ProductListResponse> getProducts({int limit = 20, int skip = 0}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/products',
      queryParameters: {'limit': limit, 'skip': skip},
    );
    return ProductListResponse.fromJson(response.data!);
  }

  Future<ProductListResponse> getProductsByCategory(
    String slug, {
    int limit = 20,
    int skip = 0,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/products/category/$slug',
      queryParameters: {'limit': limit, 'skip': skip},
    );
    return ProductListResponse.fromJson(response.data!);
  }

  Future<ProductListResponse> searchProducts(
    String query, {
    int limit = 20,
    int skip = 0,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/products/search',
      queryParameters: {'q': query, 'limit': limit, 'skip': skip},
    );
    return ProductListResponse.fromJson(response.data!);
  }

  Future<ProductModel> getProductById(int id) async {
    final response = await _dio.get<Map<String, dynamic>>('/products/$id');
    return ProductModel.fromJson(response.data!);
  }

  Future<List<CategoryModel>> getCategories() async {
    final response = await _dio.get<List<dynamic>>('/products/categories');
    return (response.data ?? [])
        .whereType<Map<String, dynamic>>()
        .map(CategoryModel.fromJson)
        .toList();
  }
}
