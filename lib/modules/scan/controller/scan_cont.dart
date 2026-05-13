import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';


final _kGeminiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
const _kGeminiUrl =
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';


class ScanController extends GetxController {
  final _db = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  final _picker = ImagePicker();

  late TextEditingController nameCtrl;
  late TextEditingController brandCtrl;
  late TextEditingController quantityCtrl;
  late TextEditingController unitCtrl;

  
  final isSaving = false.obs;
  final errorMsg = ''.obs;
  final selectedZone = 'pantry'.obs;
  final selectedEmoji = '📦'.obs;
  final expiryDate = Rx<DateTime?>(null);
  final purchaseDate = Rx<DateTime?>(DateTime.now());
  final barcodeResult = ''.obs;
  final isCameraMode = true.obs;

  
  final isAiScanning = false.obs;
  final aiResult = Rx<Map<String, String>?>(null);
  final capturedImagePath = ''.obs;

  
  static const zones = [
    {'key': 'fridge', 'label': 'Refrigerator', 'emoji': '❄️'},
    {'key': 'pantry', 'label': 'Pantry', 'emoji': '🗄️'},
    {'key': 'counter', 'label': 'Countertop', 'emoji': '🍽️'},
    {'key': 'cabinet', 'label': 'Cabinet', 'emoji': '🚪'},
    {'key': 'basket', 'label': 'Root Basket', 'emoji': '🧺'},
    {'key': 'freezer', 'label': 'Freezer', 'emoji': '🧊'},
  ];

  static const emojiOptions = [
    '📦', '🍎', '🥦', '🥛', '🧀', '🍌', '🧅', '🥕', '🍚', '🫘',
    '🥜', '🍳', '🧈', '🥚', '🍅', '🫑', '🧄', '🌶️', '🍋', '🥝',
    '🫙', '🍯', '🧂', '🌾', '🍝', '🥫', '🍞', '🧃', '🥤', '🍪',
  ];

  
  static const _categoryEmojiMap = {
    'apple': '🍎', 'banana': '🍌', 'milk': '🥛', 'cheese': '🧀',
    'egg': '🥚', 'butter': '🧈', 'carrot': '🥕', 'onion': '🧅',
    'garlic': '🧄', 'tomato': '🍅', 'bread': '🍞', 'rice': '🍚',
    'flour': '🌾', 'oil': '🫙', 'honey': '🍯', 'salt': '🧂',
    'pasta': '🍝', 'beans': '🫘', 'juice': '🧃', 'water': '🥤',
    'yogurt': '🥛', 'chicken': '🍳', 'fish': '🐟', 'lemon': '🍋',
    'kiwi': '🥝', 'pepper': '🌶️', 'chilli': '🌶️', 'corn': '🌽',
    'peas': '🫛', 'potato': '🥔', 'spinach': '🥬', 'broccoli': '🥦',
    'peanut': '🥜', 'nut': '🥜', 'biscuit': '🍪', 'cookie': '🍪',
    'sauce': '🥫', 'can': '🥫', 'tin': '🥫', 'drink': '🥤',
    'tea': '🍵', 'coffee': '☕', 'sugar': '🍬', 'dal': '🫘',
    'paneer': '🧀', 'ghee': '🧈', 'masala': '🌶️', 'atta': '🌾',
  };

  @override
  void onInit() {
    super.onInit();
    nameCtrl = TextEditingController();
    brandCtrl = TextEditingController();
    quantityCtrl = TextEditingController(text: '1');
    unitCtrl = TextEditingController(text: 'pcs');
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    brandCtrl.dispose();
    quantityCtrl.dispose();
    unitCtrl.dispose();
    super.onClose();
  }

  
  void switchToManual() => isCameraMode.value = false;
  void switchToCamera() => isCameraMode.value = true;

  void clearAiResult() {
    aiResult.value = null;
    capturedImagePath.value = '';
  }

  
  void onBarcodeDetected(String code) {
    barcodeResult.value = code;
    isCameraMode.value = false;
    nameCtrl.text = 'Item ($code)';
    Get.snackbar(
      '📷 Scanned',
      'Barcode: $code — fill in the details below.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  

  
  Future<void> captureAndAnalyse() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1280,
    );
    if (file == null) return;
    await _analyseImage(File(file.path));
  }

  
  Future<void> pickFromGallery() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1280,
    );
    if (file == null) return;
    await _analyseImage(File(file.path));
  }

  
  Future<void> _analyseImage(File imageFile) async {
    isAiScanning.value = true;
    errorMsg.value = '';

    try {
      capturedImagePath.value = imageFile.path;

      
      final bytes = await imageFile.readAsBytes();
      final b64 = base64Encode(bytes);
      final ext = imageFile.path.split('.').last.toLowerCase();
      final mimeType = ext == 'png' ? 'image/png' : 'image/jpeg';

      
      const prompt = '''
You are a grocery item recognition AI. Analyse this image of a grocery item or its packaging.
 
Return ONLY a valid JSON object with these exact keys (no markdown, no explanation):
{
  "name": "product name in English (short, 2-4 words)",
  "brand": "brand name or empty string if not visible",
  "emoji": "single most relevant food emoji",
  "category": "food category (e.g. Dairy, Fruits, Vegetables, Grains, Snacks, Beverages)",
  "expiryDate": "expiry date in DD MMM YYYY format if visible on packaging, else empty string",
  "storageZone": "one of: fridge, pantry, counter, freezer, basket, cabinet",
  "quantity": "numeric quantity shown on pack (just the number) or 1",
  "unit": "unit like kg, g, L, ml, pcs — or pcs if unclear",
  "confidence": "High, Medium, or Low"
}
 
Rules:
- If expiry date is printed on packaging, extract it accurately.
- If no expiry date is visible, return empty string for expiryDate.
- storageZone: fridge for dairy/meat/fresh produce, freezer for frozen, pantry for dry goods, counter for fruits/bread.
- Return ONLY the JSON object. No prose, no backticks, no markdown.
''';

      
      final response = await http.post(
        Uri.parse('$_kGeminiUrl?key=$_kGeminiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'inline_data': {
                    'mime_type': mimeType,
                    'data': b64,
                  },
                },
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.1,
            'maxOutputTokens': 512,
          },
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Gemini API error ${response.statusCode}: ${response.body}');
      }

      
      final decoded = jsonDecode(response.body);
      final rawText = (decoded['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?) ?? '';
      final cleaned = rawText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final Map<String, dynamic> parsed = jsonDecode(cleaned);

      final result = <String, String>{
        'name': (parsed['name'] as String? ?? '').trim(),
        'brand': (parsed['brand'] as String? ?? '').trim(),
        'emoji': (parsed['emoji'] as String? ?? '📦').trim(),
        'category': (parsed['category'] as String? ?? '').trim(),
        'expiryDate': (parsed['expiryDate'] as String? ?? '').trim(),
        'storageZone': (parsed['storageZone'] as String? ?? 'pantry').trim(),
        'quantity': (parsed['quantity']?.toString() ?? '1').trim(),
        'unit': (parsed['unit'] as String? ?? 'pcs').trim(),
        'confidence': (parsed['confidence'] as String? ?? 'Medium').trim(),
      };

      aiResult.value = result;

      
      isCameraMode.value = false;
      await Future.delayed(const Duration(milliseconds: 300));
      _showAiResultSheet();
    } catch (e) {
      errorMsg.value = 'AI scan failed: ${e.toString().split(':').first}. Try again or enter manually.';
      Get.snackbar(
        '⚠️ Scan failed',
        'Could not analyse image. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF2A1A1A),
        colorText: const Color(0xFFFF8080),
        duration: const Duration(seconds: 4),
      );
      isCameraMode.value = false;
    } finally {
      isAiScanning.value = false;
    }
  }

  
  final aiSheetPending = false.obs;

  void _showAiResultSheet() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      aiSheetPending.value = true;
    });
  }

  void aiSheetShown() => aiSheetPending.value = false;

  
  void applyAiResult() {
    final r = aiResult.value;
    if (r == null) return;

    
    if (r['name']?.isNotEmpty == true) nameCtrl.text = r['name']!;

    
    if (r['brand']?.isNotEmpty == true) brandCtrl.text = r['brand']!;

    
    if (r['quantity']?.isNotEmpty == true) quantityCtrl.text = r['quantity']!;
    if (r['unit']?.isNotEmpty == true) unitCtrl.text = r['unit']!;

    
    String emoji = r['emoji'] ?? '📦';
    if (emoji.isEmpty || emoji == '📦') {
      final nameLower = (r['name'] ?? '').toLowerCase();
      for (final entry in _categoryEmojiMap.entries) {
        if (nameLower.contains(entry.key)) {
          emoji = entry.value;
          break;
        }
      }
    }
    selectedEmoji.value = emoji.isNotEmpty ? emoji : '📦';

    
    final zone = r['storageZone'] ?? 'pantry';
    final validZones = zones.map((z) => z['key']!).toSet();
    selectedZone.value = validZones.contains(zone) ? zone : 'pantry';

    
    final expStr = r['expiryDate'] ?? '';
    if (expStr.isNotEmpty) {
      final parsed = _parseExpiryString(expStr);
      if (parsed != null) expiryDate.value = parsed;
    }

    
    Get.snackbar(
      '✅ AI filled details',
      'Review and save to kitchen.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  
  DateTime? _parseExpiryString(String s) {
    final formats = [
      'dd MMM yyyy',
      'dd/MM/yyyy',
      'MM/yyyy',
      'dd-MM-yyyy',
      'yyyy-MM-dd',
      'MMM yyyy',
      'd MMM yyyy',
      'dd.MM.yyyy',
    ];
    for (final fmt in formats) {
      try {
        return DateFormat(fmt).parse(s);
      } catch (_) {}
    }
    
    final yearMatch = RegExp(r'(\d{4})').firstMatch(s);
    final monthMatch = RegExp(r'\b(\d{1,2})\b').firstMatch(s);
    if (yearMatch != null) {
      final year = int.tryParse(yearMatch.group(1)!);
      final month = monthMatch != null ? int.tryParse(monthMatch.group(1)!) : 12;
      if (year != null && year > 2020) {
        return DateTime(year, (month ?? 12).clamp(1, 12));
      }
    }
    return null;
  }

  
  Future<void> pickExpiryDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: expiryDate.value ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF1DB868),
            surface: Color(0xFF162019),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) expiryDate.value = picked;
  }

  
  Future<void> saveItem(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;
    if (_uid.isEmpty) {
      errorMsg.value = 'Not logged in.';
      return;
    }
    isSaving.value = true;
    errorMsg.value = '';
    try {
      final days = expiryDate.value?.difference(DateTime.now()).inDays;
      String status = 'fresh';
      if (days != null) {
        if (days < 0) status = 'expired';
        else if (days <= 3) status = 'expiring';
      }

      await _db
          .collection('users')
          .doc(_uid)
          .collection('grocery_items')
          .add({
        'name': nameCtrl.text.trim(),
        'brand': brandCtrl.text.trim(),
        'emoji': selectedEmoji.value,
        'quantity': double.tryParse(quantityCtrl.text) ?? 1,
        'unit': unitCtrl.text.trim(),
        'storage_zone': selectedZone.value,
        'expiry_date': expiryDate.value != null
            ? Timestamp.fromDate(expiryDate.value!)
            : null,
        'purchase_date': purchaseDate.value != null
            ? Timestamp.fromDate(purchaseDate.value!)
            : null,
        'status': status,
        'barcode': barcodeResult.value,
        'ai_detected': aiResult.value != null,
        'ai_confidence': aiResult.value?['confidence'] ?? '',
        'created_at': FieldValue.serverTimestamp(),
        'notified_3d': false,
        'notified_1d': false,
      });

      final savedName = nameCtrl.text.trim();
      _resetForm();
      Get.back();
      Get.snackbar(
        '✅ Saved!',
        '$savedName added to your kitchen.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMsg.value = 'Failed to save. Please try again.';
    } finally {
      isSaving.value = false;
    }
  }

  
  void _resetForm() {
    nameCtrl.clear();
    brandCtrl.clear();
    quantityCtrl.text = '1';
    unitCtrl.text = 'pcs';
    selectedZone.value = 'pantry';
    selectedEmoji.value = '📦';
    expiryDate.value = null;
    purchaseDate.value = DateTime.now();
    barcodeResult.value = '';
    errorMsg.value = '';
    aiResult.value = null;
    capturedImagePath.value = '';
    isCameraMode.value = true;
  }

  String? vRequired(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  String formatDate(DateTime? d) {
    if (d == null) return 'Tap to select';
    return DateFormat('dd MMM yyyy').format(d);
  }

  String get zoneLabelSelected => zones
      .firstWhere(
        (z) => z['key'] == selectedZone.value,
    orElse: () => {'label': 'Pantry'},
  )['label']!;

  String get zoneEmojiSelected => zones
      .firstWhere(
        (z) => z['key'] == selectedZone.value,
    orElse: () => {'emoji': '🗄️'},
  )['emoji']!;
}