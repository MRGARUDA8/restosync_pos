import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _rupeeFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  static String format(num value) {
    return _rupeeFormat.format(value);
  }
}
