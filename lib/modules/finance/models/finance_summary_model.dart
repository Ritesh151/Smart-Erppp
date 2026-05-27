class FinanceSummaryModel {
  final double totalSales;
  final double totalPurchases;
  final double totalExpenses;
  final double totalRevenue;
  final double netProfit;
  final double totalInventoryValue;
  final int transactionCount;
  final DateTime calculatedAt;

  FinanceSummaryModel({
    required this.totalSales,
    required this.totalPurchases,
    required this.totalExpenses,
    required this.totalRevenue,
    required this.netProfit,
    required this.totalInventoryValue,
    required this.transactionCount,
    required this.calculatedAt,
  });

  double get profitMargin =>
      totalRevenue > 0 ? (netProfit / totalRevenue) * 100 : 0;

  double get expenseRatio =>
      totalRevenue > 0 ? (totalExpenses / totalRevenue) * 100 : 0;

  bool get isProfitable => netProfit > 0;

  factory FinanceSummaryModel.empty() {
    return FinanceSummaryModel(
      totalSales: 0,
      totalPurchases: 0,
      totalExpenses: 0,
      totalRevenue: 0,
      netProfit: 0,
      totalInventoryValue: 0,
      transactionCount: 0,
      calculatedAt: DateTime.now(),
    );
  }

  FinanceSummaryModel copyWith({
    double? totalSales,
    double? totalPurchases,
    double? totalExpenses,
    double? totalRevenue,
    double? netProfit,
    double? totalInventoryValue,
    int? transactionCount,
    DateTime? calculatedAt,
  }) {
    return FinanceSummaryModel(
      totalSales: totalSales ?? this.totalSales,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      netProfit: netProfit ?? this.netProfit,
      totalInventoryValue: totalInventoryValue ?? this.totalInventoryValue,
      transactionCount: transactionCount ?? this.transactionCount,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }
}
