# urban-bite-app

Urban Food Bite is a food and grocery delivery platform suite comprising customer mobile apps, an admin management portal, and delivery partner tracking.

## Repository Overview

This repository contains the full source code for the Urban Bite application ecosystem:

- **`blinkit_clone/`** - Customer-facing Flutter mobile application for browsing menus, cart management, checkout, and live order tracking.
- **`blinkit_admin/`** - Admin Flutter mobile app for managing categories, products, orders, banners, and delivery personnel.
- **`delivery_app/`** - Delivery partner Flutter mobile app for riders to accept, navigate, and fulfill orders.
- **`urban_bite_admin_web/`** - Web administration dashboard built with Vite, Tailwind CSS, and Firebase.
- **`veg-menu.csv` & `non-veg-menu.csv`** - Curated restaurant and grocery catalogue datasets.

---

## Tech Stack

- **Mobile Applications**: Flutter (Dart), Firebase Authentication, Cloud Firestore, Cloud Storage, Push Notifications.
- **Admin Web Dashboard**: React / Vite, Tailwind CSS, Firebase.
- **Backend / Services**: Firebase (Auth, Firestore, Storage, Cloud Messaging).

---

## Getting Started

### Prerequisites

- Flutter SDK (>= 3.0.0)
- Node.js & npm (for `urban_bite_admin_web`)
- Android Studio / Xcode for mobile emulation
- Firebase CLI (for web deployment)

### Running Mobile Apps

```bash
# Customer App
cd blinkit_clone
flutter pub get
flutter run

# Admin Mobile App
cd blinkit_admin
flutter pub get
flutter run

# Delivery App
cd delivery_app
flutter pub get
flutter run
```

### Running Web Admin Dashboard

```bash
cd urban_bite_admin_web
npm install
npm run dev
```

---

## License

This project is proprietary and confidential.
