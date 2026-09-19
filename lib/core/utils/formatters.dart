import 'package:intl/intl.dart';

class AppFormatters {
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final NumberFormat _compactCurrencyFormatter = NumberFormat.compactCurrency(
    locale: 'en_IN',
    symbol: '₹',
  );

  static final NumberFormat _numberFormatter = NumberFormat('#,##,###');

  static String formatCurrency(num amount) {
    return _currencyFormatter.format(amount);
  }

  static String formatCompactCurrency(num amount) {
    return _compactCurrencyFormatter.format(amount);
  }

  static String formatNumber(num number) {
    return _numberFormatter.format(number);
  }

  static String formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  static String formatDateShort(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return DateFormat('dd MMM yyyy').format(dateTime);
  }
}
