// image_detection_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path_lib;
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import 'package:ultralytics_yolo/yolo_model.dart';

class ImageDetectionPage extends StatefulWidget {
  const ImageDetectionPage({super.key});

  @override
  State<ImageDetectionPage> createState() => _ImageDetectionPageState();
}

class _ImageDetectionPageState extends State<ImageDetectionPage> {
  late String imagePath;
  String? detectionResult;
  bool isLoading = false;
  ObjectDetector? _detector;
  List<dynamic> detectedObjects = []; // Using dynamic since we don't know the exact type

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    imagePath = ModalRoute.of(context)!.settings.arguments as String;
    _initializeDetector();
  }

  Future<void> _initializeDetector() async {
    try {
      final model = LocalYoloModel(
        id: 'object-detector',
        task: Task.detect,
        format: Format.tflite,
        modelPath: await _copy('assets/best_int8.tflite'),
        metadataPath: await _copy('assets/metadata.yaml'),
      );
      
      _detector = ObjectDetector(model: model);
      await _detector!.loadModel();
      _detectObjects();
    } catch (e) {
      setState(() {
        detectionResult = "Failed to initialize detector: $e";
        isLoading = false;
      });
    }
  }

  Future<void> _detectObjects() async {
    if (_detector == null) {
      setState(() => detectionResult = "Detector not initialized");
      return;
    }

    setState(() {
      isLoading = true;
      detectionResult = null;
      detectedObjects = [];
    });

    try {
      // Create temporary file
      final byteData = await rootBundle.load(imagePath);
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(path_lib.join(tempDir.path, 'temp_detect.jpg'));
      await tempFile.writeAsBytes(byteData.buffer.asUint8List());
      print("Temporary file created at: ${tempFile.path}");

      // Detect objects
      final results = await _detector!.detect(imagePath: tempFile.path);
      print("Raw detection results (type: ${results.runtimeType}): $results");

      // Handle results
      if (results == null) {
        setState(() => detectionResult = "Detection returned null");
      } else if (results.isEmpty) {
        setState(() => detectionResult = "No objects detected");
      } else {
        setState(() {
          detectedObjects = results is List ? results : [results];
          detectionResult = "Detected ${detectedObjects.length} object(s)";
        });
      }
    } catch (e) {
      print("Detection error: $e");
      setState(() {
        detectionResult = "Error: ${e.toString()}";
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Helper to safely access detection result properties
  String _getLabel(dynamic detection) {
    try {
      return detection?.label?.toString() ?? 'Object';
    } catch (e) {
      return 'Object';
    }
  }

  double? _getConfidence(dynamic detection) {
    try {
      return detection?.confidence?.toDouble();
    } catch (e) {
      return null;
    }
  }

  Future<String> _copy(String assetPath) async {
    final appDir = await getApplicationSupportDirectory();
    final fullPath = path_lib.join(appDir.path, assetPath);
    await Directory(path_lib.dirname(fullPath)).create(recursive: true);
    final file = File(fullPath);
    
    if (!await file.exists()) {
      final byteData = await rootBundle.load(assetPath);
      await file.writeAsBytes(
        byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ),
      );
    }
    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Object Detection')),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: Image.asset(imagePath),
                ),
                // You could add bounding box overlays here using detectedObjects
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (isLoading) const CircularProgressIndicator(),
                if (detectionResult != null)
                  Text(
                    detectionResult!,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                if (detectedObjects.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: detectedObjects.length,
                      itemBuilder: (context, index) {
                        final obj = detectedObjects[index];
                        final confidence = _getConfidence(obj);
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Chip(
                            label: Text(
                              "${_getLabel(obj)} "
                              "(${confidence != null ? (confidence * 100).toStringAsFixed(1) : 'N/A'}%)",
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 32.0),
            child: ElevatedButton(
              onPressed: detectionResult == null || isLoading
                  ? null
                  : () => Navigator.pushNamed(context, '/recipe'),
              child: const Text('Get Recipe'),
            ),
          ),
        ],
      ),
    );
  }
}