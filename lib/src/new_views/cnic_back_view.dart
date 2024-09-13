import 'dart:io';

import 'package:app_detection/constants/app_colors.dart';
import 'package:app_detection/model/cnic_ocr_model.dart';
import 'package:app_detection/src/new_views/capture_selfie_view.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';

class CnicBackView extends StatefulWidget {
  final CnicOcrModel cnicOcrModel;

  const CnicBackView({super.key, required this.cnicOcrModel});

  @override
  State<CnicBackView> createState() => _CnicBackViewState();
}

class _CnicBackViewState extends State<CnicBackView> {
  DocumentScanner? _documentScanner;
  File? _imageFile;

  @override
  void dispose() {
    _documentScanner?.close(); // Make sure to dispose of the scanner
    super.dispose();
  }

  void initState() {
    super.initState();
    _documentScanner = DocumentScanner(
      options: DocumentScannerOptions(
        documentFormat: DocumentFormat.jpeg,
        mode: ScannerMode.full,
        isGalleryImport: false,
        pageLimit: 1,
      ),
    );
    print("Received CNIC OCR Model: ${widget.cnicOcrModel}");
    // You can print specific fields to check their values
    print("Name: ${widget.cnicOcrModel.cnicHolderName}");
    print("CNIC Number: ${widget.cnicOcrModel.cnicNumber}");
    print("Date of Birth: ${widget.cnicOcrModel.cnicHolderDateOfBirth}");
    // Add more fields as necessary
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
                'Scan Your CNIC Back',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: Colors.white70
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: captureAndSetImagePath,
                child: Container(
                  height: 211,
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: _imageFile != null ? Image.file(_imageFile!) : Center(child: Text('Tap to scan')),
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
                      onPressed: captureAndSetImagePath,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: _buildImagePickerButton(
                      label: 'Continue',
                      icon: Icons.double_arrow_outlined,
                      onPressed: () {
                        if (_imageFile != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CaptureSelfie(cnicOcrModel: widget.cnicOcrModel)),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Please scan the CNIC back first.'))
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

  void captureAndSetImagePath() async {
    print("Attempting to capture image...");  // Check if the method is called
    var result = await _documentScanner?.scanDocument();
    if (result == null) {
      print("Document scanner did not return any result.");
      return;
    }
    if (result.images.isEmpty) {
      print("No images were captured.");
      return;
    }
    print("Image captured: ${result.images.first}");  // Check what is being captured
    setState(() {
      _imageFile = File(result.images.first);
      widget.cnicOcrModel.imagePath = _imageFile!.path;
      print("Image Path Saved: ${widget.cnicOcrModel.imagePath}");
    });
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
