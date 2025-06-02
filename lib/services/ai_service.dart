import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
import '../models/face_data_model.dart';
import '../models/processing_history_model.dart';

class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  // Backend URL - Production'da değiştirilmeli
  static const String baseUrl = 'http://localhost:8000'; // Geliştirme için
  // Deploy edildikten sonra bu URL'yi kullanın:
  // static const String baseUrl = 'https://your-app-name.up.railway.app'; // Railway
  // static const String baseUrl = 'https://your-app-name.onrender.com'; // Render
  // static const String baseUrl = 'https://your-app-name.herokuapp.com'; // Heroku
  
  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  // File'ı base64'e çevir
  Future<String> _fileToBase64(File file) async {
    try {
      Uint8List bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      throw Exception('Dosya okuma hatası: ${e.toString()}');
    }
  }

  // Image widget için base64'e çevir
  String _imageToBase64(img.Image image) {
    List<int> jpeg = img.encodeJpg(image, quality: 85);
    return base64Encode(jpeg);
  }

  // Backend sağlık kontrolü
  Future<bool> checkBackendHealth() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      print('Backend sağlık kontrolü hatası: $e');
      return false;
    }
  }

  // Yüz tespiti
  Future<List<FaceCoordinates>> detectFaces(File imageFile) async {
    try {
      String base64Image = await _fileToBase64(imageFile);
      
      final response = await _dio.post(
        '/detect-face',
        data: FormData.fromMap({
          'image': base64Image,
        }),
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          List<dynamic> faces = data['faces'] ?? [];
          return faces.map((face) => FaceCoordinates.fromMap(face['coordinates'])).toList();
        } else {
          throw Exception('Yüz tespiti başarısız');
        }
      } else {
        throw Exception('Backend hatası: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Yüz tespiti hatası: ${e.toString()}');
    }
  }

  // Yüz bulanıklaştırma
  Future<String> blurFace(File imageFile, FaceCoordinates faceCoords, {int blurIntensity = 15}) async {
    try {
      String base64Image = await _fileToBase64(imageFile);
      
      final response = await _dio.post(
        '/blur-face',
        data: FormData.fromMap({
          'image': base64Image,
          'face_coordinates': jsonEncode(faceCoords.toMap()),
          'blur_intensity': blurIntensity,
        }),
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['processed_image'];
        } else {
          throw Exception('Yüz bulanıklaştırma başarısız');
        }
      } else {
        throw Exception('Backend hatası: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Yüz bulanıklaştırma hatası: ${e.toString()}');
    }
  }

  // Avatar değiştirme
  Future<String> replaceWithAvatar(
    File imageFile, 
    FaceCoordinates faceCoords, 
    {String avatarStyle = 'cartoon'}
  ) async {
    try {
      String base64Image = await _fileToBase64(imageFile);
      
      final response = await _dio.post(
        '/replace-with-avatar',
        data: FormData.fromMap({
          'image': base64Image,
          'face_coordinates': jsonEncode(faceCoords.toMap()),
          'avatar_style': avatarStyle,
        }),
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['processed_image'];
        } else {
          throw Exception('Avatar değiştirme başarısız');
        }
      } else {
        throw Exception('Backend hatası: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Avatar değiştirme hatası: ${e.toString()}');
    }
  }

  // Sanatsal stil uygulama
  Future<String> applyArtStyle(File imageFile, {String artStyle = 'van_gogh'}) async {
    try {
      String base64Image = await _fileToBase64(imageFile);
      
      final response = await _dio.post(
        '/artify-photo',
        data: FormData.fromMap({
          'image': base64Image,
          'art_style': artStyle,
        }),
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['processed_image'];
        } else {
          throw Exception('Sanat stili uygulama başarısız');
        }
      } else {
        throw Exception('Backend hatası: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Sanat stili uygulama hatası: ${e.toString()}');
    }
  }

  // Toplu işleme
  Future<List<Map<String, dynamic>>> batchProcess(
    List<File> imageFiles, 
    String operation, 
    {Map<String, dynamic> parameters = const {}}
  ) async {
    try {
      List<String> base64Images = [];
      for (File file in imageFiles) {
        base64Images.add(await _fileToBase64(file));
      }
      
      final response = await _dio.post(
        '/batch-process',
        data: FormData.fromMap({
          'images': base64Images,
          'operation': operation,
          'parameters': jsonEncode(parameters),
        }),
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['results']);
        } else {
          throw Exception('Toplu işleme başarısız');
        }
      } else {
        throw Exception('Backend hatası: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Toplu işleme hatası: ${e.toString()}');
    }
  }

  // Hızlı yüz tespiti (local ML Kit ile)
  Future<List<FaceCoordinates>> quickFaceDetection(File imageFile) async {
    try {
      // Google ML Kit ile local yüz tespiti
      // Bu daha hızlı ama daha az hassas
      // Gerçek implementasyon için google_mlkit_face_detection paketi kullanılmalı
      
      // Geçici olarak mock data döndür
      await Future.delayed(const Duration(milliseconds: 500));
      
      return [
        FaceCoordinates(
          top: 100,
          right: 200,
          bottom: 250,
          left: 50,
          width: 150,
          height: 150,
          confidence: 0.95,
        ),
      ];
    } catch (e) {
      throw Exception('Hızlı yüz tespiti hatası: ${e.toString()}');
    }
  }

  // Resim kalitesi iyileştirme
  Future<String> enhanceImageQuality(File imageFile) async {
    try {
      // AI tabanlı resim kalitesi iyileştirme
      // Hugging Face Real-ESRGAN modeli kullanılabilir
      
      String base64Image = await _fileToBase64(imageFile);
      
      // Geçici olarak orijinal resmi döndür
      return base64Image;
    } catch (e) {
      throw Exception('Resim kalitesi iyileştirme hatası: ${e.toString()}');
    }
  }

  // Arka plan silme
  Future<String> removeBackground(File imageFile) async {
    try {
      // AI tabanlı arka plan silme
      // U2-Net veya SAM modeli kullanılabilir
      
      String base64Image = await _fileToBase64(imageFile);
      
      // Geçici olarak orijinal resmi döndür
      return base64Image;
    } catch (e) {
      throw Exception('Arka plan silme hatası: ${e.toString()}');
    }
  }

  // Yüz karşılaştırma ve benzerlik skoru
  Future<double> compareFaces(File image1, File image2) async {
    try {
      // İki yüzün benzerlik skorunu hesapla
      // Face recognition algoritması kullanılmalı
      
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock similarity score
      return 0.85;
    } catch (e) {
      throw Exception('Yüz karşılaştırma hatası: ${e.toString()}');
    }
  }

  // Video'dan frame extraction
  Future<List<File>> extractFramesFromVideo(File videoFile, {int maxFrames = 10}) async {
    try {
      // Video'dan frame'leri çıkart
      // FFmpeg kullanılabilir
      
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock extracted frames
      return [];
    } catch (e) {
      throw Exception('Video frame çıkarma hatası: ${e.toString()}');
    }
  }

  // Resim metadata'sını temizle
  File cleanImageMetadata(File imageFile) {
    try {
      // EXIF ve diğer metadata'yı temizle
      // Privary için önemli
      
      return imageFile;
    } catch (e) {
      throw Exception('Metadata temizleme hatası: ${e.toString()}');
    }
  }

  // Watermark ekleme
  Future<String> addWatermark(File imageFile, String watermarkText) async {
    try {
      // Resme watermark ekle
      String base64Image = await _fileToBase64(imageFile);
      
      // Geçici olarak orijinal resmi döndür
      return base64Image;
    } catch (e) {
      throw Exception('Watermark ekleme hatası: ${e.toString()}');
    }
  }
}

// Avatar stilleri
class AvatarStyles {
  static const String cartoon = 'cartoon';
  static const String anime = 'anime';
  static const String realistic = 'realistic';
  static const String abstract = 'abstract';
  static const String emoji = 'emoji';
  static const String pixelArt = 'pixel_art';
  
  static List<String> get allStyles => [
    cartoon, anime, realistic, abstract, emoji, pixelArt
  ];
  
  static String getDisplayName(String style) {
    switch (style) {
      case cartoon: return 'Çizgi Film';
      case anime: return 'Anime';
      case realistic: return 'Gerçekçi';
      case abstract: return 'Soyut';
      case emoji: return 'Emoji';
      case pixelArt: return 'Pixel Sanatı';
      default: return style;
    }
  }
}

// Sanat stilleri
class ArtStyles {
  static const String vanGogh = 'van_gogh';
  static const String picasso = 'picasso';
  static const String monet = 'monet';
  static const String glitch = 'glitch';
  static const String vaporwave = 'vaporwave';
  static const String sketch = 'sketch';
  
  static List<String> get allStyles => [
    vanGogh, picasso, monet, glitch, vaporwave, sketch
  ];
  
  static String getDisplayName(String style) {
    switch (style) {
      case vanGogh: return 'Van Gogh';
      case picasso: return 'Picasso';
      case monet: return 'Monet';
      case glitch: return 'Glitch';
      case vaporwave: return 'Vaporwave';
      case sketch: return 'Karakalem';
      default: return style;
    }
  }
} 