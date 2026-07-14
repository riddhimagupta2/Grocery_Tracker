import json
import logging
from django.conf import settings
from django.utils import timezone
from PIL import Image
import google.generativeai as genai
from .prompts import SYSTEM_INSTRUCTION, GROCERY_SCAN_PROMPT

logger = logging.getLogger('freshtrack.gemini')

class GeminiClient:
    def __init__(self):
        self.api_key = getattr(settings, 'GEMINI_API_KEY', '')
        self.enabled = bool(self.api_key)
        if self.enabled:
            genai.configure(api_key=self.api_key)
        else:
            logger.warning("GEMINI_API_KEY is missing. Operating in mock fallback mode.")

    def analyze_grocery_image(self, image_path):
        if not self.enabled:
            return self._get_mock_fallback_response(image_path)
            
        try:
            logger.info(f"Opening image for Gemini analysis: {image_path}")
            img = Image.open(image_path)
            
            # Load model
            model = genai.GenerativeModel(
                model_name='gemini-3.5-flash',
                system_instruction=SYSTEM_INSTRUCTION
            )
            
            current_date_str = timezone.now().date().isoformat()
            prompt = GROCERY_SCAN_PROMPT.format(current_date=current_date_str)
            
            logger.info("Calling Gemini API...")
            response = model.generate_content([prompt, img])
            text_response = response.text.strip()
            
            # Clean possible markdown JSON formatting
            if text_response.startswith('```'):
                lines = text_response.splitlines()
                if lines[0].startswith('```json'):
                    text_response = '\n'.join(lines[1:-1])
                elif lines[0].startswith('```'):
                    text_response = '\n'.join(lines[1:-1])

            data = json.loads(text_response.strip())
            logger.info(f"Gemini successfully returned {len(data.get('items', []))} items.")
            return data
            
        except Exception as e:
            logger.error(f"Gemini analysis failed: {str(e)}", exc_info=True)
            return self._get_mock_fallback_response(image_path, error=str(e))

    def generate_recipes(self, available_items, preferences):
        """
        Builds a minimal prompt and calls Gemini to generate 4 recipes.
        available_items: list of grocery item name strings + remaining days.
        preferences: dict containing diet, cuisine, household size, allergies.
        """
        if not self.enabled:
            return self._get_mock_recipe_response(preferences)

        try:
            model = genai.GenerativeModel('gemini-3.5-flash')
            
            prompt = f"""
            You are a creative chef. Generate exactly 4 recipes that can be made using the following available items.
            Prioritize items close to expiry.
            
            Available Groceries:
            {json.dumps(available_items)}
            
            User Preferences:
            - Diet: {preferences.get('diet_type', 'any')}
            - Cuisine Preference: {preferences.get('cuisine_pref', 'Indian')}
            - Allergies: {preferences.get('allergies', [])}
            - Household Size: {preferences.get('household_size', 1)}
            
            ALLERGY PROTECTION REQUIREMENT:
            Verify recipe ingredients against the user's recorded allergies ({preferences.get('allergies', [])}). 
            If any recipe contains an allergen, list it under "allergen_warning". Otherwise leave empty.
            
            Return JSON matching the following schema only:
            {{
              "recipes": [
                {{
                  "name": "string",
                  "icon_key": "string",
                  "cuisine": "string",
                  "diet_type": "veg or non-veg",
                  "prep_time_mins": number,
                  "calories_per_serving": number,
                  "servings": number,
                  "ingredients_used": ["item1", "item2"],
                  "other_ingredients": ["item3", "item4"],
                  "allergens": ["allergen1"],
                  "steps": ["step 1", "step 2"],
                  "nutrition": {{
                    "protein": "string",
                    "carbs": "string",
                    "fat": "string",
                    "fiber": "string"
                  }},
                  "tip": "string",
                  "allergen_warning": "string"
                }}
              ]
            }}
            """
            
            logger.info("Calling Gemini for Recipe Generation...")
            response = model.generate_content(prompt)
            text_response = response.text.strip()
            
            if text_response.startswith('```'):
                lines = text_response.splitlines()
                if lines[0].startswith('```json'):
                    text_response = '\n'.join(lines[1:-1])
                elif lines[0].startswith('```'):
                    text_response = '\n'.join(lines[1:-1])

            data = json.loads(text_response.strip())
            return data
            
        except Exception as e:
            logger.error(f"Recipe generation failed: {str(e)}", exc_info=True)
            return self._get_mock_recipe_response(preferences)

    def _get_mock_fallback_response(self, image_path, error=None):
        logger.info("Generating mock fallback scan detection...")
        # Safe mock detections fallback
        return {
            "items": [
                {
                    "name": "Tomato",
                    "brand": "Fresh Farms",
                    "description": "Fresh red tomatoes commonly used in curries, salads and gravies.",
                    "icon_key": "vegetables",
                    "category": "Vegetables",
                    "expiry_date": (timezone.now() + timezone.timedelta(days=7)).date().isoformat(),
                    "storage_zone": "fridge",
                    "quantity": 1.0,
                    "unit": "kg",
                    "confidence": "High"
                },
                {
                    "name": "Full Cream Milk",
                    "brand": "Amul",
                    "description": "Packaged dairy milk. Refrigerate immediately after purchase.",
                    "icon_key": "dairy",
                    "category": "Dairy",
                    "expiry_date": (timezone.now() + timezone.timedelta(days=2)).date().isoformat(),
                    "storage_zone": "fridge",
                    "quantity": 1.0,
                    "unit": "L",
                    "confidence": "High"
                }
            ]
        }

    def _get_mock_recipe_response(self, preferences):
        logger.info("Generating mock fallback recipe list...")
        return {
            "recipes": [
                {
                    "name": "Quick Tomato Soup",
                    "icon_key": "beverage",
                    "cuisine": "Continental",
                    "diet_type": "veg",
                    "prep_time_mins": 20,
                    "calories_per_serving": 150,
                    "servings": 2,
                    "ingredients_used": ["Tomato"],
                    "other_ingredients": ["Garlic", "Onion", "Butter", "Cream"],
                    "allergens": ["dairy"],
                    "steps": [
                        "Saute onions and garlic in butter.",
                        "Add chopped tomatoes and simmer for 15 minutes.",
                        "Blend until smooth and strain.",
                        "Garnish with fresh cream and serve hot."
                    ],
                    "nutrition": {
                        "protein": "3g",
                        "carbs": "12g",
                        "fat": "8g",
                        "fiber": "2g"
                    },
                    "tip": "Roast the tomatoes beforehand for a richer smoky flavor.",
                    "allergen_warning": "Contains dairy (butter and cream)" if 'dairy' in preferences.get('allergies', []) else ""
                },
                {
                    "name": "Pantry Paneer Curry",
                    "icon_key": "restaurant",
                    "cuisine": "North Indian",
                    "diet_type": "veg",
                    "prep_time_mins": 25,
                    "calories_per_serving": 320,
                    "servings": 3,
                    "ingredients_used": ["Tomato", "Milk"],
                    "other_ingredients": ["Paneer", "Ginger-Garlic Paste", "Spices", "Oil"],
                    "allergens": ["dairy"],
                    "steps": [
                        "Puree tomatoes and set aside.",
                        "Saute ginger-garlic paste and spices.",
                        "Add tomato puree and cook till oil separates.",
                        "Slowly stir in milk and add paneer cubes.",
                        "Simmer for 5 minutes and garnish with coriander."
                    ],
                    "nutrition": {
                        "protein": "14g",
                        "carbs": "10g",
                        "fat": "22g",
                        "fiber": "3g"
                    },
                    "tip": "Use warm milk to prevent curdling in the gravy.",
                    "allergen_warning": "Contains dairy" if 'dairy' in preferences.get('allergies', []) else ""
                }
            ]
        }
