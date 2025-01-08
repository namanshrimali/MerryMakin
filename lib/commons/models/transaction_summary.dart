import 'transaction.dart';
import 'transaction_categories.dart';

class TransactionSummary {
  late Map<TransactionCategory, List<MoneyTransaction>> groupedTransactions;
  late double totalCost;
  late Map<TransactionCategory, double> categoryCosts;

  // TransactionSummary(this.groupedTransactions, this.totalCost, this.categoryCosts);
  TransactionSummary(List<MoneyTransaction>? transactions,
      List<TransactionCategory> transactionCategories) {
    groupedTransactions = transactions == null ? {} :
        groupTransactionsByCategory(transactions);
    totalCost = transactions == null ? 0 : calculateTotalCost(transactions);
    categoryCosts =
        calculateCategoryCosts(groupedTransactions);

    // Sub-optimal but chatgpt did not come up with better logic and I don't have time for writing new one

    // Filter out categories not present in customCategories
    groupedTransactions.removeWhere(
        (category, _) => !transactionCategories.contains(category));
    categoryCosts.removeWhere(
        (category, _) => !transactionCategories.contains(category));
  }

  Map<TransactionCategory, List<MoneyTransaction>> groupTransactionsByCategory(
    List<MoneyTransaction> transactions) {
  return transactions.fold({},
      (Map<TransactionCategory, List<MoneyTransaction>> grouped,
          MoneyTransaction transaction) {
    grouped
        .putIfAbsent(transaction.transactionCategory, () => [])
        .add(transaction);
    return grouped;
  });
}

double calculateTotalCost(List<MoneyTransaction> transactions) {
  return transactions.fold(0.0, (sum, transaction) => sum + transaction.amount);
}

Map<TransactionCategory, double> calculateCategoryCosts(
    Map<TransactionCategory, List<MoneyTransaction>> groupedTransactions) {
  return groupedTransactions.map((category, transactions) {
    double total =
        transactions.fold(0.0, (sum, transaction) => sum + transaction.amount);
    return MapEntry(category, total);
  });
}

  List<TransactionCategory> getTopNTransactionCategories(int n) {
    // Sort categories based on total cost in descending order
    List<TransactionCategory> sortedCategories = categoryCosts.keys.toList()
      ..sort((a, b) => categoryCosts[b]!.compareTo(categoryCosts[a]!));

    // Take the top N categories
    return sortedCategories.take(n).toList();
  }
}
