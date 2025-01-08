import '../utils/date_time.dart';
import '../models/frequency.dart';

double getMonthlyAmountByFrequency(amount, frequency) {
  switch (frequency) {
    case Frequency.once:
      return 0;
    case Frequency.daily:
      return amount * getDaysInMonth(DateTime.now());
    case Frequency.weekly:
      return amount * getWeeksInMonth(DateTime.now());
    case Frequency.biWeekly:
      return amount * getTwoWeeksInMonth(DateTime.now());
    case Frequency.monthly:
      return amount;
    case Frequency.quarterly:
      return amount / 4;
    default:
      return amount / 12;
  }
}

int compareDoubles(double a, double b, {double tolerance = 1e-10}) {
  final diff = a - b;

  if (diff < -tolerance) {
    return -1; // a is less than b
  } else if (diff > tolerance) {
    return 1; // a is greater than b
  } else {
    return 0; // a and b are approximately equal
  }
}


String formatNumberWithoutDecimals(double number) {

  // Add commas for thousands separation
  List<String> parts = number.toString().split('.');
  String integerPart = parts[0].replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]},',
  );
  return integerPart;
}

String formatNumber(double? number) {
  // Uncomment if "00" digits after decimal is not needed
  // String formattedNumber = number.toStringAsFixed(2).replaceAll(RegExp(r'0*$'), ''); 
  if (number == null) {
    return '0.0';
  }
  String formattedNumber = number.toStringAsFixed(2); 
  if (formattedNumber.endsWith('.')) {
    formattedNumber = formattedNumber.substring(0, formattedNumber.length - 1);
  }

  // Add commas for thousands separation
  List<String> parts = formattedNumber.split('.');
  String integerPart = parts[0].replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]},',
  );

  // If there is a fractional part, concatenate it back
  return (parts.length == 1) ? integerPart : '$integerPart.${parts[1]}';
}
