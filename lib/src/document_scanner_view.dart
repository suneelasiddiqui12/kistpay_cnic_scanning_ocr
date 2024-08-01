import 'dart:io';
import 'package:app_detection/functions/ocr_functions.dart';
import 'package:app_detection/model/cnic_ocr_model.dart';
import 'package:app_detection/src/image_selfie_detection.dart';
import 'package:app_detection/src/utility_bill_scanner.dart';
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
  // Document scanner instance
  DocumentScanner? _documentScanner;
  // Result of the document scan
  DocumentScanningResult? _result;
  // Controllers for the text fields
  final _nameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _genderController = TextEditingController();
  final _countryController = TextEditingController();
  final _identityNumberController = TextEditingController();
  final _issueDateController = TextEditingController();
  final _dobController = TextEditingController();
  final _expiryDateController = TextEditingController();
  // Model to store CNIC OCR results
  CnicOcrModel _cnicOcrModel = CnicOcrModel();

  @override
  void dispose() {
    // Close document scanner and dispose of text controllers
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
        title: const Text(
          'Document Scanner View',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigoAccent,
        elevation: 0,
        toolbarHeight: 100,
        shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(70)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Header text for OCR scanning
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Scan CNIC for OCR reading',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(
                  Icons.document_scanner_outlined,
                  size: 50,
                  color: Colors.indigo,
                ),
                const SizedBox(width: 8),
                // Button to start scanning PDF
                _buildElevatedButton('Scan PDF', () => startScan(DocumentFormat.pdf)),
                const SizedBox(width: 8),
                // Button to start scanning JPEG
                _buildElevatedButton('Scan JPEG', () => startScan(DocumentFormat.jpeg)),
              ],
            ),
            const SizedBox(height: 40),
            // Header text for face matching
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Scan CNIC for face matching',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(
                  Icons.document_scanner_outlined,
                  size: 50,
                  color: Colors.indigo,
                ),
                const SizedBox(width: 8),
                // Button to navigate to the ImageSelfieDetection screen
                _buildElevatedButton(
                  'Get Started ---->',
                      () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ImageSelfieDetection(faceSdk: widget.faceSdk),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Scan Utility Bill for OCR',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(
                  Icons.document_scanner_outlined,
                  size: 50,
                  color: Colors.indigo,
                ),
                const SizedBox(width: 8),
                // Button to navigate to the ImageSelfieDetection screen
                _buildElevatedButton(
                  'Get Started --->',
                      () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => UtilityBillScanner(),
                      ),
                    );
                  },
                ),
              ],
            ),
            // Display PDF document if available
            if (_result?.pdf != null)
              ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('PDF Document:'),
                  ),
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
            // Display scanned images and text fields if available
            if (_result?.images.isNotEmpty == true)
              ...[
                SizedBox(
                  height: 400,
                  child: Image.file(File(_result!.images.first)),
                ),
                const SizedBox(height: 20),
                _buildTextField('Name', _nameController),
                _buildTextField('CNIC', _identityNumberController),
                _buildTextField('DOB', _dobController),
                _buildTextField('Date of Issue', _issueDateController),
                _buildTextField('Date of Expiry', _expiryDateController),
              ]
          ],
        ),
      ),
    );
  }

  // Helper method to build elevated buttons
  ElevatedButton _buildElevatedButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.indigoAccent),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  // Helper method to build text fields
  Widget _buildTextField(String labelText, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  // Method to start scanning documents
  void startScan(DocumentFormat format) async {
    try {
      // Reset the result before scanning
      setState(() {
        _result = null;
      });
      _documentScanner?.close();
      _documentScanner = DocumentScanner(
        options: DocumentScannerOptions(
          documentFormat: format,
          mode: ScannerMode.full,
          isGalleryImport: false,
          pageLimit: 1,
        ),
      );

      // Perform the document scan
      _result = await _documentScanner?.scanDocument();
      setState(() {});
      if (_result?.images.isNotEmpty == true) {
        // Scan the CNIC OCR if images are available
        await scanCnicOcr(_result!.images.first);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Method to scan CNIC OCR and update text fields
  Future<void> scanCnicOcr(String imagePath) async {
    try {
      final cnicOcrModel = await OcrFunctions().scanCnic(imageToScan: InputImage.fromFilePath(imagePath));

      // Update the state with scanned OCR results
      setState(() {
        _cnicOcrModel = cnicOcrModel;
        _nameController.text = _cnicOcrModel.cnicHolderName;
        _identityNumberController.text = _cnicOcrModel.cnicNumber;
        _dobController.text = _cnicOcrModel.cnicHolderDateOfBirth;
        _issueDateController.text = _cnicOcrModel.cnicIssueDate;
        _expiryDateController.text = _cnicOcrModel.cnicExpiryDate;
      });
    } catch (e) {
      print('Error in scanCnicOcr: $e');
    }
  }
}
