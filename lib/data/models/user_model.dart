import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String dietType;
  final List<String> allergies;
  final String cuisine;
  final int householdSize;
  final bool notifyThreeDays;
  final bool notifyOneDay;
  final bool notifyDailyRecipe;
  final String? fcmToken;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.dietType = 'vegetarian',
    this.allergies = const [],
    this.cuisine = 'North Indian',
    this.householdSize = 1,
    this.notifyThreeDays = true,
    this.notifyOneDay = true,
    this.notifyDailyRecipe = false,
    this.fcmToken,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: d['name'] ?? '',
      email: d['email'] ?? '',
      photoUrl: d['photoUrl'],
      dietType: d['dietType'] ?? 'vegetarian',
      allergies: List<String>.from(d['allergies'] ?? []),
      cuisine: d['cuisine'] ?? 'North Indian',
      householdSize: d['householdSize'] ?? 1,
      notifyThreeDays: d['notifyThreeDays'] ?? true,
      notifyOneDay: d['notifyOneDay'] ?? true,
      notifyDailyRecipe: d['notifyDailyRecipe'] ?? false,
      fcmToken: d['fcmToken'],
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'photoUrl': photoUrl,
    'dietType': dietType,
    'allergies': allergies,
    'cuisine': cuisine,
    'householdSize': householdSize,
    'notifyThreeDays': notifyThreeDays,
    'notifyOneDay': notifyOneDay,
    'notifyDailyRecipe': notifyDailyRecipe,
    'fcmToken': fcmToken,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  UserModel copyWith({
    String? name,
    String? email,
    String? photoUrl,
    String? dietType,
    List<String>? allergies,
    String? cuisine,
    int? householdSize,
    bool? notifyThreeDays,
    bool? notifyOneDay,
    bool? notifyDailyRecipe,
    String? fcmToken,
  }) => UserModel(
    uid: uid,
    name: name ?? this.name,
    email: email ?? this.email,
    photoUrl: photoUrl ?? this.photoUrl,
    dietType: dietType ?? this.dietType,
    allergies: allergies ?? this.allergies,
    cuisine: cuisine ?? this.cuisine,
    householdSize: householdSize ?? this.householdSize,
    notifyThreeDays: notifyThreeDays ?? this.notifyThreeDays,
    notifyOneDay: notifyOneDay ?? this.notifyOneDay,
    notifyDailyRecipe: notifyDailyRecipe ?? this.notifyDailyRecipe,
    fcmToken: fcmToken ?? this.fcmToken,
    createdAt: createdAt,
    updatedAt: DateTime.now(),
  );
}
