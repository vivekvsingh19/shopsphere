/// Domain entity: CartItem — pure Dart.
class CartItem {
  const CartItem({
    required this.productId,
    required this.title,
    required this.thumbnail,
    required this.price,
    required this.discountPercentage,
    required this.quantity,
    required this.stock,
  });

  final int productId;
  final String title;
  final String thumbnail;
  final double price;
  final double discountPercentage;
  final int quantity;
  final int stock;

  double get finalPrice => price * (1 - discountPercentage / 100);
  double get subtotal => finalPrice * quantity;
  double get originalSubtotal => price * quantity;
  double get discount => originalSubtotal - subtotal;

  CartItem copyWith({
    int? quantity,
    int? stock,
  }) {
    return CartItem(
      productId: productId,
      title: title,
      thumbnail: thumbnail,
      price: price,
      discountPercentage: discountPercentage,
      quantity: quantity ?? this.quantity,
      stock: stock ?? this.stock,
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'title': title,
        'thumbnail': thumbnail,
        'price': price,
        'discountPercentage': discountPercentage,
        'quantity': quantity,
        'stock': stock,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        productId: json['productId'] as int,
        title: json['title'] as String,
        thumbnail: json['thumbnail'] as String,
        price: (json['price'] as num).toDouble(),
        discountPercentage: (json['discountPercentage'] as num).toDouble(),
        quantity: json['quantity'] as int,
        stock: json['stock'] as int? ?? 0,
      );
}

/// Cart totals calculator.
class CartTotals {
  const CartTotals({
    required this.subtotal,
    required this.discount,
    required this.grandTotal,
    required this.itemCount,
  });

  final double subtotal;
  final double discount;
  final double grandTotal;
  final int itemCount;

  static CartTotals from(List<CartItem> items) {
    double subtotal = 0;
    double grandTotal = 0;
    int count = 0;

    for (final item in items) {
      subtotal += item.originalSubtotal;
      grandTotal += item.subtotal;
      count += item.quantity;
    }

    return CartTotals(
      subtotal: subtotal,
      discount: subtotal - grandTotal,
      grandTotal: grandTotal,
      itemCount: count,
    );
  }
}
