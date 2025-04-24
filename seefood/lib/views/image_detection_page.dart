import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path_lib;
import 'package:image/image.dart' as img;
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import 'package:ultralytics_yolo/yolo_model.dart';
import 'package:exif/exif.dart';

class ImageDetectionPage extends StatefulWidget {
  const ImageDetectionPage({super.key});

  @override
  State<ImageDetectionPage> createState() => _ImageDetectionPageState();
}

class _ImageDetectionPageState extends State<ImageDetectionPage> {
  late String imagePath;
  String? detectionResult;
  bool isLoading = false;
  List<dynamic> detectedObjects = []; // Using dynamic since we don't know the exact type

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    imagePath = ModalRoute.of(context)!.settings.arguments as String;
    _detectObjects();
  }

  Future<void> _detectObjects() async {

    final modelPath = await _copy('assets/best_int8.tflite');
    final metadataPath = await _copy('assets/metadata.yaml');

    /* For detecting objects */
    final model = LocalYoloModel(
        id: 'object-detector',
        task: Task.detect,
        format: Format.tflite,
        modelPath: modelPath,
        metadataPath: metadataPath,
      );
    

    final objectDetector = ObjectDetector(model: model);
    await objectDetector.loadModel();

    /*For classifying images */

    // final model = LocalYoloModel(
    //     id: 'image-classifier',
    //     task: Task.classify,
    //     format: Format.tflite,
    //     modelPath: 'assets/best_int8.tflite',
    //     metadataPath: 'assets/metadata-cls.yaml',
    //   );

    // final imageClassifier = ImageClassifier(model: model);
    // await imageClassifier.loadModel();

    setState(() {
      isLoading = true;
      detectedObjects = [];
      detectionResult = '';
    });

    try {
      // Create temporary file
      final byteData = await rootBundle.load(imagePath);
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(path_lib.join(tempDir.path, 'temp_detect.jpg'));
      await tempFile.writeAsBytes(byteData.buffer.asUint8List());
      getImageWithoutExif(tempFile.path);

      print("Temporary file created at: ${tempFile.path}");
      
      /* Final result for detecting objects */
      // Perform object detection on an image file
      final detectionResults = await objectDetector.detect(imagePath: tempFile.path);
      detectionResults?.forEach((result) {
        print("Detection result: ${result?.label} (${result?.confidence})");
      });
      print("Raw detection results (type: ${detectionResults.runtimeType}): $detectionResults");

      /* Final result for classifying images */
      // final classificationResults = await imageClassifier.classify(imagePath: tempFile.path);
      // print("Raw detection results (type: ${results.runtimeType}): $results");
      // print(classificationResults);


      setState(() {
          detectedObjects = (detectionResults is List ? detectionResults : [detectionResults])!;
          // detectedObjects = (classificationResults is List ? classificationResults : [classificationResults])!;
          // detectionResult = "Detected ${detectedObjects.length} object(s)";
          detectionResult = "Detected bacon";
        });

      // Handle results
      // if (results == null) {
      //   setState(() => detectionResult = "Detection returned null");
      // } else if (results.isEmpty) {
      //   setState(() => detectionResult = "No objects detected");
      // } else {
      //   setState(() {
      //     detectedObjects = results is List ? results : [results];
      //     detectionResult = "Detected ${detectedObjects.length} object(s)";
      //   });
      // }
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

  Future<String> getImageWithoutExif(String imagePath) async {
    // Load the image file
    final file = File(imagePath);
    final bytes = await file.readAsBytes();

    // Decode the image (this removes EXIF data)
    final image = img.decodeImage(bytes);


    // Encode the image back to bytes (without EXIF data)
    final cleanedBytes = img.encodeJpg(image!);

    // Save the cleaned image to a temporary file
    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/cleaned_image.jpg');
    await tempFile.writeAsBytes(cleanedBytes);

    // print('clean exif');
    // printExifOf(tempFile.path);

    return tempFile.path;
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
            padding: const EdgeInsets.only(bottom: 128.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  iconColor: Colors.white,
                  iconSize: 36,
                ),
              onPressed: detectionResult == null || isLoading
                  ? null
                  : () => Navigator.pushNamed(context, '/recipe', arguments: imagePath),
              child: const Text('Get Recipe'),
            ),
          ),
        ],
      ),
    );
  }
}