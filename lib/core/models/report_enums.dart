import 'package:hive/hive.dart';

part 'report_enums.g.dart';

@HiveType(typeId: 30)
enum ReportType {
  @HiveField(0)
  sales,
  @HiveField(1)
  purchase,
  @HiveField(2)
  expense,
  @HiveField(3)
  stock,
  @HiveField(4)
  profitLoss,
  @HiveField(5)
  payroll,
}

@HiveType(typeId: 31)
enum ReportPeriod {
  @HiveField(0)
  daily,
  @HiveField(1)
  weekly,
  @HiveField(2)
  monthly,
  @HiveField(3)
  quarterly,
  @HiveField(4)
  yearly,
  @HiveField(5)
  custom,
}

extension ReportTypeExtension on ReportType {
  String get displayName {
    switch (this) {
      case ReportType.sales:
        return 'Sales';
      case ReportType.purchase:
        return 'Purchase';
      case ReportType.expense:
        return 'Expense';
      case ReportType.stock:
        return 'Stock';
      case ReportType.profitLoss:
        return 'Profit & Loss';
      case ReportType.payroll:
        return 'Payroll';
    }
  }

  String get iconName {
    switch (this) {
      case ReportType.sales:
        return 'trending_up';
      case ReportType.purchase:
        return 'shopping_cart';
      case ReportType.expense:
        return 'money_off';
      case ReportType.stock:
        return 'inventory';
      case ReportType.profitLoss:
        return 'account_balance';
      case ReportType.payroll:
        return 'people';
    }
  }
}

extension ReportPeriodExtension on ReportPeriod {
  String get displayName {
    switch (this) {
      case ReportPeriod.daily:
        return 'Daily';
      case ReportPeriod.weekly:
        return 'Weekly';
      case ReportPeriod.monthly:
        return 'Monthly';
      case ReportPeriod.quarterly:
        return 'Quarterly';
      case ReportPeriod.yearly:
        return 'Yearly';
      case ReportPeriod.custom:
        return 'Custom';
    }
  }
}
