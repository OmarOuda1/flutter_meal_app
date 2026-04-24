class Recipe {
  final String id;
  final String title;
  final String imageUrl;
  final String instructions;
  final String ingredients; // Stored as a comma-separated or JSON string depending on needs, simplifying to String for SQLite easily
  final String category;
  final String area;
  final bool isFavorite;
  final bool isCustom;

  Recipe({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.instructions,
    required this.ingredients,
    required this.category,
    required this.area,
    this.isFavorite = false,
    this.isCustom = false,
  });

  Recipe copyWith({
    String? id,
    String? title,
    String? imageUrl,
    String? instructions,
    String? ingredients,
    String? category,
    String? area,
    bool? isFavorite,
    bool? isCustom,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      instructions: instructions ?? this.instructions,
      ingredients: ingredients ?? this.ingredients,
      category: category ?? this.category,
      area: area ?? this.area,
      isFavorite: isFavorite ?? this.isFavorite,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'instructions': instructions,
      'ingredients': ingredients,
      'category': category,
      'area': area,
      'isFavorite': isFavorite ? 1 : 0,
      'isCustom': isCustom ? 1 : 0,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      title: map['title'],
      imageUrl: map['imageUrl'],
      instructions: map['instructions'],
      ingredients: map['ingredients'],
      category: map['category'],
      area: map['area'],
      isFavorite: map['isFavorite'] == 1,
      isCustom: map['isCustom'] == 1,
    );
  }

  factory Recipe.fromMealDB(Map<String, dynamic> map) {
    List<String> ingredientsList = [];
    for (int i = 1; i <= 20; i++) {
      String? ingredient = map['strIngredient$i'];
      String? measure = map['strMeasure$i'];
      if (ingredient != null && ingredient.trim().isNotEmpty) {
        ingredientsList.add("${measure != null ? measure.trim() : ''} ${ingredient.trim()}".trim());
      }
    }

    return Recipe(
      id: map['idMeal'],
      title: map['strMeal'] ?? '',
      imageUrl: map['strMealThumb'] ?? '',
      instructions: map['strInstructions'] ?? '',
      ingredients: ingredientsList.join('\n'),
      category: map['strCategory'] ?? '',
      area: map['strArea'] ?? '',
    );
  }

  factory Recipe.fromDummyJSON(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'].toString(),
      title: map['name'] ?? '',
      imageUrl: map['image'] ?? '',
      instructions: (map['instructions'] as List<dynamic>?)?.join('\n') ?? '',
      ingredients: (map['ingredients'] as List<dynamic>?)?.join('\n') ?? '',
      category: map['cuisine'] ?? '',
      area: '',
    );
  }
}
