import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/face_data_model.dart';
import '../models/processing_history_model.dart';
import '../models/person_model.dart';

class AppProvider extends ChangeNotifier {
  // App state
  bool _isDarkMode = true;
  String _currentLanguage = 'tr';
  bool _isOfflineMode = false;
  
  // Processing state
  bool _isProcessing = false;
  double _processingProgress = 0.0;
  String _processingStatus = '';
  
  // Statistics
  int _totalProcessedImages = 0;
  int _totalDetectedFaces = 0;
  
  // Gallery state
  List<File> _selectedImages = [];
  List<FaceDataModel> _detectedFaces = [];
  List<ProcessingHistoryModel> _processingHistory = [];
  
  // Person management - YENİ EKLENEN
  List<PersonModel> _addedPersons = [];
  List<PhotoMatchModel> _photoMatches = [];
  
  // Settings
  int _defaultBlurIntensity = 25;
  String _defaultAvatarStyle = 'cartoon';
  String _defaultArtStyle = 'van_gogh';
  bool _autoSaveProcessedImages = true;
  bool _showWatermark = false;
  
  // Getters
  bool get isDarkMode => _isDarkMode;
  String get currentLanguage => _currentLanguage;
  bool get isOfflineMode => _isOfflineMode;
  
  bool get isProcessing => _isProcessing;
  double get processingProgress => _processingProgress;
  String get processingStatus => _processingStatus;
  
  int get totalProcessedImages => _totalProcessedImages;
  int get totalDetectedFaces => _totalDetectedFaces;
  
  List<File> get selectedImages => _selectedImages;
  List<FaceDataModel> get detectedFaces => _detectedFaces;
  List<ProcessingHistoryModel> get processingHistory => _processingHistory;
  
  // YENİ GETTERS
  List<PersonModel> get addedPersons => _addedPersons;
  List<PhotoMatchModel> get photoMatches => _photoMatches;
  
  bool get autoSaveProcessedImages => _autoSaveProcessedImages;
  bool get showWatermark => _showWatermark;
  int get defaultBlurIntensity => _defaultBlurIntensity;
  String get defaultAvatarStyle => _defaultAvatarStyle;
  String get defaultArtStyle => _defaultArtStyle;

  AppProvider() {
    _loadSettings();
  }

  // App Settings
  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setLanguage(String language) {
    _currentLanguage = language;
    _saveSettings();
    notifyListeners();
  }

  void setOfflineMode(bool offline) {
    _isOfflineMode = offline;
    notifyListeners();
  }

  // Processing state management
  void setProcessing(bool processing) {
    _isProcessing = processing;
    if (!processing) {
      _processingProgress = 0.0;
      _processingStatus = '';
    }
    notifyListeners();
  }

  void updateProcessingProgress(double progress, String status) {
    _processingProgress = progress;
    _processingStatus = status;
    notifyListeners();
  }

  // Gallery management
  void setSelectedImages(List<File> images) {
    _selectedImages = images;
    notifyListeners();
  }

  void addSelectedImage(File image) {
    _selectedImages.add(image);
    notifyListeners();
  }

  void removeSelectedImage(File image) {
    _selectedImages.remove(image);
    notifyListeners();
  }

  void clearSelectedImages() {
    _selectedImages.clear();
    notifyListeners();
  }

  // Face data management
  void setDetectedFaces(List<FaceDataModel> faces) {
    _detectedFaces = faces;
    notifyListeners();
  }

  void addDetectedFace(FaceDataModel face) {
    _detectedFaces.add(face);
    notifyListeners();
  }

  void removeDetectedFace(FaceDataModel face) {
    _detectedFaces.remove(face);
    notifyListeners();
  }

  void clearDetectedFaces() {
    _detectedFaces.clear();
    notifyListeners();
  }

  // Processing history management
  void setProcessingHistory(List<ProcessingHistoryModel> history) {
    _processingHistory = history;
    notifyListeners();
  }

  void addProcessingHistory(ProcessingHistoryModel history) {
    _processingHistory.insert(0, history);
    notifyListeners();
  }

  void removeProcessingHistory(ProcessingHistoryModel history) {
    _processingHistory.removeWhere((h) => h.id == history.id);
    notifyListeners();
  }

  void clearProcessingHistory() {
    _processingHistory.clear();
    notifyListeners();
  }

  // Processing settings
  void setDefaultBlurIntensity(int intensity) {
    _defaultBlurIntensity = intensity;
    notifyListeners();
  }

  void setDefaultAvatarStyle(String style) {
    _defaultAvatarStyle = style;
    notifyListeners();
  }

  void setDefaultArtStyle(String style) {
    _defaultArtStyle = style;
    notifyListeners();
  }

  void setAutoSaveProcessedImages(bool value) {
    _autoSaveProcessedImages = value;
    notifyListeners();
  }

  void setShowWatermark(bool value) {
    _showWatermark = value;
    notifyListeners();
  }

  // Statistics
  Map<ProcessingType, int> get processingTypeStats {
    Map<ProcessingType, int> stats = {};
    for (var history in _processingHistory) {
      stats[history.processingType] = (stats[history.processingType] ?? 0) + 1;
    }
    return stats;
  }

  double get averageProcessingTime {
    if (_processingHistory.isEmpty) return 0.0;
    double total = _processingHistory.fold(0.0, (sum, history) => sum + history.processingTime);
    return total / _processingHistory.length;
  }

  // Utility methods
  void reset() {
    _totalProcessedImages = 0;
    _totalDetectedFaces = 0;
    _selectedImages.clear();
    _detectedFaces.clear();
    _processingHistory.clear();
    notifyListeners();
  }

  Future<void> _loadSettings() async {
    // SharedPreferences'tan ayarları yükle
    // Geçici olarak default değerler kullan
  }

  Future<void> _saveSettings() async {
    // SharedPreferences'a ayarları kaydet
    // Geçici olarak hiçbir şey yapma
  }

  // Bulk operations
  Future<void> processBulkImages(
    List<File> images,
    ProcessingType type,
    Map<String, dynamic> parameters,
  ) async {
    setProcessing(true);
    
    try {
      for (int i = 0; i < images.length; i++) {
        double progress = (i + 1) / images.length;
        updateProcessingProgress(progress, 'İşleniyor: ${i + 1}/${images.length}');
        
        // Burada gerçek işleme yapılacak
        await Future.delayed(const Duration(seconds: 1)); // Simülasyon
      }
      
      updateProcessingProgress(1.0, 'Tamamlandı');
    } catch (e) {
      updateProcessingProgress(0.0, 'Hata: ${e.toString()}');
    } finally {
      setProcessing(false);
    }
  }

  // Export/Import settings
  Map<String, dynamic> exportSettings() {
    return {
      'isDarkMode': _isDarkMode,
      'currentLanguage': _currentLanguage,
      'defaultBlurIntensity': _defaultBlurIntensity,
      'defaultAvatarStyle': _defaultAvatarStyle,
      'defaultArtStyle': _defaultArtStyle,
      'autoSaveProcessedImages': _autoSaveProcessedImages,
      'showWatermark': _showWatermark,
    };
  }

  void importSettings(Map<String, dynamic> settings) {
    _isDarkMode = settings['isDarkMode'] ?? _isDarkMode;
    _currentLanguage = settings['currentLanguage'] ?? _currentLanguage;
    _defaultBlurIntensity = settings['defaultBlurIntensity'] ?? _defaultBlurIntensity;
    _defaultAvatarStyle = settings['defaultAvatarStyle'] ?? _defaultAvatarStyle;
    _defaultArtStyle = settings['defaultArtStyle'] ?? _defaultArtStyle;
    _autoSaveProcessedImages = settings['autoSaveProcessedImages'] ?? _autoSaveProcessedImages;
    _showWatermark = settings['showWatermark'] ?? _showWatermark;
    
    _saveSettings();
    notifyListeners();
  }

  // YENİ PERSON MANAGEMENT FUNCTIONS
  
  // Kişi ekleme
  Future<void> addPerson(PersonModel person) async {
    _addedPersons.add(person);
    notifyListeners();
    // TODO: Firebase'e kaydet
  }
  
  // Kişi güncelleme
  Future<void> updatePerson(PersonModel updatedPerson) async {
    int index = _addedPersons.indexWhere((p) => p.id == updatedPerson.id);
    if (index != -1) {
      _addedPersons[index] = updatedPerson;
      notifyListeners();
      // TODO: Firebase'e kaydet
    }
  }
  
  // Kişi silme
  Future<void> removePerson(String personId) async {
    _addedPersons.removeWhere((p) => p.id == personId);
    _photoMatches.removeWhere((m) => m.personId == personId);
    notifyListeners();
    // TODO: Firebase'den sil
  }
  
  // Kişiyi arşivle
  Future<void> archivePerson(String personId) async {
    int index = _addedPersons.indexWhere((p) => p.id == personId);
    if (index != -1) {
      _addedPersons[index] = _addedPersons[index].copyWith(status: 'archived');
      notifyListeners();
      // TODO: Firebase'e kaydet
    }
  }
  
  // Foto eşleşmesi ekleme
  void addPhotoMatch(PhotoMatchModel match) {
    _photoMatches.add(match);
    
    // İlgili kişinin found count'unu güncelle
    int personIndex = _addedPersons.indexWhere((p) => p.id == match.personId);
    if (personIndex != -1) {
      _addedPersons[personIndex] = _addedPersons[personIndex].copyWith(
        foundInPhotosCount: _addedPersons[personIndex].foundInPhotosCount + 1,
        lastFoundAt: DateTime.now(),
      );
    }
    
    notifyListeners();
  }
  
  // Kişiye göre eşleşmeleri getir
  List<PhotoMatchModel> getMatchesForPerson(String personId) {
    return _photoMatches.where((m) => m.personId == personId).toList();
  }
  
  // Aktif kişileri getir
  List<PersonModel> getActivePersons() {
    return _addedPersons.where((p) => p.status == 'active').toList();
  }
  
  // Arşivlenmiş kişileri getir
  List<PersonModel> getArchivedPersons() {
    return _addedPersons.where((p) => p.status == 'archived').toList();
  }
  
  // Bekleyen işlemler
  List<PhotoMatchModel> getPendingMatches() {
    return _photoMatches.where((m) => m.status == 'pending').toList();
  }
  
  // İşlenmiş fotoğraflar
  List<PhotoMatchModel> getProcessedMatches() {
    return _photoMatches.where((m) => m.status == 'processed').toList();
  }
  
  // Kişi istatistikleri
  Map<String, int> getPersonStats(String personId) {
    List<PhotoMatchModel> matches = getMatchesForPerson(personId);
    return {
      'total_matches': matches.length,
      'pending': matches.where((m) => m.status == 'pending').length,
      'processed': matches.where((m) => m.status == 'processed').length,
      'ignored': matches.where((m) => m.status == 'ignored').length,
    };
  }
} 