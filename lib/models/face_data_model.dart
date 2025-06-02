class FaceDataModel {
  String? id;
  String name;
  String originalImageUrl;
  List<FaceCoordinates> faceCoordinates;
  DateTime createdAt;
  String personId; // Aynı kişinin farklı yüzlerini gruplamak için
  double confidence;
  Map<String, dynamic> metadata;

  FaceDataModel({
    this.id,
    required this.name,
    required this.originalImageUrl,
    required this.faceCoordinates,
    required this.createdAt,
    required this.personId,
    this.confidence = 0.0,
    this.metadata = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'originalImageUrl': originalImageUrl,
      'faceCoordinates': faceCoordinates.map((face) => face.toMap()).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'personId': personId,
      'confidence': confidence,
      'metadata': metadata,
    };
  }

  static FaceDataModel fromMap(Map<String, dynamic> map) {
    return FaceDataModel(
      name: map['name'] ?? '',
      originalImageUrl: map['originalImageUrl'] ?? '',
      faceCoordinates: (map['faceCoordinates'] as List<dynamic>?)
          ?.map((face) => FaceCoordinates.fromMap(face as Map<String, dynamic>))
          .toList() ?? [],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      personId: map['personId'] ?? '',
      confidence: (map['confidence'] ?? 0.0).toDouble(),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  FaceDataModel copyWith({
    String? id,
    String? name,
    String? originalImageUrl,
    List<FaceCoordinates>? faceCoordinates,
    DateTime? createdAt,
    String? personId,
    double? confidence,
    Map<String, dynamic>? metadata,
  }) {
    return FaceDataModel(
      id: id ?? this.id,
      name: name ?? this.name,
      originalImageUrl: originalImageUrl ?? this.originalImageUrl,
      faceCoordinates: faceCoordinates ?? this.faceCoordinates,
      createdAt: createdAt ?? this.createdAt,
      personId: personId ?? this.personId,
      confidence: confidence ?? this.confidence,
      metadata: metadata ?? this.metadata,
    );
  }
}

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