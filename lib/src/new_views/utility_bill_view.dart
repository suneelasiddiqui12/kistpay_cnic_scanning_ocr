import 'package:app_detection/constants/app_colors.dart';
import 'package:app_detection/src/new_views/id_verification.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UtilityBillView extends StatefulWidget {
  const UtilityBillView({super.key});

  @override
  State<UtilityBillView> createState() => _UtilityBillViewState();
}

class _UtilityBillViewState extends State<UtilityBillView> {
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
                'Scan Your Utility Bill',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: Colors.white70
                ),
              ),
              const SizedBox(height: 8),
              Container(
                  height: 472,
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center()
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _buildImagePickerButton(
                      label: 'Upload',
                      icon: Icons.camera_alt,
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 18,),
                  Expanded(
                    child: _buildImagePickerButton(
                      label: 'Continue',
                      icon: Icons.double_arrow_outlined,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => IdentityVerificationView()),
                        );
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
