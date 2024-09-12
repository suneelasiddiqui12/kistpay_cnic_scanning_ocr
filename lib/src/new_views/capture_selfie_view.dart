import 'package:app_detection/constants/app_colors.dart';
import 'package:app_detection/src/new_views/income_proof_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CaptureSelfie extends StatefulWidget {
  const CaptureSelfie({super.key});

  @override
  State<CaptureSelfie> createState() => _CaptureSelfieState();
}

class _CaptureSelfieState extends State<CaptureSelfie> {
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
                'Take Your Selfie',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: Colors.white70
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: ClipOval(
                  child: Container(
                      height: 325,
                      width: 269,
                      decoration: BoxDecoration(
                        color: Colors.white70,
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Center()
                  ),
                ),
              ),
              const SizedBox(height: 34),
              Align(
                alignment: Alignment.center,
                child: _buildImagePickerButton(
                  label: 'Continue',
                  icon: Icons.double_arrow_outlined,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => IncomeProofView()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
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
      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: AppColors.chineseSilver.withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 40.0),
      ),
    );
  }
}
