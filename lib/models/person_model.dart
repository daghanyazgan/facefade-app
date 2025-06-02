class PersonModel {
  String id;
  String name;
  String referenceImageUrl; // Kişinin tanıma için kullanılacak referans fotoğrafı
  List<String> additionalImageUrls; // Ek referans fotoğraflar
  DateTime addedAt;
  String emotionalNote; // "Eski sevgilim", "Artık görmek istemediğim arkadaşım" gibi
  String status; // "active", "archived", "deleted"
  int foundInPhotosCount; // Kaç fotoğrafta bulundu
  DateTime? lastFoundAt;
  Map<String, dynamic> processingPreferences; // Varsayılan işlem tercihleri
  
  // Yeni eklenen özellikler
  int processedPhotosCount; // İşlenen fotoğraf sayısı
  DateTime? lastProcessedAt; // Son işlem tarihi
  Map<String, dynamic>? processingResults; // Son işlem sonuçları
  Map<String, dynamic>? scanResults; // Tarama sonuçları

  PersonModel({
    required this.id,
    required this.name,
    required this.referenceImageUrl,
    this.additionalImageUrls = const [],
    required this.addedAt,
    this.emotionalNote = '',
    this.status = 'active',
    this.foundInPhotosCount = 0,
    this.lastFoundAt,
    this.processingPreferences = const {},
    this.processedPhotosCount = 0,
    this.lastProcessedAt,
    this.processingResults,
    this.scanResults,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'referenceImageUrl': referenceImageUrl,
      'additionalImageUrls': additionalImageUrls,
      'addedAt': addedAt.millisecondsSinceEpoch,
      'emotionalNote': emotionalNote,
      'status': status,
      'foundInPhotosCount': foundInPhotosCount,
      'lastFoundAt': lastFoundAt?.millisecondsSinceEpoch,
      'processingPreferences': processingPreferences,
      'processedPhotosCount': processedPhotosCount,
      'lastProcessedAt': lastProcessedAt?.millisecondsSinceEpoch,
      'processingResults': processingResults,
      'scanResults': scanResults,
    };
  }

  static PersonModel fromMap(Map<String, dynamic> map) {
    return PersonModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      referenceImageUrl: map['referenceImageUrl'] ?? '',
      additionalImageUrls: List<String>.from(map['additionalImageUrls'] ?? []),
      addedAt: DateTime.fromMillisecondsSinceEpoch(map['addedAt'] ?? 0),
      emotionalNote: map['emotionalNote'] ?? '',
      status: map['status'] ?? 'active',
      foundInPhotosCount: map['foundInPhotosCount'] ?? 0,
      lastFoundAt: map['lastFoundAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['lastFoundAt']) 
          : null,
      processingPreferences: Map<String, dynamic>.from(map['processingPreferences'] ?? {}),
      processedPhotosCount: map['processedPhotosCount'] ?? 0,
      lastProcessedAt: map['lastProcessedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['lastProcessedAt']) 
          : null,
      processingResults: map['processingResults'] != null 
          ? Map<String, dynamic>.from(map['processingResults']) 
          : null,
      scanResults: map['scanResults'] != null 
          ? Map<String, dynamic>.from(map['scanResults']) 
          : null,
    );
  }

  PersonModel copyWith({
    String? id,
    String? name,
    String? referenceImageUrl,
    List<String>? additionalImageUrls,
    DateTime? addedAt,
    String? emotionalNote,
    String? status,
    int? foundInPhotosCount,
    DateTime? lastFoundAt,
    Map<String, dynamic>? processingPreferences,
    int? processedPhotosCount,
    DateTime? lastProcessedAt,
    Map<String, dynamic>? processingResults,
    Map<String, dynamic>? scanResults,
  }) {
    return PersonModel(
      id: id ?? this.id,
      name: name ?? this.name,
      referenceImageUrl: referenceImageUrl ?? this.referenceImageUrl,
      additionalImageUrls: additionalImageUrls ?? this.additionalImageUrls,
      addedAt: addedAt ?? this.addedAt,
      emotionalNote: emotionalNote ?? this.emotionalNote,
      status: status ?? this.status,
      foundInPhotosCount: foundInPhotosCount ?? this.foundInPhotosCount,
      lastFoundAt: lastFoundAt ?? this.lastFoundAt,
      processingPreferences: processingPreferences ?? this.processingPreferences,
      processedPhotosCount: processedPhotosCount ?? this.processedPhotosCount,
      lastProcessedAt: lastProcessedAt ?? this.lastProcessedAt,
      processingResults: processingResults ?? this.processingResults,
      scanResults: scanResults ?? this.scanResults,
    );
  }
}

class PhotoMatchModel {
  String id;
  String personId;
  String photoPath;
  List<FaceCoordinates> matchedFaces;
  double confidence;
  DateTime detectedAt;
  String status; // "pending", "processed", "ignored"
  String? processingType; // "blur", "avatar", "artistic"
  String? processedImagePath;

  PhotoMatchModel({
    required this.id,
    required this.personId,
    required this.photoPath,
    required this.matchedFaces,
    required this.confidence,
    required this.detectedAt,
    this.status = 'pending',
    this.processingType,
    this.processedImagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'personId': personId,
      'photoPath': photoPath,
      'matchedFaces': matchedFaces.map((face) => face.toMap()).toList(),
      'confidence': confidence,
      'detectedAt': detectedAt.millisecondsSinceEpoch,
      'status': status,
      'processingType': processingType,
      'processedImagePath': processedImagePath,
    };
  }

  static PhotoMatchModel fromMap(Map<String, dynamic> map) {
    return PhotoMatchModel(
      id: map['id'] ?? '',
      personId: map['personId'] ?? '',
      photoPath: map['photoPath'] ?? '',
      matchedFaces: (map['matchedFaces'] as List<dynamic>?)
          ?.map((face) => FaceCoordinates.fromMap(face as Map<String, dynamic>))
          .toList() ?? [],
      confidence: (map['confidence'] ?? 0.0).toDouble(),
      detectedAt: DateTime.fromMillisecondsSinceEpoch(map['detectedAt'] ?? 0),
      status: map['status'] ?? 'pending',
      processingType: map['processingType'],
      processedImagePath: map['processedImagePath'],
    );
  }
}

// Face coordinates class'ını da buraya import etmemiz gerekebilir
class FaceCoordinates {
  int top;
  int right;
  int bottom;
  int left;
  int width;
  int height;
  double confidence;

  FaceCoordinates({
    required this.top,
    required this.right,
    required this.bottom,
    required this.left,
    required this.width,
    required this.height,
    this.confidence = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'top': top,
      'right': right,
      'bottom': bottom,
      'left': left,
      'width': width,
      'height': height,
      'confidence': confidence,
    };
  }

  static FaceCoordinates fromMap(Map<String, dynamic> map) {
    return FaceCoordinates(
      top: map['top'] ?? 0,
      right: map['right'] ?? 0,
      bottom: map['bottom'] ?? 0,
      left: map['left'] ?? 0,
      width: map['width'] ?? 0,
      height: map['height'] ?? 0,
      confidence: (map['confidence'] ?? 0.0).toDouble(),
    );
  }
} 