import json
import logging
from django.conf import settings
from django.utils import timezone
from PIL import Image
import google.generativeai as genai
from .base import GroceryVisionService, RecipeGenerationService
from .prompts import SYSTEM_INSTRUCTION, GROCERY_SCAN_PROMPT, RECIPE_GENERATION_PROMPT
from .schemas import GROCERY_SCAN_SCHEMA, RECIPE_GENERATION_SCHEMA

logger = logging.getLogger('freshtrack.ai.gemini')

class GeminiClient(GroceryVisionService, RecipeGenerationService):
    def __init__(self):
        self.api_key = getattr(settings, 'GEMINI_API_KEY', '')
        self.enabled = bool(self.api_key)
        
        # Load model names from settings (which are loaded from environment variables)
        self.scan_model_name = getattr(settings, 'GEMINI_MODEL_NAME', 'gemini-3.5-flash')
        self.recipe_model_name = getattr(settings, 'GEMINI_RECIPE_MODEL_NAME', 'gemini-3.5-flash')

        if self.enabled:
            genai.configure(api_key=self.api_key)
        else:
            logger.warning("GEMINI_API_KEY is missing. AI capabilities are disabled.")

    def analyze_grocery_images(self, image_paths: list, ocr_context: str = None) -> dict:
        if not self.enabled:
            logger.warning("Gemini Client is disabled. Returning empty results.")
            return {"items": []}

        try:
            # Load images
            images = []
            for path in image_paths:
                logger.info(f"Loading image for Gemini: {path}")
                images.append(Image.open(path))

            # Load model
            model = genai.GenerativeModel(
                model_name=self.scan_model_name,
                system_instruction=SYSTEM_INSTRUCTION
            )

            current_date_str = timezone.now().date().isoformat()
            prompt = GROCERY_SCAN_PROMPT.format(
                ocr_text=ocr_context or "No packaging text extracted.",
                current_date=current_date_str
            )

            logger.info(f"Calling Gemini ({self.scan_model_name}) for scan analysis...")
            # We pass the prompt, the structured schema configuration, and all images
            contents = [prompt] + images
            
            # Using generation config to enforce structured JSON output schema
            generation_config = {
                "response_mime_type": "application/json",
                "response_schema": GROCERY_SCAN_SCHEMA
            }

            response = model.generate_content(contents, generation_config=generation_config)
            text_response = response.text.strip()
            
            # Clean possible markdown block formatting
            if text_response.startswith('```'):
                lines = text_response.splitlines()
                if lines[0].startswith('```json'):
                    text_response = '\n'.join(lines[1:-1])
                elif lines[0].startswith('```'):
                    text_response = '\n'.join(lines[1:-1])

            data = json.loads(text_response.strip())
            logger.info(f"Gemini successfully scanned and returned {len(data.get('items', []))} items.")
            return data

        except Exception as e:
            logger.error(f"Gemini scan analysis failed: {e}", exc_info=True)
            raise e

    def generate_recipes(self, available_items: list, preferences: dict) -> dict:
        if not self.enabled:
            logger.warning("Gemini Client is disabled. Recipe generation skipped.")
            return {"recipes": []}

        try:
            model = genai.GenerativeModel(
                model_name=self.recipe_model_name,
                system_instruction=SYSTEM_INSTRUCTION
            )

            # Format items
            items_str = json.dumps(available_items, indent=2)

            prompt = RECIPE_GENERATION_PROMPT.format(
                available_items=items_str,
                diet_type=preferences.get('diet_type', 'any'),
                cuisine_pref=preferences.get('cuisine_pref', 'Indian'),
                allergens=json.dumps(preferences.get('allergies', [])),
                household_size=preferences.get('household_size', 1),
                max_prep_time_mins=preferences.get('max_prep_time_mins', 60),
                meal_type=preferences.get('meal_type', 'any')
            )

            logger.info(f"Calling Gemini ({self.recipe_model_name}) for recipe generation...")
            
            generation_config = {
                "response_mime_type": "application/json",
                "response_schema": RECIPE_GENERATION_SCHEMA
            }

            response = model.generate_content(prompt, generation_config=generation_config)
            text_response = response.text.strip()

            if text_response.startswith('```'):
                lines = text_response.splitlines()
                if lines[0].startswith('```json'):
                    text_response = '\n'.join(lines[1:-1])
                elif lines[0].startswith('```'):
                    text_response = '\n'.join(lines[1:-1])

            data = json.loads(text_response.strip())
            logger.info(f"Gemini successfully generated {len(data.get('recipes', []))} recipes.")
            return data

        except Exception as e:
            logger.error(f"Gemini recipe generation failed: {e}", exc_info=True)
            raise e
