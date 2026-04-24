import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/recipe.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'meal_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE recipes(
        id TEXT PRIMARY KEY,
        title TEXT,
        imageUrl TEXT,
        instructions TEXT,
        ingredients TEXT,
        category TEXT,
        area TEXT,
        isFavorite INTEGER,
        isCustom INTEGER
      )
    ''');
  }

  Future<int> insertRecipe(Recipe recipe) async {
    Database db = await database;
    return await db.insert(
      'recipes',
      recipe.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Recipe>> getFavoriteRecipes() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recipes',
      where: 'isFavorite = ?',
      whereArgs: [1],
    );
    return List.generate(maps.length, (i) {
      return Recipe.fromMap(maps[i]);
    });
  }

  Future<List<Recipe>> getCustomRecipes() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recipes',
      where: 'isCustom = ?',
      whereArgs: [1],
    );
    return List.generate(maps.length, (i) {
      return Recipe.fromMap(maps[i]);
    });
  }

  Future<int> deleteRecipe(String id) async {
    Database db = await database;
    return await db.delete(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> toggleFavorite(Recipe recipe) async {
    Database db = await database;
    // Check if it already exists
    final List<Map<String, dynamic>> existing = await db.query(
      'recipes',
      where: 'id = ?',
      whereArgs: [recipe.id],
    );

    if (existing.isNotEmpty) {
      // Exists, update it
      Recipe existingRecipe = Recipe.fromMap(existing.first);
      if (existingRecipe.isFavorite) {
        // Was favorite, now unset it.
        // If it's not custom, we might just delete it from DB if it's only stored for being a favorite.
        if (!existingRecipe.isCustom) {
           await deleteRecipe(recipe.id);
        } else {
           await db.update('recipes', existingRecipe.copyWith(isFavorite: false).toMap(), where: 'id = ?', whereArgs: [recipe.id]);
        }
      } else {
         await db.update('recipes', existingRecipe.copyWith(isFavorite: true).toMap(), where: 'id = ?', whereArgs: [recipe.id]);
      }
    } else {
      // Doesn't exist, insert as favorite
      await insertRecipe(recipe.copyWith(isFavorite: true));
    }
  }

  Future<bool> isFavorite(String id) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recipes',
      where: 'id = ? AND isFavorite = ?',
      whereArgs: [id, 1],
    );
    return maps.isNotEmpty;
  }
}
