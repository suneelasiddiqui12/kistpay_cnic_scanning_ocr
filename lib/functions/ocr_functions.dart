import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:app_detection/model/cnic_ocr_model.dart';
import 'package:app_detection/model/utility_bill_model.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;

  class OcrFunctions {
    CnicOcrModel _cnicOcrModel = CnicOcrModel();
  bool isFrontScan = false;
  /// it will pick your image either form Gallery or from Camera
  final ImagePicker _picker = ImagePicker();

  /// it will check the image source
  late ImageSource source;
  /// this method will process the images and extract information from the card
  Future<CnicOcrModel> scanCnic({required InputImage imageToScan}) async {
    List<String> cnicDates = [];
    // GoogleMlKit.vision.languageModelManager();
    TextRecognizer textDetector = GoogleMlKit.vision.textRecognizer();
    final RecognizedText recognisedText =
    await textDetector.processImage(imageToScan);
    bool isNameNext = false;

    for (TextBlock block in recognisedText.blocks) {
      for (TextLine line in block.lines) {
        if (isNameNext) {
          _cnicOcrModel.cnicHolderName = line.text;
          isNameNext = false;
        }
        if (line.text.toLowerCase() == "name" ||
            line.text.toLowerCase() == "nane" ||
            line.text.toLowerCase() == "nam" ||
            line.text.toLowerCase() == "ame") {
          isNameNext = true;
        }
        for (TextElement element in line.elements) {
          String selectedText = element.text;
          if (selectedText.length == 15 &&
              selectedText.contains("-", 5) &&
              selectedText.contains("-", 13)) {
            _cnicOcrModel.cnicNumber = selectedText;
          } else if (selectedText.length == 10 &&
              ((selectedText.contains("/", 2) &&
                  selectedText.contains("/", 5)) ||
                  (selectedText.contains(".", 2) &&
                      selectedText.contains(".", 5)))) {
            cnicDates.add(selectedText.replaceAll(".", "/"));
          }
        }
      }
    }
    if (cnicDates.length > 0 &&
        _cnicOcrModel.cnicExpiryDate.length == 10 &&
        !cnicDates.contains(_cnicOcrModel.cnicExpiryDate)) {
      cnicDates.add(_cnicOcrModel.cnicExpiryDate);
    }
    if (cnicDates.length > 0 &&
        _cnicOcrModel.cnicIssueDate.length == 10 &&
        !cnicDates.contains(_cnicOcrModel.cnicIssueDate)) {
      cnicDates.add(_cnicOcrModel.cnicIssueDate);
    }
    if (cnicDates.length > 0 &&
        _cnicOcrModel.cnicExpiryDate.length == 10 &&
        !cnicDates.contains(_cnicOcrModel.cnicExpiryDate)) {
      cnicDates.add(_cnicOcrModel.cnicExpiryDate);
    }
    if (cnicDates.length > 1) {
      cnicDates = sortDateList(dates: cnicDates);
    }
    if (cnicDates.length == 1 &&
        _cnicOcrModel.cnicHolderDateOfBirth.length != 10) {
      _cnicOcrModel.cnicHolderDateOfBirth = cnicDates[0];

    } else if (cnicDates.length == 2) {
      _cnicOcrModel.cnicIssueDate = cnicDates[0];
      _cnicOcrModel.cnicExpiryDate = cnicDates[1];
    } else if (cnicDates.length == 3) {
      _cnicOcrModel.cnicHolderDateOfBirth = cnicDates[0].replaceAll(".", "/");
      _cnicOcrModel.cnicIssueDate = cnicDates[1].replaceAll(".", "/");
      _cnicOcrModel.cnicExpiryDate = cnicDates[2].replaceAll(".", "/");
    }
    textDetector.close();
    return _cnicOcrModel;
  }

  /// it will sort the dates
  static List<String> sortDateList({required List<String> dates}) {
    List<DateTime> tempList = [];
    DateFormat format = DateFormat("dd/MM/yyyy");
    for (int i = 0; i < dates.length; i++) {
      tempList.add(format.parse(dates[i]));
    }
    tempList.sort((a, b) => a.compareTo(b));
    dates.clear();
    for (int i = 0; i < tempList.length; i++) {
      dates.add(format.format(tempList[i]));
    }
    return dates;
  }

  // OCR for bills
  Future<String> extractText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = GoogleMlKit.vision.textRecognizer();
    final recognizedText = await textRecognizer.processImage(inputImage);
    return recognizedText.text;
  }

    UtilityBillModel parseTextForKE(String text) {
      List<String> lines = text.split('\n');
      String name = _extractName(lines);
      int addressStartIndex = lines.indexOf(name) + 1;
      int cnicIndex = lines.indexWhere((line) => line.contains('CNIC No.') || line.contains('CNIC Number'));
      String address = (cnicIndex != -1)
          ? lines.sublist(addressStartIndex, cnicIndex).join('\n').trim()
          : lines.sublist(addressStartIndex).join('\n').trim();
      String city = text.contains('KE') ? 'Karachi' : '';
      String amountPayable = _extractLineValue(lines, 'Amount Payable');
      String issueDate = _extractLineValue(lines, 'Issue Date');
      String dueDate = _extractDueDate(lines);
      String paidDate = _extractPaidDateIfAvailable(text, lines);
      List<String> datesAfterMMYY = extractNextThreeDatesAfterMMYY(lines);
      List<String> datesAfterPayDate = extractNextThreeDatesAfterPayDate(lines);
      // Extract billed amounts after the "Billed Amount" keyword
      List<String> billedAmounts = extractAmountsAfterKeyword(lines, 'Billed Amount');

      // Extract payment amounts after the "Payment" keyword
      List<String> paymentAmounts = extractAmountsAfterKeyword(lines, 'Payment');
      bool hasLatePayments = checkForLatePayments(billedAmounts, paymentAmounts);

      return UtilityBillModel(
          name: name,
          address: address,
          city: city,
          amountPayable: amountPayable,
          issueDate: issueDate,
          dueDate: dueDate,
          paidDate: paidDate,
          datesAfterMMYY: datesAfterMMYY,
          datesAfterPayDate: datesAfterPayDate,
          payments: paymentAmounts,
          billedAmounts: billedAmounts,
        hasLatePayments: hasLatePayments,
      );

    }

    UtilityBillModel parseTextForHESCO(String text) {
      List<String> lines = text.split('\n');
      String name = _extractNameAndAddress(lines);
      int refNoIndex = lines.indexWhere((line) => line.contains('Reference No.'));
      String city = 'Hyderabad'; // Example city, modify as needed
      String amountPayable = _extractLineValue(lines, 'Current Amount');
      String issueDate = _extractLineValue(lines, 'Bill Date');
      String dueDate = _extractDueDate(lines);
      String paidDate = _extractPaidDateIfAvailable(text, lines);
      List<String> datesAfterMMYY = extractNextThreeDatesAfterMMYY(lines);
      List<String> datesAfterPayDate = extractNextThreeDatesAfterPayDate(lines);
      List<String> billedAmounts = extractAmountsAfterKeyword(lines, 'Current Charges');
      List<String> paymentAmounts = extractAmountsAfterKeyword(lines, 'Paid Amount');
      bool hasLatePayments = checkForLatePayments(billedAmounts, paymentAmounts);

      return UtilityBillModel(
        name: name,
        city: city,
        amountPayable: amountPayable,
        issueDate: issueDate,
        dueDate: dueDate,
        paidDate: paidDate,
        datesAfterMMYY: datesAfterMMYY,
        datesAfterPayDate: datesAfterPayDate,
        payments: paymentAmounts,
        billedAmounts: billedAmounts,
        hasLatePayments: hasLatePayments,
      );
    }


//For KE
  String _extractName(List<String> lines) {
    return lines.firstWhere(
          (line) => line.trim().isNotEmpty && !RegExp(r'\d').hasMatch(line) && line.split(' ').length > 1,
      orElse: () => '',
    );
  }

  String _extractLineValue(List<String> lines, String keyword) {
    int index = lines.indexWhere((line) => line.contains(keyword));
    if (index != -1) {
      // Check the line after the keyword
      if (index + 1 < lines.length) {
        return lines[index + 1].trim();
      }
      // Check the line containing the keyword itself if it might have the value
      else if (RegExp(r'\d{2}-[A-Za-z]{3}-\d{2}').hasMatch(lines[index])) {
        final match = RegExp(r'\d{2}-[A-Za-z]{3}-\d{2}').firstMatch(lines[index]);
        return match?.group(0)?.trim() ?? '';
      }
    }
    return '';
  }

  String _extractDueDate(List<String> lines) {
    // Start looking from the bottom of the document for the due date
    for (int i = lines.length - 1; i >= 0; i--) {
      if (lines[i].contains('Due Date')) {
        // Check the same line for the due date in the format dd-MMM-yy
        final match = RegExp(r'\d{2}-[A-Za-z]{3}-\d{2}').firstMatch(lines[i]);
        if (match != null) {
          return match.group(0)?.trim() ?? '';
        }
        // If not found in the same line, check the previous line
        if (i > 0) {
          final prevLineMatch = RegExp(r'\d{2}-[A-Za-z]{3}-\d{2}').firstMatch(lines[i - 1]);
          if (prevLineMatch != null) {
            return prevLineMatch.group(0)?.trim() ?? '';
          }
        }
      }
    }
    return '';
  }

  String _extractPaidDateIfAvailable(String text, List<String> lines) {
    if (text.contains('PAID')) {
      int dateLineIndex = lines.indexWhere((line) => line.startsWith('Date:'));
      if (dateLineIndex != -1) {
        String dateLine = lines[dateLineIndex];
        // Extracting the date from the format "Date: dd-MMM-yyyy"
        return RegExp(r'\d{2}-[A-Za-z]{3}-\d{4}').firstMatch(dateLine)?.group(0)?.trim() ?? 'No paid date available';
      }
    }
    return '';
  }

  Future<File> cropBottomLeft(File imageFile) async {
      final bytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(Uint8List.fromList(bytes));

      if (originalImage == null) return imageFile;

      // Define the cropping area (e.g., bottom left corner)
      final int cropWidth = originalImage.width ~/ 2; // 50% width
      final int cropHeight = originalImage.height ~/ 2.5; // 40% height (adjust if needed)

      final croppedImage = img.copyCrop(
        originalImage,
        0, // X position (start from left)
        originalImage.height - cropHeight, // Y position (start from the bottom)
        cropWidth,
        cropHeight,
      );

      final croppedFile = File('${imageFile.path}_cropped.png');
      await croppedFile.writeAsBytes(img.encodePng(croppedImage));
      return croppedFile;
    }

    // OCR for the cropped image
    Future<String> extractCroppedText(File croppedImageFile) async {
      final inputImage = InputImage.fromFile(croppedImageFile);
      final textRecognizer = GoogleMlKit.vision.textRecognizer();
      final recognizedText = await textRecognizer.processImage(inputImage);
      return recognizedText.text;
    }

    List<String> extractNextThreeDatesAfterMMYY(List<String> lines) {
      List<String> extractedDates = [];
      final mmYYIndex = lines.indexWhere((line) => line.trim().contains('MM') && line.contains('/YY'));

      if (mmYYIndex != -1 && mmYYIndex + 3 < lines.length) {
        for (int i = 1; i <= 3; i++) {
          if (RegExp(r'\d{2}/\d{2}').hasMatch(lines[mmYYIndex + i])) {
            extractedDates.add(lines[mmYYIndex + i].trim());
          }
        }
      }

      return extractedDates;
    }

    List<String> extractNextThreeDatesAfterPayDate(List<String> lines) {
      List<String> extractedDates = [];
      int payDateIndex = lines.indexWhere((line) => line.trim().contains('Pay-Date'));

      if (payDateIndex != -1) {
        for (int i = payDateIndex + 1; i < lines.length && extractedDates.length < 3; i++) {
          if (RegExp(r'\d{2}-[A-Za-z]{3}-\d{2}').hasMatch(lines[i])) {
            String date = RegExp(r'\d{2}-[A-Za-z]{3}-\d{2}').firstMatch(lines[i])!.group(0)!;
            extractedDates.add(date);
          }
        }
      }

      return extractedDates;
    }

    List<String> extractAmountsAfterKeyword(List<String> lines, String keyword) {
      List<String> extractedAmounts = [];
      bool keywordFound = false;

      for (String line in lines) {
        if (line.trim().contains(keyword)) {
          keywordFound = true;
          continue;
        }
        if (keywordFound) {
          String cleanedLine = line.trim().replaceAll(RegExp(r'[^\d,.]'), '');

          // Ensure this line contains a valid amount
          if (RegExp(r'^\d{1,3}(,\d{3})*(\.\d{2})?$').hasMatch(cleanedLine)) {
            extractedAmounts.add(cleanedLine);
            if (extractedAmounts.length == 3) {
              break;
            }
          }
        }
      }
      return extractedAmounts;
    }

    bool checkForLatePayments(List<String> billedAmounts, List<String> payments) {
      if (billedAmounts.isEmpty || payments.isEmpty) return false;

      for (int i = 0; i < min(billedAmounts.length, payments.length); i++) {
        double billedAmount = double.parse(billedAmounts[i].replaceAll(',', ''));
        double payment = double.parse(payments[i].replaceAll(',', ''));

        if (payment > billedAmount * 1.05) {
          return true;
        }
      }

      return false;
    }


    // For Hyd
    String _extractNameAndAddress(List<String> lines) {
      int nameAddressIndex = lines.indexWhere((line) => line.contains('NAME & ADDRESS'));

      if (nameAddressIndex != -1 && nameAddressIndex + 2 < lines.length) {
        // Extract the first two lines after "NAME & ADDRESS"
        String firstLine = lines[nameAddressIndex + 1].trim();
        String secondLine = lines[nameAddressIndex + 2].trim();

        return '$firstLine\n$secondLine';
      }

      return 'Name and Address Not Found';
    }

  }
