import 'package:app_detection/functions/ocr_functions.dart';
import 'package:app_detection/model/utility_bill_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:lottie/lottie.dart';

class UtilityBillScanner extends StatefulWidget {
  const UtilityBillScanner({super.key});

  @override
  _UtilityBillScannerState createState() => _UtilityBillScannerState();
}

class _UtilityBillScannerState extends State<UtilityBillScanner> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  String _extractedText = '';
  UtilityBillModel? _utilityBill;
  bool _isLoading = false;
  XFile? _croppedImage;
  String _croppedText = '';
  final OcrFunctions _ocrFunctions = OcrFunctions();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? selected = await _picker.pickImage(source: source);
      if (selected != null) {
        setState(() {
          _image = selected;
          _isLoading = true;
        });
        await _extractText(File(_image!.path));
      }
    } catch (e) {
      setState(() {
        _extractedText = 'Error: ${e.toString()}';
        _isLoading = false; // Ensure loading state is stopped on error
      });
    }
  }

  Future<void> _extractText(File imageFile) async {
    final text = await _ocrFunctions.extractText(imageFile);
    print("OCR Text Output: $text");

    // Crop the image
    final croppedFile = await _ocrFunctions.cropBottomLeft(imageFile);
    final croppedText = await _ocrFunctions.extractCroppedText(croppedFile);

    print("Cropped Text OCR: $croppedText");

    setState(() {
      _extractedText = text;
      _croppedText = croppedText;
      _croppedImage = XFile(croppedFile.path); // Update the cropped image state
      _parseText(text);
      _isLoading = false;
    });
  }

  void _parseText(String text) {
    print("Parsing text...");
    _utilityBill = _ocrFunctions.parseText(text);

    if (_utilityBill?.dueDate != null) {
      // Check if the bill is within 3 months old
      _utilityBill!.isVerified = _isBillVerified(_utilityBill!.dueDate);
    }

    // Debug print to confirm parsing
    print("Parsed Data:");
    print("Name: ${_utilityBill?.name}");
    print("Address: ${_utilityBill?.address}");
    print("City: ${_utilityBill?.city}");
    print("Amount Payable: ${_utilityBill?.amountPayable}");
    print("Issue Date: ${_utilityBill?.issueDate}");
    print("Due Date: ${_utilityBill?.dueDate}");
    print("Paid Date: ${_utilityBill?.paidDate}");
    print("Is Verified: ${_utilityBill?.isVerified}");


    setState(() {}); // Ensure UI updates after parsing
  }
  bool _isBillVerified(String dueDate) {
    try {
      final format = DateFormat('dd-MMM-yy'); // Assuming date format is 'dd-MMM-yy'
      final dueDateParsed = format.parse(dueDate);
      final now = DateTime.now();
      final difference = now.difference(dueDateParsed);

      return difference.inDays <= 90; // 90 days = 3 months
    } catch (e) {
      print("Error parsing due date: $e");
      return false;
    }
  }
  @override
  Widget build(BuildContext context) {
    print('Building UI with UtilityBill: ${_utilityBill?.name}');

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Utility Bill Scanner',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 22),
        ),
        centerTitle: true,
        toolbarHeight: 100,
        backgroundColor: Colors.indigoAccent,
        elevation: 0,
        shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(70)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isLoading)
                Center(
                  child: Lottie.network(
                    'https://raw.githubusercontent.com/xvrh/lottie-flutter/master/example/assets/Mobilo/A.json',
                    height: 700,
                  ),
                ),
              if (_image != null && !_isLoading) Image.file(File(_image!.path)),
              if (_image == null && !_isLoading) _buildImagePickerButtons(),
              const SizedBox(height: 20),
              if (_utilityBill != null)
                _utilityBill == null ? const Text('No data') : _buildExtractedData(),
              const SizedBox(height: 20),
              if (_croppedImage != null && !_isLoading) ...[
                const SizedBox(height: 20),
                Image.file(File(_croppedImage!.path)),
                const SizedBox(height: 10),
                Text(_croppedText),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePickerButtons() {
    return Center(
      child: Column(
        children: [
          _buildImagePickerButton(
            label: 'Capture Image',
            icon: Icons.camera_alt,
            onPressed: () => _pickImage(ImageSource.camera),
          ),
          const SizedBox(height: 32),
          _buildImagePickerButton(
            label: 'Select from Gallery',
            icon: Icons.browse_gallery,
            onPressed: () => _pickImage(ImageSource.gallery),
          ),
        ],
      ),
    );
  }

  ElevatedButton _buildImagePickerButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.indigoAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
      ),
    );
  }

  Widget _buildExtractedData() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withOpacity(0.3),
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExtractedDataRow('Name: ', _utilityBill?.name ?? 'Not Available'),
          const SizedBox(height: 10),
          _buildExtractedDataRow('Address: ', _utilityBill?.address ?? 'Not Available'),
          const SizedBox(height: 10),
          _buildExtractedDataRow('City: ', _utilityBill?.city ?? 'Not Available'),
          const SizedBox(height: 10),
          _buildExtractedDataRow('Amount Payable: ', _utilityBill?.amountPayable ?? 'Not Available'),
          const SizedBox(height: 10),
          _buildExtractedDataRow('Issue Date: ', _utilityBill?.issueDate ?? 'Not Available'),
          const SizedBox(height: 10),
          _buildExtractedDataRow('Due Date: ', _utilityBill?.dueDate ?? 'Not Available'),
          const SizedBox(height: 10),
          _buildExtractedDataRow('Paid Date: ', _utilityBill?.paidDate ?? 'Not Available'),
          const SizedBox(height: 10),
          _buildExtractedDataRow('Verification: ', _utilityBill?.isVerified == true ? 'Verified' : 'Not Verified'),
        ],
      ),
    );
  }

  Widget _buildExtractedDataRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        Flexible(
          child: Text(
            value,
            overflow: TextOverflow.visible,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}










