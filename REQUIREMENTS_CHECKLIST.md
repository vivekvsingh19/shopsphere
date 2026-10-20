# ShopSphere — Requirements Checklist

> Last updated: 2026-10-20 | Audited against the Prosessed Flutter Intern assignment PDF.

## Legend
- ✅ COMPLETE — implemented and verified
- 🔶 PARTIAL — started but incomplete
- ❌ NOT STARTED

---

## A. Project Foundation

| # | Requirement | Status | Notes |
|---|-------------|--------|-------|
| A1 | Flutter project initialised | ✅ | Blank scaffold exists |
| A2 | Git repository initialised | ❌ | No `.git` directory found |
| A3 | Meaningful Git history (20+ commits) | ❌ | No commits yet |
| A4 | Feature-first folder structure | ❌ | Only `lib/main.dart` exists |
| A5 | Material 3 design system | ❌ | Default MaterialApp, no theme |
| A6 | Dependency injection configured | ❌ | No DI setup |
| A7 | Riverpod / BLoC / Provider chosen | ❌ | No state management |
| A8 | Shared HTTP client configured | ❌ | No http package |
| A9 | Typed error hierarchy | ❌ | Not started |
| A10 | Analysis options strict | 🔶 | flutter_lints present, rules minimal |

---

## B. Authentication

| # | Requirement | Status | Notes |
|---|-------------|--------|-------|
| B1 | Splash screen with session restoration | ❌ | |
| B2 | Login form with validation | ❌ | |
| B3 | Password visibility toggle | ❌ | |
| B4 | Login loading state | ❌ | |
| B5 | Invalid-credentials error message | ❌ | |
| B6 | Secure token storage (flutter_secure_storage) | ❌ | |
| B7 | Bearer-token injection on protected requests | ❌ | |
| B8 | POST /auth/login integration | ❌ | |
| B9 | GET /auth/me integration | ❌ | |
| B10 | Logout — clear session + navigate | ❌ | |
| B11 | Expired-session handling / 401 redirect | ❌ | |
| B12 | BONUS: POST /auth/refresh token rotation | ❌ | |

---

## C. Product Catalogue

| # | Requirement | Status | Notes |
|---|-------------|--------|-------|
| C1 | GET /products pagination (limit=20) | ❌ | |
| C2 | Infinite scroll | ❌ | |
| C3 | Pull-to-refresh | ❌ | |
| C4 | Responsive grid (2 cols phone, 3-4 tablet) | ❌ | |
| C5 | Navigation rail on medium screens | ❌ | |
| C6 | Master-detail on expanded screens | ❌ | |
| C7 | GET /products/categories + category filtering | ❌ | |
| C8 | GET /products/category/{slug} | ❌ | |
| C9 | Debounced search ~400ms (GET /products/search) | ❌ | |
| C10 | Sort by price asc/desc, rating, title | ❌ | |
| C11 | Skeleton loading cards | ❌ | |
| C12 | Empty state widget | ❌ | |
| C13 | Cached product images + placeholder + fallback | ❌ | |

---

## D. Product Details

| # | Requirement | Status | Notes |
|---|-------------|--------|-------|
| D1 | GET /products/{id} | ❌ | |
| D2 | Image carousel with page indicator | ❌ | |
| D3 | Title, brand, price, discount %, rating | ❌ | |
| D4 | Description and stock status | ❌ | |
| D5 | Customer reviews list | ❌ | |
| D6 | Quantity selector (prevent ≤ 0) | ❌ | |
| D7 | Add-to-cart action | ❌ | |
| D8 | Disable purchasing when out of stock | ❌ | |
| D9 | Graceful handling of nonexistent product IDs | ❌ | |

---

## E. Cart & Checkout

| # | Requirement | Status | Notes |
|---|-------------|--------|-------|
| E1 | Add item to cart | ❌ | |
| E2 | Remove item from cart | ❌ | |
| E3 | Update quantity (prevent 0 / negative) | ❌ | |
| E4 | Subtotal, discount, grand total calculation | ❌ | |
| E5 | Persist cart locally (shared_preferences / Hive) | ❌ | |
| E6 | Cart badge count updates immediately | ❌ | |
| E7 | POST /carts/add checkout integration | ❌ | |
| E8 | Order confirmation screen | ❌ | |
| E9 | Clear cart only after successful checkout | ❌ | |

---

## F. Profile

| # | Requirement | Status | Notes |
|---|-------------|--------|-------|
| F1 | Profile screen — avatar, name, email, phone | ❌ | |
| F2 | GET /auth/me data display | ❌ | |
| F3 | Logout clears all session data | ❌ | |
| F4 | Expired session re-routes to login | ❌ | |

---

## G. Error Handling & Network

| # | Requirement | Status | Notes |
|---|-------------|--------|-------|
| G1 | HTTP 400 / 401 / 403 / 404 / 500 typed failures | ❌ | |
| G2 | Network failure / timeout UI + retry | ❌ | |
| G3 | Friendly error screens | ❌ | |
| G4 | Debug-only request/response logging | ❌ | |
| G5 | Connect + receive timeout configured | ❌ | |

---

## H. UI/UX & Accessibility

| # | Requirement | Status | Notes |
|---|-------------|--------|-------|
| H1 | 48 dp minimum tap targets | ❌ | |
| H2 | Support large system font sizes | ❌ | |
| H3 | Responsive portrait + landscape | ❌ | |
| H4 | Smooth animations (no excessive complexity) | ❌ | |
| H5 | Consistent spacing / typography / elevation | ❌ | |

---

## I. Testing

| # | Requirement | Status | Notes |
|---|-------------|--------|-------|
| I1 | ≥15 meaningful unit tests | ❌ | |
| I2 | JSON model parsing tests | ❌ | |
| I3 | Repository success + failure tests | ❌ | |
| I4 | Login use-case tests | ❌ | |
| I5 | Product-fetching use-case tests | ❌ | |
| I6 | Search + pagination logic tests | ❌ | |
| I7 | Cart calculation tests | ❌ | |
| I8 | State transition tests | ❌ | |
| I9 | `flutter test` passes with 0 failures | ❌ | |

---

## J. Documentation & Submission

| # | Requirement | Status | Notes |
|---|-------------|--------|-------|
| J1 | Complete README.md | ❌ | Placeholder only |
| J2 | Screenshots (4 phone + 2 tablet) | ❌ | |
| J3 | Architecture diagram in README | ❌ | |
| J4 | State-management rationale | ❌ | |
| J5 | Test credentials in README | ❌ | |
| J6 | Demo video (2–4 min) | ❌ | |
| J7 | `dart format` clean | ❌ | |
| J8 | `flutter analyze` 0 issues | ❌ | |
| J9 | Release APK built | ❌ | |
| J10 | APK smoke-tested | ❌ | |
| J11 | Git tag `v1.0.0` | ❌ | |

---

## Summary

| Category | Complete | Partial | Not Started |
|----------|----------|---------|-------------|
| Foundation | 1 | 1 | 8 |
| Auth | 0 | 0 | 12 |
| Products | 0 | 0 | 13 |
| Details | 0 | 0 | 9 |
| Cart | 0 | 0 | 9 |
| Profile | 0 | 0 | 4 |
| Errors | 0 | 0 | 5 |
| UI/UX | 0 | 0 | 5 |
| Testing | 0 | 0 | 9 |
| Docs | 0 | 0 | 11 |
| **Total** | **1** | **1** | **85** |
