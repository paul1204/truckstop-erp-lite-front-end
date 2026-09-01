# Truck Stop ERP Lite (Front End)

Web-based front end for the Truck Stop ERP Lite operations management system, built with Flutter.

## Overview

Truck Stop ERP Lite provides a unified management dashboard and operational tools for truck stop management:

- **Dashboard**: High-level operational metrics and status summaries.
- **Fuel Inventory**: Tank levels, recent deliveries, and delivery logging.
- **Store Inventory**: Categorized merchandise inventory tracking.
- **House Accounts**: Fleet and customer credit accounts, billing records, and balance tracking.
- **Parking Management**: Spot availability and lot occupancy visualization.
- **Showers**: Driver shower stall reservation and occupancy status.
- **Shift Sales**: Sales breakdowns by shift and date.

## Tech Stack

- **Framework**: Flutter (Web / Multi-platform)
- **Language**: Dart (SDK ^3.12.2)
- **HTTP Client**: `package:http`
- **State Management**: `ChangeNotifier` / `ListenableBuilder` architecture

## Getting Started

### Prerequisites

- Flutter SDK (3.x or later)
- Chrome or any supported web browser

### Backend Setup

The front end communicates with the backend services at `http://localhost:9000`. To run the full system locally, clone and start the backend service repository:

```bash
git clone https://github.com/paul1204/truckstop-services.git
```

### Installation

Clone the repository and install dependencies:

```bash
flutter pub get
```

### Running Locally

To run the web app on a local development server:

```bash
flutter run -d web-server --web-port=8600 --web-hostname=0.0.0.0
```

Or run directly in Chrome:

```bash
flutter run -d chrome
```

## Project Structure

```text
lib/
├── data/              # API catalog and HTTP client configuration
├── features/          # Feature modules (views, state notifiers, custom widgets)
│   ├── about/
│   ├── customers/
│   ├── dashboard/
│   ├── fuel_inventory/
│   ├── house_accounts/
│   ├── incidents/
│   ├── inventory/
│   ├── parking/
│   ├── profile_switcher/
│   ├── sales/
│   ├── settings/
│   └── showers/
├── ui/core/           # Design tokens, theme styling, and core widgets
└── main.dart          # App entrypoint, shell navigation, and theme initialization
```