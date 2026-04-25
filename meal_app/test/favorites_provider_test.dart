import 'package:flutter_test/flutter_test.dart';
import 'package:meal_app/models/recipe.dart';
import 'package:meal_app/services/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('FavoritesNotifier state with SharedPreferences', () async {
    SharedPreferences.setMockInitialValues({});

    final dbHelper = DatabaseHelper();

    final recipe = Recipe(
      id: "12345",
      title: "Test Recipe",
      imageUrl: "http://example.com/image.jpg",
      instructions: "Mix it all together.",
      ingredients: "1 cup sugar",
      category: "Dessert",
      area: "American",
    );

    await dbHelper.toggleFavorite(recipe);

    final favsAfter = await dbHelper.getFavoriteRecipes();
    expect(favsAfter.length, 1);
  });
}
