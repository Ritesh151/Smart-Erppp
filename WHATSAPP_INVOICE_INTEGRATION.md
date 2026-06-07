# WhatsApp Invoice Notification System

A fully integrated WhatsApp notification system for the Siddhivinayak Enterprise Flutter ERP. This system automatically sends invoice details to customers via WhatsApp when an invoice is created or updated.

## Features

- ✅ Automatic invoice notification via WhatsApp
- ✅ Professional message templates with invoice details
- ✅ Platform-specific handling (Android, iOS, Web, Desktop)
- ✅ WhatsApp Business API ready architecture
- ✅ Send history tracking
- ✅ Error handling and retry mechanisms
- ✅ Multi-platform support

## Architecture

### Directory Structure

```
lib/modules/invoice/
├── models/
│   ├── whatsapp_invoice_model.dart        # WhatsApp send history model
│   └── whatsapp_message_template.dart     # Message template generator
├── services/
│   ├── whatsapp_service.dart              # WhatsApp core service
│   ├── message_template_service.dart      # Message formatting service
│   └── invoice_service.dart               # Enhanced with WhatsApp methods
├── repositories/
│   ├── whatsapp_repository.dart           # Data persistence layer
│   └── invoice_repository.dart
├── providers/
│   ├── whatsapp_provider.dart             # WhatsApp state management
│   └── invoice_provider.dart              # Enhanced with WhatsApp methods
├── utils/
│   └── whatsapp_helper.dart               # Platform-specific utilities
└── widgets/
    └── whatsapp_send_button.dart          # Reusable UI component
```

## Core Components

### 1. WhatsApp Service (`whatsapp_service.dart`)

The core service that handles all WhatsApp interactions:

```dart
final service = WhatsAppService(
  repository: WhatsAppRepository(storage),
);

// Send invoice via WhatsApp
await service.sendInvoiceViaWhatsApp(
  customerPhone: '+919876543210',
  invoice: invoice,
  items: items,
);

// Send via Android intent (optimized)
await service.sendInvoiceViaAndroidIntent(
  customerPhone: '+919876543210',
  invoice: invoice,
  items: items,
);

// Future-proof API method
await service.sendInvoiceViaAPI(
  customerPhone: '+919876543210',
  invoice: invoice,
  items: items,
);
```

### 2. Message Template Service (`message_template_service.dart`)

Generates professional WhatsApp messages:

```dart
final message = MessageTemplateService.generateInvoiceMessage(
  customerName: 'John Doe',
  invoiceNumber: 'INV-2024-0001',
  items: items,
  subtotal: 5000.00,
  taxAmount: 900.00,
  totalAmount: 5900.00,
);
```

### 3. WhatsApp Provider (`whatsapp_provider.dart`)

Manages WhatsApp state using Provider pattern:

```dart
// In your widget
final whatsappProvider = context.read<WhatsAppProvider>();

// Load history
await whatsappProvider.loadHistory();

// Send invoice
await whatsappProvider.sendInvoiceWithAutoMessage(
  customerPhone: '+919876543210',
  invoice: invoice,
  items: items,
);

// Get send history
final history = whatsappProvider.sendHistory;
```

### 4. WhatsApp Helper (`whatsapp_helper.dart`)

Platform-specific utilities:

```dart
// Normalize phone number
final phone = WhatsAppHelper.normalizePhoneNumber('9876543210');

// Validate phone number
final isValid = WhatsAppHelper.isValidPhoneNumber(phone);

// Build WhatsApp URL
final url = WhatsAppHelper.buildWhatsAppUrl(
  phoneNumber: phone,
  message: 'Hello, this is a test message',
);

// Check if running on specific platform
if (WhatsAppHelper.isAndroid()) { /* ... */ }
if (WhatsAppHelper.isIOS()) { /* ... */ }
if (WhatsAppHelper.isWeb()) { /* ... */ }
```

## Integration Guide

### Step 1: Add Dependencies

Add `url_launcher` to your `pubspec.yaml`:

```yaml
dependencies:
  url_launcher: ^6.2.0
  provider: ^6.1.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
```

### Step 2: Initialize WhatsApp Repository

In your `main.dart` or where you initialize repositories:

```dart
// Initialize WhatsApp history box
await Hive.openBox('whatsapp_history');

// Create WhatsApp repository
final whatsappRepo = WhatsAppRepository(
  StorageService<Map<dynamic, dynamic>>('whatsapp_history'),
);

// Create WhatsApp service
final whatsappService = WhatsAppService(repository: whatsappRepo);

// Create WhatsApp provider
final whatsappProvider = WhatsAppProvider(whatsappService);
```

### Step 3: Add to MultiProvider

```dart
MultiProvider(
  providers: [
    // ... other providers
    ChangeNotifierProvider<WhatsAppProvider>(
      create: (context) => WhatsAppProvider(
        context.read<WhatsAppService>(),
      ),
    ),
  ],
  child: const MyApp(),
)
```

### Step 4: Use WhatsApp Provider in Invoice Creation

```dart
// In your invoice form screen
final whatsappProvider = context.read<WhatsAppProvider>();

// After invoice is created
final newInvoice = await invoiceProvider.createInvoice();

if (newInvoice != null) {
  // Send via WhatsApp
  final success = await whatsappProvider.sendInvoiceWithAutoMessage(
    customerPhone: invoiceProvider.editingCustomerPhone,
    invoice: newInvoice,
    items: invoiceProvider.editingItems,
  );
  
  if (success) {
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Invoice sent to ${invoiceProvider.editingCustomerName} via WhatsApp')),
    );
  }
}
```

## Message Templates

### Default Format

```
Hello [Customer Name],

Thank you for your purchase from Siddhivinayak Enterprise.

Invoice Details:
━━━━━━━━━━━━━━━━
Invoice No: INV-2024-0001

• Product A × 2 = ₹500
• Product B × 1 = ₹1200

━━━━━━━━━━━━━━━━
Subtotal: ₹1700
Tax: ₹306

Total Amount: ₹2006

We appreciate your business.

Thank You,
Siddhivinayak Enterprise
```

### Short Format

```
Hello [Customer Name],

Thank you for your purchase!

Invoice: INV-2024-0001
Amount: ₹2006

Items:
• Product A × 2
• Product B × 1
... and 3 more items

Thank You,
Siddhivinayak Enterprise
```

## Platform-Specific Handling

### Android

- Uses direct WhatsApp app launch via intent
- Optimized for Android devices
- Falls back to URL if intent fails

### iOS

- Uses URL launcher to open WhatsApp
- Checks for WhatsApp app availability
- Opens in-app browser if WhatsApp not installed

### Web

- Opens WhatsApp Web in new tab
- Handles WhatsApp Web URL properly

### Desktop (Windows, macOS, Linux)

- Opens WhatsApp Web in default browser
- Falls back to URL launcher

## Error Handling

### Common Errors

1. **Invalid Phone Number**
   ```
   ValidationException: Invalid phone number
   ```
   Solution: Normalize phone number before sending

2. **WhatsApp Not Installed**
   ```
   Failed to launch WhatsApp
   ```
   Solution: Show user-friendly error message

3. **Network Error**
   ```
   Failed to send WhatsApp invoice
   ```
   Solution: Retry mechanism or manual intervention

### Error Codes

- `INVALID_PHONE`: Phone number format is invalid
- `WHATSAPP_NOT_INSTALLED`: WhatsApp app not found
- `NETWORK_ERROR`: Network connectivity issue
- `MESSAGE_TOO_LONG`: Message exceeds character limit (65536 chars)

## Future Enhancements

### WhatsApp Business API Integration

The architecture is ready for WhatsApp Business API integration:

```dart
// Future implementation
Future<bool> sendInvoiceViaBusinessAPI({
  required String customerPhone,
  required InvoiceModel invoice,
}) async {
  final api = WhatsAppBusinessAPI();
  return await api.sendMessage(
    to: customerPhone,
    template: 'invoice_template',
    parameters: {
      'invoice_number': invoice.invoiceNumber,
      'amount': invoice.totalAmount.toString(),
      'date': formatDate(invoice.invoiceDate),
    },
  );
}
```

### PDF Attachment Support

```dart
// Future implementation
await service.sendInvoiceWithPDF(
  customerPhone: phone,
  invoice: invoice,
  pdfPath: generatedPdfPath,
);
```

### Automated Scheduled Messages

```dart
// Future implementation
await service.scheduleMessage(
  customerPhone: phone,
  invoice: invoice,
  scheduledTime: DateTime.now().add(const Duration(hours: 1)),
);
```

## Testing

### Unit Tests

```dart
void main() {
  group('WhatsAppService', () {
    late WhatsAppService service;
    late WhatsAppRepository repository;

    setUp(() {
      repository = WhatsAppRepository(storage);
      service = WhatsAppService(repository: repository);
    });

    test('should normalize phone number', () {
      final phone = service.normalizePhoneNumber('9876543210');
      expect(phone, '+919876543210');
    });

    test('should validate phone number', () {
      expect(service.isValidPhoneNumber('9876543210'), true);
      expect(service.isValidPhoneNumber('123'), false);
    });
  });
}
```

### Widget Tests

```dart
void main() {
  group('WhatsAppSendButton', () {
    testWidgets('should show WhatsApp icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WhatsAppSendButton(
            invoice: mockInvoice,
            items: [],
            customerPhone: '+919876543210',
          ),
        ),
      );

      expect(find.byIcon(Icons.whatsapp), findsOneWidget);
    });
  });
}
```

## Best Practices

1. **Always Validate Phone Numbers**
   ```dart
   final normalized = WhatsAppHelper.normalizePhoneNumber(phone);
   if (WhatsAppHelper.isValidPhoneNumber(normalized)) {
     // Proceed with sending
   }
   ```

2. **Use Short Format for Long Lists**
   ```dart
   final message = MessageTemplateService.generateInvoiceMessage(
     // ...
     useShortFormat: items.length > 5,
   );
   ```

3. **Handle errors gracefully**
   ```dart
   try {
     await whatsappProvider.sendInvoiceWithAutoMessage(...);
   } catch (e) {
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('Failed: ${e.toString()}')),
     );
   }
   ```

4. **Show loading states**
   ```dart
   final isSending = whatsappProvider.isSending;
   if (isSending) {
     return CircularProgressIndicator();
   }
   ```

5. **Display send history**
   ```dart
   final history = whatsappProvider.sendHistory;
   if (history.isNotEmpty) {
     // Show last sent message date
   }
   ```

## Troubleshooting

### WhatsApp Not Opening

1. Check if WhatsApp is installed
2. Verify phone number format
3. Check network connectivity
4. Try URL launcher fallback

### Messages Not Being Sent

1. Verify phone number format
2. Check if message is too long
3. Ensure proper URL encoding
4. Check WhatsApp app permissions

### History Not Saving

1. Verify Hive box is initialized
2. Check storage permissions
3. Verify WhatsAppRepository is created correctly

## Support

For issues or questions:
- Check the architecture documentation
- Review error logs in Logger
- Check WhatsApp app permissions
- Verify phone number format

## License

This module is part of Siddhivinayak Enterprise ERP and follows the same license.