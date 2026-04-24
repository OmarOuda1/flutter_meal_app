import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recipe.dart';
import '../services/database_helper.dart';

class FavoritesNotifier extends StateNotifier<List<Recipe>> {
  FavoritesNotifier() : super([]) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final db = DatabaseHelper();
    state = await db.getFavoriteRecipes();
  }

  Future<void> toggleFavorite(Recipe recipe) async {
    final db = DatabaseHelper();
    await db.toggleFavorite(recipe);
    await loadFavorites();
  }

  bool isFavorite(String id) {
    return state.any((r) => r.id == id);
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<Recipe>>((ref) {
  return FavoritesNotifier();
});

class CustomRecipesNotifier extends StateNotifier<List<Recipe>> {
  CustomRecipesNotifier() : super([]) {
    loadCustomRecipes();
  }

  Future<void> loadCustomRecipes() async {
    final db = DatabaseHelper();
    state = await db.getCustomRecipes();
  }

  Future<void> addCustomRecipe(Recipe recipe) async {
    final db = DatabaseHelper();
    await db.insertRecipe(recipe);
    await loadCustomRecipes();
  }

  Future<void> deleteCustomRecipe(String id) async {
    final db = DatabaseHelper();
    await db.deleteRecipe(id);
    await loadCustomRecipes();
    // also reload favorites just in case it was a favorite custom recipe
  }
}

final customRecipesProvider = StateNotifierProvider<CustomRecipesNotifier, List<Recipe>>((ref) {
  return CustomRecipesNotifier();
});
