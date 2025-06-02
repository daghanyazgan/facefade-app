import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  
  User? _user;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _initializeAuthState();
  }

  void _initializeAuthState() {
    _firebaseService.authStateChanges.listen((User? user) async {
      _user = user;
      if (user != null) {
        await _loadUserModel(user.uid);
      } else {
        _userModel = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserModel(String uid) async {
    try {
      _userModel = await _firebaseService.getUserData(uid);
    } catch (e) {
      print('Kullanıcı modeli yüklenemedi: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Kullanıcı kaydı
  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final userCredential = await _firebaseService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );

      if (userCredential != null) {
        _user = userCredential.user;
        await _loadUserModel(_user!.uid);
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Kullanıcı girişi
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final userCredential = await _firebaseService.signIn(
        email: email,
        password: password,
      );

      if (userCredential != null) {
        _user = userCredential.user;
        await _loadUserModel(_user!.uid);
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Şifre sıfırlama
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _setError(null);

      await _firebaseService.resetPassword(email);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Kullanıcı çıkışı
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _firebaseService.signOut();
      _user = null;
      _userModel = null;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Kullanıcı profilini güncelle
  Future<bool> updateProfile({
    String? displayName,
    String? profileImageUrl,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      if (_user == null) return false;

      Map<String, dynamic> updates = {};
      
      if (displayName != null) {
        await _user!.updateDisplayName(displayName);
        updates['displayName'] = displayName;
      }

      if (profileImageUrl != null) {
        updates['profileImageUrl'] = profileImageUrl;
      }

      if (updates.isNotEmpty) {
        await _firebaseService.updateUserData(_user!.uid, updates);
        await _loadUserModel(_user!.uid);
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // E-posta doğrulama gönder
  Future<bool> sendEmailVerification() async {
    try {
      if (_user != null && !_user!.emailVerified) {
        await _user!.sendEmailVerification();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // E-posta doğrulama durumunu yenile
  Future<void> reloadUser() async {
    try {
      if (_user != null) {
        await _user!.reload();
        _user = _firebaseService.currentUser;
        notifyListeners();
      }
    } catch (e) {
      print('Kullanıcı yenilenemedi: $e');
    }
  }

  // Kullanıcı hesabını sil
  Future<bool> deleteAccount() async {
    try {
      _setLoading(true);
      _setError(null);

      if (_user == null) return false;

      // Firestore verilerini sil
      // Bu işlem daha detaylı olabilir - kullanıcının tüm verilerini temizleme
      
      // Firebase Auth hesabını sil
      await _user!.delete();
      
      _user = null;
      _userModel = null;
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Hata mesajını temizle
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Re-authentication (hassas işlemler için)
  Future<bool> reauthenticate(String password) async {
    try {
      if (_user == null || _user!.email == null) return false;

      final credential = EmailAuthProvider.credential(
        email: _user!.email!,
        password: password,
      );

      await _user!.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Şifre değiştir
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      // Önce re-authenticate
      final isReauthenticated = await reauthenticate(currentPassword);
      if (!isReauthenticated) {
        _setError('Mevcut şifre yanlış');
        return false;
      }

      await _user!.updatePassword(newPassword);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
} 