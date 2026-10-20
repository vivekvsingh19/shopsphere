import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/products/data/models/product_models.dart';

void main() {
  group('ProductModel', () {
    late Map<String, dynamic> validJson;

    setUp(() {
      final file = File('test/fixtures/product.json');
      validJson = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    });

    test('T01: parses a valid product JSON correctly', () {
      final model = ProductModel.fromJson(validJson);

      expect(model.id, 1);
      expect(model.title, 'iPhone 9');
      expect(model.price, 549.99);
      expect(model.discountPercentage, 12.96);
      expect(model.rating, 4.69);
      expect(model.stock, 94);
      expect(model.brand, 'Apple');
      expect(model.category, 'smartphones');
      expect(model.images.length, 2);
    });

    test('T02: parses reviews from JSON', () {
      final model = ProductModel.fromJson(validJson);

      expect(model.reviews.length, 1);
      expect(model.reviews.first.reviewerName, 'John Doe');
      expect(model.reviews.first.rating, 5.0);
      expect(model.reviews.first.comment, 'Very satisfied!');
    });

    test('T03: handles nullable fields gracefully', () {
      final minimalJson = {
        'id': 99,
        'title': 'Minimal Product',
        'description': 'Desc',
        'price': 10.0,
        'discountPercentage': 0.0,
        'rating': 3.5,
        'stock': 0,
        'category': 'test',
        'thumbnail': '',
        'images': <String>[],
      };
      final model = ProductModel.fromJson(minimalJson);

      expect(model.brand, isNull);
      expect(model.dimensions, isNull);
      expect(model.meta, isNull);
      expect(model.sku, isNull);
      expect(model.reviews, isEmpty);
      expect(model.tags, isEmpty);
    });

    test('T04: finalPrice is calculated correctly with discount', () {
      final model = ProductModel.fromJson(validJson);
      final expected = 549.99 * (1 - 12.96 / 100);

      expect(model.finalPrice, closeTo(expected, 0.01));
    });

    test('T05: inStock returns false when stock is 0', () {
      final json = Map<String, dynamic>.from(validJson)..['stock'] = 0;
      final model = ProductModel.fromJson(json);

      expect(model.inStock, isFalse);
    });

    test('T06: inStock returns true when stock is positive', () {
      final model = ProductModel.fromJson(validJson);

      expect(model.inStock, isTrue);
    });
  });

  group('ProductListResponse', () {
    late Map<String, dynamic> listJson;

    setUp(() {
      final file = File('test/fixtures/product_list.json');
      listJson = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    });

    test('T07: parses product list response correctly', () {
      final response = ProductListResponse.fromJson(listJson);

      expect(response.products.length, 2);
      expect(response.total, 194);
      expect(response.skip, 0);
      expect(response.limit, 20);
    });

    test('T08: hasMore is true when more products exist', () {
      final response = ProductListResponse.fromJson(listJson);

      expect(response.hasMore, isTrue); // 0 + 20 < 194
    });

    test('T09: hasMore is false at last page', () {
      final json = Map<String, dynamic>.from(listJson)
        ..['skip'] = 180
        ..['total'] = 194;
      final response = ProductListResponse.fromJson(json);

      expect(response.hasMore, isFalse); // 180 + 20 = 200 >= 194
    });
  });

  group('ReviewModel', () {
    test('T10: parses review JSON correctly', () {
      const json = {
        'rating': 4.0,
        'comment': 'Great product!',
        'date': '2024-01-15T00:00:00.000Z',
        'reviewerName': 'Alice',
        'reviewerEmail': 'alice@example.com',
      };
      final review = ReviewModel.fromJson(json);

      expect(review.rating, 4.0);
      expect(review.comment, 'Great product!');
      expect(review.reviewerName, 'Alice');
      expect(review.reviewerEmail, 'alice@example.com');
    });
  });
}
