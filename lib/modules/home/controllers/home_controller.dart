import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final currentIndex = 0.obs;
  final user = FirebaseAuth.instance.currentUser;

  String get displayName => user?.displayName?.split(' ').first ?? 'Friend';
  String get avatarLetter => (user?.displayName?.isNotEmpty == true
      ? user!.displayName![0].toUpperCase()
      : user?.email?[0].toUpperCase() ?? 'F');

  void changeTab(int i) => currentIndex.value = i;
}