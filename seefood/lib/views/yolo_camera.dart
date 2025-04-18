import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import 'package:ultralytics_yolo/yolo_model.dart';
import 'package:camera/camera.dart';

class YoloCameraPage extends StatefulWidget {
  const YoloCameraPage({super.key});

  @override
  State<YoloCameraPage> createState() => _YoloCameraPageState();
}

class _YoloCameraPageState extends State<YoloCameraPage> {
  final controller = UltralyticsYoloCameraController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Camera Detection')),
      body: FutureBuilder<bool>(
        future: _checkPermissions(),
        builder: (context, snapshot) {
          final allPermissionsGranted = snapshot.data ?? false;

          return !allPermissionsGranted
              ? const Center(child: Text("Error requesting permissions"))
              : FutureBuilder<ObjectDetector>(
                  future: _initObjectDetectorWithLocalModel(),
                  builder: (context, snapshot) {
                    final predictor = snapshot.data;

                    return predictor == null
                        ? const Center(child: CircularProgressIndicator())
                        : Stack(
                            children: [
                              UltralyticsYoloCameraPreview(
                                controller: controller,
                                predictor: predictor,
                                onCameraCreated: () {
                                  predictor.loadModel(useGpu: true);
                                },
                              ),
                              StreamBuilder<double?>(
                                stream: predictor.inferenceTime,
                                builder: (context, snapshot) {
                                  final inferenceTime = snapshot.data;

                                  return StreamBuilder<double?>(
                                    stream: predictor.fpsRate,
                                    builder: (context, snapshot) {
                                      final fpsRate = snapshot.data;

                                      return Times(
                                        inferenceTime: inferenceTime,
                                        fpsRate: fpsRate,
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          );
                  },
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.cameraswitch),
        onPressed: () {
          controller.toggleLensDirection();
        },
      ),
    );
  }

  Future<ObjectDetector> _initObjectDetectorWithLocalModel() async {
    final modelPath = await _copy('assets/yolov8n_int8.tflite');
    final metadataPath = await _copy('assets/metadata.yaml');
    final model = LocalYoloModel(
      id: '',
      task: Task.detect,
      format: Format.tflite,
      modelPath: modelPath,
      metadataPath: metadataPath,
    );
    return ObjectDetector(model: model);
  }

  Future<String> _copy(String assetPath) async {
    final path = '${(await getApplicationSupportDirectory()).path}/$assetPath';
    await io.Directory(dirname(path)).create(recursive: true);
    final file = io.File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(assetPath);
      await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return file.path;
  }

  Future<bool> _checkPermissions() async {
    List<Permission> permissions = [];

    var cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) permissions.add(Permission.camera);

    // var storageStatus = await Permission.photos.status;
    // if (!storageStatus.isGranted) permissions.add(Permission.photos);

    if (permissions.isEmpty) {
      return true;
    } else {
      try {
        Map<Permission, PermissionStatus> statuses = await permissions.request();
        return statuses.values.every((status) => status == PermissionStatus.granted);
      } on Exception catch (_) {
        return false;
      }
    }
  }
}

class Times extends StatelessWidget {
  const Times({
    super.key,
    required this.inferenceTime,
    required this.fpsRate,
  });

  final double? inferenceTime;
  final double? fpsRate;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Colors.black54,
            ),
            child: Text(
              '${(inferenceTime ?? 0).toStringAsFixed(1)} ms  -  ${(fpsRate ?? 0).toStringAsFixed(1)} FPS',
              style: const TextStyle(color: Colors.white70),
            )),
      ),
    );
  }
}