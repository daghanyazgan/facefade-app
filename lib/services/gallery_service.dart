import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';

class GalleryService {
  static final GalleryService _instance = GalleryService._internal();
  factory GalleryService() => _instance;
  GalleryService._internal();

  /// Galeri izni isteme
  Future<bool> requestGalleryPermission() async {
    try {
      // Android 13+ için yeni izin sistemi
      if (Platform.isAndroid) {
        final PermissionStatus status = await Permission.photos.request();
        if (status.isDenied || status.isPermanentlyDenied) {
          // Fallback: eski storage permission dene
          final PermissionStatus storageStatus = await Permission.storage.request();
          return storageStatus.isGranted;
        }
        return status.isGranted;
      } else if (Platform.isIOS) {
        final PermissionStatus status = await Permission.photos.request();
        return status.isGranted;
      }
      return false;
    } catch (e) {
      print('İzin isteme hatası: $e');
      return false;
    }
  }

  /// Tüm fotoğrafları getir
  Future<List<File>> getAllPhotos({int limit = 1000}) async {
    try {
      // İzin kontrolü
      bool hasPermission = await requestGalleryPermission();
      if (!hasPermission) {
        throw Exception('Galeri erişim izni verilmedi');
      }

      // Photo Manager ile fotoğrafları al
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (!ps.isAuth) {
        throw Exception('PhotoManager izni verilmedi');
      }

      // Galeri album'larını al
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true, // Sadece "All Photos" album'u
      );

      if (albums.isEmpty) {
        return [];
      }

      // İlk album'dan fotoğrafları al (genellikle "All Photos")
      AssetPathEntity album = albums.first;
      List<AssetEntity> assets = await album.getAssetListPaged(
        page: 0,
        size: limit,
      );

      // AssetEntity'leri File'a dönüştür
      List<File> imageFiles = [];
      for (AssetEntity asset in assets) {
        File? file = await asset.file;
        if (file != null && file.existsSync()) {
          imageFiles.add(file);
        }
      }

      return imageFiles;
    } catch (e) {
      print('Galeri fotoğrafları alma hatası: $e');
      return [];
    }
  }

  /// Son N fotoğrafı getir
  Future<List<File>> getRecentPhotos({int count = 100}) async {
    try {
      bool hasPermission = await requestGalleryPermission();
      if (!hasPermission) {
        throw Exception('Galeri erişim izni verilmedi');
      }

      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (!ps.isAuth) {
        throw Exception('PhotoManager izni verilmedi');
      }

      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
      );

      if (albums.isEmpty) {
        return [];
      }

      AssetPathEntity album = albums.first;
      List<AssetEntity> assets = await album.getAssetListPaged(
        page: 0,
        size: count,
      );

      List<File> imageFiles = [];
      for (AssetEntity asset in assets) {
        File? file = await asset.file;
        if (file != null && file.existsSync()) {
          imageFiles.add(file);
        }
      }

      return imageFiles;
    } catch (e) {
      print('Son fotoğrafları alma hatası: $e');
      return [];
    }
  }

  /// Belirli tarih aralığındaki fotoğrafları getir
  Future<List<File>> getPhotosInDateRange({
    required DateTime startDate,
    required DateTime endDate,
    int limit = 500,
  }) async {
    try {
      bool hasPermission = await requestGalleryPermission();
      if (!hasPermission) {
        throw Exception('Galeri erişim izni verilmedi');
      }

      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (!ps.isAuth) {
        throw Exception('PhotoManager izni verilmedi');
      }

      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
        filterOption: FilterOptionGroup(
          createTimeCond: DateTimeCond(
            min: startDate,
            max: endDate,
          ),
        ),
      );

      if (albums.isEmpty) {
        return [];
      }

      AssetPathEntity album = albums.first;
      List<AssetEntity> assets = await album.getAssetListPaged(
        page: 0,
        size: limit,
      );

      List<File> imageFiles = [];
      for (AssetEntity asset in assets) {
        File? file = await asset.file;
        if (file != null && file.existsSync()) {
          imageFiles.add(file);
        }
      }

      return imageFiles;
    } catch (e) {
      print('Tarih aralığı fotoğraf alma hatası: $e');
      return [];
    }
  }

  /// Galeri istatistikleri
  Future<Map<String, int>> getGalleryStats() async {
    try {
      bool hasPermission = await requestGalleryPermission();
      if (!hasPermission) {
        return {'total_photos': 0, 'total_albums': 0};
      }

      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (!ps.isAuth) {
        return {'total_photos': 0, 'total_albums': 0};
      }

      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
      );

      int totalPhotos = 0;
      for (AssetPathEntity album in albums) {
        totalPhotos += await album.assetCountAsync;
      }

      return {
        'total_photos': totalPhotos,
        'total_albums': albums.length,
      };
    } catch (e) {
      print('Galeri istatistik hatası: $e');
      return {'total_photos': 0, 'total_albums': 0};
    }
  }

  /// İzin durumu kontrolü
  Future<bool> checkPermissionStatus() async {
    try {
      if (Platform.isAndroid) {
        final PermissionStatus photosStatus = await Permission.photos.status;
        final PermissionStatus storageStatus = await Permission.storage.status;
        return photosStatus.isGranted || storageStatus.isGranted;
      } else if (Platform.isIOS) {
        final PermissionStatus status = await Permission.photos.status;
        return status.isGranted;
      }
      return false;
    } catch (e) {
      print('İzin durumu kontrol hatası: $e');
      return false;
    }
  }

  /// Batch fotoğraf işleme - belirli aralıklarla fotoğrafları getir (memory yönetimi için)
  Future<List<List<File>>> getBatchedPhotos({
    int batchSize = 100,
    int maxBatches = 10,
  }) async {
    try {
      bool hasPermission = await requestGalleryPermission();
      if (!hasPermission) {
        throw Exception('Galeri erişim izni verilmedi');
      }

      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (!ps.isAuth) {
        throw Exception('PhotoManager izni verilmedi');
      }

      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
      );

      if (albums.isEmpty) {
        return [];
      }

      AssetPathEntity album = albums.first;
      List<List<File>> batches = [];

      for (int batchIndex = 0; batchIndex < maxBatches; batchIndex++) {
        List<AssetEntity> assets = await album.getAssetListPaged(
          page: batchIndex,
          size: batchSize,
        );

        if (assets.isEmpty) break;

        List<File> batchFiles = [];
        for (AssetEntity asset in assets) {
          File? file = await asset.file;
          if (file != null && file.existsSync()) {
            batchFiles.add(file);
          }
        }

        if (batchFiles.isNotEmpty) {
          batches.add(batchFiles);
        }
      }

      return batches;
    } catch (e) {
      print('Batch fotoğraf alma hatası: $e');
      return [];
    }
  }

  /// Memory-safe tek seferde az fotoğraf al
  Future<List<File>> getSafePhotosBatch({
    int page = 0,
    int pageSize = 50,
  }) async {
    try {
      bool hasPermission = await requestGalleryPermission();
      if (!hasPermission) {
        throw Exception('Galeri erişim izni verilmedi');
      }

      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (!ps.isAuth) {
        throw Exception('PhotoManager izni verilmedi');
      }

      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
      );

      if (albums.isEmpty) {
        return [];
      }

      AssetPathEntity album = albums.first;
      List<AssetEntity> assets = await album.getAssetListPaged(
        page: page,
        size: pageSize,
      );

      List<File> imageFiles = [];
      for (AssetEntity asset in assets) {
        File? file = await asset.file;
        if (file != null && file.existsSync()) {
          imageFiles.add(file);
        }
      }

      return imageFiles;
    } catch (e) {
      print('Safe batch fotoğraf alma hatası: $e');
      return [];
    }
  }
} 