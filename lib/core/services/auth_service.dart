import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:tutor_finder_app/features/auth/data/models/user_model.dart';
import 'package:tutor_finder_app/features/auth/data/models/user_role.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign Up
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String username,
    required String firstName,
    required String lastName,
    required String mobilePhone,
    required UserRole role,
  }) async {
    try {
      // 0. Check Uniqueness
      final usernameCheck = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get()
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw 'Connection timed out. Please check your internet.';
      });

      if (usernameCheck.docs.isNotEmpty) {
        throw 'Username already taken';
      }

      final phoneCheck = await _firestore
          .collection('users')
          .where('mobilePhone', isEqualTo: mobilePhone)
          .get()
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw 'Connection timed out. Please check your internet.';
      });

      if (phoneCheck.docs.isNotEmpty) {
        throw 'Phone number already in use';
      }

      // 1. Create User in Firebase Auth
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;
      if (user == null) return null;

      // Update Display Name in Firebase Auth
      await user.updateDisplayName('$firstName $lastName');

      // 2. Create UserModel
      final now = DateTime.now();
      final userModel = UserModel(
        uid: user.uid,
        email: email,
        username: username,
        firstName: firstName,
        lastName: lastName,
        mobilePhone: mobilePhone,
        role: role,
        createdAt: now,
        updatedAt: now,
        isEmailVerified: false,
        isMobilePhoneVerified: false,
      );

      // 3. Save to Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toMap());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An unknown error occurred';
    } catch (e) {
      throw e.toString();
    }
  }

  // Sign In
  Future<UserModel?> signIn({
    required String identifier,
    required String password,
    required bool isPhone,
  }) async {
    try {
      String email = identifier;

      // 1. Lookup Email if not providing email directly
      if (isPhone) {
        final query = await _firestore
            .collection('users')
            .where('mobilePhone', isEqualTo: identifier)
            .get()
            .timeout(const Duration(seconds: 10));
        
        if (query.docs.isEmpty) throw 'User not found';
        email = query.docs.first.data()['email'];
      } else {
        // Check if it looks like an email
        if (!identifier.contains('@')) {
          // Treat as username
          final query = await _firestore
              .collection('users')
              .where('username', isEqualTo: identifier.toLowerCase()) // assuming usernames are stored lowercase
              .get()
              .timeout(const Duration(seconds: 10));
          
          if (query.docs.isEmpty) throw 'User not found';
          email = query.docs.first.data()['email'];
        }
      }

      // 2. Authenticate
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) return null;

      // 3. Fetch User Data
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;

      final userData = doc.data()!;
      UserModel userModel = UserModel.fromMap(userData);

      // 4. Auto-Reactivate if needed
      if (!userModel.isActive) {
        await _firestore.collection('users').doc(user.uid).update({'isActive': true});
        userModel = userModel.copyWith(isActive: true);
      }

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Authentication failed';
    } catch (e) {
      throw e.toString();
    }
  }



  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Update User Profile
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update(user.toMap());
      notifyListeners();
    } catch (e) {
      print('Error updating user: $e');
      throw e;
    }
  }

  // Email Verification
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) throw 'No user logged in';
    if (user.emailVerified) throw 'Email is already verified';

    try {
      await user.sendEmailVerification();
    } catch (e) {
      throw e.toString();
    }
  }

  // Phone Verification: Start
  Future<void> startPhoneVerification({
    required String phoneNumber,
    required Function(String, int?) onCodeSent,
    required Function(FirebaseAuthException) onVerificationFailed,
    required Function(String) onAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-retrieval or instant verification (Android)
        await _verifyCredential(credential);
      },
      verificationFailed: onVerificationFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: onAutoRetrievalTimeout,
    );
  }

  // Phone Verification: Verify OTP
  Future<void> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    await _verifyCredential(credential);
  }

  // Internal helper to complete verification
  Future<void> _verifyCredential(AuthCredential credential) async {
    final user = _auth.currentUser;
    if (user == null) throw 'No user logged in';

    try {
      // Use updatePhoneNumber instead of linkWithCredential
      // This is more appropriate for "Setting/Verifying" the phone number.
      await user.updatePhoneNumber(credential as PhoneAuthCredential);
      
      // Update Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'isMobilePhoneVerified': true,
        'mobilePhone': user.phoneNumber, // Ensure Firestore matches Auth
      });
      // Update local User model if we were caching it, forcing a reload of the UI
      await user.reload();
      
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use' || e.code == 'phone-number-already-exists') {
         throw 'This phone number is already associated with another account.';
      }
      if (e.code == 'invalid-verification-code') {
        throw 'The SMS code entered is invalid.';
      }
      // Catch the confusing email error and provide a better message
      if (e.code == 'account-exists-with-different-credential') {
        throw 'This phone number is already linked to an existing account. Please use a different number.';
      }
      throw e.message ?? 'Verification failed';
    } catch (e) {
      throw e.toString();
    }
  }

  // Reload user to update verification status
  Future<void> reloadUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
    }
  }
  // Fetch all tutors
  Future<List<UserModel>> getAllTutors() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'tutor')
          .where('isActive', isEqualTo: true)
          .where('isEmailVerified', isEqualTo: true)
          .where('isMobilePhoneVerified', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching tutors: $e');
      return [];
    }
  }


  // Deactivate Account
  Future<void> deactivateAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw 'No user logged in';

    try {
      await _firestore.collection('users').doc(user.uid).update({'isActive': false});
    } catch (e) {
      throw e.toString();
    }
  }

  // Delete Account
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw 'No user logged in';

    try {
      // 1. Delete from Firestore
      await _firestore.collection('users').doc(user.uid).delete();
      
      // 2. Delete from Auth (Requires recent login, might throw error if stale)
      await user.delete();
    } on FirebaseAuthException catch (e) {
       if (e.code == 'requires-recent-login') {
         throw 'Please log out and log in again to delete your account.';
       }
       throw e.message ?? 'Failed to delete account';
    } catch (e) {
      throw e.toString();
    }
  }
  // Fetch current user data
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      // 1. Force reload to get latest emailVerified status from Firebase Auth
      await user.reload();
      final refreshedUser = _auth.currentUser; // Get the refreshed user object

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;

      UserModel userModel = UserModel.fromMap(doc.data()!);

      // 2. Sync Email Verification Status if needed
      if (refreshedUser != null && refreshedUser.emailVerified && !userModel.isEmailVerified) {
        await _firestore.collection('users').doc(user.uid).update({
          'isEmailVerified': true,
        });
        // Return updated model locally without re-fetching
        userModel = userModel.copyWith(isEmailVerified: true);
      }

      return userModel;
    } catch (e) {
      print('Error fetching current user: $e');
      return null;
    }
  }

  // Get User Stream by ID
  Stream<UserModel?> getUserStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!);
    });
  }

  // Get User by ID
  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!);
    } catch (e) {
      print('Error fetching user $uid: $e');
      return null;
    }
  }
}
