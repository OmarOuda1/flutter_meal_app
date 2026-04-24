import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/recipe.dart';
import '../providers/settings_provider.dart';
import '../providers/recipes_provider.dart';
import 'recipe_detail_screen.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Recipe> _recipes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialRecipes();
  }

  Future<void> _loadInitialRecipes() async {
    setState(() {
      _isLoading = true;
    });
    final apiService = ref.read(apiServiceProvider);
    // Load some default recipes, let's search for an empty string or a generic letter
    final recipes = await apiService.searchRecipes('chicken');
    if (mounted) {
      setState(() {
        _recipes = recipes;
        _isLoading = false;
      });
    }
  }

  Future<void> _searchRecipes(String query) async {
    if (query.isEmpty) {
      _loadInitialRecipes();
      return;
    }
    setState(() {
      _isLoading = true;
    });
    final apiService = ref.read(apiServiceProvider);
    final recipes = await apiService.searchRecipes(query);
    if (mounted) {
      setState(() {
        _recipes = recipes;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search recipes...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: _searchRecipes,
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _recipes.isEmpty
                  ? const Center(child: Text('No recipes found.'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = _recipes[index];
                        final isFavorite = ref.watch(favoritesProvider).any((r) => r.id == recipe.id);
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecipeDetailScreen(recipe: recipe),
                              ),
                            );
                          },
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: recipe.imageUrl.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: recipe.imageUrl,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                          errorWidget: (context, url, error) => const Icon(Icons.error),
                                        )
                                      : Container(
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.fastfood, size: 50),
                                        ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          recipe.title,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          isFavorite ? Icons.favorite : Icons.favorite_border,
                                          color: isFavorite ? Colors.red : null,
                                        ),
                                        onPressed: () {
                                          ref.read(favoritesProvider.notifier).toggleFavorite(recipe);
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
