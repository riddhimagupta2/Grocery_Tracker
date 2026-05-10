import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import '../../config/app_routes.dart';
import '../../data/models/user_model.dart';
import '../../data/repo/auth_repo.dart';

class FirebaseAuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  late final UserRepository _userRepo;

  final Rx<User?> firebaseUser    = Rx<User?>(null);
  final Rx<UserModel?> appUser    = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    _userRepo = Get.find<UserRepository>();
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _handleAuthChange);
  }

  Future<void> _handleAuthChange(User? user) async {
    if (user != null) {
      appUser.value = await _userRepo.getUser(user.uid);
    } else {
      appUser.value = null;
    }
  }

  User?      get currentUser    => _auth.currentUser;
  UserModel? get currentAppUser => appUser.value;
  bool       get isLoggedIn     => currentUser != null;
  bool       get isEmailVerified => currentUser?.emailVerified ?? false;

  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  Future<UserCredential?> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await cred.user?.updateDisplayName(name.trim());
      await cred.user?.sendEmailVerification();
      final now = DateTime.now();
      await _userRepo.createUser(UserModel(
        uid: cred.user!.uid, name: name.trim(),
        email: email.trim(), photoUrl: cred.user?.photoURL,
        createdAt: now, updatedAt: now,
      ));
      return cred;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  Future<void> resendVerificationEmail() async {
    try { await currentUser?.sendEmailVerification(); }
    on FirebaseAuthException catch (e) { throw _mapFirebaseError(e); }
  }

  Future<bool> reloadAndCheckVerified() async {
    await currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    appUser.value = null;
    Get.offAllNamed(AppRoutes.login);
  }

  Future<void> deleteAccount() async {
    final uid = currentUser?.uid;
    if (uid != null) await _userRepo.deleteUser(uid);
    await currentUser?.delete();
    await _googleSignIn.signOut();
    Get.offAllNamed(AppRoutes.login);
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return e.message ?? 'Something went wrong. Please try again.';
    }
  }
}
