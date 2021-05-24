import 'package:firebase_auth/firebase_auth.dart';
import 'package:sosapp/models/kullanici.dart';

class AuthorizationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String activeUserId;
  Kullanici _kullaniciOlustur(FirebaseUser kullanici) {
    return kullanici == null ? null : Kullanici.firebasedenUret(kullanici);
  }

  Stream<Kullanici> get durumTakipcisi {
    return _firebaseAuth.onAuthStateChanged.map(_kullaniciOlustur);
  }

  Future<Kullanici> regWithMail(String email, String password) async {
    var enterKey = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _kullaniciOlustur(enterKey.user);
  }

  Future<Kullanici> logInWithMail(String email, String password) async {
    var enterKey = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _kullaniciOlustur(enterKey.user);
  }

  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> exit() {
    return _firebaseAuth.signOut();
  }
}
