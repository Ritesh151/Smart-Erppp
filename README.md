# Siddhivinayak Enterprise - Enterprise Resource Planning System

## 🎯 Overview

Siddhivinayak Enterprise is a production-grade, enterprise-level Flutter ERP frontend application designed for comprehensive business management. Built with clean architecture principles, SOLID design patterns, and scalable infrastructure.

## ✨ Features

### Phase 1 - Foundation Architecture (Current)

- **Authentication System**
  - Local authentication with fixed credentials
  - Session management with auto-login
  - Secure logout with session cleanup

- **Dashboard**
  - Real-time business metrics
  - Revenue, expenses, and profit tracking
  - Quick action shortcuts
  - Responsive grid layout

- **Module Screens**
  - Products Management
  - Finance Dashboard
  - Transport Operations
  - Bills & Invoices
  - Expense Tracking
  - Payroll Management
  - Reports & Analytics
  - Settings & Configuration

- **Theme System**
  - Light Theme
  - Dark Theme
  - Business Blue Theme
  - Professional Green Theme
  - Persistent theme selection

- **Responsive Design**
  - Mobile-first approach
  - Tablet optimization
  - Desktop layout
  - Adaptive sidebar (permanent/collapsible/drawer)

## 🏗️ Architecture

### Clean Architecture Layers

```
lib/
├── core/                          # Core application infrastructure
│   ├── constants/                 # App-wide constants
│   │   ├── app_constants.dart
│   │   └── storage_keys.dart
│   ├── routes/                    # Navigation configuration
│   │   ├── app_routes.dart
│   │   └── app_router.dart
│   ├── widgets/                   # Reusable UI components
│   │   ├── app_button.dart
│   │   ├── app_text_field.dart
│   │   ├── app_card.dart
│   │   ├── app_dialog.dart
│   │   ├── app_shell.dart
│   │   ├── sidebar_menu.dart
│   │   ├── dashboard_card.dart
│   │   ├── loading_widget.dart
│   │   └── empty_state_widget.dart
│   ├── models/                    # Data models
│   │   ├── user_model.dart
│   │   ├── product_model.dart
│   │   ├── invoice_model.dart
│   │   ├── employee_model.dart
│   │   ├── expense_model.dart
│   │   └── transport_model.dart
│   ├── services/                  # Business logic services
│   │   └── auth_service.dart
│   ├── theme/                     # Theme configuration
│   │   ├── app_theme.dart
│   │   └── theme_extensions.dart
│   ├── utils/                     # Utility functions
│   │   └── logger.dart
│   ├── extensions/                # Dart extensions
│   │   ├── context_extensions.dart
│   │   ├── string_extensions.dart
│   │   └── date_extensions.dart
│   ├── exceptions/                # Custom exceptions
│   │   └── app_exception.dart
│   ├── responsive/                # Responsive utilities
│   │   ├── breakpoints.dart
│   │   └── responsive_builder.dart
│   └── storage/                   # Storage layer
│       ├── storage_service.dart
│       └── preferences_service.dart
│
└── modules/                       # Feature modules
    ├── auth/                      # Authentication module
    │   ├── providers/
    │   │   └── auth_provider.dart
    │   └── screens/
    │       └── login_screen.dart
    ├── dashboard/                 # Dashboard module
    │   └── screens/
    │       └── dashboard_screen.dart
    ├── products/                  # Products module
    │   └── screens/
    │       └── products_screen.dart
    ├── finance/                   # Finance module
    │   └── screens/
    │       └── finance_screen.dart
    ├── transport/                 # Transport module
    │   └── screens/
    │       └── transport_screen.dart
    ├── invoice/                   # Invoice module
    │   └── screens/
    │       └── invoices_screen.dart
    ├── expenses/                  # Expenses module
    │   └── screens/
    │       └── expenses_screen.dart
    ├── payroll/                   # Payroll module
    │   └── screens/
    │       └── payroll_screen.dart
    ├── reports/                   # Reports module
    │   └── screens/
    │       └── reports_screen.dart
    └── settings/                  # Settings module
        ├── providers/
        │   └── theme_provider.dart
        └── screens/
            └── settings_screen.dart
```

## 🔧 Technology Stack

### State Management
- **Provider** - Lightweight, scalable state management

### Local Storage
- **SharedPreferences** - Key-value storage for preferences
- **Hive** - Fast, lightweight NoSQL database

### Navigation
- **GoRouter** - Declarative routing with deep linking support

### UI/UX
- **Material Design 3** - Modern, accessible design system
- **Google Fonts** - Professional typography
- **Flutter Animate** - Smooth, performant animations

### Architecture Patterns
- **MVC + Service + Provider** - Clear separation of concerns
- **Repository Pattern** - Data access abstraction
- **SOLID Principles** - Maintainable, extensible code
- **Clean Architecture** - Independent, testable layers

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)

### Installation

1. **Clone the repository**
   ```bash
   cd smarterp
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

### Login Credentials

```
Email: ritesh.work.1510@gmail.com
Password: 8980614160@.com
```

## 📱 Responsive Breakpoints

| Device Type      | Width Range        | Layout                    |
|------------------|-------------------|---------------------------|
| Mobile           | < 600px           | Drawer navigation         |
| Tablet           | 600px - 900px     | Collapsible sidebar       |
| Desktop          | 900px - 1200px    | Permanent sidebar         |
| Large Desktop    | > 1200px          | Permanent sidebar (wide)  |

## 🎨 Theme System

### Available Themes

1. **Light Theme** - Clean, professional light interface
2. **Dark Theme** - Eye-friendly dark interface
3. **Business Blue** - Corporate blue color scheme
4. **Professional Green** - Nature-inspired green palette

### Theme Persistence

Themes are automatically saved and restored on app restart using SharedPreferences.

## 🔐 Authentication Flow

```
1. User opens app
   ↓
2. Check stored session
   ↓
3. If valid session exists → Auto-login → Dashboard
   ↓
4. If no session → Login Screen
   ↓
5. User enters credentials
   ↓
6. Validate against fixed credentials
   ↓
7. If valid → Save session → Navigate to Dashboard
   ↓
8. If invalid → Show error message
```

## 📦 Storage Architecture

### SharedPreferences (Key-Value Storage)
- User session state
- Theme preferences
- UI preferences (sidebar state)
- Last login timestamp

### Hive (NoSQL Database)
- Products data
- Invoices data
- Employees data
- Expenses data
- Transport data
- Sales records
- Purchase records
- Settings data

## 🎯 Design Principles

### SOLID Principles
- **Single Responsibility** - Each class has one reason to change
- **Open/Closed** - Open for extension, closed for modification
- **Liskov Substitution** - Subtypes must be substitutable
- **Interface Segregation** - Many specific interfaces over one general
- **Dependency Inversion** - Depend on abstractions, not concretions

### Clean Architecture
- **Independence** - Framework, UI, database, and external agency independent
- **Testability** - Business rules testable without UI, database, or external elements
- **UI Independence** - UI can change without changing the rest of the system
- **Database Independence** - Business rules not bound to the database

## 🔄 State Management Strategy

### Provider Pattern
- **AuthProvider** - Manages authentication state
- **ThemeProvider** - Manages theme state
- Future providers for each module

### State Flow
```
User Action → Provider → Service → Repository → Storage
                ↓
            UI Update (notifyListeners)
```

## 🛡️ Error Handling

### Exception Hierarchy
- `AppException` - Base exception class
- `AuthenticationException` - Authentication errors
- `ValidationException` - Input validation errors
- `StorageException` - Storage operation errors
- `NetworkException` - Network-related errors
- `NotFoundException` - Resource not found errors

### Error Handling Strategy
1. Try-catch blocks at service layer
2. Custom exceptions for specific error types
3. User-friendly error messages
4. Logging for debugging
5. Graceful degradation

## 📊 Performance Optimizations

- **Const Constructors** - Reduced widget rebuilds
- **Lazy Loading** - Load data on demand
- **Efficient State Updates** - Minimal notifyListeners calls
- **Widget Reusability** - DRY principle throughout
- **Memory Management** - Proper disposal of controllers and streams

## 🧪 Code Quality

### Naming Conventions
- **Classes** - PascalCase (e.g., `AuthService`)
- **Files** - snake_case (e.g., `auth_service.dart`)
- **Variables** - camelCase (e.g., `isLoggedIn`)
- **Constants** - camelCase (e.g., `defaultPadding`)
- **Private** - Prefix with underscore (e.g., `_currentUser`)

### Code Organization
- One class per file
- Related files grouped in directories
- Clear separation of concerns
- Consistent file structure across modules

## 🔮 Future Enhancements (Phase 2+)

- Backend API integration
- Real-time data synchronization
- Advanced reporting with charts
- Multi-user support
- Role-based access control
- Data export (PDF, Excel)
- Offline-first architecture
- Push notifications
- Advanced search and filtering
- Batch operations
- Audit logging

## 📝 Development Guidelines

### Adding a New Module

1. Create module directory in `lib/modules/`
2. Add screens, providers, repositories, services
3. Create models in `lib/core/models/`
4. Add routes in `lib/core/routes/`
5. Update navigation in `app_router.dart`
6. Add sidebar menu item

### Adding a New Theme

1. Define theme in `app_theme.dart`
2. Add to `AppThemeMode` enum
3. Create theme extension in `theme_extensions.dart`
4. Update theme selector in settings

### Adding a New Storage Box

1. Add box name to `storage_keys.dart`
2. Initialize in `main.dart`
3. Create service using `StorageService<T>`
4. Add repository layer
5. Connect to provider

## 🤝 Contributing

This is a production-grade enterprise application. Follow the established patterns and architecture when extending functionality.

## 📄 License

Proprietary - Siddhivinayak Enterprise

## 👨‍💻 Developer

**Ritesh**
- Email: ritesh.work.1510@gmail.com

---

**Built with ❤️ using Flutter**
