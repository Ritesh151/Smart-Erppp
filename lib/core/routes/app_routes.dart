class AppRoutes {
  AppRoutes._();

  static const String root = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String products = '/products';
  static const String finance = '/finance';
  static const String invoices = '/invoices';
  static const String expenses = '/expenses';
  static const String expenseAdd = '/expenses/add';
  static const String expenseDetails = '/expenses/:id';
  static const String expenseEdit = '/expenses/:id/edit';
  static const String expenseSummary = '/expenses/summary';
  static const String payroll = '/payroll';
  static const String reports = '/reports';
  static const String settings = '/settings';
  
  static const String productDetails = '/products/:id';
  static const String productCreate = '/products/create';
  static const String productEdit = '/products/:id/edit';
  static const String invoiceDetails = '/invoices/:id';
  static const String invoiceCreate = '/invoices/create';
  static const String invoiceEdit = '/invoices/:id/edit';
  static const String invoicePayments = '/invoices/:id/payments';
  static const String customers = '/customers';
  static const String customerDetails = '/customers/:id';
  static const String customerCreate = '/customers/create';
  static const String customerEdit = '/customers/:id/edit';
  static const String employeeDetails = '/payroll/:id';
  static const String employeeEdit = '/payroll/:id/edit';
  static const String employeeAdd = '/payroll/add';
  static const String employeeHistory = '/payroll/:id/history';
  static const String purchases = '/purchases';
  static const String purchaseCreate = '/purchases/create';
  static const String purchaseDetails = '/purchases/:id';
  static const String purchaseEdit = '/purchases/:id/edit';
  
  static List<String> get protectedRoutes => [
    dashboard,
    products,
    finance,
    invoices,
    expenses,
    payroll,
    reports,
    settings,
    purchases,
  ];
  
  static bool isProtectedRoute(String route) {
    return protectedRoutes.any((r) => route.startsWith(r));
  }
}
