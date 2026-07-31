# Hacky Pizza POS

A premium restaurant point-of-sale application scaffold built with Flutter for the frontend and a Node.js/Express backend stub for MongoDB Atlas sync and Socket.IO real-time order updates.

## Project Structure

- `lib/` - Flutter application code, including models, providers, screens, services, and widgets.
- `backend/` - Node.js/Express backend scaffold, socket integration, MongoDB sync endpoint, and sync model.

## Getting Started

### Flutter frontend

1. Run `flutter pub get` to install Dart dependencies.
2. Run `flutter analyze` to validate the code.
3. Run `flutter test` to verify the app scaffold starts correctly.
4. Use `flutter run` to launch the application on a connected device.

### Backend server

1. Navigate to `backend/`.
2. Copy `.env.example` to `.env` and set your `MONGO_URI`.
3. Run `npm install` to install dependencies.
4. Start the server with `npm start`.

## Features

- Offline-first local persistence with SQLite.
- POS billing, product variant management, inventory tracking, expenses, customer CRM, and analytics UI.
- Bluetooth thermal printer integration stub and PDF fallback.
- Cloud sync engine scaffold with API sync endpoints and Socket.IO order update broadcast.
- Indian rupee currency formatting and dark-mode-first interface.
