import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../../kitchen/providers/kitchen_provider.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_spacing.dart';
import '../../../config/app_radius.dart';
import '../../../config/app_icon_sizes.dart';
import '../../../config/app_text_styles.dart';
import '../../../config/app_routes.dart';
import '../../../config/recipe_icon_mapper.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_retry_state.dart';
import '../../../core/extensions/responsive_context_extension.dart';

class RecipesView extends StatefulWidget {
  const RecipesView({super.key});

  @override
  State<RecipesView> createState() => _RecipesViewState();
}

class _RecipesViewState extends State<RecipesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipeProvider>().fetchRecipes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final recipe = context.watch<RecipeProvider>();
    final kitchen = context.watch<KitchenProvider>();

    return AppScaffold(
      isLoading: recipe.isLoading,
      appBar: AppBar(
        title: Text(
          'Smart Recipes', 
          style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: context.scaleFont(20.0)),
        ),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.tips_and_updates_outlined, size: AppIconSizes.md(context), color: AppColors.primary),
            onPressed: () {
              // Show AI recipe tips dialogue
            },
          )
        ],
      ),
      body: recipe.errorMessage != null
          ? AppRetryState(
              errorMessage: recipe.errorMessage!,
              onRetry: () => recipe.fetchRecipes(),
            )
          : Column(
              children: [
                // Filter Tab Bar
                _buildFiltersBar(recipe),
                const Divider(),
                
                // Recipe List
                Expanded(
                  child: recipe.recipes.isEmpty
                      ? _buildEmptyState(recipe, kitchen)
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.md(context),
                            vertical: AppSpacing.sm(context),
                          ),
                          itemCount: recipe.recipes.length,
                          itemBuilder: (ctx, index) {
                            final r = recipe.recipes[index];
                            return _buildRecipeCard(r);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildFiltersBar(RecipeProvider provider) {
    final filters = [
      {'key': 'all', 'label': 'All Recipes'},
      {'key': 'veg', 'label': 'Vegetarian'},
      {'key': 'non-veg', 'label': 'Meat/Fish'},
      {'key': 'quick', 'label': 'Quick (<30m)'},
    ];

    return SizedBox(
      height: context.scaleHeight(48.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm(context)),
        itemCount: filters.length,
        itemBuilder: (ctx, index) {
          final f = filters[index];
          final isSelected = provider.filter == f['key'];
          return GestureDetector(
            onTap: () => provider.setFilter(f['key']!),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.card,
                borderRadius: BorderRadius.circular(AppRadius.chip(context) * 2.0),
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.cardBorder),
              ),
              child: Center(
                child: Text(
                  f['label']!,
                  style: AppTextStyles.labelMedium(context).copyWith(
                    color: isSelected ? AppColors.white : AppColors.textPrimary,
                    fontSize: context.scaleFont(12.0),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecipeCard(dynamic r) {
    return Card(
      color: AppColors.card,
      margin: EdgeInsets.symmetric(vertical: AppSpacing.xxs(context)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card(context)),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.recipeDetail, arguments: r);
        },
        borderRadius: BorderRadius.circular(AppRadius.card(context)),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.sm(context)),
          child: Row(
            children: [
              // Recipe Icon Box
              Container(
                width: context.scaleWidth(56.0),
                height: context.scaleWidth(56.0),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.card(context) * 0.75),
                ),
                child: Center(
                  child: Icon(
                    RecipeIconMapper.fromKey(r.iconKey),
                    size: AppIconSizes.md(context),
                    color: AppColors.primary,
                  ),
                ),
              ),
              AppGap.sm(context),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.name,
                      style: AppTextStyles.headingMedium(context).copyWith(fontSize: context.scaleFont(16.0)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: [
                        Text(
                          '${r.prepTimeMins} mins',
                          style: AppTextStyles.caption(context).copyWith(color: AppColors.textSecondary),
                        ),
                        Text(
                          '${r.caloriesPerServing} kcal',
                          style: AppTextStyles.caption(context).copyWith(color: AppColors.textSecondary),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: r.dietType.toLowerCase() == 'veg'
                                ? AppColors.success.withValues(alpha: 0.1)
                                : AppColors.danger.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            r.dietType.toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: context.scaleFont(8.0),
                              color: r.dietType.toLowerCase() == 'veg' ? AppColors.success : AppColors.danger,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: AppIconSizes.sm(context) * 0.8, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(RecipeProvider recipe, KitchenProvider kitchen) {
    final bool hasKitchenItems = kitchen.items.isNotEmpty;
    
    return Padding(
      padding: EdgeInsets.all(AppSpacing.xl(context)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_rounded,
            size: AppIconSizes.lg(context) * 2.0,
            color: AppColors.textSecondary,
          ),
          AppGap.md(context),
          Text(
            'No Recipes Yet',
            style: AppTextStyles.headingMedium(context),
          ),
          AppGap.xs(context),
          Text(
            hasKitchenItems
                ? 'Generate delicious recipes using ingredients already in your kitchen.'
                : 'Add groceries to your kitchen to enable recipe generation.',
            style: AppTextStyles.bodyMedium(context),
            textAlign: TextAlign.center,
          ),
          AppGap.lg(context),
          if (hasKitchenItems)
            SizedBox(
              width: context.scaleWidth(220.0),
              child: AppButton(
                text: 'Generate Recipes',
                onPressed: () => recipe.generateNewRecipes(),
              ),
            ),
        ],
      ),
    );
  }
}
