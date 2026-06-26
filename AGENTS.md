# Jobodia Frontend — Agent Instructions

## Project Overview

Jobodia is a Flutter job-board app built with:

* **Flutter** (latest stable)
* **GetX** — state management, navigation, dependency injection
* **Feature-based architecture** — each feature is self-contained
* **MVVM-inspired** — Controllers (ViewModels) + Views + Models
* **get_storage** — local persistence (no backend yet)
* Mock data only — no real API integration

Current priority: **Build and polish UI first.** Do not implement real backend logic unless explicitly requested.

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

Use feature-based structure:

```txt
lib/
├── app/
│   ├── bindings/        # InitialBinding (permanent controllers)
│   ├── middleware/       # AuthMiddleware (route guards)
│   ├── routes/          # AppRoutes + AppPages
│   └── theme/           # AppTheme (light/dark)
├── core/
│   ├── constants/       # AppColors, AppPalette, AppSpacing, AppDurations
│   ├── extensions/      # ContextX, StringX, DateX
│   ├── utils/           # Validators, DateFormatter, Debouncer
│   └── widgets/         # EmptyState, ErrorState, ShimmerPlaceholder, etc.
├── features/
│   ├── auth/            # Login, signup, OTP, reset
│   ├── home/            # Main shell, feed, nav bar
│   ├── job_detail/      # Job detail screen + widgets
│   ├── profile/         # User profile + edit
│   ├── cv_builder/      # CV wizard + preview + PDF
│   ├── ai_chat/         # AI chat with sessions
│   ├── interview/       # Flashcards, mock interview, calendar
│   ├── applications/    # Application tracking + Kanban
│   ├── saved_jobs/      # Saved jobs + comparison
│   ├── search/          # Search with filters
│   ├── notifications/   # Notification list
│   ├── settings/        # Settings, theme, feedback
│   ├── pricing/         # Plans + checkout
│   ├── company/         # Company profiles
│   ├── analytics/       # Application analytics
│   ├── report/          # Report form
│   ├── about/           # About, privacy policy
│   ├── onboarding/      # Onboarding pages
│   └── preferences/     # Post-onboarding wizard
└── services/            # SecureStorageService
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

Check `lib/core/widgets/` before creating new widgets:

| Widget | Purpose |
|--------|---------|
| `EmptyState` | Icon + title + subtitle + action for empty lists |
| `ErrorState` | Error icon + message + retry button |
| `ShimmerPlaceholder` | Animated shimmer bar for loading states |
| `SkeletonJobCard` | Skeleton matching JobFeedCard dimensions |
| `LoadingOverlay` | Semi-transparent overlay with spinner |
| `ConfirmationDialog` | `showConfirmationDialog()` — confirm/cancel |
| `UndoSnackbar` | `showUndoSnackbar()` — snackbar with Undo |
| `ScrollToTopButton` | FAB that appears after 500px scroll |
| `DismissKeyboardWrapper` | Unfocus on tap outside |
| `AnimatedScaleButton` | Scale-down on press |
| `ImageWithPlaceholder` | Image.network with loading + error |
| `CompanyAvatar` | Circle with company initials + deterministic color |
| `TypingIndicator` | 3-dot pulsing animation |
| `BadgeDot` | Red dot/counter badge |
| `Debouncer` | Timer-based input debouncer (300ms) |

**CustomButton** and **CustomTextField** are in `core/widgets/`. Use them.

---

## Styling Rules

Avoid hardcoded color values. Use the palette system:

```dart
// In any widget with BuildContext:
final palette = context.palette;
Text('Hello', style: TextStyle(color: palette.textPrimary));
Container(color: palette.surface);
```

**AppColors** — static constants (brand colors, gradients, semantic tokens):
- `AppColors.brandTeal` — brand accent (0xFF0EA5A4)
- `AppColors.success` / `.warning` / `.info` / `.error` — semantic colors
- `AppColors.cardGradients` — job card gradient pairs

**AppPalette** — light/dark theme-aware (accessed via `context.palette`):
- `.scaffold`, `.surface`, `.surfaceMuted` — backgrounds
- `.textPrimary`, `.textSecondary`, `.textTertiary` — text
- `.iconPrimary`, `.iconMuted` — icons
- `.border`, `.divider` — outlines
- `.success`, `.warning`, `.info`, `.error` — semantic (theme-aware)

**AppSpacing** — standardized spacing: xs(4), sm(8), md(12), lg(16), xl(20), xxl(24), xxxl(32)

Maintain visual consistency throughout the app. Test in both light and dark mode.

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
