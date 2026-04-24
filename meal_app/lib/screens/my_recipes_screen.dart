import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/recipe.dart';
import '../providers/recipes_provider.dart';
import 'recipe_detail_screen.dart';

class MyRecipesScreen extends ConsumerStatefulWidget {
  const MyRecipesScreen({super.key});

  @override
  ConsumerState<MyRecipesScreen> createState() => _MyRecipesScreenState();
}

class _MyRecipesScreenState extends ConsumerState<MyRecipesScreen> {
  @override
  Widget build(BuildContext context) {
    final customRecipes = ref.watch(customRecipesProvider);

    return Scaffold(
      body: customRecipes.isEmpty
          ? const Center(child: Text('No custom recipes added yet.'))
          : ListView.builder(
              itemCount: customRecipes.length,
              itemBuilder: (context, index) {
                final recipe = customRecipes[index];
                return ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.book),
                  ),
                  title: Text(recipe.title),
                  subtitle: Text(recipe.category),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      ref.read(customRecipesProvider.notifier).deleteCustomRecipe(recipe.id);
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailScreen(recipe: recipe),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddRecipeDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddRecipeDialog(BuildContext context) {
    final titleController = TextEditingController();
    final ingredientsController = TextEditingController();
    final instructionsController = TextEditingController();
    final categoryController = TextEditingController();
    String? selectedImagePath;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Add Custom Recipe'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (selectedImagePath != null)
                      Image.file(
                        File(selectedImagePath!),
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    else
                      Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 50),
                      ),
                    TextButton.icon(
                      onPressed: () async {
                        final picker = ImagePicker();
                        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          setStateDialog(() {
                            selectedImagePath = pickedFile.path;
                          });
                        }
                      },
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Select Image'),
                    ),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Category (e.g. Italian)'),
                ),
                TextField(
                  controller: ingredientsController,
                  decoration: const InputDecoration(labelText: 'Ingredients'),
                  maxLines: 3,
                ),
                    TextField(
                      controller: instructionsController,
                      decoration: const InputDecoration(labelText: 'Instructions'),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      final newRecipe = Recipe(
                        // Simple UUID for offline recipes
                        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                        title: titleController.text,
                        imageUrl: selectedImagePath ?? '', // We could add image picker later
                        instructions: instructionsController.text,
                        ingredients: ingredientsController.text,
                        category: categoryController.text,
                        area: '',
                        isCustom: true,
                      );
                      ref.read(customRecipesProvider.notifier).addCustomRecipe(newRecipe);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
