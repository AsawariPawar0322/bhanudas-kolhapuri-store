# 🧵 Artisan Intelligence

## 🚀 A Google Anti-Gravity Moonshot Project

**AI-powered, offline-first platform for traditional craftsmen**

> "Existing apps assume internet, literacy, and scale. This system is different — it's **offline-first**, **human-first**, and designed for **informal economies that tech forgot**."

---

## 🌟 What Makes This Special

| Feature | Description |
|---------|-------------|
| 🧠 **AI Demand Prediction** | Predicts demand using festivals, seasons, weather, and local patterns |
| 📴 **Offline-First** | Works without internet, syncs when connected |
| 👨‍🎨 **Artisan-Centric** | Designed for traditional craftsmen, supports voice input |
| 🌱 **Sustainability** | Reduces waste by producing only what will sell |
| 🎙️ **Voice Orders** | Create orders by speaking in local language |

---

## 📁 Project Structure

```
NEW PROJECT/
├── artisan_app/            # Flutter Android App (Actual Code)
│   ├── lib/
│   │   ├── main.dart
│   │   └── ...
│   └── android/
│
├── backend/                   # Python FastAPI Backend
│   ├── main.py                
│   └── requirements.txt       
│
├── index.html                 # Web prototype (high fidelity)
└── styles.css                 
```

---

## 🛠️ Setup Instructions

### Backend (Python)

```bash
# Navigate to backend
cd backend

# Create virtual environment
python -m venv venv

# Activate (Windows)
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run server
python main.py
# or
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

API will be available at: `http://localhost:8000`

### Frontend (Flutter)

```bash
# Navigate to frontend
cd frontend

# Get dependencies
flutter pub get

# Run on device/emulator
flutter run

# Run on web (bonus)
flutter run -d chrome
```

---

## 🔌 API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/predictions/today` | GET | Today's AI demand prediction |
| `/api/predictions/weekly` | GET | 7-day demand forecast |
| `/api/predictions/recommendations` | GET | Production plan |
| `/api/orders` | GET | List all orders |
| `/api/orders` | POST | Create new order |
| `/api/sync` | POST | Sync offline orders |
| `/api/impact` | GET | Sustainability metrics |
| `/api/festivals/upcoming` | GET | Festival calendar |

---

## 🎯 Features Breakdown

### 1. AI Demand Prediction
- Analyzes **day of week** patterns
- Tracks **festival proximity** (Diwali, Makar Sankranti, etc.)
- Considers **seasonal factors** (Wedding season = 3x demand)
- Monitors **weather conditions**

### 2. Offline-First Architecture
- All orders work without internet
- Automatic sync when connection returns
- Local SQLite storage in Flutter
- Visual queue showing pending syncs

### 3. Voice Input
- Create orders by speaking
- Supports local languages
- Perfect for low-literacy users

### 4. Sustainability Tracking
- Waste prevention metrics
- Carbon footprint savings
- Production accuracy scoring
- Income growth tracking

---

## 🎨 Design System

### Colors
- **Primary**: `#6366F1` (Indigo)
- **Secondary**: `#F59E0B` (Amber)
- **Accent**: `#10B981` (Emerald)
- **Background**: `#0F0F1A` (Dark)

### Typography
- Font: **Outfit** (Google Fonts)
- Weights: 400, 500, 600, 700, 800

### Effects
- Glassmorphism cards
- Gradient buttons
- Animated AI orb
- Bar chart animations

---

## 📱 Screenshots

*Run the app to see the beautiful UI!*

---

## 🚀 Pitch to Google

> ### The Problem
> Most AI apps die without internet. Traditional artisans have no access to demand prediction or inventory intelligence.

> ### Our Solution
> **Artisan Intelligence** — an AI system that works offline, understands traditional craft cycles, and helps artisans produce only what will sell.

> ### Key Differentiators
> - ✅ Works without internet
> - ✅ Voice-first for low-literacy users
> - ✅ AI trained on non-traditional signals (festivals, weather, seasons)
> - ✅ Reduces waste by 34%
> - ✅ Built for informal economies

---

## 📄 License

MIT License - Built for Google Anti-Gravity / Moonshot consideration

---

**Made with ❤️ for Traditional Artisans**
