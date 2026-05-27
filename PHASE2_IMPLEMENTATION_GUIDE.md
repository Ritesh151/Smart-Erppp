# SmartERP Phase 2 - Implementation Guide

## 🎯 Phase 2 Overview

This guide provides the complete implementation roadmap for Phase 2, building upon the Phase 1 foundation.

## ✅ Files Created So Far

### Models
- ✅ `transaction_model.dart` - Transaction data model with Hive annotations
- ✅ `finance_summary_model.dart` - Finance calculations model
- ✅ Enhanced `product_model.dart` - Added Hive annotations, GST, HSN, image support

### Repositories
- ✅ `product_repository.dart` - Complete CRUD + search/filter operations

### Services
- ✅ `product_service.dart` - Business logic with validation

### Providers
- ✅ `product_provider.dart` - State management with search/filter/sort

## 📋 Remaining Implementation Tasks

### 1. Complete Product Module Screens

#### A. Products List Screen (Enhanced)
**File:** `lib/modules/products/screens/products_screen.dart`

**Features to implement:**
```dart
- Advanced data table with sorting
- Search bar with real-time filtering
- Category filter dropdown
- Stock status filter (In Stock/Low Stock/Out of Stock)
- Price range filter
- Pagination (20 items per page)
- Product cards for mobile view
- Floating action button for "Add Product"
- Pull-to-refresh
- Empty state when no products
- Loading shimmer effect
- Stock status color indicators:
  * Green: In Stock
  * Orange: Low Stock
  * Red: Out of Stock
```

**Layout:**
```
Desktop: Data Table with columns
- Image thumbnail
- Product Name
- HSN Code
- Category
- Price (with GST)
- Stock Quantity
- Status Badge
- Actions (View/Edit/Delete)

Mobile: Product Cards
- Image
- Name
- Price
- Stock badge
- Tap to view details
```

#### B. Product Form Screen
**File:** `lib/modules/products/screens/product_form_screen.dart`

**Form Fields:**
```dart
1. Product Name* (TextFormField)
2. HSN Code (TextFormField with validation)
3. Category* (Dropdown or Autocomplete)
4. Price* (Number input, min: 0.01)
5. Cost Price* (Number input)
6. Stock Quantity* (Integer input, min: 0)
7. Minimum Stock Level* (Integer input)
8. GST Rate* (Dropdown: 0%, 5%, 12%, 18%, 28%)
9. Unit* (Dropdown: Piece, Kg, Liter, Box, etc.)
10. SKU (Optional text)
11. Barcode (Optional text)
12. Description (Multi-line text)
13. Product Image (Image picker)
```

**Validation Rules:**
```dart
- Product name: Required, min 2 chars, unique
- Price: Required, > 0, max 2 decimal places
- Cost Price: Required, >= 0
- Stock: Required, >= 0, integer only
- GST Rate: Required, 0-100
- HSN Code: Optional, 4-8 digits
- Duplicate name check before save
```

**Image Handling:**
```dart
- Use image_picker package
- Support camera and gallery
- Compress images before saving
- Store in app documents directory
- Generate unique filename
- Show image preview
- Allow image removal
- Default placeholder if no image
```

#### C. Product Detail Screen
**File:** `lib/modules/products/screens/product_detail_screen.dart`

**Sections:**
```dart
1. Product Image (large, zoomable)
2. Product Information Card
   - Name
   - HSN Code
   - SKU
   - Barcode
   - Category
3. Pricing Card
   - Cost Price
   - Selling Price
   - GST Rate
   - Price with GST
   - Profit Margin
   - Profit %
4. Stock Information Card
   - Current Stock
   - Minimum Level
   - Stock Status Badge
   - Unit
5. Description Card
6. Metadata
   - Created Date
   - Last Updated
7. Action Buttons
   - Edit Product
   - Delete Product (with confirmation)
   - Update Stock (quick action)
```

### 2. Enhanced Dashboard Implementation

#### File: `lib/modules/dashboard/screens/dashboard_screen.dart`

**Replace existing dashboard with:**

**Section 1: Metrics Grid (Top)**
```dart
Row of 4 DashboardCard widgets:

1. Total Sales Card
   - Icon: trending_up
   - Value: ₹12,45,890
   - Subtitle: +12.5% from last month
   - Color: Green
   - Calculate from transactions (type: sale)

2. Net Profit Card
   - Icon: account_balance_wallet
   - Value: ₹4,13,440
   - Subtitle: Profit margin: 33.2%
   - Color: Blue
   - Formula: Total Sales - Total Purchases - Total Expenses

3. Total Inventory Value Card
   - Icon: inventory_2
   - Value: ₹8,45,230
   - Subtitle: 156 products
   - Color: Purple
   - Formula: Σ(Product Price × Stock Quantity)

4. Total Purchases Card
   - Icon: shopping_cart
   - Value: ₹6,32,450
   - Subtitle: +5.2% from last month
   - Color: Orange
   - Calculate from transactions (type: purchase)
```

**Section 2: Quick Actions (Below Metrics)**
```dart
Responsive Grid of Action Cards:

1. Create Invoice
   - Icon: receipt_long
   - Navigate to: /invoices/create

2. Manage Products
   - Icon: inventory_2
   - Navigate to: /products

3. Record Purchase
   - Icon: shopping_bag
   - Navigate to: /purchases/create

4. Transport
   - Icon: local_shipping
   - Navigate to: /transport

5. View Reports
   - Icon: assessment
   - Navigate to: /reports

6. Manage Payroll
   - Icon: people
   - Navigate to: /payroll

Layout:
- Desktop: 3 columns
- Tablet: 2 columns
- Mobile: 1 column

Each card:
- Hover effect (scale + shadow)
- Ripple on tap
- Icon with background circle
- Title
- Subtitle/description
```

**Section 3: Payment Due Monitoring**
```dart
Row of 3 Status Cards:

1. Overdue Payments
   - Count: 5
   - Amount: ₹1,23,450
   - Color: Red
   - Icon: error
   - Progress indicator

2. Due Soon (Next 7 days)
   - Count: 12
   - Amount: ₹2,45,670
   - Color: Orange
   - Icon: warning
   - Progress indicator

3. Paid This Month
   - Count: 45
   - Amount: ₹8,90,120
   - Color: Green
   - Icon: check_circle
   - Progress indicator
```

**Section 4: Recent Activities**
```dart
Scrollable List Widget:

Display last 10 activities:
- Recent invoices created
- Products added/updated
- Expenses recorded
- Payroll processed
- Transport trips

Each activity item:
- Icon (based on type)
- Title
- Description
- Time ago (e.g., "2 hours ago")
- Tap to view details

Use ListView.builder
Implement pull-to-refresh
```

**Section 5: Analytics Charts**
```dart
Use fl_chart package

Chart 1: Sales Trend (Line Chart)
- X-axis: Last 7 days
- Y-axis: Sales amount
- Show data points
- Gradient fill
- Responsive height

Chart 2: Inventory Distribution (Pie Chart)
- By category
- Show percentages
- Interactive legend
- Color-coded

Chart 3: Expense Overview (Bar Chart)
- By category
- Last 30 days
- Horizontal bars
- Show values

Chart 4: Profit/Loss Trend (Line Chart)
- Monthly data
- Dual line (Revenue vs Expenses)
- Show profit area in green
- Loss area in red

Layout:
- Desktop: 2x2 grid
- Tablet: 2x1 grid (scrollable)
- Mobile: 1 column (scrollable)
```

### 3. Finance Module Implementation

#### A. Finance Service
**File:** `lib/modules/finance/services/finance_service.dart`

```dart
class FinanceService {
  // Calculate total sales from transactions
  Future<double> calculateTotalSales(DateTime? startDate, DateTime? endDate);
  
  // Calculate total purchases
  Future<double> calculateTotalPurchases(DateTime? startDate, DateTime? endDate);
  
  // Calculate total expenses
  Future<double> calculateTotalExpenses(DateTime? startDate, DateTime? endDate);
  
  // Calculate net profit
  Future<double> calculateNetProfit(DateTime? startDate, DateTime? endDate);
  
  // Get finance summary
  Future<FinanceSummaryModel> getFinanceSummary(DateTime? startDate, DateTime? endDate);
  
  // Get transactions by type
  Future<List<TransactionModel>> getTransactionsByType(TransactionType type);
  
  // Get transactions by date range
  Future<List<TransactionModel>> getTransactionsByDateRange(DateTime start, DateTime end);
  
  // Get monthly summary
  Future<Map<String, double>> getMonthlySummary(int year);
}
```

#### B. Finance Provider
**File:** `lib/modules/finance/providers/finance_provider.dart`

```dart
class FinanceProvider extends ChangeNotifier {
  FinanceSummaryModel _summary;
  List<TransactionModel> _transactions;
  bool _isLoading;
  
  // Load finance summary
  Future<void> loadSummary();
  
  // Load transactions
  Future<void> loadTransactions();
  
  // Filter by date range
  void filterByDateRange(DateTime start, DateTime end);
  
  // Filter by type
  void filterByType(TransactionType type);
  
  // Refresh data
  Future<void> refresh();
}
```

#### C. Finance Screen
**File:** `lib/modules/finance/screens/finance_screen.dart`

**Layout:**
```dart
1. Summary Cards Row
   - Total Sales
   - Total Purchases
   - Net Revenue
   - Total Profit

2. Date Range Filter
   - Start Date Picker
   - End Date Picker
   - Quick filters (Today, This Week, This Month, This Year)

3. Transaction Type Tabs
   - All
   - Sales
   - Purchases
   - Expenses
   - Income

4. Transactions List
   - Date
   - Description
   - Type badge
   - Amount
   - Reference ID
   - Tap to view details

5. Charts Section
   - Monthly trend chart
   - Category-wise breakdown
   - Profit/Loss chart
```

### 4. Search & Filter Engine

#### File: `lib/core/widgets/search_filter_bar.dart`

```dart
class SearchFilterBar extends StatelessWidget {
  final String searchQuery;
  final Function(String) onSearchChanged;
  final List<FilterOption> filters;
  final Function(FilterOption) onFilterSelected;
  final Function() onClearFilters;
  
  // Features:
  // - Search text field with debounce
  // - Filter chips
  // - Sort dropdown
  // - Clear all button
  // - Responsive layout
}
```

### 5. Image Management

#### File: `lib/core/services/image_service.dart`

```dart
class ImageService {
  // Pick image from camera
  Future<String?> pickFromCamera();
  
  // Pick image from gallery
  Future<String?> pickFromGallery();
  
  // Compress image
  Future<File> compressImage(File image);
  
  // Save image to local storage
  Future<String> saveImage(File image);
  
  // Delete image
  Future<void> deleteImage(String path);
  
  // Get image file
  File? getImage(String? path);
}
```

### 6. Analytics Widgets

#### File: `lib/core/widgets/charts/sales_trend_chart.dart`
```dart
- Line chart showing sales over time
- Use fl_chart LineChart
- Responsive sizing
- Touch interactions
```

#### File: `lib/core/widgets/charts/inventory_pie_chart.dart`
```dart
- Pie chart for inventory distribution
- Category-wise breakdown
- Interactive legend
- Percentage labels
```

#### File: `lib/core/widgets/charts/expense_bar_chart.dart`
```dart
- Bar chart for expenses
- Category comparison
- Horizontal or vertical bars
- Value labels
```

#### File: `lib/core/widgets/charts/profit_loss_chart.dart`
```dart
- Line chart with dual lines
- Revenue vs Expenses
- Profit area highlighted
- Loss area highlighted
```

### 7. Additional Widgets

#### File: `lib/core/widgets/metric_card.dart`
```dart
class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final Widget? trailing;
  
  // Animated counter
  // Gradient background option
  // Responsive sizing
}
```

#### File: `lib/core/widgets/activity_item.dart`
```dart
class ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final DateTime timestamp;
  final VoidCallback? onTap;
  
  // Time ago display
  // Icon with colored background
  // Divider between items
}
```

#### File: `lib/core/widgets/status_badge.dart`
```dart
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  
  // Rounded badge
  // Icon support
  // Multiple color schemes
}
```

#### File: `lib/core/widgets/quick_action_card.dart`
```dart
class QuickActionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  
  // Hover animation
  // Ripple effect
  // Icon with background
  // Responsive sizing
}
```

### 8. Update Main App

#### File: `lib/main.dart`

**Add to MultiProvider:**
```dart
ChangeNotifierProvider<ProductProvider>(
  create: (context) {
    final storage = StorageService<Map<dynamic, dynamic>>(
      StorageKeys.productsBox,
    );
    storage.init();
    final repository = ProductRepository(storage);
    final service = ProductService(repository);
    return ProductProvider(service)..loadProducts();
  },
),

ChangeNotifierProvider<FinanceProvider>(
  create: (context) {
    // Initialize finance provider
  },
),
```

### 9. Update Routes

#### File: `lib/core/routes/app_router.dart`

**Add routes:**
```dart
GoRoute(
  path: '/products/create',
  name: 'product-create',
  pageBuilder: (context, state) => _buildPageWithTransition(
    context: context,
    state: state,
    child: const ProductFormScreen(),
  ),
),

GoRoute(
  path: '/products/:id',
  name: 'product-detail',
  pageBuilder: (context, state) {
    final id = state.pathParameters['id']!;
    return _buildPageWithTransition(
      context: context,
      state: state,
      child: ProductDetailScreen(productId: id),
    );
  },
),

GoRoute(
  path: '/products/:id/edit',
  name: 'product-edit',
  pageBuilder: (context, state) {
    final id = state.pathParameters['id']!;
    return _buildPageWithTransition(
      context: context,
      state: state,
      child: ProductFormScreen(productId: id),
    );
  },
),
```

### 10. Update pubspec.yaml

**Add dependencies:**
```yaml
dependencies:
  # Existing dependencies...
  
  # Image handling
  image_picker: ^1.0.7
  image: ^4.1.7
  path_provider: ^2.1.2
  
  # Additional utilities
  flutter_slidable: ^3.0.1
  shimmer: ^3.0.0
```

### 11. Generate Hive Adapters

**Run command:**
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

**This will generate:**
- `product_model.g.dart`
- `transaction_model.g.dart`

### 12. Mock Data Generation

#### File: `lib/core/services/mock_data_service.dart`

```dart
class MockDataService {
  // Generate sample products
  static Future<void> generateSampleProducts(ProductService service);
  
  // Generate sample transactions
  static Future<void> generateSampleTransactions();
  
  // Generate sample invoices
  static Future<void> generateSampleInvoices();
  
  // Clear all data
  static Future<void> clearAllData();
}
```

## 🎨 Design Guidelines

### Color Scheme for Stock Status
```dart
- In Stock: Colors.green.shade600
- Low Stock: Colors.orange.shade600
- Out of Stock: Colors.red.shade600
```

### Animation Guidelines
```dart
- Card hover: Scale 1.0 to 1.02, duration 200ms
- Page transitions: Slide + Fade, duration 300ms
- List items: Fade in with stagger, duration 150ms each
- Charts: Animate on load, duration 800ms
- Buttons: Ripple effect with scale, duration 150ms
```

### Responsive Breakpoints
```dart
- Mobile: < 600px
- Tablet: 600px - 900px
- Desktop: > 900px
```

## 🧪 Testing Checklist

### Product Module
- [ ] Create product with all fields
- [ ] Create product with minimum fields
- [ ] Update product
- [ ] Delete product
- [ ] Search products
- [ ] Filter by category
- [ ] Filter by stock status
- [ ] Sort products
- [ ] Upload product image
- [ ] View product details
- [ ] Stock status indicators work
- [ ] Validation errors display correctly
- [ ] Duplicate name prevention works

### Dashboard
- [ ] Metrics calculate correctly
- [ ] Quick actions navigate properly
- [ ] Charts display data
- [ ] Recent activities load
- [ ] Payment status cards show correct data
- [ ] Responsive layout works on all devices
- [ ] Pull-to-refresh works
- [ ] Real-time updates when data changes

### Finance
- [ ] Summary calculations correct
- [ ] Transactions list loads
- [ ] Date range filter works
- [ ] Type filter works
- [ ] Charts display correctly
- [ ] Monthly summary accurate

## 📊 Performance Optimization

1. **Use const constructors** wherever possible
2. **Implement pagination** for large lists
3. **Lazy load images** with cached_network_image
4. **Debounce search** input (300ms delay)
5. **Use ListView.builder** for long lists
6. **Implement pull-to-refresh** for data updates
7. **Cache calculations** in providers
8. **Use compute()** for heavy calculations
9. **Optimize image sizes** before storage
10. **Implement shimmer loading** for better UX

## 🚀 Deployment Steps

1. Run `flutter pub get`
2. Run `flutter packages pub run build_runner build`
3. Test on all platforms
4. Verify all CRUD operations
5. Test responsive layouts
6. Verify calculations
7. Test image upload/display
8. Check performance
9. Build release version
10. Deploy

## 📝 Next Phase Planning

**Phase 3 will include:**
- Invoice module with PDF generation
- Transport module with trip tracking
- Payroll module with salary calculations
- Advanced reports with export
- Settings module enhancements
- Backup and restore functionality

---

**Phase 2 Status:** Implementation Guide Complete
**Ready for:** Full Development
**Estimated Time:** 40-60 hours of development

---

This guide provides the complete roadmap for Phase 2 implementation. Follow the structure, implement each component, and test thoroughly before moving to Phase 3.
