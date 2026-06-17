# Jobodai Project Instructions

## Project Overview

Jobodia is a Flutter mobile application built with:

* Flutter
* GetX
* Feature-based architecture
* MVVM-inspired structure
* Reusable widgets
* Backend integration later

Current priority:

**Build and polish UI first.**

Do not implement real backend logic unless explicitly requested.

---

## Main Rules

1. Build UI first.
2. Backend will be connected later.
3. Use GetX.
4. Keep code beginner-friendly.
5. Keep code readable and maintainable.
6. Avoid unnecessary complexity.
7. Match provided screenshots closely.
8. Follow existing project structure.
9. Reuse existing widgets whenever possible.
10. Do not break existing functionality.

---

## Architecture Rules

Use feature-based structure.

Example:

```txt
lib/
├── core/
│   ├── constants/
│   ├── widgets/
│   ├── routes/
│   └── theme/
│
├── features/
│   ├── onboarding/
│   ├── auth/
│   ├── home/
│   ├── jobs/
│   ├── profile/
│   └── settings/
```

Do not create new architecture patterns.

Follow the existing project structure.

---

## GetX Rules

Use GetX only when needed.

Allowed:

* Navigation
* Tab switching
* PageView index
* Loading state
* Simple UI state

Avoid:

* Large controllers
* Premature business logic
* Unnecessary dependency injection

If a screen is static, do not create a controller.

---

## Current Onboarding Location

Current onboarding screen:

```txt
features/onboarding/views/welcome_screen_1.dart
```

When updating onboarding screens:

* Keep navigation working.
* Maintain existing flow.
* Improve UI without changing app behavior.

---

## UI Design Rules

Design should be:

* Modern
* Clean
* Professional
* Mobile-first

Requirements:

* Responsive layout
* Good spacing
* Rounded corners
* Consistent typography
* Proper padding
* Professional button styles

Match screenshots as closely as possible.

You may improve spacing and layout when beneficial.

---

## Reusable Widgets

Before creating a new widget, check:

```txt
core/widgets/
```

If a reusable widget already exists:

* Use it.
* Extend it only if necessary.

Avoid duplicate widgets.

Examples:

* CustomButton
* CustomTextField
* CustomAppBar

---

## Styling Rules

Avoid hardcoded values when possible.

Use existing project files such as:

* AppColors
* AppSizes
* AppConstants
* AppTextStyles
* AppTheme

Only use these files if they already exist.

Maintain visual consistency throughout the app.

---

## Backend Rules

Do not create backend-related logic unless explicitly requested.

Do NOT:

* Connect APIs
* Implement authentication requests
* Create repositories
* Create network services
* Add Dio logic
* Add Retrofit logic
* Add database logic

Use mock data when needed.

Example:

```dart
final jobs = [
  Job(title: "Flutter Developer"),
  Job(title: "Backend Developer"),
];
```

---

## Navigation Rules

Use GetX navigation.

Examples:

```dart
Get.to(...);
Get.back();
Get.off(...);
Get.offAll(...);
```

Do not introduce another navigation system.

---

## Controller Rules

Create a controller only when necessary.

Good examples:

* Password visibility toggle
* Bottom navigation index
* Onboarding page index
* Loading state

Bad examples:

* Controller for static UI
* Controller with empty methods
* Controller prepared only for future backend

Keep controllers small.

---

## Code Generation Rules

When generating code:

1. Generate complete files when requested.
2. Preserve existing functionality.
3. Avoid placeholder backend code.
4. Use null safety.
5. Remove unused imports.
6. Keep widgets reusable.
7. Prefer StatelessWidget when possible.
8. Use StatefulWidget only when required.
9. Use GetX state only when beneficial.
10. Write production-quality UI code.
11. Do not modify `pubspec.yaml` unless explicitly requested.
12. Do not add new packages unless explicitly requested.

---

## Documentation Rules

Whenever code is modified, explain shortly:

1. What files were changed.
2. Why they were changed.
3. Any new widgets created.

Keep explanations short and clear.

---

## Important

Unless explicitly requested:

* Do not implement backend.
* Do not create APIs.
* Do not create authentication services.
* Do not create database logic.
* Do not create unnecessary controllers.
* Do not add new packages.

Focus on UI quality and clean Flutter code.
