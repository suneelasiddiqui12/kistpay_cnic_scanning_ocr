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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/images/kistpay_logo.png'),
              SizedBox(height: MediaQuery.sizeOf(context).height / 2.5),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CnicFrontView()),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward_sharp),
                  label: const Text('Start Verification', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
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
}
