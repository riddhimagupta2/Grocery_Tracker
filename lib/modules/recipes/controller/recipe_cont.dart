import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../data/models/recipe_model.dart';

class RecipeController extends GetxController {
  final _db  = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  final isLoading   = false.obs;
  final recipes     = <Recipe>[].obs;
  final errorMsg    = ''.obs;
  final selectedFilter = 'All'.obs;
  final selectedRecipe = Rx<Recipe?>(null);

  final filters = ['All', 'Veg', 'Non-Veg', 'Quick <30m', 'No Allergens'];

  static const _geminiKey = 'YOUR_GEMINI_API_KEY';
  static const _geminiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  @override
  void onInit() {
    super.onInit();
    fetchRecipes();
  }

  Future<void> fetchRecipes() async {
    if (_uid.isEmpty) return;
    isLoading.value = true;
    errorMsg.value  = '';
    try {
      // Get expiring items from Firestore
      final snap = await _db
          .collection('users').doc(_uid)
          .collection('grocery_items')
          .where('status', whereIn: ['fresh', 'expiring'])
          .limit(15)
          .get();

      if (snap.docs.isEmpty) {
        errorMsg.value = 'Add grocery items first to get recipe suggestions.';
        isLoading.value = false;
        return;
      }

          final items = snap.docs.map((d) {
        final data = d.data();
        return {'name': data['name'] ?? '', 'quantity': '${data['quantity']} ${data['unit']}'};
      }).toList();

      final userDoc = await _db.collection('users').doc(_uid).get();
      final prefs   = userDoc.data() ?? {};

      await _callGemini(items, prefs);
    } catch (e) {
      errorMsg.value = 'Failed to load recipes. Check your connection.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _callGemini(List<Map> items, Map prefs) async {
    final itemsStr = items.map((i) => '${i['name']} (${i['quantity']})').join(', ');
    final diet     = prefs['diet_type'] ?? 'vegetarian';
    final cuisine  = prefs['cuisine_pref'] ?? 'Indian';
    final allergies = List<String>.from(prefs['allergies'] ?? []);
    final allergyStr = allergies.isEmpty ? 'none' : allergies.join(', ');

    final prompt = '''You are a professional chef. Suggest 4 recipes using these ingredients: $itemsStr.
User: diet=$diet, cuisine=$cuisine, allergies=$allergyStr, cooking time: under 45 mins.
Return ONLY a valid JSON array, no markdown, no explanation:
[{"name":"","emoji":"","cuisine":"","diet_type":"veg","prep_time_mins":30,"calories_per_serving":300,"servings":2,"ingredients_used":[],"other_ingredients":[],"allergens":[],"steps":[],"nutrition":{"protein_g":0,"carbs_g":0,"fat_g":0,"fiber_g":0},"tip":""}]''';

    try {
      final res = await http.post(
        Uri.parse('$_geminiUrl?key=$_geminiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{'parts': [{'text': prompt}]}],
          'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 2000},
        }),
      );

      if (res.statusCode == 200) {
        final data   = jsonDecode(res.body);
        var text     = data['candidates'][0]['content']['parts'][0]['text'] as String;
        text = text.replaceAll(RegExp(r'```json|```'), '').trim();
        final list   = jsonDecode(text) as List;
        recipes.value = list.map((j) => Recipe.fromJson(j)).toList();
      } else {
         recipes.value = _mockRecipes();
      }
    } catch (_) {
      recipes.value = _mockRecipes();
    }
  }

  List<Recipe> get filteredRecipes {
    final f = selectedFilter.value;
    if (f == 'All') return recipes;
    if (f == 'Veg') return recipes.where((r) => r.dietType == 'veg').toList();
    if (f == 'Non-Veg') return recipes.where((r) => r.dietType == 'non-veg').toList();
    if (f == 'Quick <30m') return recipes.where((r) => r.prepTimeMins < 30).toList();
    if (f == 'No Allergens') return recipes.where((r) => r.allergens.isEmpty).toList();
    return recipes;
  }

  List<Recipe> _mockRecipes() => [
    Recipe(
      name: 'Dal Tadka', emoji: '🫘', cuisine: 'North Indian', dietType: 'veg',
      prepTimeMins: 30, caloriesPerServing: 320, servings: 2,
      ingredientsUsed: ['Lentils', 'Tomatoes', 'Onion'],
      otherIngredients: ['Ghee', 'Cumin', 'Garlic', 'Salt'],
      allergens: [], steps: [
      'Boil lentils until soft', 'Prepare tadka with ghee, cumin, garlic',
      'Add tomatoes and onion to tadka', 'Combine with lentils and simmer 10 mins',
    ],
      nutrition: {'protein_g': 14, 'carbs_g': 48, 'fat_g': 6, 'fiber_g': 8},
      tip: 'Add a squeeze of lemon at the end for extra flavour.',
    ),
    Recipe(
      name: 'Paneer Bhurji', emoji: '🧀', cuisine: 'North Indian', dietType: 'veg',
      prepTimeMins: 20, caloriesPerServing: 280, servings: 2,
      ingredientsUsed: ['Paneer', 'Tomatoes', 'Onion', 'Capsicum'],
      otherIngredients: ['Oil', 'Spices', 'Coriander'],
      allergens: ['Dairy'], steps: [
      'Crumble paneer and keep aside',
      'Sauté onion and capsicum in oil',
      'Add tomatoes and cook till soft',
      'Mix in paneer and spices, cook 5 mins',
    ],
      nutrition: {'protein_g': 18, 'carbs_g': 12, 'fat_g': 18, 'fiber_g': 3},
      tip: 'Use fresh paneer for best texture.',
    ),
    Recipe(
      name: 'Aloo Sabzi', emoji: '🥔', cuisine: 'North Indian', dietType: 'veg',
      prepTimeMins: 25, caloriesPerServing: 220, servings: 3,
      ingredientsUsed: ['Potato', 'Tomatoes', 'Onion'],
      otherIngredients: ['Mustard seeds', 'Turmeric', 'Salt'],
      allergens: [], steps: [
      'Boil potatoes and cube them',
      'Sauté onions with mustard seeds',
      'Add tomatoes and turmeric',
      'Mix potatoes, cook 10 mins',
    ],
      nutrition: {'protein_g': 4, 'carbs_g': 38, 'fat_g': 5, 'fiber_g': 4},
      tip: 'Add amchur (dry mango powder) for tangy taste.',
    ),
    Recipe(
      name: 'Curd Rice', emoji: '🍚', cuisine: 'South Indian', dietType: 'veg',
      prepTimeMins: 15, caloriesPerServing: 240, servings: 2,
      ingredientsUsed: ['Rice', 'Milk', 'Curd'],
      otherIngredients: ['Mustard seeds', 'Curry leaves', 'Salt'],
      allergens: ['Dairy'], steps: [
      'Cook rice and let it cool slightly',
      'Mix warm milk with curd and add to rice',
      'Prepare tempering with mustard and curry leaves',
      'Mix tempering into rice',
    ],
      nutrition: {'protein_g': 8, 'carbs_g': 42, 'fat_g': 4, 'fiber_g': 1},
      tip: 'Best served chilled with pickle.',
    ),
  ];

  void setFilter(String f) => selectedFilter.value = f;
  void openRecipe(Recipe r) { selectedRecipe.value = r; Get.toNamed('/recipe-detail'); }
}