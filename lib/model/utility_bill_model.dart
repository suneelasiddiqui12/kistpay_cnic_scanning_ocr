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
  });
}
