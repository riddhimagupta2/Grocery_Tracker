class RecipeModel {
  final String id;
  final String name;
  final String iconKey;
  final String cuisine;
  final String dietType;
  
  final int prepTimeMins;
  final int caloriesPerServing;
  final int servings;
  
  final List<String> ingredientsUsed;
  final List<String> otherIngredients;
  final List<String> allergens;
  final List<String> steps;
  final Map<String, String> nutrition;
  
  final String tip;
  final String allergenWarning;

  const RecipeModel({
    required this.id,
    required this.name,
    this.iconKey = 'restaurant',
    required this.cuisine,
    required this.dietType,
    required this.prepTimeMins,
    required this.caloriesPerServing,
    required this.servings,
    required this.ingredientsUsed,
    required this.otherIngredients,
    required this.allergens,
    required this.steps,
    required this.nutrition,
    required this.tip,
    required this.allergenWarning,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      iconKey: json['icon_key'] ?? 'restaurant',
      cuisine: json['cuisine'] ?? '',
      dietType: json['diet_type'] ?? 'veg',
      prepTimeMins: int.tryParse(json['prep_time_mins']?.toString() ?? '30') ?? 30,
      caloriesPerServing: int.tryParse(json['calories_per_serving']?.toString() ?? '200') ?? 200,
      servings: int.tryParse(json['servings']?.toString() ?? '2') ?? 2,
      ingredientsUsed: List<String>.from(json['ingredients_used'] ?? []),
      otherIngredients: List<String>.from(json['other_ingredients'] ?? []),
      allergens: List<String>.from(json['allergens'] ?? []),
      steps: List<String>.from(json['steps'] ?? []),
      nutrition: Map<String, String>.from(json['nutrition'] ?? {}),
      tip: json['tip'] ?? '',
      allergenWarning: json['allergen_warning'] ?? '',
    );
  }
}