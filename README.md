<!-- Banner -->
<p align="center">
  <img src="assets/icons/app_icon.png" alt="Jobodia Logo" width="120" />
</p>

<h1 align="center">Jobodia</h1>

<p align="center">
  <strong>AI-Powered Job Board & Career Assistant</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.44-blue?logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.12+-0175C2?logo=dart" alt="Dart" />
  <img src="https://img.shields.io/badge/GetX-4.7-purple" alt="GetX" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-brightgreen" alt="Platforms" />
  <img src="https://img.shields.io/badge/License-Private-red" alt="License" />
  <img src="https://img.shields.io/badge/CI-GitHub%20Actions-black?logo=githubactions" alt="CI" />
</p>

<p align="center">
  A cross-platform Flutter application that helps job seekers discover opportunities, build professional CVs, prepare for interviews, and manage their entire job search — all in one place.
</p>

---

## Table of Contents

- [Overview](#overview)
- [Screenshots](#screenshots)
- [Features](#features)
- [Architecture](#architecture)
- [App Flow](#app-flow)
- [Project Structure](#project-structure)
- [Tech Stack](#tech-stack)
- [Design System](#design-system)
- [Getting Started](#getting-started)
- [Running the App](#running-the-app)
- [CI/CD](#cicd)
- [Security](#security)
- [Roadmap](#roadmap)
- [Contributing](#contributing)

---

## Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         JOBODIA                                  │
│                                                                  │
│   ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│   │  🔍 Job  │  │  📄 CV   │  │  🤖 AI   │  │  🎤 Int  │       │
│   │  Search  │  │  Builder │  │  Chat    │  │  Prep    │       │
│   └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘       │
│        │             │             │             │               │
│        └─────────────┴──────┬──────┴─────────────┘               │
│                             │                                    │
│                    ┌────────▼────────┐                           │
│                    │   GetStorage    │                           │
│                    │   (Local DB)    │                           │
│                    └─────────────────┘                           │
└─────────────────────────────────────────────────────────────────┘
```

Jobodia is a **mobile-first career companion** built with Flutter and GetX. It provides job seekers with:

- A curated, searchable job feed with smart filtering
- A step-by-step CV builder with PDF export
- An AI career chat assistant
- Interview preparation tools (mock interviews, flashcards, recruiter message templates)
- Full dark mode support with a polished glassmorphism UI

> **Status:** Frontend prototype with mock data. Backend integration (Spring Boot) is planned.

---

## Screenshots

> 📸 **Add your screenshots here.** Recommended: 3-4 screens showing light & dark mode.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│   📸 screenshots/01_onboarding.png      📸 screenshots/02_home_feed.png    │
│   ┌─────────────────────┐               ┌─────────────────────┐            │
│   │                     │               │  🔍  Jobs you like  │            │
│   │    🚀               │               │  ┌───────────────┐  │            │
│   │                     │               │  │ Top Pick 98%  │  │            │
│   │   Find Your         │               │  │ NovaTech Labs │  │            │
│   │   Dream Job         │               │  │ Product Design│  │            │
│   │                     │               │  └───────────────┘  │            │
│   │   [Get Started]     │               │  ┌───────────────┐  │            │
│   │                     │               │  │ Finverse  92% │  │            │
│   └─────────────────────┘               │  └───────────────┘  │            │
│                                         └─────────────────────┘            │
│                                                                             │
│   📸 screenshots/03_job_detail.png      📸 screenshots/04_cv_builder.png   │
│   ┌─────────────────────┐               ┌─────────────────────┐            │
│   │  ← NovaTech Labs    │               │  CV Builder         │            │
│   │                     │               │  Step 1 of 3        │            │
│   │  Product Designer   │               │  ┌───────────────┐  │            │
│   │  98% Match          │               │  │ Full Name     │  │            │
│   │                     │               │  │ Email         │  │            │
│   │  $3,500-$5,200      │               │  │ Phone         │  │            │
│   │  Singapore          │               │  │ Location      │  │            │
│   │                     │               │  └───────────────┘  │            │
│   │  [Apply] [Save]     │               │  [Next Step →]      │            │
│   └─────────────────────┘               └─────────────────────┘            │
│                                                                             │
│   📸 screenshots/05_ai_chat.png         📸 screenshots/06_dark_mode.png    │
│   ┌─────────────────────┐               ┌─────────────────────┐            │
│   │  AI Assistant       │               │  ██ DARK MODE ██    │            │
│   │                     │               │                     │            │
│   │  "Review my CV"     │               │  Same screens,      │            │
│   │                     │               │  dark palette.      │            │
│   │  Absolutely! Please │               │                     │            │
│   │  upload your CV...  │               │  ┌───────────────┐  │            │
│   │                     │               │  │ Job Feed Card │  │            │
│   │  [Improve summary]  │               │  │ Dark variant  │  │            │
│   │  [Add skills]       │               │  └───────────────┘  │            │
│   │                     │               │                     │            │
│   │  Type a message...  │               │  🏠 💼 🤖 🎤       │            │
│   └─────────────────────┘               └─────────────────────┘            │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

> Place actual screenshots in a `screenshots/` folder and replace the placeholders above.

---

## Features

```
┌──────────────────────────────────────────────────────────────────────┐
│                        FEATURE MAP                                    │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  🔐 AUTHENTICATION          🏠 HOME & JOB FEED                      │
│  ├─ Login / Signup           ├─ Curated job feed with Top Pick       │
│  ├─ OTP Verification         ├─ Filter by level, location, salary    │
│  ├─ Password Reset           ├─ Full-text search                     │
│  ├─ Social Login (UI)        ├─ Dismiss / undo jobs                  │
│  └─ Demo Account Flow        └─ Share jobs via system share sheet    │
│                                                                      │
│  📄 CV BUILDER               💼 JOB DETAIL                           │
│  ├─ 3-Step wizard            ├─ Full job description                 │
│  │  (Info → Experience →     ├─ Company logo & details               │
│  │   Template)               ├─ Apply with confirmation dialog       │
│  ├─ Up to 3 work entries     ├─ Save / unsave jobs                   │
│  ├─ Up to 3 education entries├─ Per-job notes (persisted)            │
│  ├─ Skills tag input         ├─ Match breakdown sheet                │
│  ├─ Headshot photo picker    ├─ More jobs from company               │
│  ├─ 3 CV templates           └─ Report inappropriate listings       │
│  │  (Classic / Balanced /                                            │
│  │   Modern)                   📋 APPLICATIONS                       │
│  ├─ PDF generation & export  ├─ Track applied jobs                   │
│  └─ Persistent CV storage    ├─ Application date history             │
│                              └─ Cover letter support                 │
│  🤖 AI CHAT                                                       │
│  ├─ Career assistant chat    🔖 SAVED JOBS                           │
│  ├─ Smart suggestion chips   ├─ Favorited / bookmarked jobs          │
│  ├─ Chat session history     ├─ Remove from saved                    │
│  ├─ Session search           └─ Persisted across restarts            │
│  └─ New chat / load session                                         │
│                              🔔 NOTIFICATIONS                        │
│  🎤 INTERVIEW PREP           ├─ Job match alerts                     │
│  ├─ Mock Interview           ├─ AI CV update notices                 │
│  │  ├─ 90-second timer       ├─ Interview prep reminders             │
│  │  ├─ Rate: nailed/almost/  ├─ Weekly summary                       │
│  │  │        missed          ├─ Mark read / mark all read            │
│  │  ├─ Score tracking        └─ Unread badge count                   │
│  │  └─ Past session history                                         │
│  ├─ Flash Cards              👤 PROFILE                              │
│  │  ├─ HTML/CSS/JS concepts  ├─ Cover photo & avatar                 │
│  │  ├─ Bookmark cards        ├─ Name, role, bio                     │
│  │  └─ Progress tracking     ├─ Experience timeline                  │
│  └─ Recruiter Messages       ├─ Edit profile screen                  │
│     ├─ Template library      └─ Persistent profile data              │
│     └─ Copy to clipboard                                            │
│                              ⚙️ SETTINGS                             │
│  📊 PREFERENCES WIZARD       ├─ Dark / Light mode toggle             │
│  ├─ Select desired role      ├─ Biometric auth (UI placeholder)     │
│  ├─ Select experience level  ├─ Passcode lock (UI placeholder)      │
│  ├─ Select location          ├─ Notifications toggle                 │
│  └─ Pre-seeds home filters   ├─ Privacy policy link                  │
│                              ├─ About us                             │
│  🏷️ PRICING                  ├─ Share app                            │
│  ├─ Free / Pro / Enterprise  ├─ Rate app                             │
│  └─ Feature comparison       └─ Submit feedback                      │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│                      ARCHITECTURE OVERVIEW                            │
│                                                                      │
│   ┌──────────────────────────────────────────────────────────────┐   │
│   │                      PRESENTATION LAYER                       │   │
│   │                                                              │   │
│   │   ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐       │   │
│   │   │ Screens │  │ Widgets │  │  Theme  │  │  Routes │       │   │
│   │   │ (Views) │  │ (Reuse) │  │ (Light/ │  │  (GetX  │       │   │
│   │   │         │  │         │  │  Dark)  │  │  Pages) │       │   │
│   │   └────┬────┘  └────┬────┘  └────┬────┘  └────┬────┘       │   │
│   │        │            │            │            │              │   │
│   └────────┼────────────┼────────────┼────────────┼──────────────┘   │
│            │            │            │            │                   │
│   ┌────────┼────────────┼────────────┼────────────┼──────────────┐   │
│   │        ▼            ▼            ▼            ▼              │   │
│   │                  LOGIC LAYER                                 │   │
│   │                                                              │   │
│   │   ┌─────────────────────────────────────────────────────┐   │   │
│   │   │              GetX Controllers (Reactive)             │   │   │
│   │   │                                                     │   │   │
│   │   │  AuthController · HomeController · CvBuilderCtrl    │   │   │
│   │   │  AiChatController · InterviewCtrl · ProfileCtrl    │   │   │
│   │   │  SavedJobsCtrl · ApplicationsCtrl · SearchCtrl     │   │   │
│   │   │  ThemeController · PreferencesCtrl · ReportCtrl    │   │   │
│   │   └─────────────────────────────────────────────────────┘   │   │
│   │        │                                                    │   │
│   │        │  Observables (RxList, RxString, RxBool...)         │   │
│   │        │  Obx() / GetX<Controller> auto-rebuild             │   │
│   │        │                                                    │   │
│   └────────┼────────────────────────────────────────────────────┘   │
│            │                                                        │
│   ┌────────┼────────────────────────────────────────────────────┐   │
│   │        ▼                                                    │   │
│   │                  DATA LAYER                                 │   │
│   │                                                              │   │
│   │   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │   │
│   │   │  GetStorage  │  │   Models     │  │  Repository  │     │   │
│   │   │  (Key-Value  │  │  (fromJson/  │  │  (Mock auth  │     │   │
│   │   │   Persist)   │  │   toJson)    │  │   for now)   │     │   │
│   │   └──────────────┘  └──────────────┘  └──────────────┘     │   │
│   │                                                              │   │
│   └──────────────────────────────────────────────────────────────┘   │
│                                                                      │
│   ┌──────────────────────────────────────────────────────────────┐   │
│   │                     DEPENDENCY INJECTION                      │   │
│   │                                                              │   │
│   │   InitialBinding (permanent singletons):                     │   │
│   │   AuthRepo → AuthCtrl → ThemeCtrl → SavedJobsCtrl →         │   │
│   │   ApplicationsCtrl → PreferencesCtrl → NotificationsCtrl →  │   │
│   │   CvBuilderCtrl → SearchHistoryCtrl → FlashcardsCtrl        │   │
│   │                                                              │   │
│   │   Lazy bindings (per-route):                                 │   │
│   │   OnboardingCtrl · JobDetailCtrl · AiChatCtrl ·             │   │
│   │   CvBuilderCtrl · ProfileCtrl · ReportCtrl ·                │   │
│   │   MockInterviewCtrl · PreferencesCtrl                       │   │
│   └──────────────────────────────────────────────────────────────┘   │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

### Pattern: Feature-First + GetX

Each feature is self-contained with its own **controller**, **model**, and **view**:

```
lib/features/<feature>/
  ├── controller/     ← GetX controller (business logic, reactive state)
  ├── model/          ← Data classes with toJson/fromJson
  ├── view/           ← Screens and reusable widgets
  ├── repository/     ← Data access layer (mock for now)
  ├── service/        ← Feature-specific services
  └── data/           ← Static data / constants
```

---

## App Flow

```
┌──────────────────────────────────────────────────────────────────────┐
│                          USER JOURNEY                                 │
│                                                                      │
│   App Launch                                                         │
│       │                                                              │
│       ▼                                                              │
│   ┌─────────────┐     No      ┌──────────────────┐                  │
│   │  Onboarding │────────────▶│  Onboarding View │                  │
│   │  Seen?      │             │  (3 pages)       │                  │
│   └──────┬──────┘             └────────┬─────────┘                  │
│          │ Yes                         │                             │
│          ▼                             ▼                             │
│   ┌─────────────┐             ┌──────────────────┐                  │
│   │ Login /     │◀────────────│  Get Started     │                  │
│   │ Signup Tab  │             └──────────────────┘                  │
│   └──────┬──────┘                                                    │
│          │                                                           │
│          ▼                                                           │
│   ┌─────────────┐             ┌──────────────────┐                  │
│   │ OTP Verify  │────────────▶│  Preferences     │                  │
│   │             │             │  Wizard (3 steps) │                  │
│   └─────────────┘             └────────┬─────────┘                  │
│                                        │                             │
│                                        ▼                             │
│                              ┌──────────────────┐                    │
│                              │   Main Shell     │                    │
│                              │   ┌──┬──┬──┬──┐  │                    │
│                              │   │🏠│📄│🤖│🎤│  │                    │
│                              │   └──┴──┴──┴──┘  │                    │
│                              │   Home|CV|AI|Int │                    │
│                              └──────────────────┘                    │
│                                                                      │
│   Bottom Navigation Tabs:                                            │
│   🏠 Home Feed ──── Search, Filter, Save, Apply, Share, Report      │
│   📄 CV Builder ─── 3-step wizard → Preview → Export PDF            │
│   🤖 AI Chat ────── Career assistant with session history           │
│   🎤 Interview ──── Mock interview, Flashcards, Recruiter msgs     │
│                                                                      │
│   Overflow Menu (top bar):                                           │
│   👤 Profile ───── View & edit profile, experience timeline         │
│   ⚙️ Settings ──── Theme, notifications, about, feedback            │
│   🔔 Notifications── Job matches, AI updates, reminders             │
│   🔖 Saved Jobs ── Bookmarked positions                             │
│   📋 Applications── Applied job history                             │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Project Structure

```
jobodia_frontend/
├── lib/
│   ├── main.dart                              # App entry point
│   ├── app/
│   │   ├── bindings/
│   │   │   └── initial_binding.dart           # Global DI setup
│   │   ├── routes/
│   │   │   ├── app_pages.dart                 # GetX route → page mapping
│   │   │   └── app_routes.dart                # Route name constants
│   │   └── theme/
│   │       └── app_theme.dart                 # Light & dark ThemeData
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_colors.dart                # Color palette & AppPalette
│   │   └── widgets/
│   │       ├── custom_button.dart             # Reusable CTA button
│   │       ├── custom_text_field.dart         # Styled text input
│   │       ├── feature_card_container.dart    # Card wrapper
│   │       └── feature_header.dart            # Section header
│   └── features/
│       ├── about/                             # About Us & Privacy Policy
│       ├── ai_chat/                           # AI career assistant
│       │   ├── controller/ai_chat_controller.dart
│       │   ├── model/chat_message_model.dart
│       │   ├── model/chat_session.dart
│       │   └── view/ai_chat_screen.dart
│       ├── applications/                      # Job application tracking
│       ├── auth/                              # Login, signup, OTP, reset
│       │   ├── controller/auth_controller.dart
│       │   ├── model/user_model.dart
│       │   ├── repository/auth_repository.dart
│       │   └── view/ (6 files + widgets/)
│       ├── cv_builder/                        # CV creation wizard
│       │   ├── controller/cv_builder_controller.dart
│       │   ├── model/cv_data.dart
│       │   ├── service/cv_pdf_builder.dart
│       │   └── view/ (2 screens)
│       ├── home/                              # Job feed & navigation shell
│       │   ├── controller/home_controller.dart
│       │   ├── model/job_feed_model.dart
│       │   └── view/ (2 screens + 7 widgets)
│       ├── interview/                         # Interview prep hub
│       │   ├── controller/ (2 controllers)
│       │   ├── data/ (flashcard_data, recruiter_messages)
│       │   └── view/ (4 screens)
│       ├── job_detail/                        # Single job view
│       │   ├── controller/ (2 controllers)
│       │   ├── model/job_detail_model.dart
│       │   └── view/ (1 screen + 10 widgets)
│       ├── notifications/                     # Notification center
│       ├── onboarding/                        # First-launch onboarding
│       │   ├── controllers/
│       │   ├── views/
│       │   └── widgets/ (5 widgets)
│       ├── preferences/                       # Post-signup preference wizard
│       ├── pricing/                           # Pricing plans screen
│       ├── profile/                           # User profile & editing
│       ├── report/                            # Job listing reports
│       ├── saved_jobs/                        # Bookmarked jobs
│       ├── search/                            # Search with history
│       └── settings/                          # App settings
├── assets/
│   ├── icons/                                 # google.png, github.png
│   └── images/onboarding/                     # Onboarding illustrations
├── android/                                   # Android platform config
├── ios/                                       # iOS platform config
├── web/                                       # Web platform config
├── test/                                      # Widget tests
├── .github/workflows/flutter_ci.yml           # CI pipeline
├── pubspec.yaml                               # Dependencies
└── README.md                                  # This file
```

**Total Dart files:** 100

---

## Tech Stack

```
┌──────────────────────────────────────────────────────────────────┐
│                        TECH STACK                                 │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  FRAMEWORK          STATE MGMT         STORAGE                   │
│  ┌────────────┐    ┌────────────┐    ┌────────────┐             │
│  │  Flutter   │    │   GetX     │    │ GetStorage │             │
│  │  3.44.0    │    │   4.7.3    │    │   2.1.1    │             │
│  │            │    │            │    │            │             │
│  │ • Material │    │ • Reactive │    │ • Key-value│             │
│  │   Design 3 │    │   state    │    │   persist  │             │
│  │ • Cross-   │    │ • Route    │    │ • JSON on  │             │
│  │   platform │    │   mgmt     │    │   disk     │             │
│  │ • Hot      │    │ • DI /     │    │            │             │
│  │   reload   │    │   Bindings │    │            │             │
│  └────────────┘    └────────────┘    └────────────┘             │
│                                                                  │
│  UI EFFECTS         PDF GENERATION     SHARING                   │
│  ┌────────────┐    ┌────────────┐    ┌────────────┐             │
│  │ Liquid     │    │   pdf      │    │ share_plus │             │
│  │ Glass      │    │   3.13.0   │    │  13.1.0    │             │
│  │ Widgets    │    │            │    │            │             │
│  │            │    │ printing   │    │ System     │             │
│  │ Frosted    │    │  5.15.0    │    │ share      │             │
│  │ glass UI   │    │            │    │ sheet      │             │
│  └────────────┘    └────────────┘    └────────────┘             │
│                                                                  │
│  IMAGE PICKING      CI/CD              DART SDK                  │
│  ┌────────────┐    ┌────────────┐    ┌────────────┐             │
│  │image_picker│    │  GitHub    │    │  Dart 3.12 │             │
│  │   1.2.2    │    │  Actions   │    │            │             │
│  │            │    │            │    │ • Null     │             │
│  │ Camera &   │    │ • Analyze  │    │   safety   │             │
│  │ gallery    │    │ • Format   │    │ • Records  │             │
│  │ access     │    │ • Test     │    │ • Patterns │             │
│  │            │    │ • Telegram │    │            │             │
│  └────────────┘    └────────────┘    └────────────┘             │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## Design System

### Color Palette

```
┌──────────────────────────────────────────────────────────────┐
│                      COLOR SYSTEM                             │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  BRAND COLORS                                                │
│  ┌────────┐ ┌────────┐ ┌────────┐                           │
│  │████████│ │████████│ │████████│                           │
│  │Primary │ │ Purple │ │ Purple │                           │
│  │#202428 │ │Accent  │ │ Dark   │                           │
│  │        │ │#8B5CF6 │ │#7C3AED│                           │
│  └────────┘ └────────┘ └────────┘                           │
│                                                              │
│  SEMANTIC COLORS                                             │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐               │
│  │████████│ │████████│ │████████│ │████████│               │
│  │  Bg    │ │Surface │ │ Error  │ │  Hint  │               │
│  │#F7F8F9 │ │ White  │ │#D93B3B│ │#B9BEC3│               │
│  └────────┘ └────────┘ └────────┘ └────────┘               │
│                                                              │
│  JOB CARD GRADIENTS (cycle by index)                         │
│  ┌────────────────┐  ┌────────────────┐                     │
│  │▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│  │▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒│                     │
│  │ Blue → Purple  │  │Teal → Emerald  │                     │
│  │#2B5DF0→#7C3AED │  │#0EA5A4→#10B981 │                     │
│  └────────────────┘  └────────────────┘                     │
│  ┌────────────────┐  ┌────────────────┐                     │
│  │░░░░░░░░░░░░░░░░│  │▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│                     │
│  │Orange → Coral  │  │Indigo → Violet │                     │
│  │#FF7E45→#FF5A6E │  │#6D5BF8→#B14CF0 │                     │
│  └────────────────┘  └────────────────┘                     │
│                                                              │
│  LIGHT THEME PALETTE (AppPalette.light)                      │
│  scaffold:    #F5F6F8    textPrimary:   #101214             │
│  surface:     #FFFFFF    textSecondary: #6F7378             │
│  surfaceMuted:#F3F5F7    textTertiary:  #9A9FA4             │
│  border:      #E9E9E9    iconPrimary:   #101214             │
│  divider:     #E7E9EC    iconMuted:     #8C8C8C             │
│                                                              │
│  DARK THEME PALETTE (AppPalette.dark)                        │
│  scaffold:    #101214    textPrimary:   #FFFFFF             │
│  surface:     #1A1D20    textSecondary: #B7BDC3             │
│  surfaceMuted:#22262B    textTertiary:  #7E868D             │
│  border:      #2A2E33    iconPrimary:   #FFFFFF             │
│  divider:     #2A2E33    iconMuted:     #A5ABB1             │
│                                                              │
│  TOP PICK HERO CARD                                          │
│  ┌──────────────────────────────────┐                       │
│  │▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│                       │
│  │▓  Teal Gradient #0EA5A4→#0C8A89 ▓│                       │
│  │▓  "Top Pick for you" badge       ▓│                       │
│  │▓  White text, translucent pills  ▓│                       │
│  │▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│                       │
│  └──────────────────────────────────┘                       │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### Theme Switching

```
┌─────────────┐    toggleTheme()    ┌─────────────┐
│  Light Mode │◀───────────────────▶│  Dark Mode   │
│             │    Get.change       │              │
│  AppTheme   │    ThemeMode()      │  AppTheme    │
│  .light     │                     │  .dark       │
│             │    Persisted via    │              │
│  #F7F8F9 bg │    GetStorage       │  #101214 bg  │
└─────────────┘    'isDarkMode'     └─────────────┘
```

---

## Getting Started

### Prerequisites

```
┌──────────────────────────────────────────┐
│  REQUIREMENTS                             │
├──────────────────────────────────────────┤
│  Flutter SDK     ≥ 3.44.0 (stable)       │
│  Dart SDK        ≥ 3.12.0                │
│  Android Studio  ≥ 2024.1 (for Android)  │
│  Xcode           ≥ 16.0 (for iOS/macOS)  │
│  Chrome          Latest (for web)        │
│  Java            17 (Zulu recommended)   │
└──────────────────────────────────────────┘
```

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/<your-org>/jobodia_frontend.git
cd jobodia_frontend

# 2. Install dependencies
flutter pub get

# 3. Verify setup
flutter doctor

# 4. Run static analysis
flutter analyze

# 5. Run tests
flutter test
```

---

## Running the App

```bash
# Android emulator or device
flutter run

# iOS simulator or device
flutter run -d ios

# Chrome (web)
flutter run -d chrome

# Specific device
flutter devices           # list connected devices
flutter run -d <device_id>
```

### Build Commands

```bash
# Android APK (release)
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (requires macOS + Xcode)
flutter build ios --release

# Web
flutter build web
```

---

## CI/CD

```
┌──────────────────────────────────────────────────────────────────┐
│                    CI PIPELINE (GitHub Actions)                    │
│                                                                   │
│   Push / PR to main                                               │
│        │                                                          │
│        ▼                                                          │
│   ┌──────────────┐                                               │
│   │   Checkout   │                                               │
│   └──────┬───────┘                                               │
│          ▼                                                        │
│   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐        │
│   │ Setup Java   │──▶│ Setup Flutter │──▶│ pub get      │        │
│   │ (Zulu 17)    │   │ (3.44 stable)│   │              │        │
│   └──────────────┘   └──────────────┘   └──────┬───────┘        │
│                                                 ▼                │
│   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐        │
│   │ dart format  │──▶│flutter analyze│──▶│ flutter test │        │
│   │ --set-exit   │   │              │   │              │        │
│   └──────────────┘   └──────────────┘   └──────┬───────┘        │
│                                                 │                │
│                                                 ▼                │
│                                        ┌──────────────┐         │
│                                        │   Telegram   │         │
│                                        │  Notification│         │
│                                        │ (✅ or ❌)    │         │
│                                        └──────────────┘         │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘
```

The CI pipeline runs on every push and PR to `main`:

| Step | Command | Purpose |
|------|---------|---------|
| Format | `dart format --output=none --set-exit-if-changed .` | Enforce consistent style |
| Analyze | `flutter analyze` | Static analysis, lint rules |
| Test | `flutter test` | Run widget/unit tests |
| Notify | Telegram bot | Push build status to team channel |

---

## Security

See **[fix_todo.md](fix_todo.md)** for the full security audit report and remediation checklist.

### Current Security Posture

```
┌──────────────────────────────────────────────────────────────────┐
│                     SECURITY STATUS                               │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ✅ CLEAN                        ⚠️  NEEDS WORK                  │
│  ├─ No stack traces exposed      ├─ Hardcoded demo credentials   │
│  ├─ No debug logging             ├─ GetStorage is unencrypted    │
│  ├─ iOS ATS fully enforced       ├─ No password strength rules   │
│  ├─ No WebView / XSS vectors     ├─ Missing .gitignore entries   │
│  ├─ No deep link handling         ├─ No R8/ProGuard minification │
│  ├─ No analytics SDK leaking PII ├─ Fake biometric toggles       │
│  └─ CI secrets via GH Actions    └─ No secure storage (yet)     │
│                                                                   │
│  📋 Full audit: 15 findings across CRITICAL/HIGH/MEDIUM/LOW      │
│  📄 See fix_todo.md for agent-ready fix prompts                  │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘
```

---

## Roadmap

```
┌──────────────────────────────────────────────────────────────────┐
│                        ROADMAP                                    │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│  PHASE 1 — Security & Foundation (Now)                           │
│  ├─ [ ] Fix all CRITICAL security issues (fix_todo.md)          │
│  ├─ [ ] Replace GetStorage with flutter_secure_storage          │
│  ├─ [ ] Add password strength validation                        │
│  └─ [ ] Remove hardcoded credentials                            │
│                                                                   │
│  PHASE 2 — Backend Integration                                   │
│  ├─ [ ] Add dio HTTP client with interceptors                   │
│  ├─ [ ] Connect to Spring Boot API                              │
│  ├─ [ ] Implement JWT auth with refresh tokens                  │
│  ├─ [ ] Real job listings, search, and filtering                │
│  └─ [ ] Push notifications (Firebase Cloud Messaging)           │
│                                                                   │
│  PHASE 3 — AI & Intelligence                                     │
│  ├─ [ ] Real AI chat (OpenAI / Gemini API)                      │
│  ├─ [ ] Smart job matching algorithm                            │
│  ├─ [ ] CV analysis & improvement suggestions                   │
│  └─ [ ] Interview question generation                           │
│                                                                   │
│  PHASE 4 — Polish & Scale                                        │
│  ├─ [ ] Biometric authentication (local_auth)                   │
│  ├─ [ ] Deep linking (app_links)                                │
│  ├─ [ ] Offline mode with sync                                  │
│  ├─ [ ] Analytics (Firebase Analytics)                          │
│  ├─ [ ] Error tracking (Sentry / Crashlytics)                   │
│  └─ [ ] App Store / Play Store submission                       │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘
```

---

## Contributing

### Branch Strategy

```
main ───────────────────────────────────────────────▶
  │
  ├── feature/auth-backend      ← new features
  ├── feature/ai-chat-integration
  ├── fix/security-hardening    ← bug fixes
  └── refactor/storage-layer    ← refactors
```

### Code Style

- **Dart format:** `dart format .` (enforced in CI)
- **Linting:** `flutter_lints` rules via `analysis_options.yaml`
- **Naming:** `camelCase` for variables/methods, `PascalCase` for classes, `snake_case` for files
- **GetX pattern:** Controllers extend `GetxController`, views use `GetView<T>` or `StatelessWidget`
- **Reactive state:** Use `Rx` types + `Obx()` for UI binding

### Commit Convention

```
feat: add AI chat session history
fix: prevent crash on corrupted storage data
refactor: extract theme colors to AppPalette
chore: update Flutter to 3.44.0
docs: add security audit to README
```

### Pull Request Checklist

```
┌─────────────────────────────────────────┐
│  PR CHECKLIST                           │
├─────────────────────────────────────────┤
│  [ ] dart format --set-exit-if-changed  │
│  [ ] flutter analyze (0 issues)         │
│  [ ] flutter test (all passing)         │
│  [ ] No hardcoded secrets               │
│  [ ] Dark mode tested                   │
│  [ ] Screenshots attached (if UI)       │
└─────────────────────────────────────────┘
```

---

<p align="center">
  Made with 💜 by the Jobodia Team
</p>
