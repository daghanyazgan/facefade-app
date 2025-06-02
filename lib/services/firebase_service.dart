import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';
import 'dart:typed_data';
import '../models/user_model.dart';
import '../models/face_data_model.dart';
import '../models/processing_history_model.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Authentication
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Kullanıcı Kayıt
  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Kullanıcı profilini güncelle
      await userCredential.user?.updateDisplayName(displayName);
      
      // Firestore'da kullanıcı belgesi oluştur
      await _createUserDocument(userCredential.user!, displayName);
      
      return userCredential;
    } catch (e) {
      throw Exception('Kayıt hatası: ${e.toString()}');
    }
  }

  // Kullanıcı Giriş
  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Giriş hatası: ${e.toString()}');
    }
  }

  // Şifre Sıfırlama
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Şifre sıfırlama hatası: ${e.toString()}');
    }
  }

  // Çıkış
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Kullanıcı belgesi oluştur
  Future<void> _createUserDocument(User user, String displayName) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final userData = UserModel(
      uid: user.uid,
      email: user.email!,
      displayName: displayName,
      createdAt: DateTime.now(),
      profileImageUrl: '',
      faceCount: 0,
      processedImagesCount: 0,
    );
    
    await userDoc.set(userData.toMap());
  }

  // Kullanıcı verilerini getir
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Kullanıcı verileri alınamadı: ${e.toString()}');
    }
  }

  // Kullanıcı verilerini güncelle
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      throw Exception('Kullanıcı verileri güncellenemedi: ${e.toString()}');
    }
  }

  // Yüz verisi kaydet
  Future<String> saveFaceData(String userId, FaceDataModel faceData) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('faces')
          .add(faceData.toMap());
      
      // Kullanıcının yüz sayısını artır
      await _incrementUserFaceCount(userId);
      
      return docRef.id;
    } catch (e) {
      throw Exception('Yüz verisi kaydedilemedi: ${e.toString()}');
    }
  }

  // Kullanıcının yüz verilerini getir
  Future<List<FaceDataModel>> getUserFaces(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('faces')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FaceDataModel.fromMap(doc.data() as Map<String, dynamic>)..id = doc.id)
          .toList();
    } catch (e) {
      throw Exception('Yüz verileri alınamadı: ${e.toString()}');
    }
  }

  // İşlem geçmişi kaydet
  Future<String> saveProcessingHistory(String userId, ProcessingHistoryModel history) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('processing_history')
          .add(history.toMap());
      
      // İşlenmiş resim sayısını artır
      await _incrementUserProcessedCount(userId);
      
      return docRef.id;
    } catch (e) {
      throw Exception('İşlem geçmişi kaydedilemedi: ${e.toString()}');
    }
  }

  // İşlem geçmişini getir
  Future<List<ProcessingHistoryModel>> getProcessingHistory(String userId, {int limit = 50}) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('processing_history')
          .orderBy('processedAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => ProcessingHistoryModel.fromMap(doc.data() as Map<String, dynamic>)..id = doc.id)
          .toList();
    } catch (e) {
      throw Exception('İşlem geçmişi alınamadı: ${e.toString()}');
    }
  }

  // Firebase Storage'a resim yükle
  Future<String> uploadImage(File imageFile, String path) async {
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.split('/').last}';
      Reference ref = _storage.ref().child('images/$path/$fileName');
      
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Resim yüklenemedi: ${e.toString()}');
    }
  }

  // Base64 verisini Storage'a yükle
  Future<String> uploadBase64Image(String base64Data, String path) async {
    try {
      // Base64'ü bytes'a çevir
      Uint8List imageBytes = _base64ToBytes(base64Data);
      
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_processed.jpg';
      Reference ref = _storage.ref().child('processed_images/$path/$fileName');
      
      UploadTask uploadTask = ref.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      TaskSnapshot snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('İşlenmiş resim yüklenemedi: ${e.toString()}');
    }
  }

  // Storage'dan resim sil
  Future<void> deleteImage(String imageUrl) async {
    try {
      Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // Sessizce geç, dosya zaten silinmiş olabilir
      print('Resim silinemedi: ${e.toString()}');
    }
  }

  // Yüz verisini sil
  Future<void> deleteFaceData(String userId, String faceId, String? imageUrl) async {
    try {
      // Firestore'dan sil
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('faces')
          .doc(faceId)
          .delete();
      
      // Storage'dan resmi sil
      if (imageUrl != null && imageUrl.isNotEmpty) {
        await deleteImage(imageUrl);
      }
      
      // Kullanıcının yüz sayısını azalt
      await _decrementUserFaceCount(userId);
    } catch (e) {
      throw Exception('Yüz verisi silinemedi: ${e.toString()}');
    }
  }

  // İşlem geçmişini sil
  Future<void> deleteProcessingHistory(String userId, String historyId, String? imageUrl) async {
    try {
      // Firestore'dan sil
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('processing_history')
          .doc(historyId)
          .delete();
      
      // Storage'dan resmi sil
      if (imageUrl != null && imageUrl.isNotEmpty) {
        await deleteImage(imageUrl);
      }
    } catch (e) {
      throw Exception('İşlem geçmişi silinemedi: ${e.toString()}');
    }
  }

  // Kullanıcının yüz sayısını artır
  Future<void> _incrementUserFaceCount(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'faceCount': FieldValue.increment(1),
    });
  }

  // Kullanıcının yüz sayısını azalt
  Future<void> _decrementUserFaceCount(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'faceCount': FieldValue.increment(-1),
    });
  }

  // İşlenmiş resim sayısını artır
  Future<void> _incrementUserProcessedCount(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'processedImagesCount': FieldValue.increment(1),
    });
  }

  // Base64'ü bytes'a çevir
  Uint8List _base64ToBytes(String base64String) {
    // Data URL prefix'ini kaldır
    if (base64String.startsWith('data:')) {
      base64String = base64String.split(',')[1];
    }
    return _base64Decode(base64String);
  }

  Uint8List _base64Decode(String base64String) {
    // Padding ekle
    while (base64String.length % 4 != 0) {
      base64String += '=';
    }
    
    const codec = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    List<int> bytes = [];
    
    for (int i = 0; i < base64String.length; i += 4) {
      int a = codec.indexOf(base64String[i]);
      int b = codec.indexOf(base64String[i + 1]);
      int c = codec.indexOf(base64String[i + 2]);
      int d = codec.indexOf(base64String[i + 3]);
      
      bytes.add((a << 2) | (b >> 4));
      if (c != -1) bytes.add(((b & 15) << 4) | (c >> 2));
      if (d != -1) bytes.add(((c & 3) << 6) | d);
    }
    
    return Uint8List.fromList(bytes);
  }

  // Realtime listeners
  Stream<List<FaceDataModel>> getUserFacesStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('faces')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FaceDataModel.fromMap(doc.data())..id = doc.id)
            .toList());
  }

  Stream<List<ProcessingHistoryModel>> getProcessingHistoryStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('processing_history')
        .orderBy('processedAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProcessingHistoryModel.fromMap(doc.data())..id = doc.id)
            .toList());
  }
} 