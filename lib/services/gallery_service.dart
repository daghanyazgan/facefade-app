import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';

class GalleryService {
  static final GalleryService _instance = GalleryService._internal();
  factory GalleryService() => _instance;
  GalleryService._internal();

  /// İzin kontrolü ve galeri erişimi
  Future<bool> requestGalleryPermission() async {
    final PermissionState permission = await PhotoManager.requestPermissionExtend();
    
    if (permission.isAuth) {
      return true;
    } else if (permission.hasAccess) {
      return true;
    } else {
      // İzin reddedildi, kullanıcıyı ayarlara yönlendir
      return false;
    }
  }

  /// Galeriden tüm fotoğrafları al
  Future<List<File>> getAllPhotos({int limit = 1000}) async {
    final bool hasPermission = await requestGalleryPermission();
    
    if (!hasPermission) {
      throw Exception('Galeri erişim izni gerekli');
    }

    try {
      // Albümleri al
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true, // Sadece "Tümü" albümü
      );

      if (albums.isEmpty) {
        return [];
      }

      // İlk albümden (genellikle "Tümü") fotoğrafları al
      final AssetPathEntity album = albums.first;
      final List<AssetEntity> assets = await album.getAssetListRange(
        start: 0,
        end: limit,
      );

      List<File> photos = [];
      
      for (AssetEntity asset in assets) {
        final File? file = await asset.file;
        if (file != null) {
          photos.add(file);
        }
      }

      return photos;
    } catch (e) {
      throw Exception('Galeri okuma hatası: ${e.toString()}');
    }
  }

  /// Son eklenen fotoğrafları al
  Future<List<File>> getRecentPhotos({int limit = 100}) async {
    final bool hasPermission = await requestGalleryPermission();
    
    if (!hasPermission) {
      throw Exception('Galeri erişim izni gerekli');
    }

    try {
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
      );

      if (albums.isEmpty) {
        return [];
      }

      final AssetPathEntity album = albums.first;
      final List<AssetEntity> assets = await album.getAssetListRange(
        start: 0,
        end: limit,
      );

      List<File> photos = [];
      
      for (AssetEntity asset in assets) {
        final File? file = await asset.file;
        if (file != null) {
          photos.add(file);
        }
      }

      return photos;
    } catch (e) {
      throw Exception('Son fotoğrafları alma hatası: ${e.toString()}');
    }
  }

  /// Belirli tarih aralığındaki fotoğrafları al
  Future<List<File>> getPhotosInDateRange(
    DateTime startDate,
    DateTime endDate, 
    {int limit = 500}
  ) async {
    final bool hasPermission = await requestGalleryPermission();
    
    if (!hasPermission) {
      throw Exception('Galeri erişim izni gerekli');
    }

    try {
      final FilterOptionGroup filterOption = FilterOptionGroup(
        imageOption: const FilterOption(
          sizeConstraint: SizeConstraint(ignoreSize: true),
        ),
        createTimeCond: DateTimeCond(
          min: startDate,
          max: endDate,
        ),
      );

      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        filterOption: filterOption,
      );

      if (albums.isEmpty) {
        return [];
      }

      List<File> allPhotos = [];
      
      for (AssetPathEntity album in albums) {
        final List<AssetEntity> assets = await album.getAssetListRange(
          start: 0,
          end: limit,
        );

        for (AssetEntity asset in assets) {
          final File? file = await asset.file;
          if (file != null) {
            allPhotos.add(file);
          }
        }
      }

      return allPhotos;
    } catch (e) {
      throw Exception('Tarih aralığında fotoğraf alma hatası: ${e.toString()}');
    }
  }

  /// Galeri istatistiklerini al
  Future<Map<String, int>> getGalleryStats() async {
    final bool hasPermission = await requestGalleryPermission();
    
    if (!hasPermission) {
      return {'total_photos': 0, 'total_videos': 0};
    }

    try {
      // Fotoğraflar
      final List<AssetPathEntity> photoAlbums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
      );

      // Videolar
      final List<AssetPathEntity> videoAlbums = await PhotoManager.getAssetPathList(
        type: RequestType.video,
        onlyAll: true,
      );

      int totalPhotos = 0;
      int totalVideos = 0;

      if (photoAlbums.isNotEmpty) {
        totalPhotos = await photoAlbums.first.assetCountAsync;
      }

      if (videoAlbums.isNotEmpty) {
        totalVideos = await videoAlbums.first.assetCountAsync;
      }

      return {
        'total_photos': totalPhotos,
        'total_videos': totalVideos,
      };
    } catch (e) {
      return {'total_photos': 0, 'total_videos': 0};
    }
  }

  /// Thumb nail al (önizleme için)
  Future<File?> getThumbnail(AssetEntity asset, {int size = 200}) async {
    try {
      final thumb = await asset.thumbnailDataWithSize(
        ThumbnailSize(size, size),
      );
      
      if (thumb != null) {
        // Geçici dosya oluştur
        final Directory tempDir = Directory.systemTemp;
        final File tempFile = File('${tempDir.path}/thumb_${asset.id}.jpg');
        await tempFile.writeAsBytes(thumb);
        return tempFile;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Fotoğraf batch'leri halinde al (büyük galerilerde performans için)
  Future<List<File>> getPhotosBatch(int batchSize, int offset) async {
    final bool hasPermission = await requestGalleryPermission();
    
    if (!hasPermission) {
      throw Exception('Galeri erişim izni gerekli');
    }

    try {
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
      );

      if (albums.isEmpty) {
        return [];
      }

      final AssetPathEntity album = albums.first;
      final List<AssetEntity> assets = await album.getAssetListRange(
        start: offset,
        end: offset + batchSize,
      );

      List<File> photos = [];
      
      for (AssetEntity asset in assets) {
        final File? file = await asset.file;
        if (file != null) {
          photos.add(file);
        }
      }

      return photos;
    } catch (e) {
      throw Exception('Batch fotoğraf alma hatası: ${e.toString()}');
    }
  }

  /// Performans için stream halinde fotoğraf al
  Stream<List<File>> getPhotosStream({int batchSize = 50}) async* {
    final bool hasPermission = await requestGalleryPermission();
    
    if (!hasPermission) {
      throw Exception('Galeri erişim izni gerekli');
    }

    try {
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
      );

      if (albums.isEmpty) {
        return;
      }

      final AssetPathEntity album = albums.first;
      final int totalCount = await album.assetCountAsync;
      
      for (int offset = 0; offset < totalCount; offset += batchSize) {
        final List<File> batch = await getPhotosBatch(batchSize, offset);
        yield batch;
      }
    } catch (e) {
      throw Exception('Stream fotoğraf alma hatası: ${e.toString()}');
    }
  }
} 