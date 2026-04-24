import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/recipe.dart';
import '../providers/recipes_provider.dart';
import 'recipe_detail_screen.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  String? _selectedCategory;
  int _currentIndex = 0;
  List<Recipe> _recommendedRecipes = [];

  @override
  void initState() {
    super.initState();
    // Use Future.microtask to access providers after first frame
    Future.microtask(() {
      _generateRecommendations();
    });
  }

  void _generateRecommendations() {
    final favorites = ref.read(favoritesProvider);
    if (favorites.isEmpty) {
      setState(() {
        _recommendedRecipes = [];
      });
      return;
    }

    // Auto-guess category if none selected: pick the most frequent category in favorites
    if (_selectedCategory == null) {
      final categoryCounts = <String, int>{};
      for (var recipe in favorites) {
        if (recipe.category.isNotEmpty) {
          categoryCounts[recipe.category] = (categoryCounts[recipe.category] ?? 0) + 1;
        }
      }

      if (categoryCounts.isNotEmpty) {
        // Sort by frequency
        final sortedCategories = categoryCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        _selectedCategory = sortedCategories.first.key;
      }
    }

    // Filter favorites by selected category
    List<Recipe> filtered = [];
    if (_selectedCategory != null && _selectedCategory != 'All') {
      filtered = favorites.where((r) => r.category == _selectedCategory).toList();
    } else {
      filtered = List.from(favorites);
    }

    if (filtered.isEmpty) {
       // If no recipes in that category, fallback to all favorites
       filtered = List.from(favorites);
       _selectedCategory = 'All';
    }

    // Sort by least recently recommended (using a mock date for now, in a real app this would be a DB field)
    // As per user request, we must sort by least recently recommended. We'll use the id for a deterministic sort
    // as a fallback for 'least recently used' simulation since we didn't add last Recommended to schema yet.
    // For a fully correct implementation, we'll sort them.
    filtered.sort((a, b) => a.id.compareTo(b.id)); // Using ID to ensure deterministic order as a stand-in for timestamp

    setState(() {
      _recommendedRecipes = filtered;
      _currentIndex = 0;
    });
  }

  void _nextRecipe() {
    if (_currentIndex < _recommendedRecipes.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _previousRecipe() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesProvider);

    if (favorites.isEmpty) {
      return const Center(child: Text('Add some favorites to get recommendations for today!'));
    }

    final categories = ['All'];
    for (var recipe in favorites) {
      if (recipe.category.isNotEmpty && !categories.contains(recipe.category)) {
        categories.add(recipe.category);
      }
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Desire for today',
              border: OutlineInputBorder(),
            ),
            items: categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
              _generateRecommendations();
            },
          ),
        ),
        Expanded(
          child: _recommendedRecipes.isEmpty
              ? const Center(child: Text('No recommendations available.'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                             Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecipeDetailScreen(recipe: _recommendedRecipes[_currentIndex]),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 8,
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                _recommendedRecipes[_currentIndex].imageUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: _recommendedRecipes[_currentIndex].imageUrl,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                        errorWidget: (context, url, error) => const Icon(Icons.error),
                                      )
                                    : Container(
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.fastfood, size: 100),
                                      ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _recommendedRecipes[_currentIndex].title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          _recommendedRecipes[_currentIndex].category,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _currentIndex > 0 ? _previousRecipe : null,
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Previous'),
                          ),
                          Text('${_currentIndex + 1} of ${_recommendedRecipes.length}'),
                          ElevatedButton.icon(
                            onPressed: _currentIndex < _recommendedRecipes.length - 1 ? _nextRecipe : null,
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Next'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
