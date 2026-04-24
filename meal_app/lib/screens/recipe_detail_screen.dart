import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/recipe.dart';
import '../providers/recipes_provider.dart';

class RecipeDetailScreen extends ConsumerWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(favoritesProvider).any((r) => r.id == recipe.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
            onPressed: () {
              ref.read(favoritesProvider.notifier).toggleFavorite(recipe);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (recipe.imageUrl.isNotEmpty)
              recipe.imageUrl.startsWith('http')
                  ? CachedNetworkImage(
                      imageUrl: recipe.imageUrl,
                      height: 250,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    )
                  : Image.file(
                      File(recipe.imageUrl),
                      height: 250,
                      fit: BoxFit.cover,
                    ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  if (recipe.category.isNotEmpty)
                    Chip(
                      label: Text(recipe.category),
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    ),
                  const SizedBox(height: 16),
                  Text(
                    'Ingredients',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(recipe.ingredients),
                  const SizedBox(height: 16),
                  Text(
                    'Instructions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(recipe.instructions),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
