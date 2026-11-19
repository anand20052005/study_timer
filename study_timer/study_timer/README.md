# Study Timer

Strava-inspired study hours tracker built with Flutter (one codebase for Android and Windows/desktop).

## What it does
- **Record tab:** stopwatch with Start / Pause / Resume / Finish. A ring around the clock shows today's progress toward your daily goal. Pick a subject before starting.
- **Finish** saves the session and adds it to today's total. Running sessions survive app restarts.
- **Week tab:** bar chart of the past 7 days, weekly total, daily average, best day, streak, and time by subject.
- **Activity tab:** feed of every session. Swipe left to delete.
- Data is stored locally on the device (shared_preferences). No login, works offline.

## Run it
1. Install Flutter: https://docs.flutter.dev/get-started/install
2. In this folder, generate the platform folders (only once):
   ```
   flutter create --platforms=android,windows .
   ```
3. Then:
   ```
   flutter pub get
   flutter run            # pick your Android phone/emulator or Windows
   flutter build apk      # installable Android APK
   flutter build windows  # PC version (on Windows)
   ```

## Notes
- A session that crosses midnight is counted on the day it started.
- Subjects list lives in `lib/store.dart` (`subjects`); edit it for your own syllabus.
