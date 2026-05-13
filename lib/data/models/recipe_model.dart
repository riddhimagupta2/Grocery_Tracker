class Recipe {
  final String name;
  final String emoji;
  final String cuisine;
  final String dietType;
  final int prepTimeMins;
  final int caloriesPerServing;
  final int servings;
  final List<String> ingredientsUsed;
  final List<String> otherIngredients;
  final List<String> allergens;
  final List<String> steps;
  final Map<String, dynamic> nutrition;
  final String tip;

  Recipe({
    required this.name, required this.emoji, required this.cuisine,
    required this.dietType, required this.prepTimeMins,
    required this.caloriesPerServing, required this.servings,
    required this.ingredientsUsed, required this.otherIngredients,
    required this.allergens, required this.steps,
    required this.nutrition, required this.tip,
  });

  factory Recipe.fromJson(Map<String, dynamic> j) => Recipe(
    name:               j['name']               ?? 'Recipe',
    emoji:              j['emoji']              ?? '🍛',
    cuisine:            j['cuisine']            ?? 'Indian',
    dietType:           j['diet_type']          ?? 'veg',
    prepTimeMins:       (j['prep_time_mins']    ?? 30) as int,
    caloriesPerServing: (j['calories_per_serving'] ?? 300) as int,
    servings:           (j['servings']          ?? 2) as int,
    ingredientsUsed:    List<String>.from(j['ingredients_used'] ?? []),
    otherIngredients:   List<String>.from(j['other_ingredients'] ?? []),
    allergens:          List<String>.from(j['allergens'] ?? []),
    steps:              List<String>.from(j['steps'] ?? []),
    nutrition:          Map<String, dynamic>.from(j['nutrition'] ?? {}),
    tip:                j['tip'] ?? '',
  );
}