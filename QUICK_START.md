# SmartERP - Quick Start Guide

## 🚀 Get Started in 3 Minutes

### Step 1: Install Dependencies (30 seconds)

```bash
cd "/run/media/ritesh/Project Data/Flutter Projects/Siddhivinayak Enterprise/smarterp"
flutter pub get
```

### Step 2: Run the App (10 seconds)

```bash
flutter run
```

### Step 3: Login (5 seconds)

```
Email: ritesh.work.1510@gmail.com
Password: 8980614160@.com
```

**That's it! You're in! 🎉**

---

## 📱 What You'll See

### 1. Login Screen
- Professional animated login interface
- Email and password fields with validation
- Smooth transitions

### 2. Dashboard
- Welcome message
- 8 metric cards showing business data
- Quick action buttons
- Responsive grid layout

### 3. Navigation
- **Desktop:** Permanent sidebar on the left
- **Tablet:** Collapsible sidebar
- **Mobile:** Drawer menu

### 4. Available Modules
- 📊 Dashboard - Business overview
- 📦 Products - Inventory management
- 💰 Finance - Financial dashboard
- 🚚 Transport - Trip management
- 🧾 Invoices - Billing system
- 💳 Expenses - Expense tracking
- 👥 Payroll - Employee management
- 📈 Reports - Analytics
- ⚙️ Settings - App configuration

---

## 🎨 Try These Features

### Change Theme
1. Click on your profile (top right)
2. Go to Settings
3. Select a theme:
   - Light Theme
   - Dark Theme
   - Business Blue
   - Professional Green

### Test Responsive Design
- Resize your window
- Watch the sidebar adapt:
  - Wide: Permanent sidebar
  - Medium: Collapsible sidebar
  - Narrow: Drawer menu

### Explore Modules
- Click any menu item
- Each module has a dedicated screen
- Empty states show where data will appear

### Logout
1. Click your profile (top right)
2. Select "Logout"
3. Confirm logout
4. Returns to login screen

---

## 🔧 Quick Commands

### Run on Specific Device

```bash
# List available devices
flutter devices

# Run on Android
flutter run -d android

# Run on iOS
flutter run -d ios

# Run on Chrome
flutter run -d chrome

# Run on Windows
flutter run -d windows
```

### Development Commands

```bash
# Hot reload (while app is running)
Press 'r' in terminal

# Hot restart (while app is running)
Press 'R' in terminal

# Quit app
Press 'q' in terminal

# Clean build
flutter clean
flutter pub get
flutter run
```

### Build Commands

```bash
# Build Android APK
flutter build apk

# Build iOS
flutter build ios

# Build Web
flutter build web

# Build Windows
flutter build windows
```

---

## 📊 Project Structure Overview

```
lib/
├── core/                    # Core infrastructure
│   ├── constants/           # App constants
│   ├── routes/              # Navigation
│   ├── widgets/             # Reusable widgets
│   ├── models/              # Data models
│   ├── services/            # Business logic
│   ├── theme/               # Theme system
│   └── storage/             # Local storage
│
├── modules/                 # Feature modules
│   ├── auth/                # Login/Logout
│   ├── dashboard/           # Main dashboard
│   ├── products/            # Products module
│   ├── finance/             # Finance module
│   ├── transport/           # Transport module
│   ├── invoice/             # Invoice module
│   ├── expenses/            # Expenses module
│   ├── payroll/             # Payroll module
│   ├── reports/             # Reports module
│   └── settings/            # Settings module
│
└── main.dart                # App entry point
```

---

## 🎯 Key Features to Test

### ✅ Authentication
- [x] Login with credentials
- [x] Session persistence (close and reopen app)
- [x] Auto-login on restart
- [x] Logout functionality

### ✅ Navigation
- [x] Click all menu items
- [x] Check active route highlighting
- [x] Test back navigation
- [x] Verify smooth transitions

### ✅ Themes
- [x] Switch between 4 themes
- [x] Verify theme persists after restart
- [x] Check all screens in each theme

### ✅ Responsive
- [x] Test on different screen sizes
- [x] Verify sidebar behavior
- [x] Check mobile drawer
- [x] Test tablet collapsible sidebar

### ✅ Dashboard
- [x] View all metric cards
- [x] Check quick actions
- [x] Verify responsive grid
- [x] Test animations

---

## 🐛 Troubleshooting

### Issue: Dependencies not installing

```bash
flutter clean
rm pubspec.lock
flutter pub get
```

### Issue: App not running

```bash
# Check Flutter installation
flutter doctor

# Check connected devices
flutter devices

# Run with verbose logging
flutter run -v
```

### Issue: Hot reload not working

```bash
# Press 'R' for hot restart
# Or restart the app completely
```

### Issue: Build errors

```bash
flutter clean
flutter pub get
flutter run
```

---

## 📚 Documentation

### Available Docs
- **README.md** - Project overview
- **ARCHITECTURE.md** - Architecture details
- **SETUP_GUIDE.md** - Detailed setup
- **PROJECT_SUMMARY.md** - Complete summary
- **VERIFICATION.md** - Quality verification
- **QUICK_START.md** - This guide

### Code Documentation
- Inline comments in complex logic
- Class-level documentation
- Method documentation
- Well-organized structure

---

## 💡 Tips

### Development Tips
1. Use hot reload ('r') for quick UI changes
2. Use hot restart ('R') for logic changes
3. Check terminal for errors
4. Use Flutter DevTools for debugging

### Testing Tips
1. Test on multiple screen sizes
2. Try all themes
3. Test navigation thoroughly
4. Verify data persistence

### Performance Tips
1. Use const constructors
2. Avoid unnecessary rebuilds
3. Dispose controllers properly
4. Monitor memory usage

---

## 🎓 Learning Resources

### Flutter
- [Flutter Documentation](https://flutter.dev/docs)
- [Flutter Cookbook](https://flutter.dev/docs/cookbook)
- [Flutter YouTube](https://www.youtube.com/c/flutterdev)

### Dart
- [Dart Documentation](https://dart.dev/guides)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)

### This Project
- Read ARCHITECTURE.md for design patterns
- Check PROJECT_SUMMARY.md for features
- Review code for best practices

---

## 📞 Support

### Need Help?
- Check documentation files
- Review error messages
- Search Flutter documentation
- Contact: ritesh.work.1510@gmail.com

### Found a Bug?
- Check VERIFICATION.md for known issues
- Review error logs
- Contact developer

---

## 🎉 Success Checklist

After running the app, verify:

- [ ] App launches successfully
- [ ] Login screen appears
- [ ] Can login with credentials
- [ ] Dashboard loads
- [ ] All menu items work
- [ ] Can switch themes
- [ ] Responsive design works
- [ ] Can logout
- [ ] Session persists on restart

**All checked? Congratulations! 🎊**

---

## 🚀 What's Next?

### Explore
1. Navigate through all modules
2. Try different themes
3. Test responsive layouts
4. Check dashboard metrics

### Customize
1. Modify theme colors
2. Add new widgets
3. Extend functionality
4. Add your data

### Develop
1. Read ARCHITECTURE.md
2. Understand the patterns
3. Plan Phase 2 features
4. Start building!

---

## 📊 Quick Reference

### Login Credentials
```
Email: ritesh.work.1510@gmail.com
Password: 8980614160@.com
```

### Hot Keys (while running)
```
r - Hot reload
R - Hot restart
p - Performance overlay
P - Debug paint
i - Widget inspector
q - Quit
```

### Common Commands
```bash
flutter pub get          # Install dependencies
flutter run              # Run app
flutter clean            # Clean build
flutter doctor           # Check setup
flutter devices          # List devices
flutter build apk        # Build Android
```

---

## ✨ Features at a Glance

| Feature | Status | Description |
|---------|--------|-------------|
| Authentication | ✅ | Local auth with session |
| Dashboard | ✅ | Business metrics overview |
| Navigation | ✅ | GoRouter with guards |
| Themes | ✅ | 4 professional themes |
| Responsive | ✅ | Mobile, tablet, desktop |
| Storage | ✅ | Hive + SharedPreferences |
| State | ✅ | Provider pattern |
| Widgets | ✅ | 10+ reusable components |
| Models | ✅ | 6 complete data models |
| Modules | ✅ | 8 feature modules |

---

## 🎯 Mission

**Build a production-grade ERP system with Flutter**

**Status:** ✅ Phase 1 Complete

**Next:** Phase 2 - Backend Integration

---

**Happy Coding! 🚀**

**SmartERP - Enterprise Resource Planning Made Simple**
