import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImageUploadPage extends StatefulWidget {
  const ImageUploadPage({super.key});

  @override
  State<ImageUploadPage> createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  List<String> imagePaths = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final manifestMap = Map<String, dynamic>.from(
          const JsonDecoder().convert(manifestContent));
      setState(() {
        imagePaths = manifestMap.keys
            .where((key) => key.startsWith('assets/images/'))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select An Image')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : imagePaths.isEmpty
              ? const Center(child: Text('No images found'))
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: imagePaths.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/classify',
                        arguments: imagePaths[index],
                      ),
                      
                      child: Image.asset(imagePaths[index], fit: BoxFit.cover),
                    );
                  },
                ),
    );
  }
}