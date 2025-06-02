class ProcessingHistoryModel {
  String? id;
  String originalImageUrl;
  String processedImageUrl;
  ProcessingType processingType;
  DateTime processedAt;
  Map<String, dynamic> processingParameters;
  String? description;
  double processingTime; // seconds
  bool isSuccessful;
  
  // Yeni eklenen özellikler
  int imageCount; // İşlenen toplam fotoğraf sayısı
  Duration processingDuration; // İşlem süresi
  int deletedPhotos; // Silinen fotoğraf sayısı
  int inpaintedPhotos; // AI ile düzenlenen fotoğraf sayısı
  int ceremonyPhotos; // Seremoni ile dönüştürülen fotoğraf sayısı

  ProcessingHistoryModel({
    this.id,
    required this.originalImageUrl,
    required this.processedImageUrl,
    required this.processingType,
    required this.processedAt,
    this.processingParameters = const {},
    this.description,
    this.processingTime = 0.0,
    this.isSuccessful = true,
    this.imageCount = 1,
    this.processingDuration = const Duration(seconds: 0),
    this.deletedPhotos = 0,
    this.inpaintedPhotos = 0,
    this.ceremonyPhotos = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'originalImageUrl': originalImageUrl,
      'processedImageUrl': processedImageUrl,
      'processingType': processingType.toString(),
      'processedAt': processedAt.millisecondsSinceEpoch,
      'processingParameters': processingParameters,
      'description': description,
      'processingTime': processingTime,
      'isSuccessful': isSuccessful,
      'imageCount': imageCount,
      'processingDuration': processingDuration.inMilliseconds,
      'deletedPhotos': deletedPhotos,
      'inpaintedPhotos': inpaintedPhotos,
      'ceremonyPhotos': ceremonyPhotos,
    };
  }

  static ProcessingHistoryModel fromMap(Map<String, dynamic> map) {
    return ProcessingHistoryModel(
      originalImageUrl: map['originalImageUrl'] ?? '',
      processedImageUrl: map['processedImageUrl'] ?? '',
      processingType: ProcessingType.values.firstWhere(
        (type) => type.toString() == map['processingType'],
        orElse: () => ProcessingType.faceDetection,
      ),
      processedAt: DateTime.fromMillisecondsSinceEpoch(map['processedAt'] ?? 0),
      processingParameters: Map<String, dynamic>.from(map['processingParameters'] ?? {}),
      description: map['description'],
      processingTime: (map['processingTime'] ?? 0.0).toDouble(),
      isSuccessful: map['isSuccessful'] ?? true,
      imageCount: map['imageCount'] ?? 1,
      processingDuration: Duration(milliseconds: map['processingDuration'] ?? 0),
      deletedPhotos: map['deletedPhotos'] ?? 0,
      inpaintedPhotos: map['inpaintedPhotos'] ?? 0,
      ceremonyPhotos: map['ceremonyPhotos'] ?? 0,
    );
  }

  ProcessingHistoryModel copyWith({
    String? id,
    String? originalImageUrl,
    String? processedImageUrl,
    ProcessingType? processingType,
    DateTime? processedAt,
    Map<String, dynamic>? processingParameters,
    String? description,
    double? processingTime,
    bool? isSuccessful,
    int? imageCount,
    Duration? processingDuration,
    int? deletedPhotos,
    int? inpaintedPhotos,
    int? ceremonyPhotos,
  }) {
    return ProcessingHistoryModel(
      id: id ?? this.id,
      originalImageUrl: originalImageUrl ?? this.originalImageUrl,
      processedImageUrl: processedImageUrl ?? this.processedImageUrl,
      processingType: processingType ?? this.processingType,
      processedAt: processedAt ?? this.processedAt,
      processingParameters: processingParameters ?? this.processingParameters,
      description: description ?? this.description,
      processingTime: processingTime ?? this.processingTime,
      isSuccessful: isSuccessful ?? this.isSuccessful,
      imageCount: imageCount ?? this.imageCount,
      processingDuration: processingDuration ?? this.processingDuration,
      deletedPhotos: deletedPhotos ?? this.deletedPhotos,
      inpaintedPhotos: inpaintedPhotos ?? this.inpaintedPhotos,
      ceremonyPhotos: ceremonyPhotos ?? this.ceremonyPhotos,
    );
  }

  String get processingTypeDisplayName {
    switch (processingType) {
      case ProcessingType.faceDetection:
        return 'Yüz Tespit';
      case ProcessingType.faceBlur:
      case ProcessingType.blur:
        return 'Yüz Bulanıklaştırma';
      case ProcessingType.avatarReplacement:
        return 'Avatar Değiştirme';
      case ProcessingType.artStyleTransfer:
      case ProcessingType.artistic:
        return 'Sanat Stili';
      case ProcessingType.backgroundRemoval:
        return 'Arka Plan Silme';
      case ProcessingType.colorEnhancement:
        return 'Renk İyileştirme';
      case ProcessingType.smartProcessing:
        return 'Akıllı İşleme';
      case ProcessingType.closureCeremony:
        return 'Kapanış Seremonisi';
    }
  }

  String get processingTypeIcon {
    switch (processingType) {
      case ProcessingType.faceDetection:
        return '👤';
      case ProcessingType.faceBlur:
      case ProcessingType.blur:
        return '🔵';
      case ProcessingType.avatarReplacement:
        return '🎭';
      case ProcessingType.artStyleTransfer:
      case ProcessingType.artistic:
        return '🎨';
      case ProcessingType.backgroundRemoval:
        return '✂️';
      case ProcessingType.colorEnhancement:
        return '🌈';
      case ProcessingType.smartProcessing:
        return '🤖';
      case ProcessingType.closureCeremony:
        return '🎭';
    }
  }
}

enum ProcessingType {
  faceDetection,
  faceBlur,
  blur, // Yeni eklenen
  avatarReplacement,
  artStyleTransfer,
  artistic, // Yeni eklenen
  backgroundRemoval,
  colorEnhancement,
  smartProcessing, // Yeni eklenen
  closureCeremony, // Yeni eklenen
} 