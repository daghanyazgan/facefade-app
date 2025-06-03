import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io';
import '../providers/app_provider.dart';
import '../widgets/custom_button.dart';
import '../theme/app_colors.dart';
import '../models/person_model.dart';
import '../services/ai_service.dart';
import '../services/firebase_service.dart';
import '../services/gallery_service.dart';

class AddPersonPage extends StatefulWidget {
  const AddPersonPage({super.key});

  @override
  State<AddPersonPage> createState() => _AddPersonPageState();
}

class _AddPersonPageState extends State<AddPersonPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emotionalNoteController = TextEditingController();
  final PageController _pageController = PageController();
  
  File? _selectedImage;
  bool _isProcessing = false;
  int _currentStep = 0;
  
  final List<String> _emotionalNoteExamples = [
    "Artık görmek istemediğim eski sevgilim",
    "Beni üzen eski arkadaşım", 
    "Kötü anılarım olan aile bireyi",
    "Geçmişte kalan iş arkadaşım",
    "Acı veren eski dostum",
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emotionalNoteController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Kişi Ekle',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildWelcomeStep(),
          _buildPhotoStep(),
          _buildInfoStep(),
          _buildScanningStep(),
        ],
      ),
    );
  }

  Widget _buildWelcomeStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Spacer(),
          
          // Emoji ve başlık
          Text(
            '💙',
            style: const TextStyle(fontSize: 80),
          ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
          
          const SizedBox(height: 24),
          
          Text(
            'Dijital Temizlik',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
          
          const SizedBox(height: 16),
          
          Text(
            'Geçmişte birlikte olduğun ama artık görmek istemediğin kişilerle ilgili dijital anıları temizlemenin zamanı.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 500.ms, duration: 600.ms),
          
          const SizedBox(height: 40),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.auto_fix_high,
                  color: AppColors.primary,
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  'AI, o kişiyi tüm galerinde bulup dönüştürecek',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate().slideY(delay: 700.ms, duration: 600.ms, begin: 0.3),
          
          const Spacer(),
          
          CustomButton(
            text: 'Başlayalım',
            icon: Icons.arrow_forward,
            onPressed: () => _nextStep(),
            backgroundColor: AppColors.primary,
            textColor: Colors.white,
          ).animate().slideY(delay: 900.ms, duration: 600.ms, begin: 0.3),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPhotoStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          Text(
            'Kişinin Fotoğrafını Ekle',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Bu fotoğraf sayesinde AI, o kişiyi galerindeki tüm fotoğraflarda bulacak.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 40),
          
          // Fotoğraf seçme alanı
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _selectedImage != null 
                      ? AppColors.primary 
                      : AppColors.border,
                  width: 2,
                ),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Fotoğraf Ekle',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Dokunarak galeri veya kamera seç',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOut),
          
          const Spacer(),
          
          if (_selectedImage != null)
            CustomButton(
              text: 'Devam Et',
              icon: Icons.arrow_forward,
              onPressed: () => _nextStep(),
              backgroundColor: AppColors.primary,
              textColor: Colors.white,
            ).animate().slideY(duration: 400.ms, begin: 0.3),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          Text(
            'Kişi Hakkında',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Bu bilgiler sadece sana ait kalacak ve duygusal iyileşmen için kullanılacak.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 40),
          
          // İsim girişi
          TextField(
            controller: _nameController,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'İsim veya Takma Ad',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              hintText: 'Örn: Eski sevgilim, Ahmet',
              hintStyle: TextStyle(color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ).animate().slideY(delay: 200.ms, duration: 600.ms, begin: 0.3),
          
          const SizedBox(height: 20),
          
          // Duygusal not
          TextField(
            controller: _emotionalNoteController,
            maxLines: 3,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Duygusal Not (Opsiyonel)',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              hintText: 'Bu kişi hakkında hislerinizi yazın...',
              hintStyle: TextStyle(color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ).animate().slideY(delay: 400.ms, duration: 600.ms, begin: 0.3),
          
          const SizedBox(height: 20),
          
          // Örnek notlar
          Text(
            'Örnek notlar:',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _emotionalNoteExamples.map((example) {
              return GestureDetector(
                onTap: () => _emotionalNoteController.text = example,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    example,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ).animate().fadeIn(delay: 600.ms, duration: 600.ms),
          
          const Spacer(),
          
          CustomButton(
            text: 'Galeriyi Tara',
            icon: Icons.search,
            onPressed: _nameController.text.isNotEmpty ? () => _startScanning() : null,
            backgroundColor: AppColors.primary,
            textColor: Colors.white,
          ).animate().slideY(delay: 800.ms, duration: 600.ms, begin: 0.3),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildScanningStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Tarama animasyonu
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.3),
                  AppColors.primary,
                ],
              ),
            ),
            child: Icon(
              Icons.face_outlined,
              size: 60,
              color: Colors.white,
            ),
          ).animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: 2.seconds),
          
          const SizedBox(height: 40),
          
          Text(
            'Galerin Taranıyor...',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(duration: 600.ms),
          
          const SizedBox(height: 16),
          
          Text(
            'AI, ${_nameController.text} isimli kişiyi tüm fotoğraflarında arıyor.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
          
          const SizedBox(height: 40),
          
          LinearProgressIndicator(
            backgroundColor: AppColors.surface,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ).animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: 1.5.seconds),
        ],
      ),
    );
  }

  void _nextStep() {
    setState(() {
      _currentStep++;
    });
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Fotoğraf Seç',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Kamera',
                    icon: Icons.camera_alt,
                    onPressed: () => _selectImage(ImageSource.camera),
                    backgroundColor: AppColors.primary,
                    textColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: 'Galeri',
                    icon: Icons.photo_library,
                    onPressed: () => _selectImage(ImageSource.gallery),
                    backgroundColor: AppColors.surface,
                    textColor: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectImage(ImageSource source) async {
    Navigator.pop(context);
    
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fotoğraf seçilirken hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _startScanning() async {
    if (_selectedImage == null || _nameController.text.isEmpty) return;
    
    _nextStep(); // Tarama ekranına geç
    
    setState(() {
      _isProcessing = true;
    });

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final aiService = AiService();
      final galleryService = GalleryService();
      
      // İzin kontrolü
      bool hasPermission = await galleryService.requestGalleryPermission();
      if (!hasPermission) {
        _showErrorDialog('İzin Gerekli', 'Galeri erişimi için izin vermeniz gerekiyor.');
        return;
      }
      
      // Galeri fotoğraflarını al
      List<File> galleryPhotos = await galleryService.getAllPhotos(limit: 500);
      
      if (galleryPhotos.isEmpty) {
        _showErrorDialog('Galeri Boş', 'Galerinizde işlenecek fotoğraf bulunamadı.');
        return;
      }
      
      // Akıllı galeri temizleme workflow'unu başlat
      Map<String, dynamic> result = await aiService.intelligentGalleryCleanup(
        _selectedImage!,
        _nameController.text,
        _emotionalNoteController.text,
        galleryPhotos,
        threshold: 0.6,
        processingMethod: 'smart',
      );
      
      if (result['success']) {
        // Kişiyi oluştur ve kaydet
        PersonModel newPerson = PersonModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text,
          referenceImageUrl: _selectedImage!.path,
          addedAt: DateTime.now(),
          emotionalNote: _emotionalNoteController.text,
          scanResults: result,
        );
        
        await appProvider.addPerson(newPerson);
        
        // Tarama sonuçları sayfasına git
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/scan-results');
        }
      } else {
        _showErrorDialog('Tarama Hatası', 'Galeri taraması başarısız oldu.');
      }
      
    } catch (e) {
      _showErrorDialog('Hata', e.toString());
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tamam'),
          ),
        ],
      ),
    );
  }
} 