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

  var _status = "Ready ";
  var _similarityStatus = "nil";
  var _livenessStatus = "nil";
  var _uiImage1 = Image.asset('assets/images/portrait.png');
  var _uiImage2 = Image.asset('assets/images/portrait.png');

  set status(String val) => setState(() => _status = val);
  set similarityStatus(String val) => setState(() => _similarityStatus = val);
  set livenessStatus(String val) => setState(() => _livenessStatus = val);
  set uiImage1(Image val) => setState(() => _uiImage1 = val);
  set uiImage2(Image val) => setState(() => _uiImage2 = val);

  DocumentScanner? _documentScanner;
  DocumentScanningResult? _result;

  MatchFacesImage? mfImage1;
  MatchFacesImage? mfImage2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text(_status))),
      body: Container(
        margin: EdgeInsets.fromLTRB(0, 0, 0, MediaQuery.of(context).size.height / 8),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            image(_uiImage1, () {
              startScan(DocumentFormat.jpeg);
            }),
            image(_uiImage2, () => setImageDialog(context, 2)),
            Container(margin: EdgeInsets.fromLTRB(0, 0, 0, 15)),
            button("Match", () => matchFaces()),
            button("Liveness", () => startLiveness()),
            button("Clear", () => clearResults()),
            Container(margin: EdgeInsets.fromLTRB(0, 15, 0, 0)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                text("Similarity: " + _similarityStatus),
                Container(margin: EdgeInsets.fromLTRB(20, 0, 0, 0)),
                text("Liveness: " + _livenessStatus)
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget image(Image image, Function() onTap) => GestureDetector(
    onTap: onTap,
    child: Image(height: 150, width: 150, image: image.image),
  );

  setImageDialog(BuildContext context, int number) => showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text("Select option"),
      actions: [useGallery(number), useCamera(number)],
    ),
  );

  Widget useGallery(int number) {
    return textButton("Use gallery", () async {
      Navigator.pop(context);
      var image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        var bytes = await File(image.path).readAsBytes();
        setImage(bytes, ImageType.PRINTED, number);
      }
    });
  }

  Widget useCamera(int number) {
    return textButton("Use camera", () async {
      Navigator.pop(context);
      var response = await faceSdk.startFaceCapture(
          config: FaceCaptureConfig(cameraSwitchEnabled: true));
      var image = response.image;
      if (image != null) setImage(image.image, image.imageType, number);
    });
  }

  setImage(Uint8List bytes, ImageType type, int number) {
    _similarityStatus = "nil";
    var mfImage = MatchFacesImage(bytes, type);
    if (number == 1) {
      mfImage1 = mfImage;
      uiImage1 = Image.memory(bytes);
      _livenessStatus = "nil";
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
        _similarityStatus = "failed";
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
    _livenessStatus = result.liveness.name.toLowerCase();
  }

  clearResults() {
    _status = "Ready";
    _similarityStatus = "nil";
    _livenessStatus = "nil";
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

  Widget button(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }

  Widget text(String text) {
    return Text(text);
  }
}

