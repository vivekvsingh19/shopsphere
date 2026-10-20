import 'package:json_annotation/json_annotation.dart';

part 'product_models.g.dart';

@JsonSerializable()
class ReviewModel {
  const ReviewModel({
    required this.rating,
    required this.comment,
    required this.date,
    required this.reviewerName,
    required this.reviewerEmail,
  });

  final double rating;
  final String comment;
  final String date;
  final String reviewerName;
  final String reviewerEmail;

  factory ReviewModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewModelFromJson(json);
}

@JsonSerializable()
class DimensionsModel {
  const DimensionsModel({
    required this.width,

    required this.height,
    required this.depth,
  });

  final double width;
  final double height;
  final double depth;

  factory DimensionsModel.fromJson(Map<String, dynamic> json) =>
      _$DimensionsModelFromJson(json);
}

@JsonSerializable()
class MetaModel {
  const MetaModel({this.createdAt, this.updatedAt, this.barcode, this.qrCode});

  final String? createdAt;
  final String? updatedAt;
  final String? barcode;
  final String? qrCode;

  factory MetaModel.fromJson(Map<String, dynamic> json) =>
      _$MetaModelFromJson(json);
}

@JsonSerializable()
class ProductModel {
  const ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.brand,
    required this.category,
    required this.thumbnail,
    required this.images,
    this.reviews = const [],
    this.dimensions,
    this.meta,
    this.tags = const [],
    this.sku,
    this.weight,
    this.warrantyInformation,
    this.shippingInformation,
    this.availabilityStatus,
    this.returnPolicy,
    this.minimumOrderQuantity,
  });

  final int id;
  final String title;
  final String description;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String? brand;
  final String category;
  final String thumbnail;
  final List<String> images;
  final List<ReviewModel> reviews;
  final DimensionsModel? dimensions;
  final MetaModel? meta;
  final List<String> tags;
  final String? sku;
  final double? weight;
  final String? warrantyInformation;
  final String? shippingInformation;
  final String? availabilityStatus;
  final String? returnPolicy;
  final int? minimumOrderQuantity;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  /// Discounted price.
  double get finalPrice => price * (1 - discountPercentage / 100);

  bool get inStock => stock > 0;
}

@JsonSerializable()
class ProductListResponse {
  const ProductListResponse({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  final List<ProductModel> products;
  final int total;
  final int skip;
  final int limit;

  factory ProductListResponse.fromJson(Map<String, dynamic> json) =>
      _$ProductListResponseFromJson(json);

  bool get hasMore => skip + limit < total;
}

@JsonSerializable()
class CategoryModel {
  const CategoryModel({
    required this.slug,
    required this.name,
    required this.url,
  });

  final String slug;
  final String name;
  final String url;

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);
}
