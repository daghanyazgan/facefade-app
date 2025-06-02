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
    );
  }

  String get processingTypeDisplayName {
    switch (processingType) {
      case ProcessingType.faceDetection:
        return 'Yüz Tespit';
      case ProcessingType.faceBlur:
        return 'Yüz Bulanıklaştırma';
      case ProcessingType.avatarReplacement:
        return 'Avatar Değiştirme';
      case ProcessingType.artStyleTransfer:
        return 'Sanat Stili';
      case ProcessingType.backgroundRemoval:
        return 'Arka Plan Silme';
      case ProcessingType.colorEnhancement:
        return 'Renk İyileştirme';
    }
  }

  String get processingTypeIcon {
    switch (processingType) {
      case ProcessingType.faceDetection:
        return '👤';
      case ProcessingType.faceBlur:
        return '🔵';
      case ProcessingType.avatarReplacement:
        return '🎭';
      case ProcessingType.artStyleTransfer:
        return '🎨';
      case ProcessingType.backgroundRemoval:
        return '✂️';
      case ProcessingType.colorEnhancement:
        return '🌈';
    }
  }
}

enum ProcessingType {
  faceDetection,
  faceBlur,
  avatarReplacement,
  artStyleTransfer,
  backgroundRemoval,
  colorEnhancement,
} 