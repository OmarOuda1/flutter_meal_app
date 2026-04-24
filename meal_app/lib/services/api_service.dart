import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

abstract class ApiService {
  Future<List<Recipe>> searchRecipes(String query, {int skip = 0, int limit = 20});
  Future<List<Recipe>> getRecipesByCategory(String category);
  Future<List<String>> getCategories();
  Future<Recipe?> getRecipeById(String id);
}

class TheMealDBService implements ApiService {
  final String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  @override
  Future<List<Recipe>> searchRecipes(String query, {int skip = 0, int limit = 20}) async {
    // TheMealDB doesn't support proper pagination for search.
    // We'll fetch all and simulate pagination locally.
    // If the query is empty, we search for a random letter to populate the feed.
    final actualQuery = query.isEmpty ? 'c' : query;
    final response = await http.get(Uri.parse('$_baseUrl/search.php?s=$actualQuery'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['meals'] != null) {
        final allRecipes = (data['meals'] as List).map((json) => Recipe.fromMealDB(json)).toList();
        if (skip >= allRecipes.length) return [];
        return allRecipes.skip(skip).take(limit).toList();
      }
    }
    return [];
  }

  @override
  Future<List<Recipe>> getRecipesByCategory(String category) async {
    final response = await http.get(Uri.parse('$_baseUrl/filter.php?c=$category'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['meals'] != null) {
        // filter.php only returns partial meal data (id, title, image)
        // We might need to fetch full details if needed, but for listing this is okay.
        return (data['meals'] as List).map((json) => Recipe.fromMealDB(json)).toList();
      }
    }
    return [];
  }

  @override
  Future<List<String>> getCategories() async {
    final response = await http.get(Uri.parse('$_baseUrl/list.php?c=list'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['meals'] != null) {
        return (data['meals'] as List).map((json) => json['strCategory'] as String).toList();
      }
    }
    return [];
  }

  @override
  Future<Recipe?> getRecipeById(String id) async {
    final response = await http.get(Uri.parse('$_baseUrl/lookup.php?i=$id'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['meals'] != null && data['meals'].isNotEmpty) {
        return Recipe.fromMealDB(data['meals'][0]);
      }
    }
    return null;
  }
}

class DummyJSONService implements ApiService {
  final String _baseUrl = 'https://dummyjson.com/recipes';

  @override
  Future<List<Recipe>> searchRecipes(String query, {int skip = 0, int limit = 20}) async {
    final response = await http.get(Uri.parse('$_baseUrl/search?q=$query&skip=$skip&limit=$limit'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['recipes'] != null) {
        return (data['recipes'] as List).map((json) => Recipe.fromDummyJSON(json)).toList();
      }
    }
    return [];
  }

  @override
  Future<List<Recipe>> getRecipesByCategory(String category) async {
    final response = await http.get(Uri.parse('$_baseUrl/tag/$category'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['recipes'] != null) {
        return (data['recipes'] as List).map((json) => Recipe.fromDummyJSON(json)).toList();
      }
    }
    return [];
  }

  @override
  Future<List<String>> getCategories() async {
    final response = await http.get(Uri.parse('$_baseUrl/tags'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // DummyJSON returns a list of strings directly
      return List<String>.from(data);
    }
    return [];
  }

  @override
  Future<Recipe?> getRecipeById(String id) async {
    final response = await http.get(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Recipe.fromDummyJSON(data);
    }
    return null;
  }
}
