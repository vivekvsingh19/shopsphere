import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/cart_item.dart';

/// Persists cart items to SharedPreferences as JSON.
class CartLocalDataSource {
  CartLocalDataSource(this._prefs);
  final SharedPreferences _prefs;

  static const _cartKey = 'cart_items';

  List<CartItem> loadCart() {
    final raw = _prefs.getString(_cartKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map(CartItem.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCart(List<CartItem> items) async {
    final raw = jsonEncode(items.map((e) => e.toJson()).toList());
    await _prefs.setString(_cartKey, raw);
  }

  Future<void> clearCart() async {
    await _prefs.remove(_cartKey);
  }
}
