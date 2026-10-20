/// Domain entity: Product — pure Dart, no Flutter, no HTTP.
class Product {
  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.category,
    required this.thumbnail,
    required this.images,
    this.brand,
    this.reviews = const [],
    this.tags = const [],
    this.availabilityStatus,
    this.shippingInformation,
    this.warrantyInformation,
    this.returnPolicy,
  });

  final int id;
  final String title;
  final String description;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String category;
  final String thumbnail;
  final List<String> images;
  final String? brand;
  final List<Review> reviews;
  final List<String> tags;
  final String? availabilityStatus;
  final String? shippingInformation;
  final String? warrantyInformation;
  final String? returnPolicy;

  double get finalPrice => price * (1 - discountPercentage / 100);
  bool get inStock => stock > 0;
}

/// Domain entity: Review.
class Review {
  const Review({
    required this.rating,
    required this.comment,
    required this.reviewerName,
    required this.reviewerEmail,
    required this.date,
  });

  final double rating;
  final String comment;
  final String reviewerName;
  final String reviewerEmail;
  final String date;
}

/// Domain entity: Category.
class Category {
  const Category({required this.slug, required this.name});
  final String slug;
  final String name;
}

/// Pagination metadata.
class ProductPage {
  const ProductPage({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  final List<Product> products;
  final int total;
  final int skip;
  final int limit;

  bool get hasMore => skip + limit < total;
}
