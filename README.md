# Vaani - Digital Kirana Storefront

A mini app built on top of Paytm POS that turns any kirana (local grocery) store into a digitally-managed business - with voice-powered billing, an AI-driven inventory engine, and a customer-facing storefront, all within the Paytm ecosystem.

---

## Overview

| Layer | What it is |
|-------|-----------|
| `pos_frontend/` | Flutter app that **mocks the Paytm Android POS terminal** and hosts the merchant-side mini app |
| `backend/` | FastAPI service powering voice cart parsing via Sarvam AI |
| `app_frontend/` | Customer-facing storefront mini app (served inside the Paytm mock) |

The `pos_frontend` simulates the Paytm POS interface. From within it, the merchant can open the Kirana Store screen, manage the digital catalog, take voice orders, process payments (UPI QR / card / cash), and view ICE-driven inventory insights.

---

## Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                    Paytm POS (pos_frontend)                  │
│                                                              │
│  ┌─────────────┐  ┌──────────────┐  ┌────────────────────┐  │
│  │  Dashboard  │  │ Kirana Store │  │   ICE Tab          │  │
│  │  Sales tab  │  │  + Cart      │  │  (Inventory Engine)│  │
│  │  ICE card   │  │  + Voice STT │  │                    │  │
│  └─────────────┘  └──────┬───────┘  └────────────────────┘  │
│                          │ POST /voice-cart                  │
└──────────────────────────┼───────────────────────────────────┘
                           │
                    ┌──────▼──────┐
                    │   Backend   │
                    │  (FastAPI)  │
                    │             │
                    │  Sarvam STT │  ← saaras:v4
                    │  Sarvam LLM │  ← sarvam-105b
                    └─────────────┘
```

---

## Features

### Kirana Store Screen
- Full digital product catalog with emoji tiles, prices, and units
- Cart management - add, remove, adjust quantities
- Cart sheet with itemised bill summary and total

### Voice Cart (Sarvam AI)
- Tap the mic icon to open a Siri-style listening sheet with live waveform animation
- Speak in **Hindi, Hinglish, Marathi, or English** - e.g. *"ek kilo pyaaz aur do packet bread"*
- Sarvam `saaras:v4` transcribes the audio; `sarvam-105b` extracts structured items
- Parsed cart preview shows catalog-matched items with emoji, price, and quantity before adding
- Falls back to "Could not parse your list" with a Try Again button if no catalog match is found

### Payment Flow
- Choose between **UPI QR**, Card, or Cash
- UPI QR screen shows a real scannable QR code encoding the UPI deep link (`upi://pay?pa=shreeram@paytm&…`)
- Payment processing screen with animated waiting state
- Receipt screen with itemised bill, store address, and total

### ICE - Inventory Confidence Engine
An AI-modelled inventory layer that infers stock levels and demand velocity purely from POS sales - no manual stock counting required.

- **Health Score** - percentage of items in healthy stock status
- **Velocity** - EWMA-smoothed daily demand per item
- **Trend** - relative acceleration vs. 2-week baseline
- **Stock Estimation** - inferred from last anchor + cumulative sales
- **Confidence Score** - composite of recency, frequency, and consistency
- **Status Classification** - Critical / Low / Healthy
- **Calculated Allocations** - 7-day forward reorder quantities with safety buffers
- **AI Insights** - anomaly cards (demand spikes, imminent stockouts, co-purchase patterns)
- **Suggested Reorder** - itemised reorder list with total cost and supplier dispatch button

See [ICE Formulation](./ice-formulation.md) for the complete formulae, pipeline, and tuning parameters.

---

## Project Structure

```
paytm-hack/
├── pos_frontend/           Flutter - Paytm POS mock + merchant mini app
│   ├── lib/
│   │   ├── screens/
│   │   │   ├── pos_home_screen.dart       Dashboard (Sales / Invoices / Products / ICE tabs)
│   │   │   ├── kirana_store_screen.dart   Product catalog + cart + voice STT
│   │   │   ├── charge_screen.dart         New sale entry
│   │   │   ├── payment_method_screen.dart Payment method selector
│   │   │   ├── payment_processing_screen.dart  QR / card / cash waiting screens
│   │   │   ├── receipt_screen.dart        Post-payment receipt
│   │   │   └── ice_screen.dart            ICE inventory dashboard
│   │   ├── widgets/
│   │   │   ├── cart_sheet.dart            Bottom sheet cart UI
│   │   │   └── voice_listening_sheet.dart  Siri-style voice recording + preview
│   │   ├── services/
│   │   │   └── voice_cart_service.dart    Audio recording + backend POST
│   │   └── config.dart                    Backend URL, brand colours
│   └── android/
│       └── app/build.gradle.kts           compileSdk = 37
│
├── backend/                FastAPI - voice cart parsing
│   ├── main.py
│   └── app/
│       ├── api/voice_cart.py              POST /voice-cart
│       ├── services/
│       │   ├── sarvam_client.py           Singleton Sarvam client
│       │   └── cart_parser.py             STT → LLM pipeline
│       ├── schemas/cart.py                CartItem, VoiceCartResponse
│       └── core/config.py                 Env / API key loader
│
├── app_frontend/           Customer-facing storefront (mini app)
├── ice-formulation.md      ICE engine formulae and pipeline
└── README.md
```

---

## Setup

### Backend

Requires Python 3.13+. Dependencies are managed with `uv`.

```bash
cd backend

# Install dependencies
uv sync

# Set environment variables
echo "SARVAM_API_KEY=your_key_here" > .env

# Run
uv run uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### POS Frontend (Flutter)

```bash
cd pos_frontend
flutter pub get
flutter run
```

**Android device - connect backend:**
```bash
adb reverse tcp:8000 tcp:8000
```

The app uses `http://localhost:8000` as the backend base URL (see `lib/config.dart`). The `adb reverse` tunnel makes the host machine's port 8000 available as `localhost` on the device.

**Android SDK note:** `permission_handler` requires `compileSdk 37`. If the `android-37` platform is missing run:
```bash
ln -s "$ANDROID_HOME/platforms/android-37.0" "$ANDROID_HOME/platforms/android-37"
```

---

## Voice Cart API

```
POST /voice-cart
Content-Type: multipart/form-data

audio: <WAV file>  (16 kHz, mono recommended)
```

**Response:**
```json
{
  "transcript": "एक किलो प्याज और दो पैकेट ब्रेड",
  "items": [
    { "name": "onions", "qty": 1,   "unit": "kg"  },
    { "name": "bread",  "qty": 2,   "unit": "packet" }
  ]
}
```

**Pipeline:**
1. Audio bytes → Sarvam `saaras:v4` (multilingual STT)
2. Transcript → Sarvam `sarvam-105b` with a Hindi/Marathi/English normalisation prompt
3. Structured JSON output validated against a strict JSON Schema
4. Items fuzzy-matched against the store catalog in the Flutter app

---

## ICE - Inventory Confidence Engine

ICE infers inventory health from POS sales data alone, without manual stock counts.

**Core formulae at a glance:**

| Metric | Formula |
|--------|---------|
| Velocity | `V(t) = 0.3 · D(t) + 0.7 · V(t−1)` |
| Trend | `τ = (V_recent − V_baseline) / V_baseline × 100%` |
| Adjusted velocity | `V_adj = V · (1 + τ/100)` |
| Stock estimate | `S_est = S_anchor − Σ sales + Σ reorders` |
| Days to stockout | `D_out = S_est / V_adj` |
| 7-day allocation | `A₇ = max(0, V_adj · 7 − S_est) · (1 + buffer)` |
| Confidence | `C = 0.40·recency + 0.35·frequency + 0.25·consistency` |
| Health score | `H = healthy_count / total_count × 100` |

Full derivation, parameter table, pipeline diagram, and future extensions: [ice-formulation.md](./ice-formulation.md)

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| POS app | Flutter 3, Dart |
| Audio recording | `record 7.1.1` |
| QR generation | `qr_flutter` |
| HTTP client | `dart:io` HttpClient |
| Backend | Python 3.13, FastAPI, uvicorn |
| Dependency management | `uv` |
| STT | Sarvam AI `saaras:v4` |
| LLM | Sarvam AI `sarvam-105b` |
| Env config | `python-dotenv` |
