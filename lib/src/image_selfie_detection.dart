import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_face_api/flutter_face_api.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:image_picker/image_picker.dart';

class ImageSelfieDetection extends StatefulWidget {
  final FaceSDK faceSdk;

  const ImageSelfieDetection({super.key, required this.faceSdk});

  @override
  State<ImageSelfieDetection> createState() => _ImageSelfieDetectionState();
}

class _ImageSelfieDetectionState extends State<ImageSelfieDetection> {
  var faceSdk = FaceSDK.instance;

  var _status = "Face Match Verification";
  var _similarityStatus = " ";
  var _uiImage1 = Image.asset('assets/images/portrait.png');
  var _uiImage2 = Image.asset('assets/images/portrait.png');

  set status(String val) => setState(() => _status = val);
  set similarityStatus(String val) => setState(() => _similarityStatus = val);
  set uiImage1(Image val) => setState(() => _uiImage1 = val);
  set uiImage2(Image val) => setState(() => _uiImage2 = val);

  DocumentScanner? _documentScanner;
  DocumentScanningResult? _result;

  MatchFacesImage? mfImage1;
  MatchFacesImage? mfImage2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(_status,
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 22),
        ),
        centerTitle: true,
        toolbarHeight: 100,
        backgroundColor: Colors.indigoAccent,
        elevation: 0,
        shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(70))
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            SizedBox(height: 16),
            image(_uiImage1, () {
              startScan(DocumentFormat.jpeg);
            }),
            Text('Scan Cnic', style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.w600,
                color: Colors.black87.withOpacity(0.7)
            ),),
            SizedBox(height: 16),
            image(_uiImage2, () => setImageDialog(context, 2)),
            Text('Take Selfie', style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.w600,
                color: Colors.black87.withOpacity(0.7)
            ),),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                button("Match Images", Icons.compare_arrows, () => matchFaces()),
                SizedBox(height: 32),
                // button("Liveness", Icons.verified_user, () => startLiveness()),
                button("Clear Images", Icons.clear, () => clearResults()),
              ],
            ),
            SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              border: Border.all(color: Colors.black26)
            ),
            width: MediaQuery.sizeOf(context).width,
            height: 150,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                text("Similarity Found: "),
                Text(_similarityStatus, style: TextStyle(fontSize: 26, color: Colors.pink, fontWeight: FontWeight.w700),)
              ],
            )
          )
          ],
        ),
      ),
    );
  }

  Widget image(Image image, Function() onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(15)),
          border: Border.all(color: Colors.black54, width: 0.5)),
        child: Image(height: 150, width: 150, image: image.image)),
  );

  setImageDialog(BuildContext context, int number) => showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text("A recent selfie is needed"),
      actions: [useCamera(number)],
    ),
  );
  //
  // Widget useGallery(int number) {
  //   return textButton("Use gallery", () async {
  //     Navigator.pop(context);
  //     var image = await ImagePicker().pickImage(source: ImageSource.gallery);
  //     if (image != null) {
  //       var bytes = await File(image.path).readAsBytes();
  //       setImage(bytes, ImageType.PRINTED, number);
  //     }
  //   });
  // }

  Widget useCamera(int number) {
    return textButton("Capture Selfie", () async {
      Navigator.pop(context);
      var response = await faceSdk.startFaceCapture(
          config: FaceCaptureConfig(cameraSwitchEnabled: true));
      var image = response.image;
      if (image != null) setImage(image.image, image.imageType, number);
    });
  }

  setImage(Uint8List bytes, ImageType type, int number) {
    _similarityStatus = " ";
    var mfImage = MatchFacesImage(bytes, type);
    if (number == 1) {
      mfImage1 = mfImage;
      uiImage1 = Image.memory(bytes);
    }
    if (number == 2) {
      mfImage2 = mfImage;
      uiImage2 = Image.memory(bytes);
    }
  }

  matchFaces() async {
    if (mfImage1 == null || mfImage2 == null) {
      setState(() {
        _status = "Both images required!";
      });
      return;
    }

    setState(() {
      _status = "Processing...";
    });

    var request = MatchFacesRequest([mfImage1!, mfImage2!]);
    var response = await faceSdk.matchFaces(request);

    print('MatchFaces response: ${response.results}');

    if (response.results.isNotEmpty) {
      for (var result in response.results) {
        if (result is ComparedFacesPair) {
          print('ComparedFacesPair: similarity=${result.similarity}');
        }
      }
    } else {
      print('No match found');
    }

    var split = await faceSdk.splitComparedFaces(response.results, 0.75);
    var match = split.matchedFaces;

    setState(() {
      if (match.isNotEmpty) {
        _similarityStatus = (match[0].similarity * 100).toStringAsFixed(2) + "%";
      } else {
        _similarityStatus = "Unable to match";
      }
      _status = "Ready";
    });
  }

  startLiveness() async {
    var result = await faceSdk.startLiveness(
      config: LivenessConfig(skipStep: [LivenessSkipStep.ONBOARDING_STEP]),
      notificationCompletion: (notification) {
        print('Notification status ==${notification.status}');
      },
    );
    if (result.image == null) return;
    setImage(result.image!, ImageType.LIVE, 1);
  }

  clearResults() {
    _status = "Ready";
    _similarityStatus = " ";
    uiImage2 = Image.asset('assets/images/portrait.png');
    uiImage1 = Image.asset('assets/images/portrait.png');
    mfImage1 = null;
    mfImage2 = null;
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

      _result = await _documentScanner?.scanDocument();
      if (_result != null && _result!.images.isNotEmpty) {
        var bytes = await File(_result!.images.first).readAsBytes();
        setImage(bytes, ImageType.PRINTED, 1);
      }
      setState(() {});
    } catch (e) {
      print('Error: $e');
    }
  }

  Widget textButton(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }

  Widget button(String text, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),),
      style: ElevatedButton.styleFrom(
        primary: Colors.indigoAccent,
        onPrimary: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
      ),
    );
  }

  Widget text(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 26.0,
        fontWeight: FontWeight.w600,
        color: Colors.black45
      ),
    );
  }
}



