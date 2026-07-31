import 'invoice_item.dart';

enum OrderType { takeAway, delivery }
enum PaymentMethod { cash, upi, card, split }
enum InvoiceStatus { pending, completed, cancelled, refunded }

class Invoice {
  final String id;
  final String invoiceNumber;
  final DateTime timestamp;
  final String customerId;
  final double subtotal;
  final double tax;
  final double discount;
  final double grandTotal;
  final PaymentMethod paymentMethod;
  final OrderType orderType;
  final InvoiceStatus status;
  final String userId;
  final String deliveryAddress;
  final String deliveryFee;
  final String riderName;
  final String deliveryStatus;
  final List<InvoiceItem> items;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.timestamp,
    required this.customerId,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.grandTotal,
    required this.paymentMethod,
    required this.orderType,
    required this.status,
    required this.userId,
    this.deliveryAddress = '',
    this.deliveryFee = '0',
    this.riderName = '',
    this.deliveryStatus = '',
    this.items = const [],
  });

  factory Invoice.fromMap(Map<String, Object?> map) {
    return Invoice(
      id: map['id'] as String,
      invoiceNumber: map['invoice_number'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      customerId: map['customer_id'] as String,
      subtotal: (map['subtotal'] as num).toDouble(),
      tax: (map['tax'] as num).toDouble(),
      discount: (map['discount'] as num).toDouble(),
      grandTotal: (map['grand_total'] as num).toDouble(),
      paymentMethod: PaymentMethod.values.firstWhere((value) => value.name == map['payment_method']),
      orderType: OrderType.values.firstWhere((value) => value.name == map['order_type']),
      status: InvoiceStatus.values.firstWhere((value) => value.name == map['status']),
      userId: map['user_id'] as String,
      deliveryAddress: map['delivery_address'] as String? ?? '',
      deliveryFee: map['delivery_fee'] as String? ?? '0',
      riderName: map['rider_name'] as String? ?? '',
      deliveryStatus: map['delivery_status'] as String? ?? '',
      items: const [],
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'timestamp': timestamp.toIso8601String(),
      'customer_id': customerId,
      'subtotal': subtotal,
      'tax': tax,
      'discount': discount,
      'grand_total': grandTotal,
      'payment_method': paymentMethod.name,
      'order_type': orderType.name,
      'status': status.name,
      'user_id': userId,
      'delivery_address': deliveryAddress,
      'delivery_fee': deliveryFee,
      'rider_name': riderName,
      'delivery_status': deliveryStatus,
    };
  }
}
