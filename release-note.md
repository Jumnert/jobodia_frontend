# Build Release v0.2 | 0.2.2026

**APK:** `build/app/outputs/flutter-apk/app-release.apk`  
**Package version:** `1.0.0+1`

## Added

- UAT notice for guest access, followed by role selection and a Next step.
- Settings → Testing performance overlay with draggable live frame-time and engine-load graphs.
- AI chat animated green response backdrop and compact Forui model menu.
- Forui dialogs for avatar options, Face ID, logout, UAT notice, and job application confirmation.

## Fixed

- Android launch configuration crash caused by the MainActivity package path.
- Job-detail drawer dismissal, close control, content layout, and Apply Now dialog overflow.
- Chat header/model selector overflow and chat state persistence across tab changes.
- Onboarding full-screen layout, safe-area button placement, dark mode, artwork treatment, and looping progress.
- About Us card spacing and responsive content layout.

## Improved

- Selected role cards use the Jobodia green accent with layered visual depth.
- Bottom navigation and chatbot composer spacing were refined for mobile devices.
- Profile photo presentation is circular and profile photo options use Forui UI.

## Notes

- The performance overlay's frame graph uses Flutter build and raster timings. Its CPU value is an engine-load estimate because Flutter does not expose native process CPU usage directly.
- This is a UAT/testing build. Some functionality may still be incomplete or change during testing.
