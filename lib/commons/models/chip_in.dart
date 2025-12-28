import 'country_currency.dart';

class ChipIn {
  double? amount;
  CountryCurrency? currency;
  String? venmoUserId;
  String? paypalUserId;
  String? zelleUserId;
  String? cashappUserId;

  ChipIn({
    this.amount,
    this.currency,
    this.venmoUserId,
    this.paypalUserId,
    this.zelleUserId,
    this.cashappUserId,
  });

  factory ChipIn.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return ChipIn();
    }
    String? _getValue(dynamic value) {
      if (value == null) return null;
      final str = value.toString().trim();
      return str.isEmpty ? null : str;
    }
    return ChipIn(
      amount: map['amount'] != null ? (map['amount'] is double ? map['amount'] : double.tryParse(map['amount'].toString())) : null,
      currency: map['currency'] != null ? CountryCurrency.values.firstWhere(
        (cc) => cc.name == map['currency'],
        orElse: () => CountryCurrency.UnitedStatesDollarUnitedStates,
      ) : null,
      venmoUserId: _getValue(map['venmoUserId']),
      paypalUserId: _getValue(map['paypalUserId']),
      zelleUserId: _getValue(map['zelleUserId']),
      cashappUserId: _getValue(map['cashappUserId']),
    );
  }

  List<String> getPaymentMethodLabelsList() {
    return [
      if (venmoUserId != null && venmoUserId!.isNotEmpty) 'Venmo',
      if (paypalUserId != null && paypalUserId!.isNotEmpty) 'PayPal',
      if (zelleUserId != null && zelleUserId!.isNotEmpty) 'Zelle',
      if (cashappUserId != null && cashappUserId!.isNotEmpty) 'CashApp',
    ];
  }

  String getPaymentMethodLabels() {
    return getPaymentMethodLabelsList().join('/');
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'currency': currency?.name,
      'venmoUserId': venmoUserId,
      'paypalUserId': paypalUserId,
      'zelleUserId': zelleUserId,
      'cashappUserId': cashappUserId,
    };
  }

  String? getPaymentMethodUserIdViaLabel(String label) {
    switch (label) {
      case 'Venmo':
        return venmoUserId;
      case 'PayPal':
        return paypalUserId;
    case 'Zelle':
      return zelleUserId;
    case 'CashApp':
      return cashappUserId;
    default:
      return null;
  }}

  String? getPaymentMethodUserId(String label) {
    switch (label) {
      case 'Venmo User ID':
        return venmoUserId;
      case 'PayPal User ID':
        return paypalUserId;
      case 'Zelle User ID':
        return zelleUserId;
      case 'CashApp User ID':
        return cashappUserId;
      default:
        return null;
    }
  }
  
  String? getEventChipInDescriptionString() {
    if (amount != null && amount! > 0 && currency != null) {
      return "${currency?.getCurrencySymbol()}${amount!.toStringAsFixed(2)} per person${getPaymentMethodString()}";
    }
    return null;
  }

  String getPaymentMethodString() {
    if (hasAnyPaymentMethod) {
      return ' via ' + getPaymentMethodLabels();
    }
    return '';
  }

  String getChipInAmountString() {
    if (amount != null && amount! > 0 && currency != null) {
      return '${currency?.getCurrencySymbol()}${amount!.toStringAsFixed(2)} per person';
    }
    return '';
  }

  bool get hasAnyPaymentMethod {
    return
        ((venmoUserId != null && venmoUserId!.isNotEmpty) ||
        (paypalUserId != null && paypalUserId!.isNotEmpty) ||
        (zelleUserId != null && zelleUserId!.isNotEmpty) ||
        (cashappUserId != null && cashappUserId!.isNotEmpty));
  }

  @override
  String toString() {
    return 'ChipIn{amount: $amount, currency: $currency, venmoUserId: $venmoUserId, paypalUserId: $paypalUserId, zelleUserId: $zelleUserId, cashappUserId: $cashappUserId}';
  }
}

