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
  static const String baseUrl = 'https://facefade-backend.onrender.com'; // Production URL (fixed)
  // static const String baseUrl = 'http://localhost:8000'; // Geçici local test
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

  // Kişi karşılaştırma - referans kişinin başka fotoğrafta olup olmadığını kontrol eder
  Future<Map<String, dynamic>> compareFaces(
    File referenceImage, 
    File targetImage, 
    {double threshold = 0.6}
  ) async {
    try {
      String refBase64 = await _fileToBase64(referenceImage);
      String targetBase64 = await _fileToBase64(targetImage);
      
      final response = await _dio.post(
        '/compare-faces',
        data: FormData.fromMap({
          'reference_image': refBase64,
          'target_image': targetBase64,
          'threshold': threshold,
        }),
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Backend hatası: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Yüz karşılaştırma hatası: ${e.toString()}');
    }
  }

  // Galeri tarama - referans kişiyi tüm galeride arar
  Future<Map<String, dynamic>> scanGalleryForPerson(
    File referenceImage,
    List<File> galleryImages,
    String personName,
    {double threshold = 0.6}
  ) async {
    try {
      String refBase64 = await _fileToBase64(referenceImage);
      List<String> galleryBase64 = [];
      
      for (File file in galleryImages) {
        galleryBase64.add(await _fileToBase64(file));
      }
      
      final response = await _dio.post(
        '/scan-gallery',
        data: FormData.fromMap({
          'reference_image': refBase64,
          'gallery_images': galleryBase64,
          'threshold': threshold,
          'person_name': personName,
        }),
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Backend hatası: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Galeri tarama hatası: ${e.toString()}');
    }
  }

  // Eşleşen fotoğrafları toplu işleme
  Future<Map<String, dynamic>> processMatchedPhotos(
    List<File> matchedImages,
    List<String> faceCoordinatesList,
    String processingType,
    {Map<String, dynamic> parameters = const {}}
  ) async {
    try {
      List<String> imagesBase64 = [];
      for (File file in matchedImages) {
        imagesBase64.add(await _fileToBase64(file));
      }
      
      final response = await _dio.post(
        '/process-matched-photos',
        data: FormData.fromMap({
          'images_with_matches': imagesBase64,
          'face_coordinates_list': faceCoordinatesList,
          'processing_type': processingType,
          'processing_params': jsonEncode(parameters),
        }),
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Backend hatası: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Toplu işleme hatası: ${e.toString()}');
    }
  }

  // Kişi ekleme ve tarama workflow'u
  Future<Map<String, dynamic>> addPersonAndScanGallery(
    File personReferenceImage,
    String personName,
    String emotionalNote,
    List<File> galleryImages,
    {double threshold = 0.6}
  ) async {
    try {
      // İlk önce referans fotoğrafta yüz var mı kontrol et
      List<FaceCoordinates> refFaces = await detectFaces(personReferenceImage);
      if (refFaces.isEmpty) {
        throw Exception('Referans fotoğrafta yüz bulunamadı');
      }

      // Galeriyi tara
      Map<String, dynamic> scanResult = await scanGalleryForPerson(
        personReferenceImage,
        galleryImages,
        personName,
        threshold: threshold,
      );

      return {
        'success': true,
        'person_name': personName,
        'emotional_note': emotionalNote,
        'reference_faces_count': refFaces.length,
        'scan_result': scanResult,
        'added_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Kişi ekleme ve tarama hatası: ${e.toString()}');
    }
  }

  // Toplu kapanış seremonisi - tüm eşleşen fotoğrafları sanatsal stile dönüştür
  Future<Map<String, dynamic>> performClosureCeremony(
    List<File> matchedImages,
    List<String> faceCoordinatesList,
    String artStyle,
    String personName,
  ) async {
    try {
      // Tüm fotoğrafları sanatsal stile dönüştür
      Map<String, dynamic> result = await processMatchedPhotos(
        matchedImages,
        faceCoordinatesList,
        'artistic',
        parameters: {
          'art_style': artStyle,
        },
      );

      // Kapanış seremonisi metadata'sı ekle
      return {
        ...result,
        'ceremony_type': 'closure',
        'person_name': personName,
        'art_style': artStyle,
        'ceremony_completed_at': DateTime.now().toIso8601String(),
        'emotional_message': 'Anıların dönüştürüldü. İyileşme yolculuğun başladı. 💙',
      };
    } catch (e) {
      throw Exception('Kapanış seremonisi hatası: ${e.toString()}');
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

  // Fotoğrafta kaç kişi olduğunu say (akıllı silme için)
  Future<Map<String, dynamic>> countPeopleInPhoto(File imageFile) async {
    try {
      String base64Image = await _fileToBase64(imageFile);
      
      final response = await _dio.post(
        '/count-people',
        data: FormData.fromMap({
          'image': base64Image,
        }),
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Backend hatası: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Kişi sayma hatası: ${e.toString()}');
    }
  }

  // Akıllı kişi silme - tek kişiyse fotoğraf sil, çok kişiyse AI inpainting
  Future<Map<String, dynamic>> smartRemovePerson(
    File imageFile,
    Map<String, dynamic> targetCoordinates,
    {String removalMethod = 'auto'}
  ) async {
    try {
      String base64Image = await _fileToBase64(imageFile);
      
      final response = await _dio.post(
        '/smart-remove-person',
        data: FormData.fromMap({
          'image': base64Image,
          'target_face_coordinates': jsonEncode(targetCoordinates),
          'removal_method': removalMethod,
        }),
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Backend hatası: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Akıllı silme hatası: ${e.toString()}');
    }
  }

  // Kapanış Seremonisi - anıları sanat eserine dönüştür
  Future<Map<String, dynamic>> performAdvancedClosureCeremony(
    List<File> imageFiles,
    String personName,
    {String artStyle = 'van_gogh', String ceremonyType = 'artistic'}
  ) async {
    try {
      List<String> base64Images = [];
      for (File file in imageFiles) {
        base64Images.add(await _fileToBase64(file));
      }
      
      final response = await _dio.post(
        '/closure-ceremony',
        data: FormData.fromMap({
          'images': base64Images,
          'person_name': personName,
          'art_style': artStyle,
          'ceremony_type': ceremonyType,
        }),
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Backend hatası: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Kapanış seremonisi hatası: ${e.toString()}');
    }
  }

  // Gelişmiş galeri tarama ve akıllı işleme workflow'u
  Future<Map<String, dynamic>> intelligentGalleryCleanup(
    File personReferenceImage,
    String personName,
    String emotionalNote,
    List<File> galleryImages,
    {double threshold = 0.6, String processingMethod = 'smart'}
  ) async {
    try {
      // 1. Referans fotoğrafta yüz kontrol et
      List<FaceCoordinates> refFaces = await detectFaces(personReferenceImage);
      if (refFaces.isEmpty) {
        throw Exception('Referans fotoğrafta yüz bulunamadı');
      }

      // 2. Galeriyi tara ve eşleşmeleri bul
      Map<String, dynamic> scanResult = await scanGalleryForPerson(
        personReferenceImage,
        galleryImages,
        personName,
        threshold: threshold,
      );

      List<Map<String, dynamic>> intelligentResults = [];
      
      if (scanResult['success'] && scanResult['total_matches_found'] > 0) {
        // 3. Her eşleşen fotoğraf için akıllı analiz yap
        List<dynamic> scanResults = scanResult['scan_result']['scan_results'];
        
        for (int i = 0; i < scanResults.length; i++) {
          var result = scanResults[i];
          if (result['found'] && result['matches_count'] > 0) {
            File imageFile = galleryImages[result['image_index']];
            
            // Fotoğrafta kaç kişi var kontrol et
            Map<String, dynamic> peopleCount = await countPeopleInPhoto(imageFile);
            
            // İlk match'in koordinatlarını al
            var firstMatch = result['matches'][0];
            Map<String, dynamic> targetCoords = firstMatch['coordinates'];
            
            intelligentResults.add({
              'image_file': imageFile,
              'image_index': result['image_index'],
              'total_people': peopleCount['total_people'],
              'target_coordinates': targetCoords,
              'smart_suggestion': peopleCount['smart_suggestion'],
              'matches_found': result['matches_count'],
            });
          }
        }
      }

      return {
        'success': true,
        'person_name': personName,
        'emotional_note': emotionalNote,
        'reference_faces_count': refFaces.length,
        'scan_result': scanResult,
        'intelligent_analysis': intelligentResults,
        'total_photos_to_process': intelligentResults.length,
        'processing_method': processingMethod,
        'added_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Akıllı galeri temizleme hatası: ${e.toString()}');
    }
  }

  // Batch akıllı işleme - çoklu fotoğrafları akıllıca işle
  Future<Map<String, dynamic>> batchIntelligentProcessing(
    List<Map<String, dynamic>> photosToProcess,
    String processingType, // 'smart', 'closure_ceremony', 'delete_all'
    {Map<String, dynamic> parameters = const {}}
  ) async {
    try {
      List<Map<String, dynamic>> processedResults = [];
      int deletedPhotos = 0;
      int inpaintedPhotos = 0;
      int ceremonyPhotos = 0;

      for (var photoData in photosToProcess) {
        File imageFile = photoData['image_file'];
        Map<String, dynamic> targetCoords = photoData['target_coordinates'];
        String suggestion = photoData['smart_suggestion'];
        
        try {
          if (processingType == 'smart') {
            // Akıllı işleme - her fotoğraf için en iyi yöntemi seç
            if (suggestion == 'delete_photo') {
              processedResults.add({
                'index': photoData['image_index'],
                'action': 'delete',
                'message': 'Fotoğraf tamamen silindi (tek kişi)',
                'success': true,
              });
              deletedPhotos++;
            } else {
              // AI inpainting uygula
              Map<String, dynamic> smartResult = await smartRemovePerson(
                imageFile,
                targetCoords,
                removalMethod: 'inpaint',
              );
              
              processedResults.add({
                'index': photoData['image_index'],
                'action': 'inpaint',
                'processed_image': smartResult['processed_image'],
                'message': smartResult['message'],
                'success': smartResult['success'],
              });
              inpaintedPhotos++;
            }
          } else if (processingType == 'closure_ceremony') {
            // Kapanış seremonisi - sadece sanatsal dönüşüm
            Map<String, dynamic> ceremonyResult = await performAdvancedClosureCeremony(
              [imageFile],
              parameters['person_name'] ?? 'Kişi',
              artStyle: parameters['art_style'] ?? 'van_gogh',
              ceremonyType: parameters['ceremony_type'] ?? 'artistic',
            );
            
            if (ceremonyResult['success'] && ceremonyResult['processed_images'].isNotEmpty) {
              processedResults.add({
                'index': photoData['image_index'],
                'action': 'ceremony',
                'processed_image': ceremonyResult['processed_images'][0]['transformed_image'],
                'ceremony_message': ceremonyResult['ceremony_message'],
                'success': true,
              });
              ceremonyPhotos++;
            }
          }
        } catch (e) {
          processedResults.add({
            'index': photoData['image_index'],
            'action': 'error',
            'error': e.toString(),
            'success': false,
          });
        }
      }

      return {
        'success': true,
        'processing_type': processingType,
        'total_processed': processedResults.length,
        'deleted_photos': deletedPhotos,
        'inpainted_photos': inpaintedPhotos,
        'ceremony_photos': ceremonyPhotos,
        'results': processedResults,
        'processing_completed_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Batch akıllı işleme hatası: ${e.toString()}');
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