import 'dart:typed_data';
import 'package:app_detection/src/document_scanner_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_face_api/flutter_face_api.dart';

void main() => runApp(const MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var faceSdk = FaceSDK.instance;
  var _status = "nil";

  set status(String val) => setState(() => _status = val);

  @override
  void initState() {
    super.initState();
    init();
  }

  /// Initializes the face SDK and navigates to DocumentScannerView on success
  void init() async {
    if (!await initialize()) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DocumentScannerView(faceSdk: faceSdk)),
    );
  }

  /// Initializes the FaceSDK with a license if available
  Future<bool> initialize() async {
    status = "Initializing...";
    var license = await loadAssetIfExists("assets/regula.license");
    InitConfig? config = license != null ? InitConfig(license) : null;
    var (success, error) = await faceSdk.initialize(config: config);
    if (!success) {
      status = error!.message;
      print("${error.code}: ${error.message}");
    }
    return success;
  }

  /// Loads an asset if it exists, returns null otherwise
  Future<ByteData?> loadAssetIfExists(String path) async {
    try {
      return await rootBundle.load(path);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text(_status))),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
