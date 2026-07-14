class ScanCandidateModel {
  final String id;
  final String scanSession;
  
  final String name;
  final String brand;
  final String description;
  final String iconKey;
  final String category;
  
  final double quantity;
  final String unit;
  final String storageZone;
  
  final DateTime? expiryDate;
  final String confidence;
  final List<String> validationWarnings;
  final bool selected;

  const ScanCandidateModel({
    required this.id,
    required this.scanSession,
    required this.name,
    required this.brand,
    required this.description,
    this.iconKey = 'grocery',
    required this.category,
    required this.quantity,
    required this.unit,
    required this.storageZone,
    this.expiryDate,
    required this.confidence,
    required this.validationWarnings,
    required this.selected,
  });

  factory ScanCandidateModel.fromJson(Map<String, dynamic> json) {
    return ScanCandidateModel(
      id: json['id'] ?? '',
      scanSession: json['scan_session'] ?? '',
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      description: json['description'] ?? '',
      iconKey: json['icon_key'] ?? 'grocery',
      category: json['category'] ?? 'Vegetables',
      quantity: double.tryParse(json['quantity']?.toString() ?? '1.0') ?? 1.0,
      unit: json['unit'] ?? 'pcs',
      storageZone: json['storage_zone'] ?? 'pantry',
      expiryDate: json['expiry_date'] != null ? DateTime.tryParse(json['expiry_date']) : null,
      confidence: json['confidence'] ?? 'High',
      validationWarnings: List<String>.from(json['validation_warnings'] ?? []),
      selected: json['selected'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'brand': brand,
    'description': description,
    'icon_key': iconKey,
    'category': category,
    'quantity': quantity,
    'unit': unit,
    'storage_zone': storageZone,
    'expiry_date': expiryDate?.toIso8601String().substring(0, 10),
    'confidence': confidence,
    'selected': selected,
  };

  ScanCandidateModel copyWith({
    String? name,
    String? brand,
    String? description,
    String? iconKey,
    String? category,
    double? quantity,
    String? unit,
    String? storageZone,
    DateTime? expiryDate,
    String? confidence,
    bool? selected,
  }) {
    return ScanCandidateModel(
      id: id,
      scanSession: scanSession,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      description: description ?? this.description,
      iconKey: iconKey ?? this.iconKey,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      storageZone: storageZone ?? this.storageZone,
      expiryDate: expiryDate ?? this.expiryDate,
      confidence: confidence ?? this.confidence,
      validationWarnings: validationWarnings,
      selected: selected ?? this.selected,
    );
  }
}
