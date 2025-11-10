import 'package:intl/intl.dart';

class TFormatter {
  static String formatDate(DateTime? date) {
    date ??= DateTime.now();
    return DateFormat("dd-MM-yyyy").format(date);
  }

  static String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'en_NG', symbol: '₦').format(amount);
  }

  static String formatPhoneNumber(String phoneNumber) {
    // Remove all non-numeric characters
    phoneNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

    if (phoneNumber.length == 11 && phoneNumber.startsWith('0')) {
      // Format as (080) 123-4567
      final RegExp regExp = RegExp(r'(\d{3})(\d{3})(\d{4})');
      return phoneNumber.replaceAllMapped(
          regExp, (Match match) => '(${match[1]}) ${match[2]}-${match[3]}');
    } else if (phoneNumber.length == 13 && phoneNumber.startsWith('+234')) {
      // Convert +2348012345678 to (234) 801-234-5678
      final RegExp regExp = RegExp(r'(\+234)(\d{3})(\d{3})(\d{4})');
      return phoneNumber.replaceAllMapped(regExp,
          (Match match) => '(${match[1]}) ${match[2]}-${match[3]}-${match[4]}');
    } else if (phoneNumber.length == 14 && phoneNumber.startsWith('00234')) {
      // Convert 002348012345678 to (234) 801-234-5678
      final RegExp regExp = RegExp(r'(00234)(\d{3})(\d{3})(\d{4})');
      return phoneNumber.replaceAllMapped(
          regExp,
          (Match match) =>
              '(${match[1]?.replaceAll('00', '+')}) ${match[2]}-${match[3]}-${match[4]}');
    }

    return phoneNumber; // Return as is if format is unknown
  }

  static String internationalFormatPhoneNumber(
      String phoneNumber, String countryCode) {
    phoneNumber = phoneNumber.replaceAll(
        RegExp(r'\D'), ''); // Remove non-numeric characters

    if (phoneNumber.length >= 10 && phoneNumber.length <= 13) {
      final RegExp regExp = RegExp(r'(\d{3})(\d{3})(\d{4,})');
      return '+$countryCode ${phoneNumber.replaceAllMapped(regExp, (Match match) => '${match[1]} ${match[2]} ${match[3]}')}';
    } else {
      return '+$countryCode $phoneNumber'; // Fallback for unknown formats
    }
  }
}
