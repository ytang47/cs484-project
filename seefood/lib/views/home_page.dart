import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seefood')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Seefood',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 150,
              height: 75,
              child: ElevatedButton(// Button that leads to camera feature
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  iconColor: Colors.white,
                  iconSize: 36,
                ),
                onPressed: () => Navigator.pushNamed(context, '/camera'), 
                child: const Icon(Icons.camera_alt),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 150,
              height: 75,
              child: ElevatedButton(// Button that leads to upload feature
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  iconColor: Colors.white,
                  iconSize: 36,
                ),
                onPressed: () => Navigator.pushNamed(context, '/upload'),
                child: const Icon(Icons.upload_file),
              ),
            ),
          ],
        ),
      ),
    );
  }
}