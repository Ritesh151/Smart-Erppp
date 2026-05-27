# SmartERP Architecture Documentation

## 🏛️ Architecture Overview

SmartERP follows **Clean Architecture** principles combined with **MVC + Service + Provider** pattern for maximum maintainability, testability, and scalability.

## 📐 Architecture Layers

### 1. Presentation Layer (UI)
**Location:** `lib/modules/*/screens/` and `lib/core/widgets/`

**Responsibilities:**
- Display data to users
- Capture user interactions
- Trigger provider methods
- Handle UI state

**Components:**
- Screens (StatefulWidget/StatelessWidget)
- Reusable widgets
- UI-specific logic

**Rules:**
- No business logic
- No direct storage access
- Only communicate with Providers
- Stateless where possible

### 2. Provider Layer (State Management)
**Location:** `lib/modules/*/providers/`

**Responsibilities:**
- Manage UI state
- Coordinate between UI and Services
- Notify listeners on state changes
- Handle loading/error states

**Components:**
- ChangeNotifier classes
- State variables
- UI-facing methods

**Rules:**
- Extend ChangeNotifier
- Call notifyListeners() after state changes
- Handle exceptions from services
- Transform service data for UI

### 3. Service Layer (Business Logic)
**Location:** `lib/core/services/` and `lib/modules/*/services/`

**Responsibilities:**
- Implement business rules
- Coordinate between repositories
- Validate data
- Transform data

**Components:**
- Service classes
- Business logic methods
- Validation logic

**Rules:**
- No UI dependencies
- No direct storage access
- Use repositories for data
- Return domain models

### 4. Repository Layer (Data Access)
**Location:** `lib/modules/*/repositories/`

**Responsibilities:**
- Abstract data sources
- Provide clean API for data access
- Handle data source switching
- Cache management

**Components:**
- Repository classes
- Data source coordination
- Caching logic

**Rules:**
- Single source of truth for data
- Hide storage implementation details
- Return domain models
- Handle data source errors

### 5. Storage Layer (Data Persistence)
**Location:** `lib/core/storage/`

**Responsibilities:**
- Persist data locally
- Provide generic storage operations
- Handle storage errors

**Components:**
- StorageService (Hive wrapper)
- PreferencesService (SharedPreferences wrapper)

**Rules:**
- Generic and reusable
- Type-safe operations
- Proper error handling
- Logging all operations

### 6. Model Layer (Data Models)
**Location:** `lib/core/models/`

**Responsibilities:**
- Define data structures
- Provide serialization/deserialization
- Business logic helpers

**Components:**
- Model classes
- toJson/fromJson methods
- Computed properties

**Rules:**
- Immutable where possible
- Include copyWith methods
- Null-safe implementation
- No external dependencies

## 🔄 Data Flow

### Read Operation Flow
```
UI Widget
    ↓ (reads state)
Provider
    ↓ (calls method)
Service
    ↓ (requests data)
Repository
    ↓ (fetches from)
Storage
    ↓ (returns data)
Repository
    ↓ (transforms to model)
Service
    ↓ (applies business logic)
Provider
    ↓ (updates state, notifyListeners)
UI Widget (rebuilds)
```

### Write Operation Flow
```
UI Widget
    ↓ (user action)
Provider
    ↓ (calls method)
Service
    ↓ (validates & processes)
Repository
    ↓ (saves to)
Storage
    ↓ (confirms)
Repository
    ↓ (returns success)
Service
    ↓ (returns result)
Provider
    ↓ (updates state, notifyListeners)
UI Widget (rebuilds with new state)
```

## 🎯 Design Patterns

### 1. Repository Pattern
**Purpose:** Abstract data source details

**Implementation:**
```dart
class ProductRepository {
  final StorageService<ProductModel> _storage;
  
  Future<List<ProductModel>> getAll() async {
    return _storage.getAll();
  }
  
  Future<void> save(ProductModel product) async {
    await _storage.save(product.id, product);
  }
}
```

### 2. Provider Pattern
**Purpose:** State management and dependency injection

**Implementation:**
```dart
class ProductProvider extends ChangeNotifier {
  final ProductService _service;
  List<ProductModel> _products = [];
  
  Future<void> loadProducts() async {
    _products = await _service.getProducts();
    notifyListeners();
  }
}
```

### 3. Service Pattern
**Purpose:** Encapsulate business logic

**Implementation:**
```dart
class ProductService {
  final ProductRepository _repository;
  
  Future<List<ProductModel>> getProducts() async {
    final products = await _repository.getAll();
    return products.where((p) => p.isActive).toList();
  }
}
```

### 4. Factory Pattern
**Purpose:** Object creation

**Implementation:**
```dart
class ProductModel {
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      // ...
    );
  }
}
```

## 🔐 Authentication Architecture

### Session Management
```
App Start
    ↓
Check SharedPreferences
    ↓
isLoggedIn == true?
    ↓ YES              ↓ NO
Restore Session    Show Login
    ↓
Validate Session
    ↓
Valid?
    ↓ YES              ↓ NO
Dashboard          Login Screen
```

### Authentication Flow
```
Login Screen
    ↓ (email, password)
AuthProvider.login()
    ↓
AuthService.login()
    ↓
Validate Credentials
    ↓
Save to SharedPreferences
    ↓
Update AuthProvider state
    ↓
Router redirects to Dashboard
```

## 🎨 Theme Architecture

### Theme System
```
ThemeProvider (ChangeNotifier)
    ↓
Manages AppThemeMode
    ↓
Provides ThemeData
    ↓
MaterialApp.theme
    ↓
All Widgets
```

### Theme Switching
```
User selects theme
    ↓
ThemeProvider.setTheme()
    ↓
Save to SharedPreferences
    ↓
Update _currentTheme
    ↓
notifyListeners()
    ↓
MaterialApp rebuilds
    ↓
All widgets get new theme
```

## 🧭 Navigation Architecture

### GoRouter Configuration
```
AppRouter
    ↓
Defines routes
    ↓
Implements redirect logic
    ↓
Checks authentication
    ↓
Redirects if needed
    ↓
Builds page with transition
```

### Route Protection
```
User navigates to protected route
    ↓
GoRouter.redirect()
    ↓
Check AuthService.isAuthenticated
    ↓
Authenticated?
    ↓ YES              ↓ NO
Allow access    Redirect to /login
```

## 📱 Responsive Architecture

### Breakpoint System
```
MediaQuery.of(context).size.width
    ↓
< 600px → Mobile
600-900px → Tablet
900-1200px → Desktop
> 1200px → Large Desktop
    ↓
Different layouts per breakpoint
```

### Responsive Widgets
```
ResponsiveBuilder
    ↓
Detects screen size
    ↓
Returns appropriate widget
    ↓
Mobile: Drawer
Tablet: Collapsible Sidebar
Desktop: Permanent Sidebar
```

## 🗄️ Storage Architecture

### Hive Storage
```
Box<T> (Type-safe storage)
    ↓
StorageService<T> (Generic wrapper)
    ↓
Repository (Domain-specific)
    ↓
Service (Business logic)
    ↓
Provider (State management)
    ↓
UI (Display)
```

### SharedPreferences
```
Key-Value pairs
    ↓
PreferencesService (Wrapper)
    ↓
Direct access from Services
    ↓
Used for:
- Session state
- Theme preference
- UI preferences
```

## 🔧 Dependency Injection

### Provider-based DI
```
main.dart
    ↓
MultiProvider
    ↓
Provides:
- PreferencesService
- AuthService
- AuthProvider
- ThemeProvider
    ↓
Available throughout widget tree
    ↓
Access via:
- context.read<T>()
- context.watch<T>()
- Provider.of<T>(context)
```

## 🎭 State Management Strategy

### Local State
**Use:** StatefulWidget
**When:** UI-only state (animations, form inputs)

### App State
**Use:** Provider (ChangeNotifier)
**When:** Shared across widgets, persisted

### Session State
**Use:** SharedPreferences + Provider
**When:** User session, preferences

### Persistent State
**Use:** Hive + Provider
**When:** Business data, offline storage

## 🚀 Performance Optimizations

### Widget Optimization
- Use `const` constructors
- Implement `shouldRebuild` logic
- Minimize widget tree depth
- Use `ListView.builder` for lists

### State Optimization
- Selective `notifyListeners()`
- Use `Consumer` for targeted rebuilds
- Avoid unnecessary state in Provider
- Dispose controllers properly

### Storage Optimization
- Lazy box opening
- Batch operations
- Index frequently queried fields
- Regular cleanup

## 🧪 Testing Strategy

### Unit Tests
- Test models (serialization)
- Test services (business logic)
- Test repositories (data access)
- Test utilities and extensions

### Widget Tests
- Test individual widgets
- Test user interactions
- Test state changes
- Test error states

### Integration Tests
- Test complete flows
- Test navigation
- Test authentication
- Test data persistence

## 📊 Error Handling Strategy

### Exception Hierarchy
```
AppException (base)
    ↓
├── AuthenticationException
├── ValidationException
├── StorageException
├── NetworkException
└── NotFoundException
```

### Error Flow
```
Storage/Service throws exception
    ↓
Repository catches and logs
    ↓
Service catches and transforms
    ↓
Provider catches and updates error state
    ↓
UI displays error message
```

## 🔄 Future Architecture Considerations

### Microservices Ready
- Repository layer abstracts data source
- Easy to add API repositories
- Service layer remains unchanged

### Offline-First
- Hive provides local storage
- Add sync service layer
- Implement conflict resolution

### Multi-tenant
- Add tenant context to services
- Filter data by tenant
- Tenant-specific themes

### Scalability
- Modular architecture allows parallel development
- Clear boundaries between modules
- Easy to split into packages

## 📝 Architecture Decisions

### Why Provider over Bloc/Riverpod?
- Simpler learning curve
- Less boilerplate
- Sufficient for current requirements
- Easy migration path if needed

### Why Hive over SQLite?
- Faster for key-value storage
- No SQL overhead
- Type-safe
- Better for offline-first

### Why GoRouter over Navigator 2.0?
- Declarative routing
- Deep linking support
- Type-safe navigation
- Better route management

### Why Clean Architecture?
- Testability
- Maintainability
- Scalability
- Independence from frameworks

---

This architecture provides a solid foundation for enterprise-grade application development while maintaining flexibility for future enhancements.
