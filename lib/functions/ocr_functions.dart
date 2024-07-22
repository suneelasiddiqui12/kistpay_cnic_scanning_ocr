import 'package:app_detection/model/cnic_ocr_model.dart';
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

}
