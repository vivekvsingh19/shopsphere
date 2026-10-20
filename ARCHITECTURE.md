# ShopSphere — Architecture Document

## State Management: Flutter Riverpod

**Choice**: `flutter_riverpod` with code generation (`riverpod_annotation` + `riverpod_generator`).

**Rationale**:
- Riverpod 2.x is compile-safe, avoids `BuildContext` dependency in providers, and supports async providers (`AsyncNotifier`, `FutureProvider`) natively — ideal for API-heavy apps.
- Scoped overrides make testing trivial without global singletons.
- `AsyncValue` models loading/data/error states cleanly, eliminating manual state management boilerplate.
- Preferred over BLoC (less boilerplate for this scale) and Provider (deprecated-leaning, context-dependent).

---

## Folder Structure

```
lib/
├── app.dart                        # Root MaterialApp + GoRouter setup
├── main.dart                       # Entry point, ProviderScope
│
├── core/
│   ├── di/
│   │   └── providers.dart          # Root DI providers (Dio, StorageService, etc.)
│   ├── network/
│   │   ├── api_client.dart         # Configured Dio instance + interceptors
│   │   ├── auth_interceptor.dart   # Bearer token injection + 401 handling
│   │   └── logging_interceptor.dart# Debug-only logging (kDebugMode)
│   ├── error/
│   │   ├── app_error.dart          # Sealed class hierarchy for typed errors
│   │   └── error_handler.dart      # DioException → AppError converter
│   ├── storage/
│   │   └── secure_storage.dart     # flutter_secure_storage wrapper
│   ├── theme/
│   │   ├── app_theme.dart          # Material 3 ThemeData (light + dark)
│   │   ├── app_colors.dart         # Colour tokens
│   │   └── app_text_styles.dart    # Typography scale
│   ├── router/
│   │   └── app_router.dart         # GoRouter routes + auth guard
│   └── widgets/
│       ├── error_widget.dart       # Reusable error + retry widget
│       ├── loading_skeleton.dart   # Shimmer skeleton cards
│       └── empty_state_widget.dart # Empty-state illustration + copy
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── login_request.dart
│   │   │   │   ├── auth_response.dart
│   │   │   │   └── user_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── auth_remote_datasource.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart    # Abstract interface
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart
│   │   │       └── get_current_user_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── auth_provider.dart
│   │       └── screens/
│   │           ├── splash_screen.dart
│   │           └── login_screen.dart
│   │
│   ├── products/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── product_model.dart
│   │   │   │   ├── product_list_response.dart
│   │   │   │   ├── review_model.dart
│   │   │   │   └── category_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── products_remote_datasource.dart
│   │   │   └── repositories/
│   │   │       └── products_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── product.dart
│   │   │   │   └── review.dart
│   │   │   ├── repositories/
│   │   │   │   └── products_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_products_usecase.dart
│   │   │       ├── get_product_details_usecase.dart
│   │   │       ├── get_categories_usecase.dart
│   │   │       └── search_products_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── products_provider.dart
│   │       │   └── product_detail_provider.dart
│   │       ├── screens/
│   │       │   ├── catalogue_screen.dart
│   │       │   └── product_detail_screen.dart
│   │       └── widgets/
│   │           ├── product_card.dart
│   │           ├── product_grid.dart
│   │           ├── category_filter_bar.dart
│   │           ├── sort_bottom_sheet.dart
│   │           └── image_carousel.dart
│   │
│   ├── cart/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── cart_item_model.dart
│   │   │   ├── datasources/
│   │   │   │   ├── cart_local_datasource.dart  # shared_preferences
│   │   │   │   └── cart_remote_datasource.dart # POST /carts/add
│   │   │   └── repositories/
│   │   │       └── cart_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── cart_item.dart
│   │   │   ├── repositories/
│   │   │   │   └── cart_repository.dart
│   │   │   └── usecases/
│   │   │       ├── checkout_usecase.dart
│   │   │       └── cart_totals_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── cart_provider.dart
│   │       └── screens/
│   │           ├── cart_screen.dart
│   │           └── order_confirmation_screen.dart
│   │
│   └── profile/
│       ├── data/
│       │   └── repositories/
│       │       └── profile_repository_impl.dart
│       ├── domain/
│       │   └── repositories/
│       │       └── profile_repository.dart
│       └── presentation/
│           ├── providers/
│           │   └── profile_provider.dart
│           └── screens/
│               └── profile_screen.dart
│
test/
├── fixtures/
│   ├── product.json
│   ├── product_list.json
│   ├── auth_response.json
│   └── user.json
└── features/
    ├── auth/
    │   ├── data/
    │   │   └── auth_repository_test.dart
    │   └── domain/
    │       └── login_usecase_test.dart
    ├── products/
    │   ├── data/
    │   │   ├── product_model_test.dart
    │   │   └── products_repository_test.dart
    │   └── domain/
    │       └── get_products_usecase_test.dart
    └── cart/
        ├── cart_totals_test.dart
        └── cart_provider_test.dart
```

---

## Layer Contracts

### Data Flow
```
UI Widget → Riverpod Provider → Use Case → Repository Interface
                                                    ↓
                                          Repository Impl → Remote/Local DataSource
                                                                      ↓
                                                              Dio (HTTP) / SharedPreferences
```

### Error Propagation
```
DioException → ErrorHandler → AppError (sealed)
                                  ├── NetworkError
                                  ├── ServerError(statusCode, message)
                                  ├── AuthError (401/403)
                                  ├── NotFoundError
                                  └── UnknownError
```

### AppError sealed class hierarchy
```dart
sealed class AppError {
  const AppError();
}
class NetworkError extends AppError { ... }
class ServerError extends AppError { final int statusCode; final String message; ... }
class AuthError extends AppError { ... }
class NotFoundError extends AppError { ... }
class UnknownError extends AppError { final String message; ... }
```

---

## Key Packages

| Package | Version | Purpose |
|---------|---------|---------|
| flutter_riverpod | ^2.6.1 | State management |
| riverpod_annotation | ^2.6.1 | Code generation |
| riverpod_generator | ^2.6.1 | Dev: provider codegen |
| build_runner | ^2.4.13 | Dev: code generation runner |
| dio | ^5.8.0+1 | HTTP client |
| flutter_secure_storage | ^9.2.2 | Secure token storage |
| shared_preferences | ^2.3.3 | Cart persistence |
| go_router | ^14.8.1 | Declarative routing + auth guard |
| cached_network_image | ^3.4.1 | Image caching + placeholder |
| shimmer | ^3.0.0 | Skeleton loading effect |
| google_fonts | ^6.2.1 | Typography (Inter) |
| mocktail | ^1.0.4 | Test mocking |
| freezed | ^2.5.7 | Immutable models (optional codegen) |
| json_annotation | ^4.9.0 | JSON serialisation |
| json_serializable | ^6.8.0 | Dev: JSON codegen |

---

## Responsive Breakpoints (Material 3)

| Screen class | Width | Layout |
|---|---|---|
| Compact | < 600 dp | BottomNavigationBar, 2-col grid |
| Medium | 600–840 dp | NavigationRail, 3-col grid |
| Expanded | > 840 dp | NavigationDrawer, master-detail, 4-col grid |
