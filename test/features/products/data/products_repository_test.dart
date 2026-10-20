import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/app_error.dart';
import 'package:shopsphere/features/products/data/datasources/products_remote_datasource.dart';
import 'package:shopsphere/features/products/data/models/product_models.dart';
import 'package:shopsphere/features/products/data/repositories/products_repository_impl.dart';

class MockProductsRemoteDataSource extends Mock
    implements ProductsRemoteDataSource {}

void main() {
  late MockProductsRemoteDataSource mockDataSource;
  late ProductsRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockProductsRemoteDataSource();
    repository = ProductsRepositoryImpl(mockDataSource);
  });

  const tProductListResponse = ProductListResponse(
    products: [
      ProductModel(
        id: 1,
        title: 'iPhone 9',
        description: 'Apple mobile',
        price: 549.99,
        discountPercentage: 12.96,
        rating: 4.69,
        stock: 94,
        category: 'smartphones',
        thumbnail: 'https://example.com/thumb.jpg',
        images: ['https://example.com/1.jpg'],
      ),
    ],
    total: 1,
    skip: 0,
    limit: 20,
  );

  const tProductModel = ProductModel(
    id: 1,
    title: 'iPhone 9',
    description: 'Apple mobile',
    price: 549.99,
    discountPercentage: 12.96,
    rating: 4.69,
    stock: 94,
    category: 'smartphones',
    thumbnail: 'https://example.com/thumb.jpg',
    images: [],
  );

  group('ProductsRepositoryImpl.getProducts', () {
    test('T25: returns ProductPage on success', () async {
      when(() => mockDataSource.getProducts(limit: 20, skip: 0))
          .thenAnswer((_) async => tProductListResponse);

      final result = await repository.getProducts();

      expect(result.products.length, 1);
      expect(result.total, 1);
      expect(result.products.first.title, 'iPhone 9');
    });

    test('T26: maps DioException to NetworkError on connection failure', () async {
      when(() => mockDataSource.getProducts(limit: 20, skip: 0))
          .thenThrow(const NetworkError());

      expect(
        () => repository.getProducts(),
        throwsA(isA<NetworkError>()),
      );
    });

    test('T27: maps 500 response to ServerError', () async {
      when(() => mockDataSource.getProducts(limit: 20, skip: 0))
          .thenThrow(const ServerError(statusCode: 500, message: 'Internal Server Error'));

      expect(
        () => repository.getProducts(),
        throwsA(isA<ServerError>()),
      );
    });
  });

  group('ProductsRepositoryImpl.getProductById', () {
    test('T28: returns Product on success', () async {
      when(() => mockDataSource.getProductById(1))
          .thenAnswer((_) async => tProductModel);

      final product = await repository.getProductById(1);

      expect(product.id, 1);
      expect(product.title, 'iPhone 9');
    });

    test('T29: throws NotFoundError for non-existent product', () async {
      when(() => mockDataSource.getProductById(9999))
          .thenThrow(const NotFoundError(message: 'Product with id "9999" not found'));

      expect(
        () => repository.getProductById(9999),
        throwsA(isA<NotFoundError>()),
      );
    });
  });

  group('ProductsRepositoryImpl.searchProducts', () {
    test('T30: returns matching products for a query', () async {
      when(() => mockDataSource.searchProducts('phone', limit: 20, skip: 0))
          .thenAnswer((_) async => tProductListResponse);

      final result = await repository.searchProducts('phone');

      expect(result.products, isNotEmpty);
    });

    test('T31: returns empty list when search yields no results', () async {
      const emptyResponse = ProductListResponse(
        products: [],
        total: 0,
        skip: 0,
        limit: 20,
      );
      when(() => mockDataSource.searchProducts('zzznoresultszzz', limit: 20, skip: 0))
          .thenAnswer((_) async => emptyResponse);

      final result = await repository.searchProducts('zzznoresultszzz');

      expect(result.products, isEmpty);
      expect(result.total, 0);
    });
  });

  group('ProductsRepositoryImpl.getCategories', () {
    test('T32: returns list of categories on success', () async {
      final tCategories = [
        const CategoryModel(
          slug: 'smartphones',
          name: 'Smartphones',
          url: 'https://dummyjson.com/products/category/smartphones',
        ),
      ];
      when(() => mockDataSource.getCategories())
          .thenAnswer((_) async => tCategories);

      final result = await repository.getCategories();

      expect(result.length, 1);
      expect(result.first.slug, 'smartphones');
      expect(result.first.name, 'Smartphones');
    });
  });
}
