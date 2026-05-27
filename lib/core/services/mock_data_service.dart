import 'package:smarterp/core/models/product_model.dart';
import 'package:smarterp/core/models/transaction_model.dart';
import 'package:smarterp/modules/finance/repositories/finance_repository.dart';
import 'package:smarterp/modules/products/repositories/product_repository.dart';
import 'package:uuid/uuid.dart';

class MockDataService {
  static Future<void> populateIfEmpty({
    required ProductRepository productRepository,
    required FinanceRepository financeRepository,
  }) async {
    final productCount = await productRepository.getTotalCount();
    if (productCount == 0) {
      await _populateProducts(productRepository);
    }

    final txs = await financeRepository.getAllTransactions();
    if (txs.isEmpty) {
      await _populateTransactions(financeRepository);
    }
  }

  static Future<void> _populateProducts(ProductRepository repo) async {
    final products = [
      ProductModel(
        id: const Uuid().v4(),
        productName: 'Cement OPC 53 Grade',
        hsnCode: '25232910',
        price: 450.00,
        costPrice: 380.00,
        stockQuantity: 1500,
        minStockLevel: 200,
        gstRate: 28.0,
        description: 'Ordinary Portland Cement, high strength OPC 53 Grade.',
        category: 'Building Materials',
        unit: 'Bag',
        sku: 'CEM-OPC-53',
        barcode: '890123456001',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      ProductModel(
        id: const Uuid().v4(),
        productName: 'TMT Steel Rebar 12mm',
        hsnCode: '72142090',
        price: 65000.00,
        costPrice: 58000.00,
        stockQuantity: 45,
        minStockLevel: 5,
        gstRate: 18.0,
        description: 'High strength thermo-mechanically treated steel reinforcement bars.',
        category: 'Steel',
        unit: 'Ton',
        sku: 'TMT-12MM',
        barcode: '890123456002',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 28)),
        updatedAt: DateTime.now().subtract(const Duration(days: 28)),
      ),
      ProductModel(
        id: const Uuid().v4(),
        productName: 'Ceramic Floor Tiles 2x2',
        hsnCode: '69072100',
        price: 850.00,
        costPrice: 620.00,
        stockQuantity: 350,
        minStockLevel: 50,
        gstRate: 18.0,
        description: 'Vitrified glazed ceramic floor tiles with matte finish.',
        category: 'Tiles',
        unit: 'Box',
        sku: 'TILE-CER-2X2',
        barcode: '890123456003',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      ProductModel(
        id: const Uuid().v4(),
        productName: 'PVC Conduit Pipe 1 Inch',
        hsnCode: '39172310',
        price: 75.00,
        costPrice: 48.00,
        stockQuantity: 12, 
        minStockLevel: 25,
        gstRate: 18.0,
        description: 'Heavy duty fire retardant PVC electrical conduit pipe.',
        category: 'Electrical',
        unit: 'Piece',
        sku: 'PVC-PIPE-1IN',
        barcode: '890123456004',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      ProductModel(
        id: const Uuid().v4(),
        productName: 'LED Panel Light 12W',
        hsnCode: '94051000',
        price: 450.00,
        costPrice: 280.00,
        stockQuantity: 0, 
        minStockLevel: 10,
        gstRate: 18.0,
        description: 'Slim round recessed ceiling LED panel light, cool daylight.',
        category: 'Electrical',
        unit: 'Piece',
        sku: 'LED-PAN-12W',
        barcode: '890123456005',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 18)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      ProductModel(
        id: const Uuid().v4(),
        productName: 'Wall Primer White 20L',
        hsnCode: '32091090',
        price: 3400.00,
        costPrice: 2750.00,
        stockQuantity: 80,
        minStockLevel: 15,
        gstRate: 18.0,
        description: 'Interior and exterior white acrylic wall primer paint.',
        category: 'Paints',
        unit: 'Bucket',
        sku: 'PNT-PRIM-20L',
        barcode: '890123456006',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];

    for (final p in products) {
      await repo.save(p);
    }
  }

  static Future<void> _populateTransactions(FinanceRepository repo) async {
    final now = DateTime.now();
    final transactions = [
      TransactionModel(
        id: const Uuid().v4(),
        type: TransactionType.sale,
        amount: 145000.00,
        date: now.subtract(const Duration(days: 1)),
        description: 'Invoice #INV-2026-004 to Siddhivinayak Builders',
        referenceId: 'INV-2026-004',
        category: 'Cement',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      TransactionModel(
        id: const Uuid().v4(),
        type: TransactionType.sale,
        amount: 85000.00,
        date: now.subtract(const Duration(days: 3)),
        description: 'Invoice #INV-2026-003 to Maruti Developers',
        referenceId: 'INV-2026-003',
        category: 'Steel',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      TransactionModel(
        id: const Uuid().v4(),
        type: TransactionType.sale,
        amount: 54000.00,
        date: now.subtract(const Duration(days: 5)),
        description: 'Invoice #INV-2026-002 to Patel Traders',
        referenceId: 'INV-2026-002',
        category: 'Tiles',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      TransactionModel(
        id: const Uuid().v4(),
        type: TransactionType.sale,
        amount: 120000.00,
        date: now.subtract(const Duration(days: 10)),
        description: 'Invoice #INV-2026-001 to Ambica Contractors',
        referenceId: 'INV-2026-001',
        category: 'Cement',
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
      TransactionModel(
        id: const Uuid().v4(),
        type: TransactionType.purchase,
        amount: 180000.00,
        date: now.subtract(const Duration(days: 12)),
        description: 'Bulk steel procurement from Tata Steel Ltd',
        referenceId: 'PO-2026-001',
        category: 'Steel',
        createdAt: now.subtract(const Duration(days: 12)),
        updatedAt: now.subtract(const Duration(days: 12)),
      ),
      TransactionModel(
        id: const Uuid().v4(),
        type: TransactionType.purchase,
        amount: 95000.00,
        date: now.subtract(const Duration(days: 18)),
        description: 'Cement batch buy from UltraTech Cement',
        referenceId: 'PO-2026-002',
        category: 'Cement',
        createdAt: now.subtract(const Duration(days: 18)),
        updatedAt: now.subtract(const Duration(days: 18)),
      ),
      TransactionModel(
        id: const Uuid().v4(),
        type: TransactionType.expense,
        amount: 12000.00,
        date: now.subtract(const Duration(days: 2)),
        description: 'Office electricity & utility bill payment',
        referenceId: 'EXP-UTIL-09',
        category: 'Utilities',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      TransactionModel(
        id: const Uuid().v4(),
        type: TransactionType.expense,
        amount: 25000.00,
        date: now.subtract(const Duration(days: 8)),
        description: 'Transport diesel fuel reimbursement',
        referenceId: 'EXP-FUEL-34',
        category: 'Logistics',
        createdAt: now.subtract(const Duration(days: 8)),
        updatedAt: now.subtract(const Duration(days: 8)),
      ),
      TransactionModel(
        id: const Uuid().v4(),
        type: TransactionType.expense,
        amount: 4500.00,
        date: now.subtract(const Duration(days: 14)),
        description: 'Office stationery & supplies',
        referenceId: 'EXP-OFF-12',
        category: 'Office',
        createdAt: now.subtract(const Duration(days: 14)),
        updatedAt: now.subtract(const Duration(days: 14)),
      ),
      TransactionModel(
        id: const Uuid().v4(),
        type: TransactionType.income,
        amount: 8000.00,
        date: now.subtract(const Duration(days: 15)),
        description: 'Scrap metal recycling salvage sale',
        referenceId: 'INC-SCRP-01',
        category: 'Salvage',
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 15)),
      ),
    ];

    for (final tx in transactions) {
      await repo.saveTransaction(tx);
    }
  }
}
