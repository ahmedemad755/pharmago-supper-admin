// ignore_for_file: public_member_api_docs

import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:supper_admin/core/errors/exceptions.dart';
// استخدام hide لمنع التعارض مع كائن User الخاص بـ Firebase

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String? _verificationId;

  // جلب المستخدم الحالي كـ Getter لتسهيل استخدامه في الدوال
  User? get currentUser => _firebaseAuth.currentUser;

  Future<void> deleteUser() async {
    try {
      await currentUser?.delete();
    } catch (e) {
      developer.log("[deleteUser] Error: $e");
      throw CustomException(message: 'حدث خطأ أثناء محاولة حذف الحساب.');
    }
  }

  Future<User> creatuserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user!;
    } on FirebaseAuthException catch (e) {
      developer.log("[createUser] FirebaseAuthException: ${e.code}");
      // تخصيص رسالة الخطأ بناءً على الكود
      String errorMessage = e.message ?? 'فشل إنشاء الحساب.';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'هذا البريد الإلكتروني مستخدم بالفعل.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'كلمة المرور ضعيفة جداً.';
      }
      throw CustomException(message: errorMessage);
    } catch (e) {
      developer.log("[createUser] Unknown error: $e");
      throw CustomException(message: 'فشل إنشاء الحساب. حاول مرة أخرى لاحقًا.');
    }
  }

  Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user!;
    } on FirebaseAuthException catch (e) {
      developer.log("[signIn] FirebaseAuthException: ${e.code}");
      String errorMessage = 'فشل تسجيل الدخول.';
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        errorMessage = 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
      }
      throw CustomException(message: errorMessage);
    } catch (e) {
      developer.log("[signIn] Unknown error: $e");
      throw CustomException(message: 'فشل تسجيل الدخول. حاول مرة أخرى لاحقًا.');
    }
  }

  Future<void> sendemailverificationlink() async {
    final user = currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      developer.log("Verification email sent to ${user.email}");
    } else {
      throw CustomException(
        message: 'المستخدم غير مسجل أو تم التحقق من البريد بالفعل.',
      );
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      developer.log("Password reset email sent to $email");
    } on FirebaseAuthException catch (e) {
      developer.log(
        "[sendPasswordResetEmail] FirebaseAuthException: ${e.code}",
      );
      throw CustomException(
        message: 'فشل إرسال رابط إعادة التعيين، تأكد من البريد الإلكتروني.',
      );
    } catch (e) {
      throw CustomException(message: 'فشل إرسال رابط إعادة تعيين كلمة المرور.');
    }
  }

  bool isLoggedIn() {
    return currentUser != null;
  }

  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      developer.log("[logout] FirebaseAuthException: ${e.code}");
      throw CustomException(message: 'فشل تسجيل الخروج من الخدمة.');
    } catch (e) {
      developer.log("[logout] Unknown error: $e");
      rethrow;
    }
  }

  Future<void> deleteUserWithReauthentication({String? storedPassword}) async {
    final user = currentUser;
    if (user == null) throw FirebaseAuthException(code: 'no-current-user');

    final providerId = user.providerData.first.providerId;
    AuthCredential? authCredential;

    if (providerId == 'google.com') {
      throw CustomException(
        message: 'يرجى تسجيل الدخول مرة أخرى لحذف حساب جوجل.',
      );
    } else if (providerId == 'password') {
      if (storedPassword == null || user.email == null) {
        throw FirebaseAuthException(code: 'missing-credentials');
      }
      authCredential = EmailAuthProvider.credential(
        email: user.email!,
        password: storedPassword,
      );
    }

    if (authCredential != null) {
      await user.reauthenticateWithCredential(authCredential);
    }
    await user.delete();
  }

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(FirebaseAuthException error) onVerificationFailed,
    required void Function(PhoneAuthCredential credential)
    onVerificationCompleted,
    required void Function(String verificationId) onAutoRetrievalTimeout,
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onVerificationFailed,
      codeSent: (id, _) {
        _verificationId = id;
        onCodeSent(id);
      },
      codeAutoRetrievalTimeout: (id) {
        _verificationId = id;
        onAutoRetrievalTimeout(id);
      },
    );
  }

  Future<UserCredential> verifySmsCode(String smsCode) async {
    if (_verificationId == null) {
      throw FirebaseAuthException(
        code: 'no-verification-id',
        message: 'انتهت صلاحية كود التحقق أو لم يتم العثور عليه.',
      );
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );

    return await _firebaseAuth.signInWithCredential(credential);
  }
}
