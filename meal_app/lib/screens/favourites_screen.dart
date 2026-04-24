import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../providers/recipes_provider.dart';
import 'recipe_detail_screen.dart';

class FavouritesScreen extends ConsumerStatefulWidget {
  const FavouritesScreen({super.key});

  @override
  ConsumerState<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends ConsumerState<FavouritesScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesProvider);

    // Extract unique categories for filter
    final categories = ['All'];
    for (var recipe in favorites) {
      if (recipe.category.isNotEmpty && !categories.contains(recipe.category)) {
        categories.add(recipe.category);
      }
    }

    final filteredFavorites = favorites.where((recipe) {
      final matchesSearch = recipe.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || recipe.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search favourites...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        if (categories.length > 1)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        Expanded(
          child: filteredFavorites.isEmpty
              ? const Center(child: Text('No favorite recipes found.'))
              : ListView.builder(
                  itemCount: filteredFavorites.length,
                  itemBuilder: (context, index) {
                    final recipe = filteredFavorites[index];
                    return ListTile(
                      leading: recipe.imageUrl.isNotEmpty
                          ? SizedBox(
                              width: 50,
                              height: 50,
                              child: recipe.imageUrl.startsWith('http')
                                  ? CachedNetworkImage(
                                      imageUrl: recipe.imageUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) => const Icon(Icons.error),
                                    )
                                  : Image.file(
                                      File(recipe.imageUrl),
                                      fit: BoxFit.cover,
                                    ),
                            )
                          : Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[300],
                              child: const Icon(Icons.fastfood),
                            ),
                      title: Text(recipe.title),
                      subtitle: Text(recipe.category),
                      trailing: IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: () {
                          ref.read(favoritesProvider.notifier).toggleFavorite(recipe);
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
        ),
      ],
    );
  }
}
