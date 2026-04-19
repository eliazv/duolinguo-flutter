import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';

class FirebaseAuthentication {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn.instance;
  Future<void>? _googleInitFuture;

  Future<void> _ensureGoogleInitialized() {
    _googleInitFuture ??= googleSignIn.initialize();
    return _googleInitFuture!;
  }

  Future<String?> createUser(String email, String password) async {
    try {
      UserCredential credential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      return credential.user!.uid;
    } on FirebaseAuthException {
      return null;
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      UserCredential credential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      return credential.user!.uid;
    } on FirebaseAuthException {
      return null;
    }
  }

  Future<bool> logout() async {
    try {
      await _firebaseAuth.signOut();
      await _ensureGoogleInitialized();
      await googleSignIn.signOut();
      return true;
    } on FirebaseAuthException {
      return false;
    }
  }

  Future<String?> loginWithGoogle() async {
    await _ensureGoogleInitialized();
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.authenticate();
    if (googleSignInAccount == null) {
      return null;
    }
    final GoogleSignInAuthentication googleSignInAuthentication =
        googleSignInAccount.authentication;
    final AuthCredential authCredential = GoogleAuthProvider.credential(
      idToken: googleSignInAuthentication.idToken,
    );
    final UserCredential authResult =
        await _firebaseAuth.signInWithCredential(authCredential);
    final User? user = authResult.user;
    if (user != null) {
      return '$user';
    }
    return null;
  }
}
