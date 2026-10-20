import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/error/error_handler.dart';
import '../../data/datasources/cart_local_datasource.dart';
import '../../data/datasources/cart_remote_datasource.dart';
import '../../domain/entities/cart_item.dart';
import '../../../products/domain/entities/product.dart';

// ─── DI ───────────────────────────────────────────────────────────────────

final cartLocalDataSourceProvider = Provider<CartLocalDataSource>((ref) {
  return CartLocalDataSource(ref.watch(sharedPreferencesProvider));
});

final cartRemoteDataSourceProvider = Provider<CartRemoteDataSource>((ref) {
  return CartRemoteDataSource(ref.watch(dioProvider));
});

// ─── Checkout state ───────────────────────────────────────────────────────

sealed class CheckoutState {
  const CheckoutState();
}

class CheckoutIdle extends CheckoutState {
  const CheckoutIdle();
}

class CheckoutLoading extends CheckoutState {
  const CheckoutLoading();
}

class CheckoutSuccess extends CheckoutState {
  const CheckoutSuccess(this.orderId);
  final int orderId;
}

class CheckoutFailure extends CheckoutState {
  const CheckoutFailure(this.message);
  final String message;
}

// ─── Cart notifier ────────────────────────────────────────────────────────

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier(this._local, this._remote) : super(const []) {
    _loadFromDisk();
  }

  final CartLocalDataSource _local;
  final CartRemoteDataSource _remote;

  void _loadFromDisk() {
    state = _local.loadCart();
  }

  Future<void> _persist() => _local.saveCart(state);

  void addItem(Product product, {int quantity = 1}) {
    final existing = state.indexWhere((i) => i.productId == product.id);
    if (existing >= 0) {
      final item = state[existing];
      final newQty = (item.quantity + quantity).clamp(1, product.stock);
      state = [
        ...state.sublist(0, existing),
        item.copyWith(quantity: newQty),
        ...state.sublist(existing + 1),
      ];
    } else {
      final qty = quantity.clamp(1, product.stock);
      state = [
        ...state,
        CartItem(
          productId: product.id,
          title: product.title,
          thumbnail: product.thumbnail,
          price: product.price,
          discountPercentage: product.discountPercentage,
          quantity: qty,
          stock: product.stock,
        ),
      ];
    }
    _persist();
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }
    state = state.map((item) {
      if (item.productId == productId) {
        return item.copyWith(quantity: quantity.clamp(1, item.stock));
      }
      return item;
    }).toList();
    _persist();
  }

  void removeItem(int productId) {
    state = state.where((i) => i.productId != productId).toList();
    _persist();
  }

  void clear() {
    state = [];
    _local.clearCart();
  }

  int get totalItemCount =>
      state.fold(0, (sum, item) => sum + item.quantity);
}

final cartNotifierProvider =
    StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier(
    ref.watch(cartLocalDataSourceProvider),
    ref.watch(cartRemoteDataSourceProvider),
  );
});

final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartNotifierProvider.notifier).totalItemCount;
});

// ─── Checkout notifier ────────────────────────────────────────────────────

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  CheckoutNotifier(this._remote, this._cartNotifier) : super(const CheckoutIdle());

  final CartRemoteDataSource _remote;
  final CartNotifier _cartNotifier;

  Future<void> checkout(List<CartItem> items) async {
    if (items.isEmpty) return;
    state = const CheckoutLoading();
    try {
      final products = items
          .map((e) => {'id': e.productId, 'quantity': e.quantity})
          .toList();
      final response = await _remote.checkout(products: products);
      final orderId = (response['id'] as int?) ?? 0;
      _cartNotifier.clear();
      state = CheckoutSuccess(orderId);
    } catch (e) {
      final err = ErrorHandler.handle(e);
      state = CheckoutFailure(err.displayMessage);
    }
  }

  void reset() => state = const CheckoutIdle();
}

final checkoutNotifierProvider =
    StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) {
  return CheckoutNotifier(
    ref.watch(cartRemoteDataSourceProvider),
    ref.watch(cartNotifierProvider.notifier),
  );
});
