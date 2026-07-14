from datetime import timedelta, date
import logging

logger = logging.getLogger('freshtrack.prediction')

class ShelfLifePredictionEngine:
    """
    ML-ready regression engine for estimating grocery item shelf life.
    This logic can be replaced with ONNX runtime, XGBoost, or LightGBM model inferences.
    """

    # Base shelf life in days per category under optimal storage conditions (fridge/cool pantry)
    BASE_SHELF_LIFE = {
        'fruits': 10,
        'vegetables': 7,
        'dairy': 14,
        'meat': 5,
        'fish': 3,
        'beverages': 30,
        'grains': 180,
        'spices': 365,
        'bakery': 4,
        'default': 14
    }

    @classmethod
    def predict(cls, data):
        """
        Estimate shelf life.
        Inputs in data dict:
            - category: str
            - storage_zone: str
            - temperature: float (Celsius)
            - humidity: float (Percentage)
            - ripeness: str ('unripe', 'ripe', 'overripe', 'not_applicable')
            - is_opened: bool
            - purchase_date: date
            - freshness_score: int (0 to 100)
        """
        category = (data.get('category') or 'default').lower()
        storage_zone = (data.get('storage_zone') or 'pantry').lower()
        temperature = float(data.get('temperature', 20.0))
        humidity = float(data.get('humidity', 50.0))
        ripeness = (data.get('ripeness') or 'not_applicable').lower()
        is_opened = bool(data.get('is_opened', False))
        purchase_date = data.get('purchase_date') or date.today()
        freshness_score = int(data.get('freshness_score', 100))

        # 1. Resolve base shelf life
        base_days = cls.BASE_SHELF_LIFE.get(category, cls.BASE_SHELF_LIFE['default'])
        
        # Scale base days by current freshness score (deterioration factor)
        freshness_factor = max(0.1, freshness_score / 100.0)
        estimated_days = base_days * freshness_factor

        # 2. Temperature coefficients (Arrhenius-like effect)
        # Optimal temperature ranges per storage zone
        optimal_temps = {
            'fridge': (2.0, 5.0),
            'freezer': (-22.0, -18.0),
            'pantry': (15.0, 20.0),
            'counter': (18.0, 22.0),
            'cabinet': (15.0, 20.0),
            'basket': (12.0, 18.0),
            'spice': (15.0, 20.0)
        }

        optimal_min, optimal_max = optimal_temps.get(storage_zone, (15.0, 22.0))
        
        # If actual temperature is higher than optimal, accelerate spoilage
        if temperature > optimal_max:
            temp_diff = temperature - optimal_max
            # Spoilage rates double roughly every 10C increase (Q10 rule of thumb)
            temp_penalty = 1.0 - min(0.8, temp_diff * 0.05)
            estimated_days *= temp_penalty
        elif temperature < optimal_min and storage_zone not in ['fridge', 'freezer']:
            # Non-optimal cold (e.g. freezing tomatoes or bananas) damages quality
            estimated_days *= 0.8

        # 3. Humidity coefficients
        # Most fresh produce prefers ~80-90% humidity (in baskets/drawers), pantry items prefer low humidity
        if category in ['vegetables', 'fruits']:
            if humidity < 60.0:
                # Dry air wilts fresh produce
                estimated_days *= 0.75
        elif category in ['grains', 'spices', 'bakery']:
            if humidity > 65.0:
                # Moisture promotes mold
                estimated_days *= 0.6

        # 4. Packaging State (Opened vs. Unopened)
        if is_opened:
            # Exposure to oxygen drastically reduces shelf life (typically by 50-70%)
            estimated_days *= 0.4

        # 5. Ripeness state
        if ripeness == 'unripe':
            # Adds remaining ripening time
            estimated_days *= 1.3
        elif ripeness == 'overripe':
            # Needs immediate consumption
            estimated_days *= 0.25

        # 6. Apply realistic minimum limit
        estimated_remaining_days = round(max(0.5, estimated_days), 1)

        # 7. Formulate dates
        predicted_expiry_date = purchase_date + timedelta(days=math_ceil(estimated_remaining_days))
        recommended_consumption_date = purchase_date + timedelta(days=math_ceil(estimated_remaining_days * 0.8))

        # 8. Compute prediction confidence category
        if is_opened or temperature > 35.0:
            confidence = 'Low' # high variance
        elif estimated_remaining_days > 30.0:
            confidence = 'Medium'
        else:
            confidence = 'High'

        # 9. Storage Recommendations and AI Explanation Texts
        why, how, shelf_life_note, explanation = cls.generate_storage_details(
            category, storage_zone, temperature, humidity, is_opened, ripeness, estimated_remaining_days
        )

        return {
            'estimated_remaining_days': estimated_remaining_days,
            'confidence': confidence,
            'predicted_expiry': predicted_expiry_date,
            'recommended_consumption_date': recommended_consumption_date,
            'storage_recommendation_why': why,
            'storage_recommendation_how': how,
            'storage_recommendation_shelf_life': shelf_life_note,
            'ai_explanation': explanation
        }

    @classmethod
    def generate_storage_details(cls, category, zone, temp, humidity, opened, ripeness, remaining_days):
        # Default templates
        why = "Standard temperature controls help sustain enzyme structures."
        how = "Store in clean, dry containers."
        shelf_life_note = f"Expected shelf life is roughly {math_ceil(remaining_days)} days."
        explanation = f"Estimated shelf life is based on typical degradation rates for {category} stored in the {zone}."

        if category == 'dairy':
            why = "Low temperatures slow down bacterial fermentation of lactic acid."
            how = "Keep in original packaging in the middle or lower refrigerator shelves. Avoid storing in the door."
            shelf_life_note = f"Will last approximately {math_ceil(remaining_days)} days in refrigerator; do not freeze unless opened."
            explanation = "Dairy is highly sensitive to temperature fluctuations. Keeping it below 4°C maintains stability."
        elif category in ['vegetables', 'fruits']:
            if zone == 'fridge':
                why = "Chilling delays the respiration rate and moisture loss of fresh cells."
                how = "Store in the crisper drawer with high humidity. Wrap leafy greens in paper towels."
            else:
                why = "Ambient temperature allows natural starches to convert to sugars at a normal rate."
                how = "Place in a breathable basket away from direct sunlight. Do not store potatoes and onions together."
            
            if ripeness == 'overripe':
                explanation = "This item is overripe and respiring rapidly. Consume immediately or freeze to prevent wastage."
            else:
                explanation = f"Respiration rate is normal. Optimal storage extends viability to {math_ceil(remaining_days)} days."
        elif category == 'meat' or category == 'fish':
            why = "Extremely fast oxidation and enzymatic decay occurs at ambient temperatures."
            how = "Keep on the lowest shelf of the refrigerator in a leak-proof container, or freeze instantly."
            explanation = "High moisture and protein content promote rapid micro-organism growth. Low temperature is critical."

        if opened:
            explanation += " Exposure to oxygen has accelerated oxidation. Shelf life is significantly reduced."

        return why, how, shelf_life_note, explanation

def math_ceil(val):
    import math
    return int(math.ceil(val))
