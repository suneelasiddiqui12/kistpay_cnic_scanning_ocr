import 'package:app_detection/constants/app_colors.dart';
import 'package:app_detection/functions/ocr_functions.dart';
import 'package:app_detection/model/cnic_ocr_model.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'dart:io';
import 'cnic_back_view.dart';

class CnicFrontView extends StatefulWidget {
  final CnicOcrModel cnicOcrModel;

  const CnicFrontView({super.key, required this.cnicOcrModel});

  @override
  State<CnicFrontView> createState() => _CnicFrontViewState();
}

class _CnicFrontViewState extends State<CnicFrontView> {
  DocumentScanner? _documentScanner;
  DocumentScanningResult? _result;
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
      backgroundColor: AppColors.chineseSilver.withOpacity(0.5),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/images/kistpay_logo.png'),
              const SizedBox(height: 80),
              const Text(
                'Scan Your CNIC Front',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: Colors.white70
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => startScan(DocumentFormat.jpeg),  // Assuming JPEG format for the document
                child: Container(
                  height: 211,
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                      child: _result != null && _result!.images.isNotEmpty
                          ? Image.file(File(_result!.images.first))
                          : const Text('Tap to scan')
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _buildImagePickerButton(
                      label: 'Upload',
                      icon: Icons.camera_alt,
                      onPressed: () => startScan(DocumentFormat.pdf),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: _buildImagePickerButton(
                      label: 'Continue',
                      icon: Icons.double_arrow_outlined,
                      onPressed: () {
                        if (_result != null && _result!.images.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CnicBackView(cnicOcrModel: _cnicOcrModel),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please scan the CNIC front first.'))
                          );
                        }
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // Refactored method to start scanning documents
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

  ElevatedButton _buildImagePickerButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: AppColors.chineseSilver.withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
      ),
    );
  }

}
