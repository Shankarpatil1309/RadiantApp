# Generate App Icon for Radiant App

## Steps to Create and Apply the App Icon

### 1. Create the Icon Image
You need to create a 1024x1024 PNG image named `app_icon.png` in the `assets/images/` directory.

**Option A: Use the SVG Template**
- Open `assets/images/app_icon_template.svg` in a vector graphics editor (Inkscape, Adobe Illustrator, etc.)
- Export as PNG at 1024x1024 resolution
- Save as `assets/images/app_icon.png`

**Option B: Design from Scratch**
- Create a 1024x1024 PNG image following the design guidelines in `APP_ICON_INSTRUCTIONS.md`
- Use the color scheme: Primary #6366F1, Secondary #8B5CF6, Accent #F59E0B
- Include education-related symbols (graduation cap, books, etc.)
- Save as `assets/images/app_icon.png`

**Option C: Quick Online Generation**
- Use an online app icon generator like:
  - https://appicon.co/
  - https://makeappicon.com/
  - https://icon.kitchen/
- Upload a simple design with "R" letter or graduation cap
- Download the generated icon as `app_icon.png`

### 2. Optional: Create Foreground Icon (for Android Adaptive Icons)
Create `assets/images/app_icon_foreground.png` (1024x1024) with just the main symbol (graduation cap) on transparent background.

### 3. Generate Platform-Specific Icons
Run the following command in the project root:

```bash
flutter packages pub run flutter_launcher_icons:main
```

### 4. Verify Installation
Check that icons were generated in:
- `android/app/src/main/res/mipmap-*/` (Android)
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/` (iOS)

### 5. Test the Icon
- Build and install the app on a device/emulator
- Check the home screen for the new icon
- Verify icon appears correctly in app stores

## Current Configuration
The `pubspec.yaml` is already configured with:
- Background color: #6366F1 (indigo)
- Theme color: #4F46E5 (darker indigo)
- Adaptive icon support for Android
- Multi-platform generation (iOS, Android, Web, Windows, macOS)

## Troubleshooting
- If icons don't update: Clean and rebuild the project
- For iOS: You may need to delete and reinstall the app
- For Android: Clear app data or reinstall

## Next Steps After Icon Creation
1. Run `flutter clean`
2. Run `flutter packages pub run flutter_launcher_icons:main`
3. Run `flutter build apk` or `flutter build ios` to test