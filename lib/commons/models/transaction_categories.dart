import 'package:flutter/material.dart';

enum TransactionCategory {
  none,
  autoAndCommute,
  billsAndUtilities,
  cashAndChecks,
  diningAndDrinks,
  education,
  entertainment,
  feesAndInterestCharges,
  giftAndDonations,
  goalContributions,
  groceries,
  healthAndFitness,
  home,
  hobby,
  income,
  investmentContributions,
  investmentIncome,
  kids,
  loans,
  otherExpenses,
  otherIncome,
  otherTransfersAndPayments,
  personalCare,
  pets,
  rental,
  savingsContributions,
  shopping,
  travel,
}

// enum ExpenseTowardsAsset {
//   cashAndChecks,
//   education,
//   healthAndFitness,
//   investmentContributions,
//   savingsContributions,
//   goalContributions,
// }

extension CategoryExtension on TransactionCategory {
  String get toCategoryString {
    switch (this) {
      case TransactionCategory.autoAndCommute:
        return 'Auto and Commute';
      case TransactionCategory.billsAndUtilities:
        return 'Bills and Utilities';
      case TransactionCategory.diningAndDrinks:
        return 'Dining and Drinks';
      case TransactionCategory.entertainment:
        return 'Entertainment';
      case TransactionCategory.feesAndInterestCharges:
        return 'Fees and Interest Charges';
      case TransactionCategory.giftAndDonations:
        return 'Gift and Donations';
      case TransactionCategory.goalContributions:
        return 'Goal Contributions';
      case TransactionCategory.groceries:
        return 'Groceries';
      case TransactionCategory.home:
        return 'Home';
      case TransactionCategory.kids:
        return 'Kids';
      case TransactionCategory.loans:
        return 'Loans';
      case TransactionCategory.otherExpenses:
        return 'Other Expenses';
      case TransactionCategory.otherTransfersAndPayments:
        return 'Other Transfers and Payments';
      case TransactionCategory.personalCare:
        return 'Personal Care';
      case TransactionCategory.pets:
        return 'Pets';
      case TransactionCategory.shopping:
        return 'Shopping';
      case TransactionCategory.travel:
        return 'Travel';
      case TransactionCategory.cashAndChecks:
        return 'Cash and Checks';
      case TransactionCategory.education:
        return 'Education';
      case TransactionCategory.healthAndFitness:
        return 'Health and Fitness';
      case TransactionCategory.hobby:
        return 'Hobby';
      case TransactionCategory.investmentContributions:
        return 'Investment Contributions';
      case TransactionCategory.savingsContributions:
        return 'Savings Contributions';
      case TransactionCategory.income:
        return 'Income';
      case TransactionCategory.investmentIncome:
        return 'Investment Income';
      case TransactionCategory.rental:
        return 'Rental Income';
      case TransactionCategory.otherIncome:
        return 'Other Income';
      default:
        return 'Uncategorized';
    }
  }
}

TransactionCategory getCategoryFromString(String categoryString) {
  switch (categoryString) {
    case 'Auto and Commute':
      return TransactionCategory.autoAndCommute;
    case 'Bills and Utilities':
      return TransactionCategory.billsAndUtilities;
    case 'Dining and Drinks':
      return TransactionCategory.diningAndDrinks;
    case 'Entertainment':
      return TransactionCategory.entertainment;
    case 'Fees and Interest Charges':
      return TransactionCategory.feesAndInterestCharges;
    case 'Gift and Donations':
      return TransactionCategory.giftAndDonations;
    case 'Goal Contributions':
      return TransactionCategory.goalContributions;
    case 'Groceries':
      return TransactionCategory.groceries;
    case 'Home':
      return TransactionCategory.home;
    case 'Kids':
      return TransactionCategory.kids;
    case 'Loans':
      return TransactionCategory.loans;
    case 'Other Expenses':
      return TransactionCategory.otherExpenses;
    case 'Other Transfers and Payments':
      return TransactionCategory.otherTransfersAndPayments;
    case 'Personal Care':
      return TransactionCategory.personalCare;
    case 'Pets':
      return TransactionCategory.pets;
    case 'Shopping':
      return TransactionCategory.shopping;
    case 'Travel':
      return TransactionCategory.travel;
    case 'Cash and Checks':
      return TransactionCategory.cashAndChecks;
    case 'Education':
      return TransactionCategory.education;
    case 'Health and Fitness':
      return TransactionCategory.healthAndFitness;
    case 'Hobby':
      return TransactionCategory.hobby;
    case 'Investment Contributions':
      return TransactionCategory.investmentContributions;
    case 'Savings Contributions':
      return TransactionCategory.savingsContributions;
    case 'Income':
      return TransactionCategory.income;
    case 'Investment Income':
      return TransactionCategory.investmentIncome;
    case 'Rental Income':
      return TransactionCategory.rental;
    case 'Other Income':
      return TransactionCategory.otherIncome;
    default:
      return TransactionCategory
          .none; // Default to a specific enum value for unmatched strings
  }
}

List<TransactionCategory> getIncomeTransactionCategories() {
  return [
    TransactionCategory.income,
    TransactionCategory.rental,
    TransactionCategory.investmentIncome,
    TransactionCategory.otherIncome
  ];
}

List<TransactionCategory> getAllExpensesCategories() {
  return [
    TransactionCategory.autoAndCommute,
    TransactionCategory.billsAndUtilities,
    TransactionCategory.cashAndChecks,
    TransactionCategory.diningAndDrinks,
    TransactionCategory.education,
    TransactionCategory.entertainment,
    TransactionCategory.feesAndInterestCharges,
    TransactionCategory.goalContributions,
    TransactionCategory.giftAndDonations,
    TransactionCategory.groceries,
    TransactionCategory.healthAndFitness,
    TransactionCategory.home,
    TransactionCategory.hobby,
    TransactionCategory.investmentContributions,
    TransactionCategory.kids,
    TransactionCategory.loans,
    TransactionCategory.otherExpenses,
    TransactionCategory.otherTransfersAndPayments,
    TransactionCategory.personalCare,
    TransactionCategory.pets,
    TransactionCategory.rental,
    TransactionCategory.shopping,
    TransactionCategory.travel,
  ];
}

IconData getIconForCategory(TransactionCategory category) {
  switch (category) {
    case TransactionCategory.autoAndCommute:
      return Icons.directions_car;
    case TransactionCategory.billsAndUtilities:
      return Icons.receipt;
    case TransactionCategory.cashAndChecks:
      return Icons.attach_money;
    case TransactionCategory.diningAndDrinks:
      return Icons.restaurant;
    case TransactionCategory.education:
      return Icons.school;
    case TransactionCategory.entertainment:
      return Icons.movie;
    case TransactionCategory.feesAndInterestCharges:
      return Icons.payment;
    case TransactionCategory.giftAndDonations:
      return Icons.card_giftcard;
    case TransactionCategory.groceries:
      return Icons.local_grocery_store;
    case TransactionCategory.healthAndFitness:
      return Icons.favorite;
    case TransactionCategory.home:
      return Icons.home;
    case TransactionCategory.hobby:
      return Icons.palette;
    case TransactionCategory.income:
      return Icons.attach_money;
    case TransactionCategory.investmentContributions:
      return Icons.trending_up;
    case TransactionCategory.investmentIncome:
      return Icons.show_chart;
    case TransactionCategory.kids:
      return Icons.child_care;
    case TransactionCategory.loans:
      return Icons.payment;
    case TransactionCategory.otherExpenses:
      return Icons.money_off;
    case TransactionCategory.otherIncome:
      return Icons.attach_money;
    case TransactionCategory.otherTransfersAndPayments:
      return Icons.swap_horiz;
    case TransactionCategory.personalCare:
      return Icons.accessibility;
    case TransactionCategory.pets:
      return Icons.pets;
    case TransactionCategory.rental:
      return Icons.home_work;
    case TransactionCategory.savingsContributions:
      return Icons.account_balance;
    case TransactionCategory.shopping:
      return Icons.shopping_cart;
    case TransactionCategory.travel:
      return Icons.flight;
    // Add more cases as needed
    // Default case
    default:
      return Icons.category; // Replace with a default icon
  }
}
