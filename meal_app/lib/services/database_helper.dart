import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static const String _favoritesKey = 'favorite_recipes';
  static const String _customRecipesKey = 'custom_recipes';

  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  Future<int> insertRecipe(Recipe recipe) async {
    final prefs = await _prefs;

    if (recipe.isFavorite) {
      List<Recipe> favs = await getFavoriteRecipes();
      final index = favs.indexWhere((r) => r.id == recipe.id);
      if (index >= 0) {
        favs[index] = recipe;
      } else {
        favs.add(recipe);
      }
      await prefs.setString(_favoritesKey, jsonEncode(favs.map((e) => e.toMap()).toList()));
    }

    if (recipe.isCustom) {
      List<Recipe> customs = await getCustomRecipes();
      final index = customs.indexWhere((r) => r.id == recipe.id);
      if (index >= 0) {
        customs[index] = recipe;
      } else {
        customs.add(recipe);
      }
      await prefs.setString(_customRecipesKey, jsonEncode(customs.map((e) => e.toMap()).toList()));
    }
    return 1;
  }

  Future<List<Recipe>> getFavoriteRecipes() async {
    final prefs = await _prefs;
    final String? data = prefs.getString(_favoritesKey);
    if (data == null) return [];

    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((e) => Recipe.fromMap(Map<String, dynamic>.from(e))).toList();
  }

  Future<List<Recipe>> getCustomRecipes() async {
    final prefs = await _prefs;
    final String? data = prefs.getString(_customRecipesKey);
    if (data == null) return [];

    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((e) => Recipe.fromMap(Map<String, dynamic>.from(e))).toList();
  }

  Future<int> deleteRecipe(String id) async {
    final prefs = await _prefs;

    // Attempt to delete from custom recipes
    List<Recipe> customs = await getCustomRecipes();
    final customIndex = customs.indexWhere((r) => r.id == id);
    if (customIndex >= 0) {
      customs.removeAt(customIndex);
      await prefs.setString(_customRecipesKey, jsonEncode(customs.map((e) => e.toMap()).toList()));
    }

    // Attempt to delete from favorites
    List<Recipe> favs = await getFavoriteRecipes();
    final favIndex = favs.indexWhere((r) => r.id == id);
    if (favIndex >= 0) {
      favs.removeAt(favIndex);
      await prefs.setString(_favoritesKey, jsonEncode(favs.map((e) => e.toMap()).toList()));
    }

    return 1;
  }

  Future<void> toggleFavorite(Recipe recipe) async {
    final prefs = await _prefs;
    List<Recipe> favs = await getFavoriteRecipes();
    final index = favs.indexWhere((r) => r.id == recipe.id);

    if (index >= 0) {
      // It exists in favorites, so remove it
      favs.removeAt(index);
      await prefs.setString(_favoritesKey, jsonEncode(favs.map((e) => e.toMap()).toList()));

      // If it's a custom recipe, we should also update its isFavorite status in custom recipes
      if (recipe.isCustom) {
         List<Recipe> customs = await getCustomRecipes();
         final customIndex = customs.indexWhere((r) => r.id == recipe.id);
         if (customIndex >= 0) {
           customs[customIndex] = customs[customIndex].copyWith(isFavorite: false);
           await prefs.setString(_customRecipesKey, jsonEncode(customs.map((e) => e.toMap()).toList()));
         }
      }
    } else {
      // It doesn't exist in favorites, so add it
      Recipe favoritedRecipe = recipe.copyWith(isFavorite: true);
      favs.add(favoritedRecipe);
      await prefs.setString(_favoritesKey, jsonEncode(favs.map((e) => e.toMap()).toList()));

      // If it's a custom recipe, we should also update its isFavorite status in custom recipes
      if (recipe.isCustom) {
         List<Recipe> customs = await getCustomRecipes();
         final customIndex = customs.indexWhere((r) => r.id == recipe.id);
         if (customIndex >= 0) {
           customs[customIndex] = customs[customIndex].copyWith(isFavorite: true);
           await prefs.setString(_customRecipesKey, jsonEncode(customs.map((e) => e.toMap()).toList()));
         }
      }
    }
  }

  Future<bool> isFavorite(String id) async {
    List<Recipe> favs = await getFavoriteRecipes();
    return favs.any((r) => r.id == id);
  }
}
