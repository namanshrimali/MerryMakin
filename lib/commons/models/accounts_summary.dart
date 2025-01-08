import '../models/account_base.dart';
import '../models/account_type.dart';

class AccountsSummary {
  late Map<AccountType, List<AccountBase>> groupedAccountByType;
  late double totalCost;
  late Map<AccountType, double> accountTypeCosts;

  // TransactionSummary(this.groupedAccountByType, this.totalCost, this.categoryCosts);
  AccountsSummary(List<AccountBase?> accounts, List<AccountType> accountTypes, {List<AccountType>? shouldBePresentAccountTypes}) {
    if (accounts.isEmpty) {
      groupedAccountByType = {};
      totalCost = 0;
      accountTypeCosts = {};
      return;
    }
    _groupAccountsByAccountType(accounts, accountTypes, shouldBePresentAccountTypes);
    totalCost = _calculateTotalCost(accounts);
    accountTypeCosts = _calculateAccountTypeCosts(groupedAccountByType);

    // Sub-optimal but chatgpt did not come up with better logic and I don't have time for writing new one

    // Filter out categories not present in customCategories
    groupedAccountByType
        .removeWhere((category, _) => !accountTypes.contains(category));
    accountTypeCosts
        .removeWhere((category, _) => !accountTypes.contains(category));
  }

  Map<AccountType, double> _calculateAccountTypeCosts(
      Map<AccountType, List<AccountBase>> groupedAccounts) {
    return groupedAccounts.map((accountType, accounts) {
      double total =
          accounts.fold(0.0, (sum, account) => sum + account.balances!.current);
      return MapEntry(accountType, total);
    });
  }

  double _calculateTotalCost(List<AccountBase?> accounts) {
    return accounts.fold(
        0.0,
        (sum, account) =>
            sum + (account == null ? 0.0 : account.balances!.current));
  }

  void _groupAccountsByAccountType(
    List<AccountBase?> accounts,
    List<AccountType> accountTypes,
    List<AccountType>? shouldBePresentAccountTypes,
  ) {
    groupedAccountByType = {};
    accountTypes
    .where((accountType) => shouldBePresentAccountTypes == null || shouldBePresentAccountTypes.contains(accountType))
    .forEach((accountType) {
      groupedAccountByType.putIfAbsent(accountType, () => []);
    });
    accounts.forEach((account) {
      if (account != null) {
        groupedAccountByType.putIfAbsent(account.type, () => []).add(account);
      }
    });
  }
}
