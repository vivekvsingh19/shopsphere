import '../entities/product.dart';

/// Abstract repository interface for product operations.
abstract class ProductsRepository {
  Future<ProductPage> getProducts({int limit = 20, int skip = 0});
  Future<ProductPage> getProductsByCategory(String slug, {int limit = 20, int skip = 0});
  Future<ProductPage> searchProducts(String query, {int limit = 20, int skip = 0});
  Future<Product> getProductById(int id);
  Future<List<Category>> getCategories();
}
