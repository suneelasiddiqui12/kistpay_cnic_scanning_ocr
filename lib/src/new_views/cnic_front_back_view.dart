import 'package:app_detection/constants/app_colors.dart';
import 'package:app_detection/src/new_views/cnic_back_view.dart';
import 'package:app_detection/src/new_views/cnic_front_view.dart';
import 'package:flutter/material.dart';

class CnicFrontBackView extends StatefulWidget {
  const CnicFrontBackView({super.key});

  @override
  State<CnicFrontBackView> createState() => _CnicFrontBackViewState();
}

class _CnicFrontBackViewState extends State<CnicFrontBackView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/images/kistpay_logo.png'),
              const SizedBox(height: 80),
                const Text('CNIC Front', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.only(top: 48, bottom: 48),
                decoration: BoxDecoration(
                  color: AppColors.lightSilver.withOpacity(0.6),
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    children: [
                      _buildImagePickerButton(
                        label: 'Upload from Gallery',
                        icon: Icons.camera_alt,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CnicFrontView()),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Text('OR'),
                      const SizedBox(height: 8),
                      _buildImagePickerButton(
                        label: 'Take Picture',
                        icon: Icons.browse_gallery,
                        onPressed: () {},
                      ),
                    ],
                  ),
                )
              ),
              const SizedBox(height: 29),
              const Text('CNIC Back', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),),
              const SizedBox(height: 8),
              Container(
                  padding: const EdgeInsets.only(top: 48, bottom: 48),
                  decoration: BoxDecoration(
                    color: AppColors.lightSilver.withOpacity(0.6),
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        _buildImagePickerButton(
                          label: 'Upload from Gallery',
                          icon: Icons.camera_alt,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CnicBackView()),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Text('OR'),
                        const SizedBox(height: 8),
                        _buildImagePickerButton(
                          label: 'Take Picture',
                          icon: Icons.browse_gallery,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  )
              ),
              const SizedBox(height: 38),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CnicFrontView()),
                    );
                  },
                  icon: Icon(Icons.arrow_forward_sharp),
                  label: Text('Next', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: AppColors.chineseSilver.withOpacity(0.9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    padding: const EdgeInsets.fromLTRB(51, 14, 51, 14),
                  ),
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
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
      ),
    );
  }
}
