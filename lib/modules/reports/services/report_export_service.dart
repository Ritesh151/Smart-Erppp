import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smarterp/core/models/expense_report_model.dart';
import 'package:smarterp/core/models/payroll_report_model.dart';
import 'package:smarterp/core/models/profit_loss_model.dart';
import 'package:smarterp/core/models/purchase_report_model.dart';
import 'package:smarterp/core/models/report_model.dart';
import 'package:smarterp/core/models/sales_report_model.dart';
import 'package:smarterp/core/models/stock_report_model.dart';
import 'package:smarterp/core/utils/logger.dart';

enum ExportFormat { csv, text }

class ReportExportService {
  Future<String> exportToCsv(ReportModel report, dynamic data) async {
    final buffer = StringBuffer();
    buffer.writeln('Report: ${report.title}');
    buffer.writeln('Period: ${_fmtDate(report.fromDate)} - ${_fmtDate(report.toDate)}');
    buffer.writeln('Generated: ${_fmtDate(report.generatedAt)}');
    buffer.writeln();

    if (data is SalesReportModel) {
      _writeSalesCsv(buffer, data);
    } else if (data is PurchaseReportModel) {
      _writePurchaseCsv(buffer, data);
    } else if (data is ExpenseReportModel) {
      _writeExpenseCsv(buffer, data);
    } else if (data is StockReportModel) {
      _writeStockCsv(buffer, data);
    } else if (data is ProfitLossModel) {
      _writeProfitLossCsv(buffer, data);
    } else if (data is PayrollReportModel) {
      _writePayrollCsv(buffer, data);
    }

    return buffer.toString();
  }

  Future<String> exportToText(ReportModel report, dynamic data) async {
    final buffer = StringBuffer();
    buffer.writeln('=' * 50);
    buffer.writeln('REPORT: ${report.title}');
    buffer.writeln('=' * 50);
    buffer.writeln('Type: ${report.type.name.toUpperCase()}');
    buffer.writeln('Period: ${_fmtDate(report.fromDate)} - ${_fmtDate(report.toDate)}');
    buffer.writeln('Generated: ${_fmtDate(report.generatedAt)}');
    buffer.writeln('-' * 50);

    if (data is SalesReportModel) {
      _writeSalesText(buffer, data);
    } else if (data is PurchaseReportModel) {
      _writePurchaseText(buffer, data);
    } else if (data is ExpenseReportModel) {
      _writeExpenseText(buffer, data);
    } else if (data is StockReportModel) {
      _writeStockText(buffer, data);
    } else if (data is ProfitLossModel) {
      _writeProfitLossText(buffer, data);
    } else if (data is PayrollReportModel) {
      _writePayrollText(buffer, data);
    }

    buffer.writeln('-' * 50);
    buffer.writeln('End of Report');
    return buffer.toString();
  }

  Future<File> saveToFile(String content, String fileName, {ExportFormat format = ExportFormat.text}) async {
    final ext = format == ExportFormat.csv ? 'csv' : 'txt';
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName.$ext');
    await file.writeAsString(content);
    Logger.success('Report saved to ${file.path}');
    return file;
  }

  void _writeSalesCsv(StringBuffer buffer, SalesReportModel data) {
    buffer.writeln('Total Sales,${data.totalSales}');
    buffer.writeln('Total Orders,${data.salesCount}');
    buffer.writeln('Average Order Value,${data.averageOrderValue}');
    buffer.writeln('Sales Per Day,${data.salesPerDay}');
    buffer.writeln('Monthly Trend,${data.monthlyTrend.join(',')}');
    buffer.writeln('Trend Labels,${data.monthlyLabels.join(',')}');
    buffer.writeln();
    buffer.writeln('Top Products');
    buffer.writeln('Name,Revenue,Quantity');
    for (final p in data.topProducts) {
      buffer.writeln('${p['name']},${p['revenue']},${p['quantity']}');
    }
    buffer.writeln();
    buffer.writeln('Top Customers');
    buffer.writeln('Name,Total Spent,Orders');
    for (final c in data.topCustomers) {
      buffer.writeln('${c['name']},${c['total']},${c['orders']}');
    }
  }

  void _writeSalesText(StringBuffer buffer, SalesReportModel data) {
    buffer.writeln('Sales Summary');
    buffer.writeln('  Total Sales:        ${_fmt(data.totalSales)}');
    buffer.writeln('  Total Orders:       ${data.salesCount}');
    buffer.writeln('  Avg Order Value:    ${_fmt(data.averageOrderValue)}');
    buffer.writeln('  Sales/Day:          ${_fmt(data.salesPerDay)}');
    buffer.writeln();
    if (data.topProducts.isNotEmpty) {
      buffer.writeln('Top Products');
      for (final p in data.topProducts) {
        buffer.writeln('  ${p['name']} - ${_fmt(p['revenue'])} (qty: ${p['quantity']})');
      }
    }
    if (data.topCustomers.isNotEmpty) {
      buffer.writeln('Top Customers');
      for (final c in data.topCustomers) {
        buffer.writeln('  ${c['name']} - ${_fmt(c['total'])} (${c['orders']} orders)');
      }
    }
  }

  void _writePurchaseCsv(StringBuffer buffer, PurchaseReportModel data) {
    buffer.writeln('Total Purchases,${data.totalPurchases}');
    buffer.writeln('Total Orders,${data.purchaseCount}');
    buffer.writeln('Average Order Value,${data.averageOrderValue}');
    buffer.writeln('Monthly Trend,${data.monthlyTrend.join(',')}');
    buffer.writeln('Trend Labels,${data.monthlyLabels.join(',')}');
    buffer.writeln();
    buffer.writeln('Top Suppliers');
    buffer.writeln('Name,Total,Orders');
    for (final s in data.topSuppliers) {
      buffer.writeln('${s['name']},${s['total']},${s['orders']}');
    }
  }

  void _writePurchaseText(StringBuffer buffer, PurchaseReportModel data) {
    buffer.writeln('Purchase Summary');
    buffer.writeln('  Total Purchases:  ${_fmt(data.totalPurchases)}');
    buffer.writeln('  Total Orders:     ${data.purchaseCount}');
    buffer.writeln('  Avg Order Value:  ${_fmt(data.averageOrderValue)}');
    if (data.topSuppliers.isNotEmpty) {
      buffer.writeln('Top Suppliers');
      for (final s in data.topSuppliers) {
        buffer.writeln('  ${s['name']} - ${_fmt(s['total'])} (${s['orders']} orders)');
      }
    }
  }

  void _writeExpenseCsv(StringBuffer buffer, ExpenseReportModel data) {
    buffer.writeln('Total Expenses,${data.totalExpenses}');
    buffer.writeln('Expense Count,${data.expenseCount}');
    buffer.writeln('Monthly Trend,${data.monthlyTrend.join(',')}');
    buffer.writeln('Trend Labels,${data.monthlyLabels.join(',')}');
    buffer.writeln();
    buffer.writeln('Category Breakdown');
    buffer.writeln('Category,Amount,Percentage');
    for (final entry in data.categoryBreakdown.entries) {
      final pct = data.totalExpenses > 0 ? (entry.value / data.totalExpenses * 100) : 0;
      buffer.writeln('${entry.key},${entry.value},${pct.toStringAsFixed(1)}%');
    }
  }

  void _writeExpenseText(StringBuffer buffer, ExpenseReportModel data) {
    buffer.writeln('Expense Summary');
    buffer.writeln('  Total Expenses:  ${_fmt(data.totalExpenses)}');
    buffer.writeln('  Expense Count:   ${data.expenseCount}');
    if (data.categoryBreakdown.isNotEmpty) {
      buffer.writeln('Category Breakdown');
      for (final entry in data.categoryBreakdown.entries) {
        final pct = data.totalExpenses > 0 ? (entry.value / data.totalExpenses * 100) : 0;
        buffer.writeln('  ${entry.key}: ${_fmt(entry.value)} (${pct.toStringAsFixed(1)}%)');
      }
    }
  }

  void _writeStockCsv(StringBuffer buffer, StockReportModel data) {
    buffer.writeln('Total Products,${data.totalProducts}');
    buffer.writeln('Total Value,${data.totalInventoryValue}');
    buffer.writeln('Low Stock Count,${data.lowStockCount}');
    buffer.writeln('Out of Stock Count,${data.outOfStockCount}');
    buffer.writeln('Stock Health,${data.stockHealthPercentage.toStringAsFixed(1)}%');
    buffer.writeln();
    buffer.writeln('Low Stock Products');
    buffer.writeln('Name,Stock,Min Level');
    for (final p in data.lowStockProducts) {
      buffer.writeln('${p['name']},${p['stock']},${p['minLevel']}');
    }
    buffer.writeln();
    buffer.writeln('Top Moving Products');
    buffer.writeln('Name,Quantity Sold');
    for (final p in data.topMovingProducts) {
      buffer.writeln('${p['name']},${p['quantity']}');
    }
  }

  void _writeStockText(StringBuffer buffer, StockReportModel data) {
    buffer.writeln('Stock Summary');
    buffer.writeln('  Total Products:  ${data.totalProducts}');
    buffer.writeln('  Total Value:     ${_fmt(data.totalInventoryValue)}');
    buffer.writeln('  Low Stock:       ${data.lowStockCount}');
    buffer.writeln('  Out of Stock:    ${data.outOfStockCount}');
    buffer.writeln('  Stock Health:    ${data.stockHealthPercentage.toStringAsFixed(1)}%');
    if (data.lowStockProducts.isNotEmpty) {
      buffer.writeln('Low Stock Products');
      for (final p in data.lowStockProducts) {
        buffer.writeln('  ${p['name']} - stock: ${p['stock']}, min: ${p['minLevel']}');
      }
    }
    if (data.topMovingProducts.isNotEmpty) {
      buffer.writeln('Top Moving Products');
      for (final p in data.topMovingProducts) {
        buffer.writeln('  ${p['name']} - ${p['quantity']} sold');
      }
    }
  }

  void _writeProfitLossCsv(StringBuffer buffer, ProfitLossModel data) {
    buffer.writeln('Total Revenue,${data.totalRevenue}');
    buffer.writeln('Cost of Goods Sold,${data.totalCostOfGoodsSold}');
    buffer.writeln('Total Expenses,${data.totalExpenses}');
    buffer.writeln('Total Payroll Cost,${data.totalPayrollCost}');
    buffer.writeln('Gross Profit,${data.grossProfit}');
    buffer.writeln('Net Profit,${data.netProfit}');
    buffer.writeln('Profit Margin,${data.profitMargin}%');
    buffer.writeln('Previous Net Profit,${data.previousNetProfit}');
    buffer.writeln('Profit Growth,${data.profitGrowth}%');
  }

  void _writeProfitLossText(StringBuffer buffer, ProfitLossModel data) {
    buffer.writeln('Profit & Loss Statement');
    buffer.writeln('  Total Revenue:     ${_fmt(data.totalRevenue)}');
    buffer.writeln('  Cost of Goods Sold:${_fmt(data.totalCostOfGoodsSold)}');
    buffer.writeln('  Total Expenses:    ${_fmt(data.totalExpenses)}');
    buffer.writeln('  Total Payroll:     ${_fmt(data.totalPayrollCost)}');
    buffer.writeln('  ${'-' * 24}');
    buffer.writeln('  Gross Profit:      ${_fmt(data.grossProfit)}');
    buffer.writeln('  Net Profit:        ${_fmt(data.netProfit)}');
    buffer.writeln('  Profit Margin:     ${data.profitMargin.toStringAsFixed(1)}%');
    buffer.writeln('  Profit Growth:     ${data.profitGrowth.toStringAsFixed(1)}%');
  }

  void _writePayrollCsv(StringBuffer buffer, PayrollReportModel data) {
    buffer.writeln('Total Employees,${data.totalEmployees}');
    buffer.writeln('Active Employees,${data.activeEmployees}');
    buffer.writeln('Total Salary Payable,${data.totalSalaryPayable}');
    buffer.writeln('Total Salary Paid,${data.totalSalaryPaid}');
    buffer.writeln('Total Salary Pending,${data.totalSalaryPending}');
    buffer.writeln('Paid Count,${data.paidCount}');
    buffer.writeln('Pending Count,${data.pendingCount}');
    buffer.writeln('Partially Paid Count,${data.partiallyPaidCount}');
    buffer.writeln('Attendance Rate,${data.attendanceRate}%');
    buffer.writeln('Payment Rate,${data.paymentRate.toStringAsFixed(1)}%');
    buffer.writeln('Salary Trend,${data.salaryTrend.join(',')}');
    buffer.writeln('Trend Labels,${data.trendLabels.join(',')}');
    buffer.writeln();
    buffer.writeln('Department Distribution');
    buffer.writeln('Department,Employee Count');
    for (final entry in data.departmentDistribution.entries) {
      buffer.writeln('${entry.key},${entry.value}');
    }
  }

  void _writePayrollText(StringBuffer buffer, PayrollReportModel data) {
    buffer.writeln('Payroll Report');
    buffer.writeln('  Total Employees:    ${data.totalEmployees}');
    buffer.writeln('  Active Employees:   ${data.activeEmployees}');
    buffer.writeln('  Total Payable:      ${_fmt(data.totalSalaryPayable)}');
    buffer.writeln('  Total Paid:         ${_fmt(data.totalSalaryPaid)}');
    buffer.writeln('  Total Pending:      ${_fmt(data.totalSalaryPending)}');
    buffer.writeln('  Payment Rate:       ${data.paymentRate.toStringAsFixed(1)}%');
    buffer.writeln('  Attendance Rate:    ${data.attendanceRate.toStringAsFixed(1)}%');
    if (data.departmentDistribution.isNotEmpty) {
      buffer.writeln('Department Distribution');
      for (final entry in data.departmentDistribution.entries) {
        buffer.writeln('  ${entry.key}: ${entry.value} employees');
      }
    }
  }

  String _fmt(dynamic value) {
    if (value is double) return '₹${value.toStringAsFixed(0)}';
    if (value is int) return '₹$value';
    return '₹$value';
  }

  String _fmtDate(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }
}
