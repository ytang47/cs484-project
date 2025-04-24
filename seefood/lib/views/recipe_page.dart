import 'package:flutter/material.dart';

class RecipePage extends StatelessWidget {
  const RecipePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the image path passed from the previous screen
    final imagePath = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Recipe Title
            const Text(
              'Recipe for Bacon',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // Detected Food Image
            Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    imagePath,
                    width: 300,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            
            // Recipe Section
            const Text(
              'Crispy Oven-Baked Bacon',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            
            // Ingredients
            const Text(
              'Ingredients:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '• 1 lb thick-cut bacon\n'
              '• 1 tbsp brown sugar (optional)\n'
              '• ½ tsp black pepper (optional)\n'
              '• ¼ tsp smoked paprika (optional)',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            
            // Instructions
            const Text(
              'Instructions:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '1. Preheat oven to 400°F (200°C).\n'
              '2. Line a baking sheet with aluminum foil.\n'
              '3. Arrange bacon slices in a single layer.\n'
              '4. Sprinkle with seasonings if desired.\n'
              '5. Bake for 15-20 minutes until crispy.\n'
              '6. Transfer to paper towels to drain.\n'
              '7. Serve immediately while hot!',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            
            // Tips
            const Text(
              'Chef\'s Tips:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '• For extra crispiness, use a baking rack\n'
              '• Save bacon grease for cooking other dishes\n'
              '• Try maple syrup glaze for sweet bacon\n'
              '• Thicker cuts take longer to cook',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}