import 'package:app_detection/constants/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IdentityVerificationView extends StatefulWidget {
  const IdentityVerificationView({super.key});

  @override
  State<IdentityVerificationView> createState() => _IdentityVerificationViewState();
}

class _IdentityVerificationViewState extends State<IdentityVerificationView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset('assets/images/kistpay_logo.png'),
                const SizedBox(height: 232),
                const Text('Your Identity has been Verified Successful', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),),
                const SizedBox(height: 221),
                const Text('Identity Verification Failed', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.arrow_forward_sharp),
                  label: Text('Retry', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: AppColors.chineseSilver.withOpacity(0.9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    padding: const EdgeInsets.fromLTRB(51, 14, 51, 14),
                  ),
                ),
                const SizedBox(height: 19),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
