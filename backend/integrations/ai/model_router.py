import os
import hashlib
import logging
from PIL import Image, ImageStat
from django.conf import settings
from django.utils import timezone
from integrations.ocr.google_vision_client import GoogleCloudVisionOCR
from integrations.ocr.text_parser import OCRDateParser
from .gemini_client import GeminiClient

logger = logging.getLogger('freshtrack.ai.model_router')

class ModelRouter:
    def __init__(self):
        self.ocr_client = GoogleCloudVisionOCR()
        self.ai_client = GeminiClient()

    def run_image_quality_checks(self, image_paths: list) -> tuple:
        """
        Validates images for corruption, resolution, duplicate hashes, and low lighting.
        Returns: (list_of_errors, list_of_warnings, list_of_unique_paths)
        """
        errors = []
        warnings = []
        seen_hashes = set()
        unique_paths = []

        max_size = getattr(settings, 'AI_MAX_IMAGE_SIZE_BYTES', 5 * 1024 * 1024) # 5MB

        for path in image_paths:
            if not os.path.exists(path):
                errors.append(f"Image file does not exist: {os.path.basename(path)}")
                continue

            # Size check
            size = os.path.getsize(path)
            if size > max_size:
                errors.append(f"Image {os.path.basename(path)} exceeds size limit.")
                continue

            # Duplicate hash check
            try:
                hasher = hashlib.md5()
                with open(path, 'rb') as f:
                    buf = f.read()
                    hasher.update(buf)
                img_hash = hasher.hexdigest()
                
                if img_hash in seen_hashes:
                    warnings.append(f"Duplicate image detected: {os.path.basename(path)}")
                    continue
                seen_hashes.add(img_hash)
            except Exception as e:
                errors.append(f"Failed to check duplicate hash for {os.path.basename(path)}: {e}")
                continue

            # Open image and check dimensions/quality
            try:
                with Image.open(path) as img:
                    width, height = img.size
                    
                    # Low resolution check
                    if width < 150 or height < 150:
                        errors.append(f"Image {os.path.basename(path)} resolution is too low ({width}x{height}).")
                        continue

                    # Dark lighting check
                    stat = ImageStat.Stat(img.convert('L'))
                    mean_brightness = stat.mean[0]
                    if mean_brightness < 35:
                        warnings.append(f"Lighting is too dark in {os.path.basename(path)}.")

                    # Contrast check (blurriness indicator)
                    std_dev = stat.stddev[0]
                    if std_dev < 10:
                        warnings.append(f"Image {os.path.basename(path)} might be too blurry or low contrast.")

                    unique_paths.append(path)

            except Exception as e:
                errors.append(f"Image {os.path.basename(path)} is corrupted or unreadable: {e}")

        return errors, warnings, unique_paths

    def process_scan(self, image_paths: list) -> dict:
        """
        Executes the two-stage pipeline:
        1. Validates image qualities.
        2. Performs Google Cloud Vision OCR if enabled.
        3. Invokes Gemini Client combining visual and OCR contexts.
        """
        # 1. Run quality validations
        errors, warnings, valid_paths = self.run_image_quality_checks(image_paths)
        if errors:
            logger.error(f"Image validation failed: {errors}")
            return {
                "success": False,
                "error": errors[0],
                "warnings": warnings,
                "items": []
            }

        if not valid_paths:
            return {
                "success": False,
                "error": "No valid images found for processing.",
                "warnings": warnings,
                "items": []
            }

        # 2. OCR Text Extraction Stage
        ocr_text = ""
        ocr_dates = {}
        ocr_enabled = getattr(settings, 'OCR_ENABLED', True)
        
        if ocr_enabled:
            ocr_results = []
            for path in valid_paths:
                res = self.ocr_client.extract_text(path)
                if res.get("success") and res.get("text"):
                    ocr_results.append(res["text"])
            
            if ocr_results:
                ocr_text = "\n---\n".join(ocr_results)
                # Parse expiry dates from OCR text directly
                ocr_dates = OCRDateParser.extract_dates(ocr_text)
                logger.info(f"OCR parsed packaging dates: {ocr_dates}")

        # 3. Gemini Multimodal Analysis Stage
        try:
            ai_result = self.ai_client.analyze_grocery_images(valid_paths, ocr_context=ocr_text)
            items = ai_result.get("items", [])
            
            # 4. Accuracy Alignment: Resolve date conflicts & append warnings
            for item in items:
                # Add validation warnings found during quality checks
                item["warnings"] = list(set(item.get("warnings", []) + warnings))

                # Date alignment logic
                if ocr_dates and ocr_dates.get("expiry_date"):
                    # Check if Gemini extracted a different date
                    gemini_exp = item.get("expiry_date")
                    ocr_exp = ocr_dates["expiry_date"].isoformat()
                    
                    if gemini_exp and gemini_exp != ocr_exp:
                        # Conflict! Mark as Low confidence and prompt user choice
                        item["date_confidence"] = "Low"
                        item["date_source"] = "ocr_verified"
                        item["raw_date_text"] = f"Conflict: Gemini found {gemini_exp} | OCR found {ocr_exp}"
                        item["warnings"].append("Conflicting packaging date values detected between OCR and AI.")
                    else:
                        # Align item dates with OCR parsed dates
                        item["expiry_date"] = ocr_exp
                        item["manufacturing_date"] = ocr_dates["manufacturing_date"].isoformat() if ocr_dates.get("manufacturing_date") else None
                        item["packed_date"] = ocr_dates["packed_date"].isoformat() if ocr_dates.get("packed_date") else None
                        item["best_before_date"] = ocr_dates["best_before_date"].isoformat() if ocr_dates.get("best_before_date") else None
                        item["date_type"] = ocr_dates.get("date_type", "unknown")
                        item["date_source"] = ocr_dates.get("date_source", "unknown")
                        item["date_confidence"] = ocr_dates.get("date_confidence", "Low")
                        item["raw_date_text"] = ocr_dates.get("raw_date_text", "")
                
                # Expiry bounds safety check
                if item.get("expiry_date"):
                    try:
                        exp = timezone.datetime.strptime(item["expiry_date"], "%Y-%m-%d").date()
                        if exp < timezone.now().date():
                            item["warnings"].append("Detected date has already expired.")
                    except ValueError:
                        pass

            return {
                "success": True,
                "items": items,
                "warnings": warnings
            }

        except Exception as e:
            logger.error(f"Failed to route analysis: {e}", exc_info=True)
            return {
                "success": False,
                "error": f"AI service failed: {e}",
                "warnings": warnings,
                "items": []
            }
