import 'dart:io';
import 'package:app_detection/functions/ocr_functions.dart';
import 'package:app_detection/model/cnic_ocr_model.dart';
import 'package:app_detection/src/image_selfie_detection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_face_api/flutter_face_api.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';

class DocumentScannerView extends StatefulWidget {
  final FaceSDK faceSdk;

  const DocumentScannerView({super.key, required this.faceSdk});

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
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                    ImageSelfieDetection(faceSdk: widget.faceSdk,)
                  ,));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: const Text(
                    'Image Verification',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
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
                if (_result?.images.isNotEmpty == true )...[
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
                ]

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

