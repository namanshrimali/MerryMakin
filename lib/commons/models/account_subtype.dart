enum AccountSubtype {
  as_401A('401A Retirement Plan'),
  as_401K('401K Retirement Plan'),
  as_403B('403B Retirement Plan'),
  as_457B('457B Deferred Compensation Plan'),
  as_529('529 Education Savings Plan'),
  BROKERAGE('Brokerage Account'),
  CASH_ISA('Cash Individual Savings Account (ISA)'),
  CRYPTO_EXCHANGE('Cryptocurrency Exchange'),
  EDUCATION_SAVINGS_ACCOUNT('Education Savings Account'),
  EBT('Electronic Benefits Transfer (EBT)'),
  FIXED_ANNUITY('Fixed Annuity'),
  GIC('Guaranteed Investment Certificate (GIC)'),
  HEALTH_REIMBURSEMENT_ARRANGEMENT('Health Reimbursement Arrangement'),
  HSA('Health Savings Account (HSA)'),
  ISA('Individual Savings Account (ISA)'),
  IRA('Individual Retirement Account (IRA)'),
  LIF('Life Income Fund (LIF)'),
  LIFE_INSURANCE('Life Insurance'),
  LIRA('Locked-In Retirement Account (LIRA)'),
  LRIF('Locked-In Retirement Income Fund (LRIF)'),
  LRSP('Locked-In Retirement Savings Plan (LRSP)'),
  NON_CUSTODIAL_WALLET('Non-Custodial Wallet'),
  NON_TAXABLE_BROKERAGE_ACCOUNT('Non-Taxable Brokerage Account'),
  OTHER('Other'),
  OTHER_INSURANCE('Other Insurance'),
  OTHER_ANNUITY('Other Annuity'),
  PRIF('Prescribed Retirement Income Fund (PRIF)'),
  RDSP('Registered Disability Savings Plan (RDSP)'),
  RESP('Registered Education Savings Plan (RESP)'),
  RLIF('Registered Life Income Fund (RLIF)'),
  RRIF('Registered Retirement Income Fund (RRIF)'),
  PENSION('Pension Plan'),
  PROFIT_SHARING_PLAN('Profit Sharing Plan'),
  RETIREMENT('Retirement Account'),
  ROTH('Roth IRA'),
  ROTH_401K('Roth 401K'),
  RRSP('Registered Retirement Savings Plan (RRSP)'),
  SEP_IRA('Simplified Employee Pension (SEP IRA)'),
  SIMPLE_IRA('Simple IRA'),
  SIPP('Self-Invested Personal Pension (SIPP)'),
  STOCK_PLAN('Stock Plan'),
  THRIFT_SAVINGS_PLAN('Thrift Savings Plan'),
  TFSA('Tax-Free Savings Account (TFSA)'),
  TRUST('Trust Account'),
  UGMA('UGMA Account'),
  UTMA('UTMA Account'),
  VARIABLE_ANNUITY('Variable Annuity'),
  CREDIT_CARD('Credit Card'),
  PAYPAL('PayPal Account'),
  CD('Certificate of Deposit (CD)'),
  CHECKING('Checking Account'),
  SAVINGS('Savings Account'),
  MONEY_MARKET('Money Market Account'),
  PREPAID('Prepaid Card'),
  AUTO('Auto Loan'),
  BUSINESS('Business Loan'),
  COMMERCIAL('Commercial Loan'),
  CONSTRUCTION('Construction Loan'),
  CONSUMER('Consumer Loan'),
  HOME_EQUITY('Home Equity Loan'),
  LOAN('Loan'),
  MORTGAGE('Mortgage'),
  OVERDRAFT('Overdraft Account'),
  LINE_OF_CREDIT('Line of Credit'),
  STUDENT('Student Loan'),
  CASH_MANAGEMENT('Cash Management Account'),
  KEOGH('Keogh Plan'),
  MUTUAL_FUND('Mutual Fund'),
  RECURRING('Recurring Payment'),
  REWARDS('Rewards Program'),
  SAFE_DEPOSIT('Safe Deposit Box'),
  SARSEP('SARSEP'),
  PAYROLL('Payroll Account');

  final String value;
  const AccountSubtype(this.value);

  @override
  String toString() => value;

  static AccountSubtype fromValue(String value) {
    return AccountSubtype.values.firstWhere((e) => e.value == value,
        orElse: () => AccountSubtype.OTHER);
  }
}
