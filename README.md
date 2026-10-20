# ShopSphere 🛍️

> A polished, production-quality Flutter e-commerce application built for the **Prosessed Flutter Developer Intern** take-home assignment.

---

## Project Overview

ShopSphere is a full-featured mobile shopping app that lets users browse products, search and filter by category, view detailed product pages with image carousels and reviews, manage a persistent cart, checkout, and view their profile — all backed by the [DummyJSON](https://dummyjson.com) public API.

---

## Implemented Features

| Area | Feature | Status |
|---|---|---|
| **Auth** | Splash screen with session restoration | ✅ |
| | Login with validation + password toggle | ✅ |
| | Loading state + invalid-credentials error | ✅ |
| | Secure token storage (flutter_secure_storage) | ✅ |
| | Bearer-token injection on all protected requests | ✅ |
| | Logout + expired-session handling | ✅ |
| | Session restore across app restarts | ✅ |
| **Products** | Paginated product grid (limit 20) + infinite scroll | ✅ |
| | Pull-to-refresh | ✅ |
| | Responsive grid (2 col phone / 3 col medium / 4 col expanded) | ✅ |
| | Bottom nav bar (compact) / Navigation rail (medium) / Drawer (expanded) | ✅ |
| | Category filter (horizontal chip bar) | ✅ |
| | Debounced search ~400 ms | ✅ |
| | Sort by price asc/desc, rating, title | ✅ |
| | Skeleton loading cards + empty state | ✅ |
| | Cached images with placeholder + error fallback | ✅ |
| **Product Detail** | Image carousel with animated page indicator | ✅ |
| | Title, brand, price, discount %, rating stars | ✅ |
| | Stock status + availability status | ✅ |
| | Shipping, warranty, return policy info | ✅ |
| | Customer reviews list | ✅ |
| | Quantity selector (clamp 1 → stock) | ✅ |
| | Add-to-cart (disabled when out of stock) | ✅ |
| | 404 not-found graceful error screen | ✅ |
| **Cart** | Add / remove / update quantity | ✅ |
| | Prevent zero or negative quantity | ✅ |
| | Subtotal, discount, grand total calculation | ✅ |
| | Cart persisted locally (SharedPreferences) | ✅ |
| | Cart badge on navigation | ✅ |
| | POST /carts/add checkout | ✅ |
| | Order confirmation screen | ✅ |
| | Cart cleared only after successful checkout | ✅ |
| **Profile** | GET /auth/me — avatar, name, email, phone, gender | ✅ |
| | Logout with confirmation dialog | ✅ |
| **Errors** | Network, timeout, 401, 403, 404, 500 typed failures | ✅ |
| | Friendly error screen + retry button | ✅ |
| | Debug-only logging (no tokens/passwords) | ✅ |
| **Testing** | 38 meaningful unit tests | ✅ |

### Not Implemented / Known Gaps
- `POST /auth/refresh` token rotation (bonus — not implemented)
- Dark mode toggle (follows system setting automatically)
- Tablet screenshots (emulator required)

---

## Setup & Run

### Prerequisites
- Flutter 3.41.9 (stable)
- Dart 3.11.5
- Android SDK / emulator (minSdkVersion 23)

### Run

```bash
git clone https://github.com/vivekvsingh19/shopsphere.git
cd shopsphere
flutter pub get
flutter run
```

### Test credentials

| Field | Value |
|---|---|
| Username | `emilys` |
| Password | `emilyspass` |

---

## Architecture

**Pattern**: Feature-first Clean Architecture with three layers per feature (data / domain / presentation).

**State Management**: **Flutter Riverpod 2.x** — chosen over BLoC and Provider because:
- Compile-safe providers without BuildContext dependency
- `AsyncValue` natively models loading/data/error — no manual union types
- Scoped provider overrides make testing trivial
- `StateNotifier` + `AsyncNotifier` cleanly separate business logic from UI

### Folder Structure

```
lib/
├── app.dart                        # Root MaterialApp.router
├── main.dart                       # ProviderScope + SharedPreferences init
├── core/
│   ├── di/providers.dart           # Root Riverpod DI providers
│   ├── network/
│   │   ├── api_client.dart         # Dio factory (timeouts, base URL)
│   │   └── interceptors.dart       # AuthInterceptor + LoggingInterceptor
│   ├── error/
│   │   ├── app_error.dart          # Sealed error hierarchy
│   │   └── error_handler.dart      # DioException → AppError
│   ├── storage/secure_storage.dart # flutter_secure_storage wrapper
│   ├── theme/
│   │   ├── app_theme.dart          # Material 3 ThemeData (light + dark)
│   │   └── app_colors.dart         # Color tokens
│   ├── router/app_router.dart      # GoRouter with auth guard
│   └── widgets/                    # Error, empty state, skeleton widgets
│
└── features/
    ├── auth/                       # Login, splash, session management
    ├── products/                   # Catalogue, detail, search, filter
    ├── cart/                       # Cart CRUD, checkout, order confirmation
    └── profile/                    # User profile, logout
```

### Data Flow

```
UI Widget → Riverpod Provider → Use Case → Repository Interface
                                                   ↓
                                         Repository Impl → Remote/Local DataSource
                                                                   ↓
                                                           Dio / SharedPreferences
```

### Error Flow

```
DioException → ErrorHandler.handle() → AppError (sealed)
  ├── NetworkError       (SocketException, connection error)
  ├── TimeoutError       (connect/receive/send/transform timeout)
  ├── AuthError          (401, 403)
  ├── NotFoundError      (404)
  ├── ServerError        (5xx)
  └── UnknownError       (catch-all)
```

---

## Flutter & Package Versions

| Package | Version | Purpose |
|---|---|---|
| flutter | 3.41.9 | Framework |
| dart | 3.11.5 | Language |
| flutter_riverpod | 2.6.1 | State management |
| go_router | 14.8.1 | Navigation + auth guard |
| dio | 5.8.0+1 | HTTP client |
| flutter_secure_storage | 9.2.4 | Token persistence |
| shared_preferences | 2.3.3 | Cart persistence |
| cached_network_image | 3.4.1 | Image caching |
| shimmer | 3.0.0 | Skeleton loading |
| google_fonts | 6.3.3 | Inter typography |
| json_annotation | 4.9.0 | JSON serialisation |
| mocktail | 1.0.4 | Test mocking |

---

## Error Handling Approach

Every repository method wraps remote calls in `try/catch`, and all exceptions are converted through `ErrorHandler.handle(e)` to a typed `AppError` sealed class. The UI pattern is:

```dart
if (state.error != null) {
  return AppErrorWidget(error: state.error!, onRetry: () => notifier.load());
}
```

`AppErrorWidget` displays a contextual icon + title + message + "Try again" button based on the error type.

**Debug logging**: `LoggingInterceptor` only runs in `kDebugMode` and never logs `Authorization` headers or `password` fields.

---

## Test Commands & Results

```bash
flutter test --reporter=compact
```

**Result: 38/38 tests passed** ✅

| Test File | Tests | Coverage |
|---|---|---|
| `product_model_test.dart` | T01–T10 | JSON parsing, nullable fields, inStock, finalPrice, hasMore |
| `auth_model_test.dart` | T11–T14 | AuthResponse parsing, nullable image, LoginRequest serialisation |
| `cart_totals_test.dart` | T15–T24 | CartItem round-trip, subtotal, discount, CartTotals calculations |
| `products_repository_test.dart` | T25–T32 | Repository success, NetworkError, ServerError, NotFoundError, search, categories |
| `auth_repository_test.dart` | T33–T38 | Login success, token saving, AuthError, NetworkError, session check |

---

## API Integration

Base URL: `https://dummyjson.com`

| Endpoint | Method | Used for |
|---|---|---|
| `/auth/login` | POST | Login |
| `/auth/me` | GET | Profile, session restore |
| `/products` | GET | Paginated catalogue |
| `/products/categories` | GET | Category filter chips |
| `/products/category/{slug}` | GET | Category-filtered catalogue |
| `/products/search` | GET | Debounced search |
| `/products/{id}` | GET | Product detail |
| `/carts/add` | POST | Checkout |

---

## Assumptions & Trade-offs

1. **No real backend persistence** — DummyJSON simulates success but doesn't persist data across requests.
2. **Cart stored locally** — SharedPreferences is used; Hive would be more robust for large carts.
3. **Token refresh not implemented** — The assignment marks this as a bonus. The interceptor clears tokens on 401 and redirects to login.
4. **Client-side sorting** — Sorting is applied to the loaded page in memory since DummyJSON doesn't support server-side sort parameters.
5. **Profile reuses AuthRepository** — `GET /auth/me` is called from the Profile screen; no separate profile domain layer is needed at this scale.

---

## AI Assistance

This project was built with AI coding assistance (Antigravity / Google DeepMind). All code has been reviewed, all import paths corrected, all tests verified as genuinely passing, and all architectural decisions are deliberate. The AI did not generate fake commits or fabricate test results.

---

## Author

**Vivek Singh** — Prosessed Flutter Developer Intern Assignment
