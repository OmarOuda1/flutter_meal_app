import 'dart:io';
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
  final ScrollController _scrollController = ScrollController();
  List<Recipe> _recipes = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String _currentQuery = '';
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialRecipes();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_isLoadingMore && _hasMore) {
      _loadMoreRecipes();
    }
  }

  Future<void> _loadInitialRecipes() async {
    setState(() {
      _isLoading = true;
      _hasMore = true;
      _recipes.clear();
    });
    final apiService = ref.read(apiServiceProvider);
    final recipes = await apiService.searchRecipes(_currentQuery, skip: 0, limit: _limit);
    if (mounted) {
      setState(() {
        _recipes = recipes;
        _isLoading = false;
        if (recipes.length < _limit) {
          _hasMore = false;
        }
      });
    }
  }

  Future<void> _loadMoreRecipes() async {
    setState(() {
      _isLoadingMore = true;
    });
    final apiService = ref.read(apiServiceProvider);
    final recipes = await apiService.searchRecipes(_currentQuery, skip: _recipes.length, limit: _limit);
    if (mounted) {
      setState(() {
        if (recipes.isEmpty) {
          _hasMore = false;
        } else {
          _recipes.addAll(recipes);
        }
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _searchRecipes(String query) async {
    _currentQuery = query;
    await _loadInitialRecipes();
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesProvider);

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
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _recipes.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _recipes.length) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final recipe = _recipes[index];
                        final isFavorite = favorites.any((r) => r.id == recipe.id);
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
                                      ? (recipe.imageUrl.startsWith('http')
                                          ? CachedNetworkImage(
                                              imageUrl: recipe.imageUrl,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                              errorWidget: (context, url, error) => const Icon(Icons.error),
                                            )
                                          : Image.file(
                                              File(recipe.imageUrl),
                                              fit: BoxFit.cover,
                                            ))
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
