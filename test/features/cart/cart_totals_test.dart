import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_item.dart';

void main() {
  group('CartItem', () {
    const item = CartItem(
      productId: 1,
      title: 'iPhone 9',
      thumbnail: 'https://example.com/thumb.jpg',
      price: 549.99,
      discountPercentage: 12.96,
      quantity: 2,
      stock: 94,
    );

    test('T15: JSON serialisation round-trip', () {
      final json = item.toJson();
      final restored = CartItem.fromJson(json);

      expect(restored.productId, item.productId);
      expect(restored.title, item.title);
      expect(restored.price, item.price);
      expect(restored.discountPercentage, item.discountPercentage);
      expect(restored.quantity, item.quantity);
      expect(restored.stock, item.stock);
    });

    test('T16: finalPrice applies discount correctly', () {
      final expected = 549.99 * (1 - 12.96 / 100);
      expect(item.finalPrice, closeTo(expected, 0.01));
    });

    test('T17: subtotal = finalPrice × quantity', () {
      final expected = item.finalPrice * 2;
      expect(item.subtotal, closeTo(expected, 0.01));
    });

    test('T18: discount = originalSubtotal - subtotal', () {
      final original = 549.99 * 2;
      final final_ = item.finalPrice * 2;
      expect(item.discount, closeTo(original - final_, 0.01));
    });

    test('T19: copyWith updates quantity', () {
      final updated = item.copyWith(quantity: 5);
      expect(updated.quantity, 5);
      expect(updated.productId, item.productId);
      expect(updated.price, item.price);
    });

    test('T20: missing stock in JSON defaults to 0', () {
      final json = item.toJson()..remove('stock');
      final restored = CartItem.fromJson(json);
      expect(restored.stock, 0);
    });
  });

  group('CartTotals', () {
    test('T21: calculates totals for empty cart', () {
      final totals = CartTotals.from([]);

      expect(totals.subtotal, 0.0);
      expect(totals.discount, 0.0);
      expect(totals.grandTotal, 0.0);
      expect(totals.itemCount, 0);
    });

    test('T22: calculates totals for multiple items', () {
      const items = [
        CartItem(
          productId: 1,
          title: 'Product A',
          thumbnail: '',
          price: 100.0,
          discountPercentage: 10.0,
          quantity: 2,
          stock: 10,
        ),
        CartItem(
          productId: 2,
          title: 'Product B',
          thumbnail: '',
          price: 200.0,
          discountPercentage: 20.0,
          quantity: 1,
          stock: 5,
        ),
      ];
      final totals = CartTotals.from(items);

      // Item 1: 100 * (1-0.1) * 2 = 180; original = 200
      // Item 2: 200 * (1-0.2) * 1 = 160; original = 200
      expect(totals.grandTotal, closeTo(340.0, 0.01));
      expect(totals.subtotal, closeTo(400.0, 0.01));
      expect(totals.discount, closeTo(60.0, 0.01));
      expect(totals.itemCount, 3); // 2 + 1
    });

    test('T23: itemCount sums all quantities', () {
      final items = List.generate(
        3,
        (i) => CartItem(
          productId: i,
          title: 'P$i',
          thumbnail: '',
          price: 10.0,
          discountPercentage: 0.0,
          quantity: i + 1,
          stock: 10,
        ),
      );
      final totals = CartTotals.from(items);

      expect(totals.itemCount, 6); // 1 + 2 + 3
    });

    test('T24: no discount when discountPercentage is 0', () {
      const items = [
        CartItem(
          productId: 1,
          title: 'No-Discount Product',
          thumbnail: '',
          price: 50.0,
          discountPercentage: 0.0,
          quantity: 3,
          stock: 10,
        ),
      ];
      final totals = CartTotals.from(items);

      expect(totals.discount, closeTo(0.0, 0.001));
      expect(totals.grandTotal, closeTo(150.0, 0.01));
    });
  });
}
