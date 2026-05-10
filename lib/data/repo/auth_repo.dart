import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';

class UserRepository extends GetxService {
  final _db = FirebaseFirestore.instance;
  static const _col = 'users';

  Future<void> createUser(UserModel user) async {
    await _db.collection(_col).doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection(_col).doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<void> updateUser(String uid, Map<String, dynamic> fields) async {
    await _db.collection(_col).doc(uid).update({
      ...fields,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> saveFcmToken(String uid, String token) async {
    await _db.collection(_col).doc(uid).update({'fcmToken': token});
  }

  Stream<UserModel?> userStream(String uid) {
    return _db
        .collection(_col)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  Future<void> deleteUser(String uid) async {
    await _db.collection(_col).doc(uid).delete();
  }
}
