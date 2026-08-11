# FreshTrack Codebase Audit Report

Date: 2026-08-11

## Summary
The FreshTrack codebase is approximately 70% complete. The scanning-to-inventory pipeline, CRUD operations, recipe generation, and UI shell are functional. The remaining gaps center around the closed-loop meal consumption tracking, barcode integration, real push notifications, real social auth, and production hardening.

## P0 — Critical (Must Fix Before Ship)

### A. Missing Feature: Meal Logging & Automatic Pantry Deduction
- **Location**: Entirely missing — no `backend/apps/meals/` app, no `MealLog` model, no Flutter `lib/features/meals/`
- **Impact**: The project synopsis explicitly names this as the key differentiator. Without it, there is no closed-loop pantry system.
- **Details**: 
  - `RecipeViewSet.mark_cooked` (`backend/apps/recipes/views.py:107-120`) only increments `user.recipes_cooked` — it never deducts `recipe.ingredients_used` from `GroceryItem` rows despite the data being available.
  - `GroceryActivity.ActivityTypes.CONSUMED` exists as a model choice and the `consume` action on `GroceryItemViewSet` already does correct atomic, row-locked deduction — this pattern should be reused.
  - No endpoint accepts meal photos/descriptions for AI ingredient inference.
  - No Flutter UI for meal logging exists.

### B. Missing Feature: Barcode Product Lookup
- **Location**: `GroceryItem.barcode` field exists, `mobile_scanner` is a pubspec dependency, but no backend endpoint queries Open Food Facts or any product database.
- **Impact**: Scanning a barcode has nowhere to resolve into product info.
- **Details**:
  - `mobile_scanner` is never imported or used anywhere in `lib/` — the scan feature uses only `image_picker` for photo-based scanning.
  - No server-side barcode lookup endpoint exists.

### C. Push Notifications Are Stubbed
- **Location**: `backend/apps/notifications/tasks.py:60-72`
- **Impact**: The 3-day/1-day expiry alert scheduling logic is correct (Celery beat, dedupe flags), but `_send_push_notification` only logs — it never calls Firebase Admin SDK / FCM.
- **Details**:
  - `firebase-admin` is listed in `requirements/base.txt` but never imported in `notifications/tasks.py`.
  - `DeviceToken` model exists and Flutter's `notification_service.dart` correctly registers tokens.

### D. Auth Uses Mock Tokens
- **Location**: `lib/features/auth/views/login_view.dart:70-72` (Google), `lib/features/auth/views/login_view.dart:101` (Apple)
- **Impact**: Google Sign-In falls back to `'mock_google_token'`; Apple Sign-In always sends `'mock_apple_identity_token'`.
- **Details**:
  - `GoogleLoginView` and `AppleLoginView` in `backend/apps/accounts/views.py` accept any token without verification — they just do `get_or_create` on the email, making the auth flow completely insecure for production.
  - `google_sign_in` and `firebase_auth` are pubspec dependencies but the real Firebase ID token flow is not wired.

### E. Insecure Configuration Defaults
- **Location**: `backend/config/settings/base.py:13-15`
- **Impact**: `SECRET_KEY` has insecure default `'django-insecure-freshtrack-secret'`, `CORS_ALLOW_ALL_ORIGINS = True` is the base default, `ALLOWED_HOSTS = ['*']` is the base default.
- **Details**:
  - `production.py` correctly overrides CORS and ALLOWED_HOSTS, but base.py silently allows-all if env vars are missing.
  - No startup check prevents booting with insecure defaults in production mode.

## P1 — Important (Fix Before Production)

### F. Scan Source Image Attribution Bug
- **Location**: `backend/apps/scans/tasks.py:60` — `source_image = images.first()  # Fallback`
- **Impact**: Every `ScanCandidate` in a multi-image batch gets attributed to the first image, not the image it was actually detected from.
- **Details**: The AI pipeline in `model_router.py` does not return source image indices; the task assigns `images.first()` globally.

### G. `mark_cooked` Does Not Deduct Ingredients
- **Location**: `backend/apps/recipes/views.py:107-120`
- **Impact**: Marking a recipe as cooked only increments a counter — ingredients are never deducted from pantry despite `ingredients_used` containing `pantry_item_id` + quantity.

### H. Mock Progress Estimate in Kitchen UI
- **Location**: `lib/features/kitchen/widgets/item_detail_panel.dart:255`
- **Impact**: Freshness progress bar uses `(14 - daysLeft.clamp(0, 14)) / 14` — a hardcoded mock estimate rather than real freshness calculation.

### I. Waste Estimate Uses Hardcoded Price
- **Location**: `backend/apps/groceries/views.py:291` — `estimated_waste_value = total_expiring * 65  # Mock Rs.65 per expiring item`
- **Impact**: Waste risk metric on dashboard is inaccurate.

### J. Email Verification Is Stubbed
- **Location**: `backend/apps/accounts/views.py:106-117` (`VerifyEmailView`), `backend/apps/accounts/views.py:119-128` (`ResendVerificationView`)
- **Impact**: `VerifyEmailView` immediately marks `email_verified = True` without any token verification. `ResendVerificationView` returns success without actually sending anything.

### K. Password Reset Is Stubbed
- **Location**: `backend/apps/accounts/views.py:90-104` (`ForgotPasswordView`)
- **Impact**: Returns success message without actually sending a reset email.

### L. Notification Preferences Endpoint Missing
- **Location**: Flutter `api_endpoints.dart:64` defines `notificationPreferences = '/notifications/preferences/'` but no matching backend URL/view exists in `backend/apps/notifications/urls.py`.
- **Impact**: Frontend↔backend contract mismatch.

### M. Daemon Thread for Eager Celery
- **Location**: `backend/apps/scans/views.py:75-80`
- **Impact**: Uses `threading.Thread(daemon=True)` for eager mode, which may cause tests to exit before background processing finishes.

## P2 — Low Priority (Polish / Nice to Have)

### N. Test Coverage Is Thin
- Existing: `accounts/tests.py` (~50 lines), `groceries/tests.py` (~76 lines), `scans/tests.py` (~50 lines)
- Missing: `recipes/tests.py`, `grocery_lists/tests.py`, `notifications/tests.py`
- Flutter: Only default `test/widget_test.dart` template

### O. No Deployment Artifacts
- No Dockerfile, docker-compose.yml, or CI/CD pipelines
- `requirements/production.txt` includes `psycopg2-binary` (duplicated from `base.txt`)

### P. README Is Default Template
- `README.md` is the default Flutter template, contains no project documentation

### Q. `GroceryItem.Units` Missing Values
- Model `Units` enum is missing 'bunch' and 'packet' which are valid units in the scan pipeline (`scans/tasks.py:72`)
- Scan task normalizes to these units but GroceryItem won't validate them via choices

### R. `auth_provider.dart` Mock Comment
- `lib/features/auth/providers/auth_provider.dart:144` contains `// mocks resend on this mock framework`

## API Contract Verification

All Flutter Dio endpoints in `api_endpoints.dart` were verified against backend URL patterns:

| Flutter Endpoint | Backend URL | Status |
|---|---|---|
| `/auth/register/` | `accounts/urls.py` RegisterView | OK |
| `/auth/login/` | `accounts/urls.py` TokenObtainPairView | OK |
| `/auth/token/refresh/` | `accounts/urls.py` TokenRefreshView | OK |
| `/auth/me/` | `accounts/urls.py` MeView | OK |
| `/auth/google/` | `accounts/urls.py` GoogleLoginView | OK |
| `/auth/apple/` | `accounts/urls.py` AppleLoginView | OK |
| `/groceries/` | `groceries/urls.py` GroceryItemViewSet | OK |
| `/groceries/{id}/consume/` | GroceryItemViewSet.consume | OK |
| `/groceries/{id}/waste/` | GroceryItemViewSet.waste | OK |
| `/groceries/{id}/adjust-quantity/` | GroceryItemViewSet.adjust_quantity | OK |
| `/groceries/use-first/` | GroceryItemViewSet.use_first | OK |
| `/groceries/stats/` | GroceryItemViewSet.stats | OK |
| `/groceries/zones/` | GroceryItemViewSet.zones | OK |
| `/groceries/predict-shelf-life/` | GroceryItemViewSet.predict_shelf_life | OK |
| `/groceries/ai-insights/` | GroceryItemViewSet.ai_insights | OK |
| `/scans/sessions/` | scans/urls.py ScanSessionViewSet | OK |
| `/scans/sessions/{id}/candidates/` | ScanSessionViewSet.candidates | OK |
| `/scans/sessions/{id}/confirm/` | ScanSessionViewSet.confirm | OK |
| `/recipes/` | recipes/urls.py RecipeViewSet | OK |
| `/recipes/generate/` | RecipeViewSet.generate | OK |
| `/recipes/{id}/mark-cooked/` | RecipeViewSet.mark_cooked | OK |
| `/grocery-lists/current/` | grocery_lists GroceryListViewSet.current | OK |
| `/grocery-lists/generate/` | GroceryListViewSet.generate | OK |
| `/grocery-lists/{id}/items/` | GroceryListViewSet.add_item | OK |
| `/notifications/device-token/` | notifications DeviceTokenView | OK |
| `/notifications/preferences/` | **MISSING** — no backend view/URL | MISMATCH |

## Response Envelope Consistency
All custom ViewSet actions manually construct the `{"success", "data", "message"/"error"}` envelope. Standard DRF list/retrieve/create/update actions are auto-wrapped by `common/renderers.py` `WrappedJSONRenderer`. Error responses go through `common/exception_handler.py`. The envelope is globally consistent.
