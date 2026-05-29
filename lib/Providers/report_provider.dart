import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:SmartERP/core/constants/storage_keys.dart';
import 'package:SmartERP/core/models/report_enums.dart';
import 'package:SmartERP/core/models/invoice_model.dart';
import 'package:SmartERP/core/models/expense_model.dart';
import 'package:SmartERP/core/models/salary_model.dart';

// ---- Data Classes ----

class SalesReportEntry {
  final String saleId;
  final String invoiceNumber;
  final String customerName;
  final DateTime createdAt;
  final double total;
  final double gstAmount;

  const SalesReportEntry({
    required this.saleId,
    required this.invoiceNumber,
    required this.customerName,
    required this.createdAt,
    required this.total,
    required this.gstAmount,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SalesReportEntry &&
          runtimeType == other.runtimeType &&
          saleId == other.saleId &&
          invoiceNumber == other.invoiceNumber &&
          customerName == other.customerName &&
          createdAt == other.createdAt &&
          total == other.total &&
          gstAmount == other.gstAmount;

  @override
  int get hashCode =>
      saleId.hashCode ^
      invoiceNumber.hashCode ^
      customerName.hashCode ^
      createdAt.hashCode ^
      total.hashCode ^
      gstAmount.hashCode;
}

class SalesReportSummary {
  final double taxableAmount;
  final double gstAmount;
  final double totalAmount;

  const SalesReportSummary({
    this.taxableAmount = 0,
    this.gstAmount = 0,
    this.totalAmount = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SalesReportSummary &&
          runtimeType == other.runtimeType &&
          taxableAmount == other.taxableAmount &&
          gstAmount == other.gstAmount &&
          totalAmount == other.totalAmount;

  @override
  int get hashCode =>
      taxableAmount.hashCode ^ gstAmount.hashCode ^ totalAmount.hashCode;
}

class PurchaseReportEntry {
  final String purchaseNumber;

  final SupplierInfo supplier;
  final DateTime purchaseDate;
  final double totalAmount;

  const PurchaseReportEntry({
    required this.purchaseNumber,
    required this.supplier,
    required this.purchaseDate,
    required this.totalAmount,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseReportEntry &&
          runtimeType == other.runtimeType &&
          purchaseNumber == other.purchaseNumber &&
          supplier == other.supplier &&
          purchaseDate == other.purchaseDate &&
          totalAmount == other.totalAmount;

  @override
  int get hashCode =>
      purchaseNumber.hashCode ^
      supplier.hashCode ^
      purchaseDate.hashCode ^
      totalAmount.hashCode;
}

class SupplierInfo {
  final String name;

  const SupplierInfo({required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupplierInfo &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}

class PurchaseReportSummary {
  final int purchaseCount;
  final double totalAmount;

  const PurchaseReportSummary({
    this.purchaseCount = 0,
    this.totalAmount = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseReportSummary &&
          runtimeType == other.runtimeType &&
          purchaseCount == other.purchaseCount &&
          totalAmount == other.totalAmount;

  @override
  int get hashCode => purchaseCount.hashCode ^ totalAmount.hashCode;
}

class ProfitLossReportData {
  final double totalSales;
  final double totalPurchases;
  final double grossProfit;
  final double totalExpenses;
  final double totalSalary;
  final double netProfit;

  const ProfitLossReportData({
    this.totalSales = 0,
    this.totalPurchases = 0,
    this.grossProfit = 0,
    this.totalExpenses = 0,
    this.totalSalary = 0,
    this.netProfit = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfitLossReportData &&
          runtimeType == other.runtimeType &&
          totalSales == other.totalSales &&
          totalPurchases == other.totalPurchases &&
          grossProfit == other.grossProfit &&
          totalExpenses == other.totalExpenses &&
          totalSalary == other.totalSalary &&
          netProfit == other.netProfit;

  @override
  int get hashCode =>
      totalSales.hashCode ^
      totalPurchases.hashCode ^
      grossProfit.hashCode ^
      totalExpenses.hashCode ^
      totalSalary.hashCode ^
      netProfit.hashCode;
}

class GstReportSummary {
  final double netLiability;
  final double outputCgst;
  final double outputSgst;
  final double outputIgst;
  final double totalOutput;
  final double inputCgst;
  final double inputSgst;
  final double inputIgst;
  final double totalInput;

  const GstReportSummary({
    this.netLiability = 0,
    this.outputCgst = 0,
    this.outputSgst = 0,
    this.outputIgst = 0,
    this.totalOutput = 0,
    this.inputCgst = 0,
    this.inputSgst = 0,
    this.inputIgst = 0,
    this.totalInput = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GstReportSummary &&
          runtimeType == other.runtimeType &&
          netLiability == other.netLiability &&
          outputCgst == other.outputCgst &&
          outputSgst == other.outputSgst &&
          outputIgst == other.outputIgst &&
          totalOutput == other.totalOutput &&
          inputCgst == other.inputCgst &&
          inputSgst == other.inputSgst &&
          inputIgst == other.inputIgst &&
          totalInput == other.totalInput;

  @override
  int get hashCode =>
      netLiability.hashCode ^
      outputCgst.hashCode ^
      outputSgst.hashCode ^
      outputIgst.hashCode ^
      totalOutput.hashCode ^
      inputCgst.hashCode ^
      inputSgst.hashCode ^
      inputIgst.hashCode ^
      totalInput.hashCode;
}

// ---- Filter State Management ----

class ReportFilterNotifier extends StateNotifier<Map<ReportType, DateTimeRange?>> {
  ReportFilterNotifier() : super({});

  void setDateRange(ReportType type, DateTimeRange? range) {
    state = {...state, type: range};
  }
}

final _reportRangeStateProvider =
    StateNotifierProvider<ReportFilterNotifier, Map<ReportType, DateTimeRange?>>(
        (ref) {
  return ReportFilterNotifier();
});

final reportDateRangeProvider =
    Provider.family<DateTimeRange?, ReportType>((ref, type) {
  return ref.watch(_reportRangeStateProvider.select((state) => state[type]));
});

final reportFilterProvider = _reportRangeStateProvider;

// ---- Helpers ----

DateTimeRange? _getRange(Ref ref, ReportType type) {
  return ref.watch(reportDateRangeProvider(type));
}

bool _isInRange(DateTime date, DateTimeRange? range) {
  if (range == null) return true;
  return !date.isBefore(range.start) && !date.isAfter(range.end);
}

InvoiceModel? _parseInvoice(Map<String, dynamic> map) {
  try {
    return InvoiceModel.fromJson(map);
  } catch (_) {
    return null;
  }
}

ExpenseModel? _parseExpense(Map<String, dynamic> map) {
  try {
    return ExpenseModel.fromJson(map);
  } catch (_) {
    return null;
  }
}

SalaryModel? _parseSalary(Map<String, dynamic> map) {
  try {
    return SalaryModel.fromJson(map);
  } catch (_) {
    return null;
  }
}

// ---- Sales Report Providers ----

final salesReportEntriesProvider = Provider<List<SalesReportEntry>>((ref) {
  final range = _getRange(ref, ReportType.sales);

  try {
    final box = Hive.box(StorageKeys.invoicesBox);
    final invoices = box.values
        .map((e) => _parseInvoice(Map<String, dynamic>.from(e as Map)))
        .whereType<InvoiceModel>()
        .where((inv) => _isInRange(inv.invoiceDate, range))
        .map((inv) => SalesReportEntry(
              saleId: inv.id,
              invoiceNumber: inv.invoiceNumber,
              customerName: inv.customerName,
              createdAt: inv.invoiceDate,
              total: inv.totalAmount,
              gstAmount: inv.taxAmount,
            ))
        .toList();

    invoices.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return invoices;
  } catch (_) {
    return [];
  }
});

final salesReportSummaryProvider = Provider<SalesReportSummary>((ref) {
  final entries = ref.watch(salesReportEntriesProvider);

  double taxable = 0;
  double gst = 0;
  double total = 0;

  for (final entry in entries) {
    taxable += entry.total - entry.gstAmount;
    gst += entry.gstAmount;
    total += entry.total;
  }

  return SalesReportSummary(
    taxableAmount: taxable,
    gstAmount: gst,
    totalAmount: total,
  );
});

// ---- Purchase Report Providers ----

final filteredPurchasesReportProvider = Provider<List<PurchaseReportEntry>>((ref) {
  final range = _getRange(ref, ReportType.purchase);

  try {
    final box = Hive.box(StorageKeys.purchaseBox);
    final purchases = box.values
        .map((e) {
          final map = Map<String, dynamic>.from(e as Map);
          final dateStr = map['purchaseDate'] as String?;
          return PurchaseReportEntry(
            purchaseNumber: map['purchaseNumber'] as String? ?? '',
            supplier: SupplierInfo(
              name: map['supplier'] is Map
                  ? ((map['supplier'] as Map)['name'] as String? ?? 'Unknown')
                  : 'Unknown',
            ),
            purchaseDate: dateStr != null
                ? DateTime.parse(dateStr)
                : DateTime.now(),
            totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0,
          );
        })
        .where((p) => _isInRange(p.purchaseDate, range))
        .toList();

    purchases.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
    return purchases;
  } catch (_) {
    return [];
  }
});

final purchaseReportSummaryProvider = Provider<PurchaseReportSummary>((ref) {
  final entries = ref.watch(filteredPurchasesReportProvider);

  int count = entries.length;
  double total = 0;

  for (final entry in entries) {
    total += entry.totalAmount;
  }

  return PurchaseReportSummary(
    purchaseCount: count,
    totalAmount: total,
  );
});

// ---- Profit/Loss Report Provider ----

final profitLossReportProvider = Provider<ProfitLossReportData>((ref) {
  final range = _getRange(ref, ReportType.profitLoss);

  double totalSales = 0;
  double totalPurchases = 0;
  double totalExpenses = 0;
  double totalSalary = 0;

  try {
    final invBox = Hive.box(StorageKeys.invoicesBox);
    for (final e in invBox.values) {
      final inv = _parseInvoice(Map<String, dynamic>.from(e as Map));
      if (inv != null && _isInRange(inv.invoiceDate, range)) {
        totalSales += inv.totalAmount;
      }
    }
  } catch (_) {}

  try {
    final purBox = Hive.box(StorageKeys.purchaseBox);
    for (final e in purBox.values) {
      final map = Map<String, dynamic>.from(e as Map);
      final dateStr = map['purchaseDate'] as String?;
      if (dateStr != null) {
        final date = DateTime.parse(dateStr);
        if (_isInRange(date, range)) {
          totalPurchases += (map['totalAmount'] as num?)?.toDouble() ?? 0;
        }
      }
    }
  } catch (_) {}

  try {
    final expBox = Hive.box(StorageKeys.expensesBox);
    for (final e in expBox.values) {
      final exp = _parseExpense(Map<String, dynamic>.from(e as Map));
      if (exp != null && _isInRange(exp.expenseDate, range)) {
        totalExpenses += exp.amount;
      }
    }
  } catch (_) {}

  try {
    final salBox = Hive.box(StorageKeys.salaryBox);
    for (final e in salBox.values) {
      final sal = _parseSalary(Map<String, dynamic>.from(e as Map));
      if (sal != null) {
        final salDate = DateTime(sal.year, sal.month, 1);
        if (_isInRange(salDate, range)) {
          totalSalary += sal.netSalary;
        }
      }
    }
  } catch (_) {}

  final grossProfit = totalSales - totalPurchases;
  final netProfit = grossProfit - totalExpenses - totalSalary;

  return ProfitLossReportData(
    totalSales: totalSales,
    totalPurchases: totalPurchases,
    grossProfit: grossProfit,
    totalExpenses: totalExpenses,
    totalSalary: totalSalary,
    netProfit: netProfit,
  );
});

// ---- GST Report Provider ----

final gstReportSummaryProvider = Provider<GstReportSummary>((ref) {
  final range = _getRange(ref, ReportType.expense);

  double outputCgst = 0;
  double outputSgst = 0;
  double outputIgst = 0;

  double inputCgst = 0;
  double inputSgst = 0;
  double inputIgst = 0;

  try {
    final invBox = Hive.box(StorageKeys.invoicesBox);
    for (final e in invBox.values) {
      final inv = _parseInvoice(Map<String, dynamic>.from(e as Map));
      if (inv != null && _isInRange(inv.invoiceDate, range)) {
        final half = inv.taxAmount / 2;
        outputCgst += half;
        outputSgst += half;
      }
    }
  } catch (_) {}

  try {
    final purBox = Hive.box(StorageKeys.purchaseBox);
    for (final e in purBox.values) {
      final map = Map<String, dynamic>.from(e as Map);
      final dateStr = map['purchaseDate'] as String?;
      if (dateStr != null) {
        final date = DateTime.parse(dateStr);
        if (_isInRange(date, range)) {
          final taxAmount = (map['taxAmount'] as num?)?.toDouble() ?? 0;
          final half = taxAmount / 2;
          inputCgst += half;
          inputSgst += half;
        }
      }
    }
  } catch (_) {}

  final totalOutput = outputCgst + outputSgst + outputIgst;
  final totalInput = inputCgst + inputSgst + inputIgst;
  final netLiability = totalOutput - totalInput;

  return GstReportSummary(
    netLiability: netLiability,
    outputCgst: outputCgst,
    outputSgst: outputSgst,
    outputIgst: outputIgst,
    totalOutput: totalOutput,
    inputCgst: inputCgst,
    inputSgst: inputSgst,
    inputIgst: inputIgst,
    totalInput: totalInput,
  );
});
