import 'dart:io';

import 'package:app_detection/model/cnic_ocr_model.dart';
import 'package:app_detection/model/utility_bill_model.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

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

    UtilityBillModel parseText(String text) {
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
      print('Extracted name: $name');
      print('Extracted address: $address');
      print('Extracted city: $city');
      print('Extracted issueDate: $issueDate');
      print('Extracted dueDate: $dueDate');
      print('Extracted paidDate: $paidDate');

      return UtilityBillModel(
        name: name,
        address: address,
        city: city,
        amountPayable: amountPayable,
        issueDate: issueDate,
        dueDate: dueDate,
        paidDate: paidDate,
      );

    }

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
}
