# Kyte POS – Code Map

This document gives a quick, human-friendly overview of the project structure, key modules, main screens, controllers, and data models. Use it as a starting point when navigating the codebase.

## Overview
- **Framework**: Flutter + GetX
- **Entry**: `lib/main.dart` (uses `GetMaterialApp`)
- **Routing**: `lib/app_route.dart` (`getPages` with bindings per route)
- **State mgmt**: GetX controllers + `StateController<T>` and reactive `uiState`
- **Organization**: Feature-first (auth, menu, home, splash), each with `data/`, `presentation/ (controller, state, ui)`

## Top-level layout
```
lib/
  main.dart
  app_route.dart
  app_color.dart
  base/                  # shared base utilities (prefs, device, network, state)
  binding/               # GetX bindings per feature/screen
  component/             # shared widgets/components
  view/
    auth/
    home/
    menu/
    splash/
```

## Entry points
- `lib/main.dart`
  - Creates `GetMaterialApp`, sets `initialRoute` to `AppRoute.splash`.
  - Wires `getPages` and `AppBinding`.
- `lib/app_route.dart`
  - Central route constants in `AppRoute`.
  - `getPages`: route → screen + binding, e.g. `AppRoute.product` → `ProductScreen` with `ProductBinding`.
- `lib/app_color.dart`
  - Color constants (e.g., `AppColor.green`, `AppColor.red`, `AppColor.white`).

## Base layer (selected)
- `lib/base/` contains cross-cutting concerns used by controllers, e.g. app prefs, device info, network, and `StateController`.

## Bindings
- `lib/binding/`
  - One binding per feature to register controllers and dependencies for a route.
  - Example: `binding/product_binding.dart` wires `ProductController` before `ProductScreen` is shown.

## Shared components
- `lib/component/custom_drawer.dart` - Reusable app drawer.

## Feature: Auth
- `lib/view/auth/data/` – API models
  - `model/request/*` and `model/response/*` e.g. `login_body.dart`, `login_response.dart`.
  - `data/network/auth_network.dart`
- `lib/view/auth/domain/` – repositories/usecases (e.g., `auth_usecase.dart`).
- `lib/view/auth/presentaion/` (note: folder name is "presentaion")
  - `controller/auth_controller.dart` – handles login, tokens, and password visibility (`isPasswordHidden`).
  - `state/auth_state.dart`
  - `ui/login_screen.dart`, `ui/registration_screen.dart` – forms using GetX controller.

---
Last updated automatically by CODEMAP generator.
