# FreshTrack — Smart Pantry & Grocery Expiry Tracker

FreshTrack is an AI-powered smart kitchen management system that eliminates food waste by tracking pantry inventory, predicting expiration dates, inferring meal consumption, looking up barcode products, generating personalized recipes from expiring ingredients, and scheduling push notification alerts.

---

## 🌟 Key Features

1. **Closed-Loop Meal Logging & Pantry Deduction**
   - Take a photo of your meal or enter a natural language description (e.g. *"I cooked chicken curry with rice and tomatoes"*).
   - Multimodal Gemini AI infers ingredient candidates and matches them against active pantry items.
   - Explicit confirmation UI lets you inspect candidate items and tweak quantities before atomic, row-locked pantry deduction.
   - Auto-deduction when marking recipes as cooked.

2. **Barcode Product Lookup**
   - Live barcode scanning using `mobile_scanner`.
   - Server-side integration with **Open Food Facts API v2** plus local user pantry history fallback.
   - Pre-fills item forms with product name, brand, category, unit, calories, and allergens.

3. **Smart Expiry Tracking & Shelf Life Prediction**
   - Temperature, humidity, storage zone, and ripeness aware prediction engine.
   - Color-coded freshness statuses (`fresh`, `expiring`, `expired`).
   - Daily Celery beat push notification alerts at 3 days and 1 day prior to expiration.

4. **AI Recipe Generator**
   - Chef-level recipe generation prioritizing near-expiry pantry items.
   - Takes diet preferences, household size, and allergen warnings into account.

5. **Grocery List Replenishment**
   - Smart replenishment list generation based on consumption history and low stock levels.
   - One-tap "Mark Purchased" moves items directly into kitchen inventory.

---

## 🏗️ Architecture & Monorepo Structure

```
grocery_track/
├── lib/                          # Flutter Mobile Application (Material 3 + Provider)
│   ├── config/                   # Design tokens, routing, theme
│   ├── core/                     # API client, services (scanner, notifications, storage)
│   ├── data/                     # REST Repositories & Data Models
│   └── features/                 # Feature-first modules
│       ├── auth/                 # Sign-in, sign-up, verification
│       ├── dashboard/            # Health analytics, expiry alert banner, AI search
│       ├── groceries/            # Pantry inventory, zone breakdown
│       ├── meals/                # Meal photo logging & confirmation UI
│       ├── recipes/              # Chef recipe generation & cook workflow
│       ├── grocery_list/         # Replenishment list
│       └── scan/                 # Receipt/Produce image scan & Barcode scanner
│
├── backend/                      # Django REST Framework API
│   ├── apps/
│   │   ├── accounts/             # Custom User model, SimpleJWT Auth
│   │   ├── groceries/            # Pantry items, deduction service, Open Food Facts lookup
│   │   ├── meals/                # MealLog, MealIngredientCandidate, AI inference
│   │   ├── recipes/              # AI recipe generation & cook deduction
│   │   ├── grocery_lists/        # Replenishment lists & pantry integration
│   │   ├── notifications/        # FCM token registration & Celery beat expiry alerts
│   │   └── scans/                # Multimodal receipt/produce scan sessions
│   ├── integrations/
│   │   ├── ai/                   # Gemini Client & structured JSON schemas
│   │   └── ocr/                  # Vision OCR & date extraction parser
│   ├── common/                   # Global exception handler & response envelope renderer
│   └── config/                   # Settings (base, development, production)
│
├── docker-compose.yml            # Production docker stack (Django + Postgres + Redis + Celery)
└── .github/workflows/ci.yml      # CI pipeline for automated testing
```

---

## 🚀 Quick Start (Local Development)

### 1. Prerequisites
- Python 3.11+
- Flutter 3.19+
- Docker & Docker Compose (optional for full stack)

### 2. Backend Setup
```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements/development.txt

# Run migrations
python manage.py migrate --settings=config.settings.development

# Start development server
python manage.py runserver --settings=config.settings.development
```

### 3. Flutter App Setup
```bash
flutter pub get
flutter run
```

---

## 🐳 Docker Deployment

To launch the full production environment (PostgreSQL + Redis + Django Web API + Celery Worker + Celery Beat):

```bash
docker-compose up --build -d
```

---

## 🧪 Running Tests

### Backend Tests
```bash
cd backend
python manage.py test --settings=config.settings.development
```

### Flutter Tests
```bash
flutter test
```

---

## 🔒 Security & Deployment Checklist
- `CORS_ALLOW_ALL_ORIGINS = False` in `config/settings/base.py`.
- Django System Check `check_secret_key_not_insecure` enforces strong `SECRET_KEY` when `DEBUG=False`.
- All inventory updates use atomic transactions with `select_for_update()` row-level locks.
- IDOR protection enforced on all ViewSets via `request.user` queryset scoping.
- Standard response envelope: `{"success": true, "data": {...}, "message": "..."}`.
