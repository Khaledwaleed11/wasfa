class MealModel {
  final String id;
  final String name;
  final String image;
  final String category;
  final String area;
  final String instructions;
  final String? youtubeUrl;
  final String? sourceUrl;
  final List<IngredientModel> ingredients;

  const MealModel({
    required this.id,
    required this.name,
    required this.image,
    required this.category,
    required this.area,
    required this.instructions,
    this.youtubeUrl,
    this.sourceUrl,
    required this.ingredients,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    final ingredients = <IngredientModel>[];

    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i']?.toString().trim() ?? '';

      final measure = json['strMeasure$i']?.toString().trim() ?? '';

      if (ingredient.isNotEmpty) {
        ingredients.add(IngredientModel(name: ingredient, measure: measure));
      }
    }

    return MealModel(
      id: json['idMeal']?.toString() ?? '',
      name: json['strMeal']?.toString() ?? '',
      image: json['strMealThumb']?.toString() ?? '',
      category: json['strCategory']?.toString() ?? '',
      area: json['strArea']?.toString() ?? '',
      instructions: json['strInstructions']?.toString() ?? '',
      youtubeUrl: _nullableValue(json['strYoutube']),
      sourceUrl: _nullableValue(json['strSource']),
      ingredients: ingredients,
    );
  }

  static String? _nullableValue(dynamic value) {
    if (value == null) {
      return null;
    }

    final result = value.toString().trim();

    if (result.isEmpty) {
      return null;
    }

    return result;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'idMeal': id,
      'strMeal': name,
      'strMealThumb': image,
      'strCategory': category,
      'strArea': area,
      'strInstructions': instructions,
      'strYoutube': youtubeUrl,
      'strSource': sourceUrl,
    };

    for (int i = 0; i < ingredients.length; i++) {
      final index = i + 1;

      data['strIngredient$index'] = ingredients[i].name;
      data['strMeasure$index'] = ingredients[i].measure;
    }

    return data;
  }

  MealModel copyWith({
    String? id,
    String? name,
    String? image,
    String? category,
    String? area,
    String? instructions,
    String? youtubeUrl,
    String? sourceUrl,
    List<IngredientModel>? ingredients,
  }) {
    return MealModel(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      category: category ?? this.category,
      area: area ?? this.area,
      instructions: instructions ?? this.instructions,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      ingredients: ingredients ?? this.ingredients,
    );
  }
}

class IngredientModel {
  final String name;
  final String measure;

  const IngredientModel({required this.name, required this.measure});

  Map<String, dynamic> toJson() {
    return {'name': name, 'measure': measure};
  }

  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    return IngredientModel(
      name: json['name']?.toString() ?? '',
      measure: json['measure']?.toString() ?? '',
    );
  }

  IngredientModel copyWith({String? name, String? measure}) {
    return IngredientModel(
      name: name ?? this.name,
      measure: measure ?? this.measure,
    );
  }
}
