import 'package:flutter/material.dart';
import 'views/home_page.dart';
import 'views/yolo_camera.dart';
import 'views/upload_page.dart';
import 'views/image_detection_page.dart';
import 'views/recipe_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seefood',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/camera': (context) => const YoloCameraPage(),
        '/upload': (context) => const ImageUploadPage(),
        '/classify': (context) => const ImageDetectionPage(),
        '/recipe': (context) => const RecipePage(),
      },
    );
  }
}