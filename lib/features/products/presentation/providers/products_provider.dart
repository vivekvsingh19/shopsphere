import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../data/datasources/products_remote_datasource.dart';
import '../../data/repositories/products_repository_impl.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/products_repository.dart';

// ─── DI ───────────────────────────────────────────────────────────────────

final productsRemoteDataSourceProvider = Provider<ProductsRemoteDataSource>((
  ref,
) {
  return ProductsRemoteDataSource(ref.watch(dioProvider));
});

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  return ProductsRepositoryImpl(ref.watch(productsRemoteDataSourceProvider));
});

// ─── Sort enum ────────────────────────────────────────────────────────────

enum ProductSort { none, priceAsc, priceDesc, ratingDesc, titleAsc }

extension ProductSortLabel on ProductSort {
  String get label => switch (this) {
    ProductSort.none => 'Default',
    ProductSort.priceAsc => 'Price: Low to High',
    ProductSort.priceDesc => 'Price: High to Low',
    ProductSort.ratingDesc => 'Top Rated',
    ProductSort.titleAsc => 'Name A–Z',
  };
}

// ─── Filter state ─────────────────────────────────────────────────────────

class CatalogueFilter {
  const CatalogueFilter({
    this.query = '',
    this.categorySlug,
    this.sort = ProductSort.none,
  });

  final String query;
  final String? categorySlug;
  final ProductSort sort;

  CatalogueFilter copyWith({
    String? query,
    String? categorySlug,
    bool clearCategory = false,
    ProductSort? sort,
  }) {
    return CatalogueFilter(
      query: query ?? this.query,
      categorySlug: clearCategory ? null : (categorySlug ?? this.categorySlug),
      sort: sort ?? this.sort,
    );
  }
}

// ─── Catalogue state ──────────────────────────────────────────────────────

class CatalogueState {
  const CatalogueState({
    this.products = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.total = 0,
    this.skip = 0,
    this.filter = const CatalogueFilter(),
  });

  final List<Product> products;
  final bool isLoading;
  final bool isLoadingMore;
  final Object? error;
  final int total;
  final int skip;
  final CatalogueFilter filter;

  bool get hasMore => skip < total && products.isNotEmpty;
  bool get isEmpty => !isLoading && products.isEmpty && error == null;

  CatalogueState copyWith({
    List<Product>? products,
    bool? isLoading,
    bool? isLoadingMore,
    Object? error,
    bool clearError = false,
    int? total,
    int? skip,
    CatalogueFilter? filter,
  }) {
    return CatalogueState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
      total: total ?? this.total,
      skip: skip ?? this.skip,
      filter: filter ?? this.filter,
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────

class CatalogueNotifier extends StateNotifier<CatalogueState> {
  CatalogueNotifier(this._repository) : super(const CatalogueState());

  final ProductsRepository _repository;
  Timer? _debounce;
  static const _pageSize = 20;

  Future<void> load({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        products: [],
        skip: 0,
        clearError: true,
      );
    } else {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    try {
      final page = await _fetchPage(skip: 0);
      _applyPage(page, isFirstPage: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final page = await _fetchPage(skip: state.skip);
      _applyPage(page, isFirstPage: false);
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e);
    }
  }

  void setSearch(String query) {
    _debounce?.cancel();
    state = state.copyWith(filter: state.filter.copyWith(query: query));
    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => load(refresh: true),
    );
  }

  void setCategory(String? slug) {
    state = state.copyWith(
      filter: slug == null
          ? state.filter.copyWith(clearCategory: true)
          : state.filter.copyWith(categorySlug: slug),
    );
    load(refresh: true);
  }

  void setSort(ProductSort sort) {
    state = state.copyWith(filter: state.filter.copyWith(sort: sort));
    _sortInPlace();
  }

  void _sortInPlace() {
    final sorted = List<Product>.from(state.products);
    switch (state.filter.sort) {
      case ProductSort.priceAsc:
        sorted.sort((a, b) => a.finalPrice.compareTo(b.finalPrice));
      case ProductSort.priceDesc:
        sorted.sort((a, b) => b.finalPrice.compareTo(a.finalPrice));
      case ProductSort.ratingDesc:
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
      case ProductSort.titleAsc:
        sorted.sort((a, b) => a.title.compareTo(b.title));
      case ProductSort.none:
        break;
    }
    state = state.copyWith(products: sorted);
  }

  Future<ProductPage> _fetchPage({required int skip}) async {
    final filter = state.filter;
    if (filter.query.isNotEmpty) {
      return _repository.searchProducts(
        filter.query,
        limit: _pageSize,
        skip: skip,
      );
    }
    if (filter.categorySlug != null) {
      return _repository.getProductsByCategory(
        filter.categorySlug!,
        limit: _pageSize,
        skip: skip,
      );
    }
    return _repository.getProducts(limit: _pageSize, skip: skip);
  }

  void _applyPage(ProductPage page, {required bool isFirstPage}) {
    final newList = isFirstPage
        ? page.products
        : [...state.products, ...page.products];

    state = state.copyWith(
      products: newList,
      isLoading: false,
      isLoadingMore: false,
      total: page.total,
      skip: page.skip + page.limit,
      clearError: true,
    );

    // Apply sort after load
    if (state.filter.sort != ProductSort.none) _sortInPlace();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

final catalogueNotifierProvider =
    StateNotifierProvider<CatalogueNotifier, CatalogueState>((ref) {
      final notifier = CatalogueNotifier(ref.watch(productsRepositoryProvider));
      notifier.load();
      return notifier;
    });

// ─── Categories ───────────────────────────────────────────────────────────

final categoriesProvider = FutureProvider<List<Category>>((ref) {
  return ref.watch(productsRepositoryProvider).getCategories();
});

// ─── Product detail ───────────────────────────────────────────────────────

final productDetailProvider = FutureProvider.family<Product, int>((ref, id) {
  return ref.watch(productsRepositoryProvider).getProductById(id);
});
