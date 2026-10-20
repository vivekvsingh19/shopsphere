import '../../../../core/error/error_handler.dart';
import '../datasources/products_remote_datasource.dart';
import '../models/product_models.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/products_repository.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  ProductsRepositoryImpl(this._remote);
  final ProductsRemoteDataSource _remote;

  @override
  Future<ProductPage> getProducts({int limit = 20, int skip = 0}) async {
    try {
      final response = await _remote.getProducts(limit: limit, skip: skip);
      return _toPage(response);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<ProductPage> getProductsByCategory(
    String slug, {
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      final response = await _remote.getProductsByCategory(slug, limit: limit, skip: skip);
      return _toPage(response);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<ProductPage> searchProducts(
    String query, {
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      final response = await _remote.searchProducts(query, limit: limit, skip: skip);
      return _toPage(response);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<Product> getProductById(int id) async {
    try {
      final model = await _remote.getProductById(id);
      return _toProduct(model);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<List<Category>> getCategories() async {
    try {
      final models = await _remote.getCategories();
      return models.map(_toCategory).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  // ─── Mappers ─────────────────────────────────────────────────────────────

  ProductPage _toPage(ProductListResponse r) {
    return ProductPage(
      products: r.products.map(_toProduct).toList(),
      total: r.total,
      skip: r.skip,
      limit: r.limit,
    );
  }

  Product _toProduct(ProductModel m) {
    return Product(
      id: m.id,
      title: m.title,
      description: m.description,
      price: m.price,
      discountPercentage: m.discountPercentage,
      rating: m.rating,
      stock: m.stock,
      category: m.category,
      thumbnail: m.thumbnail,
      images: m.images,
      brand: m.brand,
      reviews: m.reviews.map(_toReview).toList(),
      tags: m.tags,
      availabilityStatus: m.availabilityStatus,
      shippingInformation: m.shippingInformation,
      warrantyInformation: m.warrantyInformation,
      returnPolicy: m.returnPolicy,
    );
  }

  Review _toReview(ReviewModel r) {
    return Review(
      rating: r.rating,
      comment: r.comment,
      reviewerName: r.reviewerName,
      reviewerEmail: r.reviewerEmail,
      date: r.date,
    );
  }

  Category _toCategory(CategoryModel c) {
    return Category(slug: c.slug, name: c.name);
  }
}
