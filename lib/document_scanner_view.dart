// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';
// import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
//
// class DocumentScannerView extends StatefulWidget {
//   const DocumentScannerView({super.key});
//
//   @override
//   State<DocumentScannerView> createState() => _DocumentScannerViewState();
// }
//
// class _DocumentScannerViewState extends State<DocumentScannerView> {
//   DocumentScanner? _documentScanner;
//   DocumentScanningResult? _result;
//   String _ocrText = '';
//   TextEditingController _nameController = TextEditingController();
//   TextEditingController _fatherNameController = TextEditingController();
//   TextEditingController _genderController = TextEditingController();
//   TextEditingController _countryController = TextEditingController();
//   TextEditingController _identityNumberController = TextEditingController();
//   TextEditingController _issueDateController = TextEditingController();
//   TextEditingController _dobController = TextEditingController();
//   TextEditingController _expiryDateController = TextEditingController();
//
//   @override
//   void dispose() {
//     _documentScanner?.close();
//     _nameController.dispose();
//     _fatherNameController.dispose();
//     _genderController.dispose();
//     _countryController.dispose();
//     _identityNumberController.dispose();
//     _issueDateController.dispose();
//     _dobController.dispose();
//     _expiryDateController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Document Scanner'),
//         centerTitle: true,
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.document_scanner_outlined,
//                     size: 50,
//                   ),
//                   SizedBox(width: 8),
//                   ElevatedButton(
//                     style: ButtonStyle(
//                       backgroundColor:
//                       MaterialStateProperty.all<Color>(Colors.black),
//                       shape: MaterialStateProperty.all(
//                         RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                     ),
//                     onPressed: () => startScan(DocumentFormat.pdf),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 4),
//                       child: const Text(
//                         'Scan PDF',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 8),
//                   ElevatedButton(
//                     style: ButtonStyle(
//                       backgroundColor:
//                       MaterialStateProperty.all<Color>(Colors.black),
//                       shape: MaterialStateProperty.all(
//                         RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                     ),
//                     onPressed: () => startScan(DocumentFormat.jpeg),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 4),
//                       child: const Text(
//                         'Scan JPEG',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               if (_result?.pdf != null) ...[
//                 Padding(
//                   padding: const EdgeInsets.only(
//                       top: 16, bottom: 8, right: 8, left: 8),
//                   child: Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text('PDF Document:')),
//                 ),
//                 SizedBox(
//                   height: 300,
//                   child: PDFView(
//                     filePath: _result!.pdf!.uri,
//                     enableSwipe: true,
//                     swipeHorizontal: true,
//                     autoSpacing: false,
//                     pageFling: false,
//                   ),
//                 ),
//               ],
//               if (_result?.images.isNotEmpty == true) ...[
//                 Padding(
//                   padding: const EdgeInsets.only(
//                       top: 16, bottom: 8, right: 8, left: 8),
//                   child: Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text('Images [0]:')),
//                 ),
//                 SizedBox(
//                   height: 400,
//                   child: Image.file(File(_result!.images.first)),
//                 ),
//                 if (_ocrText.isNotEmpty) ...[
//                   Padding(
//                     padding: const EdgeInsets.only(top: 16, bottom: 8, right: 8, left: 8),
//                     child: Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text('OCR Result:'),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         _buildTextField('Name', _nameController),
//                         _buildTextField("Father's Name", _fatherNameController),
//                         _buildTextField('Gender', _genderController),
//                         _buildTextField('Country of Stay', _countryController),
//                         _buildTextField('Identity Number', _identityNumberController),
//                         _buildTextField('Date of Issue', _issueDateController),
//                         _buildTextField('Date of Birth', _dobController),
//                         _buildTextField('Date of Expiry', _expiryDateController),
//                         SizedBox(height: 16),
//                         Text('Scanned Text:', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 26)),
//                         SizedBox(height: 8),
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(
//                             _ocrText,
//                             textAlign: TextAlign.center,
//                             style: TextStyle(fontSize: 16),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTextField(String labelText, TextEditingController controller) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 8.0),
//       child: TextField(
//         controller: controller,
//         decoration: InputDecoration(
//           labelText: labelText,
//           border: OutlineInputBorder(),
//         ),
//       ),
//     );
//   }
//
//   void startScan(DocumentFormat format) async {
//     try {
//       _result = null;
//       _ocrText = '';
//       setState(() {});
//       _documentScanner?.close();
//       _documentScanner = DocumentScanner(
//         options: DocumentScannerOptions(
//           documentFormat: format,
//           mode: ScannerMode.full,
//           isGalleryImport: false,
//           pageLimit: 1,
//         ),
//       );
//       _result = await _documentScanner?.scanDocument();
//       if (_result?.images.isNotEmpty == true) {
//         await performOCR(_result!.images.first);
//         extractAndSetFields(_ocrText);
//       }
//       setState(() {});
//     } catch (e) {
//       print('Error: $e');
//     }
//   }
//
//   Future<void> performOCR(String imagePath) async {
//     final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
//     final inputImage = InputImage.fromFilePath(imagePath);
//
//     try {
//       final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
//       setState(() {
//         _ocrText = recognizedText.text;
//         print('OCR Text: $_ocrText'); // Debugging output
//       });
//     } catch (e) {
//       print('OCR Error: $e');
//     } finally {
//       textRecognizer.close();
//     }
//   }
//   void extractAndSetFields(String ocrText) {
//     setState(() {
//       _nameController.text = extractInformation(ocrText, 'Name');
//       _fatherNameController.text = extractInformation(ocrText, 'Father Name');
//       _genderController.text = extractInformation(ocrText, 'Gender');
//       _countryController.text = extractInformation(ocrText, 'Country of Stay');
//       _identityNumberController.text = extractInformation(ocrText, 'Identity Number');
//       _issueDateController.text = extractInformation(ocrText, 'Date of Issue');
//       _dobController.text = extractInformation(ocrText, 'Date of Birth');
//       _expiryDateController.text = extractInformation(ocrText, 'Date of Expiry');
//     });
//   }
//
//   String extractInformation(String ocrText, String label) {
//     // Updated regex patterns to better match the structure of the OCR text
//     Map<String, String> patterns = {
//       'Name': r'Name\s*(.*)',
//       'Father Name': r'Father Name\s*(.*)',
//       'Gender': r'Gender\s*(\w)',
//       'Country of Stay': r'Country of Stay\s*(.*)',
//       'Identity Number': r'Identity Number\s*([\d-]+)',
//       'Date of Issue': r'Date of Issue\s*([\d.]+)',
//       'Date of Birth': r'Date of Birth\s*([\d.]+)',
//       'Date of Expiry': r'Date of Expiry\s*([\d.]+)',
//     };
//
//     RegExp regex = RegExp(patterns[label]!, multiLine: true);
//     String? match = regex.firstMatch(ocrText)?.group(1);
//     print('Extracted match for label $label: $match'); // Debugging output
//     return match?.trim() ?? '';
//   }
// }

import 'dart:io';
import 'package:app_detection/cnic_ocr_model.dart';
import 'package:app_detection/ocr_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:image_picker/image_picker.dart';

class DocumentScannerView extends StatefulWidget {
  const DocumentScannerView({super.key});

  @override
  State<DocumentScannerView> createState() => _DocumentScannerViewState();
}

class _DocumentScannerViewState extends State<DocumentScannerView> {
  DocumentScanner? _documentScanner;
  DocumentScanningResult? _result;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _fatherNameController = TextEditingController();
  TextEditingController _genderController = TextEditingController();
  TextEditingController _countryController = TextEditingController();
  TextEditingController _identityNumberController = TextEditingController();
  TextEditingController _issueDateController = TextEditingController();
  TextEditingController _dobController = TextEditingController();
  TextEditingController _expiryDateController = TextEditingController();
  CnicOcrModel _cnicOcrModel = CnicOcrModel();

  @override
  void dispose() {
    _documentScanner?.close();
    _nameController.dispose();
    _fatherNameController.dispose();
    _genderController.dispose();
    _countryController.dispose();
    _identityNumberController.dispose();
    _issueDateController.dispose();
    _dobController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Document Scanner'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.document_scanner_outlined,
                    size: 50,
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.black),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    onPressed: () => startScan(DocumentFormat.pdf),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: const Text(
                        'Scan PDF',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.black),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    onPressed: () => startScan(DocumentFormat.jpeg),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: const Text(
                        'Scan JPEG',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              if (_result?.pdf != null) ...[
                Padding(
                  padding: const EdgeInsets.only(
                      top: 16, bottom: 8, right: 8, left: 8),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('PDF Document:')),
                ),
                SizedBox(
                  height: 300,
                  child: PDFView(
                    filePath: _result!.pdf!.uri,
                    enableSwipe: true,
                    swipeHorizontal: true,
                    autoSpacing: false,
                    pageFling: false,
                  ),
                ),
              ],

                Padding(
                  padding: const EdgeInsets.only(
                      top: 16, bottom: 8, right: 8, left: 8),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Images [0]:')),
                ),
                SizedBox(
                  height: 400,
                  child: Image.file(File(_result!.images.first)),
                ),
                SizedBox(height: 20,),
                _buildTextField('Name', _nameController),
                _buildTextField('Cnic', _identityNumberController),
                _buildTextField('DOB', _dobController),
                _buildTextField('Date of Issue', _issueDateController),
                _buildTextField('Date of Expiry', _expiryDateController),
              ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String labelText, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  void startScan(DocumentFormat format) async {
    try {
      _result = null;
      setState(() {});
      _documentScanner?.close();
      _documentScanner = DocumentScanner(
        options: DocumentScannerOptions(
          documentFormat: format,
          mode: ScannerMode.full,
          isGalleryImport: false,
          pageLimit: 1,
        ),
      );
      print('result === ${_result?.images.length}');

      _result = await _documentScanner?.scanDocument();
      print('result === ${_result?.images.first}');
      setState(() {});
      if (_result?.images.isNotEmpty == true) {
        await scanCnicOcr(_result!.images.first);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  ///data/user/0/com.example.app_detection/cache/mlkit_docscan_ui_client/1496975389217195.jpg
  ///
  /// /data/user/0/com.example.app_detection/cache/mlkit_docscan_ui_client/1497016573621428.jpg

  Future<void> scanCnicOcr(String imagePath) async {
    try {
      CnicOcrModel cnicOcrModel = CnicOcrModel();
      cnicOcrModel =  await OcrFunctions().scanCnic(imageToScan: InputImage.fromFilePath(imagePath));

      setState(() {
        _cnicOcrModel = cnicOcrModel;
        _nameController.text = _cnicOcrModel.cnicHolderName;
        print('tst==${_cnicOcrModel.cnicHolderName}');
        _identityNumberController.text = _cnicOcrModel.cnicNumber;
        _dobController.text = _cnicOcrModel.cnicHolderDateOfBirth;
        _issueDateController.text = _cnicOcrModel.cnicIssueDate;
        _expiryDateController.text = _cnicOcrModel.cnicExpiryDate;

        // Additional debug prints
        print('Name: ${_nameController.text}');
        print('CNIC: ${_identityNumberController.text}');
        print('DOB: ${_dobController.text}');
        print('Issue Date: ${_issueDateController.text}');
        print('Expiry Date: ${_expiryDateController.text}');
      });
    } catch (e) {
      print('Error in scanCnicOcr: $e');
    }
  }

}

