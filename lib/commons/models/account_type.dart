import 'package:flutter/material.dart';
import '../models/account_subtype.dart';

enum AccountType {
  CREDIT('Credit'),
  DEPOSITORY('Depository'),
  INVESTMENT('Investment'),
  LOAN('Loan'),
  BROKERAGE('Brokerage'),
  OTHER('Other'),
  ENUM_UNKNOWN('Uncategorized');

  final String value;

  const AccountType(this.value);

  @override
  String toString() => value;

  static AccountType fromValue(String value) {
    return AccountType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AccountType.ENUM_UNKNOWN,
    );
  }
}

IconData getIconForAccountType(AccountType accountType) {
  switch (accountType) {
    case AccountType.INVESTMENT:
      return Icons.trending_up;
    case AccountType.CREDIT:
      return Icons.credit_card;
    case AccountType.DEPOSITORY:
      return Icons.account_balance;
    case AccountType.LOAN:
      return Icons.attach_money;
    case AccountType.BROKERAGE:
      return Icons.business_center;
    case AccountType.OTHER:
    default:
      return Icons.battery_unknown;
  }
}

List<AccountSubtype> getAccountSubtypes(AccountType accountType) {
  switch (accountType) {
    case AccountType.CREDIT:
      return [
        AccountSubtype.CREDIT_CARD,
        AccountSubtype.PAYPAL,
        AccountSubtype.OVERDRAFT,
        AccountSubtype.LINE_OF_CREDIT,
      ];
    case AccountType.DEPOSITORY:
      return [
        AccountSubtype.CD,
        AccountSubtype.CHECKING,
        AccountSubtype.SAVINGS,
        AccountSubtype.MONEY_MARKET,
        AccountSubtype.PAYROLL,
        AccountSubtype.PREPAID,
        AccountSubtype.EBT,
        AccountSubtype.CASH_ISA,
      ];
    case AccountType.INVESTMENT:
      return [
        AccountSubtype.as_401A,
        AccountSubtype.as_401K,
        AccountSubtype.as_403B,
        AccountSubtype.as_457B,
        AccountSubtype.as_529,
        AccountSubtype.CASH_MANAGEMENT,
        AccountSubtype.EDUCATION_SAVINGS_ACCOUNT,
        AccountSubtype.FIXED_ANNUITY,
        AccountSubtype.GIC,
        AccountSubtype.HEALTH_REIMBURSEMENT_ARRANGEMENT,
        AccountSubtype.HSA,
        AccountSubtype.ISA,
        AccountSubtype.IRA,
        AccountSubtype.LIF,
        AccountSubtype.LIFE_INSURANCE,
        AccountSubtype.LIRA,
        AccountSubtype.LRIF,
        AccountSubtype.LRSP,
        AccountSubtype.NON_CUSTODIAL_WALLET,
        AccountSubtype.NON_TAXABLE_BROKERAGE_ACCOUNT,
        AccountSubtype.OTHER_ANNUITY,
        AccountSubtype.OTHER_INSURANCE,
        AccountSubtype.PRIF,
        AccountSubtype.RDSP,
        AccountSubtype.RESP,
        AccountSubtype.RLIF,
        AccountSubtype.RRIF,
        AccountSubtype.PENSION,
        AccountSubtype.PROFIT_SHARING_PLAN,
        AccountSubtype.RETIREMENT,
        AccountSubtype.ROTH,
        AccountSubtype.ROTH_401K,
        AccountSubtype.RRSP,
        AccountSubtype.SEP_IRA,
        AccountSubtype.SIMPLE_IRA,
        AccountSubtype.SIPP,
        AccountSubtype.STOCK_PLAN,
        AccountSubtype.THRIFT_SAVINGS_PLAN,
        AccountSubtype.TFSA,
        AccountSubtype.TRUST,
        AccountSubtype.UGMA,
        AccountSubtype.UTMA,
        AccountSubtype.VARIABLE_ANNUITY,
        AccountSubtype.KEOGH,
        AccountSubtype.MUTUAL_FUND,
        AccountSubtype.SARSEP,
      ];
    case AccountType.LOAN:
      return [
        AccountSubtype.AUTO,
        AccountSubtype.BUSINESS,
        AccountSubtype.COMMERCIAL,
        AccountSubtype.CONSTRUCTION,
        AccountSubtype.CONSUMER,
        AccountSubtype.HOME_EQUITY,
        AccountSubtype.LOAN,
        AccountSubtype.MORTGAGE,
        AccountSubtype.STUDENT,
      ];
    case AccountType.BROKERAGE:
      return [
        AccountSubtype.BROKERAGE,
        AccountSubtype.CRYPTO_EXCHANGE,
      ];
    case AccountType.OTHER:
      return [
        AccountSubtype.RECURRING,
        AccountSubtype.REWARDS,
        AccountSubtype.SAFE_DEPOSIT,
        AccountSubtype.OTHER,
      ];
    default:
      return [];
  }
}

AccountType getAccountTypeFromSubtype(AccountSubtype accountSubtype) {
  switch (accountSubtype) {
    // AccountSubtypes under CREDIT
    case AccountSubtype.CREDIT_CARD:
    case AccountSubtype.PAYPAL:
    case AccountSubtype.OVERDRAFT:
    case AccountSubtype.LINE_OF_CREDIT:
      return AccountType.CREDIT;

    // AccountSubtypes under DEPOSITORY
    case AccountSubtype.CD:
    case AccountSubtype.CHECKING:
    case AccountSubtype.SAVINGS:
    case AccountSubtype.MONEY_MARKET:
    case AccountSubtype.PAYROLL:
    case AccountSubtype.PREPAID:
    case AccountSubtype.EBT:
    case AccountSubtype.CASH_ISA:
      return AccountType.DEPOSITORY;

    // AccountSubtypes under INVESTMENT
    case AccountSubtype.as_401A:
    case AccountSubtype.as_401K:
    case AccountSubtype.as_403B:
    case AccountSubtype.as_457B:
    case AccountSubtype.as_529:
    case AccountSubtype.CASH_MANAGEMENT:
    case AccountSubtype.EDUCATION_SAVINGS_ACCOUNT:
    case AccountSubtype.FIXED_ANNUITY:
    case AccountSubtype.GIC:
    case AccountSubtype.HEALTH_REIMBURSEMENT_ARRANGEMENT:
    case AccountSubtype.HSA:
    case AccountSubtype.ISA:
    case AccountSubtype.IRA:
    case AccountSubtype.LIF:
    case AccountSubtype.LIFE_INSURANCE:
    case AccountSubtype.LIRA:
    case AccountSubtype.LRIF:
    case AccountSubtype.LRSP:
    case AccountSubtype.NON_CUSTODIAL_WALLET:
    case AccountSubtype.NON_TAXABLE_BROKERAGE_ACCOUNT:
    case AccountSubtype.OTHER_ANNUITY:
    case AccountSubtype.OTHER_INSURANCE:
    case AccountSubtype.PRIF:
    case AccountSubtype.RDSP:
    case AccountSubtype.RESP:
    case AccountSubtype.RLIF:
    case AccountSubtype.RRIF:
    case AccountSubtype.PENSION:
    case AccountSubtype.PROFIT_SHARING_PLAN:
    case AccountSubtype.RETIREMENT:
    case AccountSubtype.ROTH:
    case AccountSubtype.ROTH_401K:
    case AccountSubtype.RRSP:
    case AccountSubtype.SEP_IRA:
    case AccountSubtype.SIMPLE_IRA:
    case AccountSubtype.SIPP:
    case AccountSubtype.STOCK_PLAN:
    case AccountSubtype.THRIFT_SAVINGS_PLAN:
    case AccountSubtype.TFSA:
    case AccountSubtype.TRUST:
    case AccountSubtype.UGMA:
    case AccountSubtype.UTMA:
    case AccountSubtype.VARIABLE_ANNUITY:
    case AccountSubtype.KEOGH:
    case AccountSubtype.MUTUAL_FUND:
    case AccountSubtype.SARSEP:
      return AccountType.INVESTMENT;

    // AccountSubtypes under LOAN
    case AccountSubtype.AUTO:
    case AccountSubtype.BUSINESS:
    case AccountSubtype.COMMERCIAL:
    case AccountSubtype.CONSTRUCTION:
    case AccountSubtype.CONSUMER:
    case AccountSubtype.HOME_EQUITY:
    case AccountSubtype.LOAN:
    case AccountSubtype.MORTGAGE:
    case AccountSubtype.STUDENT:
      return AccountType.LOAN;

    // AccountSubtypes under BROKERAGE
    case AccountSubtype.BROKERAGE:
    case AccountSubtype.CRYPTO_EXCHANGE:
      return AccountType.BROKERAGE;

    // AccountSubtypes under OTHER
    case AccountSubtype.RECURRING:
    case AccountSubtype.REWARDS:
    case AccountSubtype.SAFE_DEPOSIT:
    case AccountSubtype.OTHER:
      return AccountType.OTHER;

    default:
      throw ArgumentError('Unknown AccountSubtype: $accountSubtype');
  }
}

Map<String, List<AccountSubtype>> getAccountTypeNameToSubtypeMap() {
  // Create an empty map to store the results
  Map<String, List<AccountSubtype>> accountTypeMap = {};

  // Start with "Suggested" to have most common accountSubtype enums
  accountTypeMap["SUGGESTED"] = [
    AccountSubtype.CREDIT_CARD,
    AccountSubtype.CHECKING,
    AccountSubtype.SAVINGS,
        AccountSubtype.BROKERAGE,
    AccountSubtype.HSA,
    AccountSubtype.as_401K,
  ];

  // Iterate over all AccountType values
  for (var accountType in AccountType.values) {
    if (accountType == AccountType.ENUM_UNKNOWN) {
      continue;
    }
    // Get the name of the AccountType as a string
    String accountTypeName = accountType.name;

    // Get the corresponding list of AccountSubtypes using the existing method
    List<AccountSubtype> subtypes = getAccountSubtypes(accountType);

    // Add the entry to the map
    accountTypeMap[accountTypeName] = subtypes;
  }

  return accountTypeMap;
}