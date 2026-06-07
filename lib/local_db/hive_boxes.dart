import 'package:hive_flutter/hive_flutter.dart';

class HiveBoxes {
  static Box<Map> invoicesBox() {
    return Hive.box<Map>('invoices');
  }

  static Box<Map> productsBox() {
    return Hive.box<Map>('products');
  }

  static Box<Map> employeesBox() {
    return Hive.box<Map>('employees');
  }

  static Box<Map> expensesBox() {
    return Hive.box<Map>('expenses');
  }

  static Box<Map> transportBox() {
    return Hive.box<Map>('transport');
  }

  static Box<Map> settingsBox() {
    return Hive.box<Map>('settings');
  }

  static Box<Map> salesBox() {
    return Hive.box<Map>('sales');
  }

  static Box<Map> purchaseBox() {
    return Hive.box<Map>('purchases');
  }

  static Box<Map> whatsappBox() {
    return Hive.box<Map>('whatsapp_history');
  }

  static Box<Map> aadhaarImagesBox() {
    return Hive.box<Map>('aadhaar_images_box');
  }

  static Box<Map> customersBox() {
    return Hive.box<Map>('customers');
  }

  static Box<Map> invoiceItemsBox() {
    return Hive.box<Map>('invoice_items');
  }
}
