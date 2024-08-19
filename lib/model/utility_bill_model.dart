class UtilityBillModel {
  final String name;
  final String address;
  final String city;
  final String amountPayable;
  final String issueDate;
  final String dueDate;
  final String paidDate;
  bool isVerified;
  final List<String> datesAfterMMYY;
  final List<String> datesAfterPayDate;
  final List<String> billedAmounts;
  final List<String> payments;
  final bool? hasLatePayments;

  UtilityBillModel({
     this.name = '',
     this.address = '',
     this.city = '',
     this.amountPayable = '',
     this.issueDate = '',
     this.dueDate = '',
     this.paidDate = '',
    this.isVerified = false,
    this.datesAfterMMYY = const [],
    this.datesAfterPayDate = const [],
    this.billedAmounts = const [],
    this.payments = const [],
    this.hasLatePayments,

  });
}
