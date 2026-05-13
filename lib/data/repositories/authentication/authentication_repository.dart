import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fast_food/data/repositories/user/user_repository.dart';
import 'package:fast_food/features/authentication/screens/signup/widgets/verify_email.dart';
import 'package:fast_food/navigation_menu.dart';
import 'package:fast_food/utils/local_storage/storage_utility.dart';

import '../../../features/authentication/screens/login/login.dart';
import '../../../features/authentication/screens/onboarding/onboarding.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  final deviceStorage = GetStorage();
  final _auth = FirebaseAuth.instance;

  /// Get Authenticated user data
  User? get authUser => _auth.currentUser;

  // Call from main.dart on app
  @override
  void onReady() {
    super.onReady();
    FlutterNativeSplash.remove();
    screenRedirect();
  }

  Future<void> screenRedirect({bool bypassEmailVerification = false}) async {
    final user = _auth.currentUser;

    if (user != null) {
      final isSocialLogin = user.providerData.any(
        (provider) => provider.providerId == 'google.com',
      );

      if (user.emailVerified || isSocialLogin || bypassEmailVerification) {

        // Initialize local storage
        YLocalStorage.init(user.uid);
        // if email is verify
        Get.offAll(() => const NavigationMenu());
      } else {
        Get.offAll(() => VerifyEmailScreen(email: user.email ?? ''));
      }
    } else {
      deviceStorage.writeIfNull('IsFirstTime', true);

      final isFirstTime = deviceStorage.read('IsFirstTime') as bool?;

      (isFirstTime ?? false)
          ? Get.offAll(() => const OnBoardingScreen())
          : Get.offAll(() => const LoginScreen());
    }

    if (kDebugMode) {
      print('================ AUTH REDIRECT ================');
      print(deviceStorage.read('IsFirstTime'));
    }
  }

  /* -------------------------- Email & Password sign-in --------------------------*/

  /// [EmailAuthentication] - LOGIN
  Future<UserCredential> loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // Sign in user
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Login failed');
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? 'Firebase error occurred');
    } on PlatformException catch (e) {
      throw Exception(e.message ?? 'Platform error occurred');
    } catch (e) {
      throw Exception('Something went wrong. Please try again');
    }
  }

  /// [EmailAuthentication] - REGISTER
  Future<UserCredential> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Authentication failed');
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? 'Firebase error occurred');
    } on FormatException catch (e) {
      throw FormatException(e.message);
    } on PlatformException catch (e) {
      throw Exception(e.message ?? 'Platform error occurred');
    } catch (e) {
      throw Exception('Something went wrong. Please try again');
    }
  }

  /// [EmailVerification] - MAIL VERIFICATION
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        throw Exception('No authenticated user found');
      }

      // Always send verification email (even if already verified, allows resending)
      await user.sendEmailVerification();

      if (kDebugMode) {
        print('Email verification sent to: ${user.email}');
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Firebase Auth Error: ${e.code} - ${e.message}');
      }
      throw Exception(e.message ?? 'Failed to send verification email');
    } catch (e) {
      if (kDebugMode) {
        print('Error sending email verification: $e');
      }
      throw Exception('Failed to send verification email: ${e.toString()}');
    }
  }

  /// [EmailAuthentication] - FORGET PASSWORD
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to send reset email');
    } catch (e) {
      throw Exception('Something went wrong. Please try again');
    }
  }

  /// [EmailAuthentication] - RE-AUTHENTICATE USER
  Future<void> reAuthenticateWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      // Create credential
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      // Re-authenticate
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Re-authentication failed');
    } catch (e) {
      throw Exception('Something went wrong. Please try again');
    }
  }

  /* -------------------- Federated identity & social sign-in --------------------*/

  /// [GoogleAuthentication] - GOOGLE
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? userAccount = await GoogleSignIn().signIn();

      if (userAccount == null) {
        throw Exception('Google sign-in cancelled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await userAccount.authentication;

      // Create a new credential
      final credentials = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      return await _auth.signInWithCredential(credentials);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Google authentication failed');
    } on PlatformException catch (e) {
      throw Exception(e.message ?? 'Platform error occurred');
    } catch (e) {
      rethrow;
    }
  }

  /* ------------------ ./end Federated identity & social sign-in ----------------*/

  /// [LogoutUser] - Valid for any authentication.
  Future<void> logout() async {
    final localStorage = GetStorage();
    // Clear Remember Me data
    localStorage.remove('REMEMBER_ME_EMAIL');
    localStorage.remove('REMEMBER_ME_PASSWORD');
    // Clear any pending sign-up data stored locally
    localStorage.remove('pending_user');
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      Get.offAll(() => LoginScreen());
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to logout');
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? 'Firebase error occurred');
    } on PlatformException catch (e) {
      throw Exception(e.message ?? 'Platform error occurred');
    } catch (e) {
      throw Exception('Something went wrong while logging out');
    }
  }

  /// [DELETE USER] - Remove user Auth and Firestore Account.
  Future<void> deleteAccount() async {
    final localStorage = GetStorage();
    final currentUser = _auth.currentUser;

    // Clear Remember Me data
    localStorage.remove('REMEMBER_ME_EMAIL');
    localStorage.remove('REMEMBER_ME_PASSWORD');

    if (currentUser == null) {
      throw Exception('No authenticated user found');
    }

    try {
      await UserRepository.instance.removeUserRecord(currentUser.uid);
      await currentUser.delete();
    } on FirebaseAuthException catch (e) {
      /// Happens if recent login is required
      if (e.code == 'requires-recent-login') {
        throw Exception('Please re-authenticate before deleting your account.');
      }
      throw Exception(e.message ?? 'Failed to delete account');
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? 'Firebase error occurred');
    } on PlatformException catch (e) {
      throw Exception(e.message ?? 'Platform error occurred');
    } catch (e) {
      throw Exception('Something went wrong while deleting account');
    }
  }
}
