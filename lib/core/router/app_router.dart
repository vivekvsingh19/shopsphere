import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/cart/presentation/screens/order_confirmation_screen.dart';
import '../../features/products/presentation/screens/catalogue_screen.dart';
import '../../features/products/presentation/screens/product_detail_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

// Route paths
const kSplashPath = '/';
const kLoginPath = '/login';
const kCataloguePath = '/catalogue';
const kProductDetailPath = '/product/:id';
const kCartPath = '/cart';
const kOrderConfirmationPath = '/order-confirmation';
const kProfilePath = '/profile';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: kSplashPath,
    refreshListenable: _AuthStateListenable(ref),
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final location = state.matchedLocation;

      // Still on splash — let SplashScreen handle things
      if (location == kSplashPath) return null;

      final isLoggedIn = authState is AuthAuthenticated;
      final isLoginPage = location == kLoginPath;

      if (!isLoggedIn && !isLoginPage) return kLoginPath;
      if (isLoggedIn && isLoginPage) return kCataloguePath;

      return null;
    },
    routes: [
      GoRoute(
        path: kSplashPath,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: kLoginPath,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: kCataloguePath,
        builder: (_, __) => const CatalogueScreen(),
      ),
      GoRoute(
        path: kProductDetailPath,
        builder: (_, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return ProductDetailScreen(productId: id);
        },
      ),
      GoRoute(
        path: kCartPath,
        builder: (_, __) => const CartScreen(),
      ),
      GoRoute(
        path: kOrderConfirmationPath,
        builder: (_, __) => const OrderConfirmationScreen(),
      ),
      GoRoute(
        path: kProfilePath,
        builder: (_, __) => const ProfileScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});

/// Bridges Riverpod state changes to GoRouter's refreshListenable.
class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(this._ref) {
    _ref.listen(authNotifierProvider, (_, __) => notifyListeners());
  }
  final Ref _ref;
}
