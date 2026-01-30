# 🎩 nudge- flutter butler
> **"Focus is fragile. The Butler protects it."**

**nudge- flutter butler** is a high-performance **Cognitive Partner** designed for engineers and students operating in high-intensity environments. Built for the **Serverpod 3 Global Hackathon**, it acts as a digital Butler—managing cognitive load, restoring work contexts, and archiving your physical world.

---

## 📽️ Demo & Visuals

### [Insert Demo Video Link Here]
*(A 3-minute walkthrough showcasing the Butler's intent engine, Android notifications, and the Serverpod Cloud architecture.)*

### 📸 Screenshots
| **Context Capsule** | **The Asset Vault** | **Ghost Focus Mode** |
| :---: | :---: | :---: |
| [Placeholder for Capsule Image] | [Placeholder for Vault Table] | [Placeholder for Ghost UI] |
| *Visual recovery for your brain.* | *Your physical world, archived.* | *Zero-distraction isolation.* |

---

## 🏆 Hackathon Context
This project was built for the **Build your Flutter Butler with Serverpod** global challenge, celebrating the release of **Serverpod 3**.
* **Track:** Mobile, Productivity, Lifehacks.
* **Goal:** To showcase the power of the Flutter + Serverpod stack by creating a digital assistant that serves, automates, and delights.

---

## ✨ The "Wow" Factor: Context Capsule 🚀
In modern work, **context switching** is the ultimate productivity killer. When you step away from a complex mission, you lose your mental map. 

**NUDGE fixes this.** Before you "pause," you snap a photo of your environment. When you return, the Butler doesn't just show you a note; it **restores your visual and mental context**, reducing the activation energy needed to restart a task to near zero.

---

## 🛠️ Features at a Glance
* **The Butler Brain (Intent Engine):** Powered by **Gemini 1.5 Flash**, Nudge uses advanced intent classification to distinguish between casual thoughts (**Intel**), deadlines (**Task**), warranties (**Asset**), or deep-work sessions (**Ghost Mode**).
* **Ghost Focus Mode:** A specialized UI overlay that "haunts" your device, visually isolating you from distractions until your mission is complete.
* **The Asset Vault:** A secure, relational archive built on **Serverpod's ORM** that tracks physical items and their warranties.

---

## 🏛️ Technical Architecture
We utilized a **"Monolith-First" Full-Stack Dart** approach to ensure maximum reliability and type safety.

* **Frontend:** **Flutter** (Mobile & Web) 
* **Backend:** **Serverpod 3** (Dart-based)
* **Database:** **PostgreSQL** via Serverpod’s built-in ORM
* **AI Engine:** **Gemini 1.5 Flash API**
* **Cloud Hosting:** Deployed on **Serverpod Cloud**

---

## 🛠️ Local Setup & Installation

### 1. Prerequisites
* **Flutter SDK**
* **Serverpod CLI**: `dart pub global activate serverpod_cli`
* **Docker**: To run the local PostgreSQL database.

### 2. Configure Backend
1. `cd nudge_server`
2. `docker-compose up -d`
3. Add Gemini API key in `lib/src/logic/parser.dart`.
4. `dart bin/main.dart --mode development`

### 3. Configure Client
1. `cd nudge_flutter`
2. Ensure `main.dart` points to `localhost`.
3. `flutter run`

---

## ⚖️ Limitations & Technical Honesty
* **Demo Optimization:** Notifications trigger **instantly** for the demo to show the full AI-to-Device loop.
* **API Usage:** Utilizes **Gemini Free Tier** with a **Safety Governor** fallback.
* **Platform Specifics:** Optimized for **Native Android**; Web version serves as a dashboard.

---

## 🚀 Future Scope
* **Multi-Modal Memory:** The Butler "sees" your Capsule images.
* **Asset OCR:** Automatically scanning warranty receipts.

---

### 👨‍💻 Developed by
**Charu**
*Submitted for the Serverpod 3 Global Hackathon — Jan 2026.*
