# Fonts Directory

## 📝 Note

This project uses **Google Fonts** package for typography, which automatically downloads and caches fonts.

The fonts referenced in `pubspec.yaml` are placeholders. You can either:

1. **Use Google Fonts (Recommended - Current Setup)**
   - No manual font files needed
   - Fonts are automatically downloaded
   - Already configured in the app

2. **Add Custom Fonts (Optional)**
   - Download Roboto font files from Google Fonts
   - Place them in this directory:
     - `Roboto-Regular.ttf`
     - `Roboto-Medium.ttf`
     - `Roboto-Bold.ttf`
   - The app will use local fonts instead

## 🔗 Google Fonts

Current implementation uses:
- **Roboto** - Primary font family
- Automatically loaded via `google_fonts` package
- No manual font files required

## 📦 Adding Custom Fonts

If you want to add custom fonts:

1. Place font files (.ttf or .otf) in this directory
2. Update `pubspec.yaml`:
```yaml
fonts:
  - family: YourFontName
    fonts:
      - asset: fonts/YourFont-Regular.ttf
      - asset: fonts/YourFont-Bold.ttf
        weight: 700
```
3. Run `flutter pub get`
4. Use in code:
```dart
Text(
  'Hello',
  style: TextStyle(fontFamily: 'YourFontName'),
)
```

## ✅ Current Status

✓ Google Fonts package configured
✓ Roboto font family in use
✓ No manual font files needed
