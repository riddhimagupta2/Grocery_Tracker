from django.db import models
from django.conf import settings
import uuid

class Recipe(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='recipes')
    
    name = models.CharField(max_length=150)
    icon_key = models.CharField(max_length=50, default='restaurant')
    cuisine = models.CharField(max_length=100, blank=True)
    diet_type = models.CharField(max_length=50, default='veg')
    
    prep_time_mins = models.PositiveIntegerField(default=30)
    calories_per_serving = models.PositiveIntegerField(default=200)
    servings = models.PositiveIntegerField(default=2)
    
    ingredients_used = models.JSONField(default=list)
    other_ingredients = models.JSONField(default=list)
    allergens = models.JSONField(default=list)
    steps = models.JSONField(default=list)
    nutrition = models.JSONField(default=dict)
    
    tip = models.TextField(blank=True)
    allergen_warning = models.TextField(blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name
