class CnicOcrModel {
  String cnicNumber;
  String cnicIssueDate;
  String cnicHolderName;
  String cnicExpiryDate;
  String cnicHolderDateOfBirth;
  String imagePath;
  String selfieImagePath;

  CnicOcrModel({
    this.cnicNumber = "",
    this.cnicIssueDate = "",
    this.cnicHolderName = "",
    this.cnicExpiryDate = "",
    this.cnicHolderDateOfBirth = "",
    this.imagePath = "",
    this.selfieImagePath = " "
  });

  @override
  String toString() {
    var string = '';
    string += cnicNumber.isNotEmpty ? 'Cnic Number = $cnicNumber\n' : '';
    string += cnicExpiryDate.isNotEmpty ? 'Cnic Expiry Date = $cnicExpiryDate\n' : '';
    string += cnicIssueDate.isNotEmpty ? 'Cnic Issue Date = $cnicIssueDate\n' : '';
    string += cnicHolderName.isNotEmpty ? 'Cnic Holder Name = $cnicHolderName\n' : '';
    string += cnicHolderDateOfBirth.isNotEmpty ? 'Cnic Holder DoB = $cnicHolderDateOfBirth\n' : '';
    string += imagePath.isNotEmpty ? 'Image Path = $imagePath\n' : '';
    string += selfieImagePath.isNotEmpty ? 'Selfie Image Path = $selfieImagePath\n' : '';
    return string;
  }
}
