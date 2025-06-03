import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../models/person_model.dart';
import '../widgets/custom_button.dart';
import 'dart:convert';
import 'dart:typed_data';

class ProcessingCompletePage extends StatefulWidget {
  const ProcessingCompletePage({super.key});

  @override
  State<ProcessingCompletePage> createState() => _ProcessingCompletePageState();
}

class _ProcessingCompletePageState extends State<ProcessingCompletePage> {
  PersonModel? _person;
  Map<String, dynamic>? _results;
  String? _processingMethod;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      _person = arguments['person'] as PersonModel?;
      _results = arguments['results'] as Map<String, dynamic>?;
      _processingMethod = arguments['processing_method'] as String?;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_person == null || _results == null) {
      return Scaffold(
        body: Center(
          child: Text('Hata: Sonuç verileri bulunamadı'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 40),
                      _buildSuccessHeader(),
                      SizedBox(height: 40),
                      _buildResultsCard(),
                      SizedBox(height: 30),
                      _buildEmotionalMessage(),
                      SizedBox(height: 30),
                      if (_processingMethod == 'closure_ceremony')
                        _buildCeremonyResults(),
                    ],
                  ),
                ),
              ),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessHeader() {
    String emoji = _processingMethod == 'closure_ceremony' ? '🎨' : '✨';
    String title = _processingMethod == 'closure_ceremony' 
        ? 'Kapanış Seremonin Tamamlandı' 
        : 'Akıllı İşleme Tamamlandı';
    
    return Column(
      children: [
        Text(
          emoji,
          style: TextStyle(fontSize: 80),
        ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
        
        SizedBox(height: 20),
        
        Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
        
        SizedBox(height: 12),
        
        Text(
          '${_person!.name} ile ilgili dijital temizlik başarıyla tamamlandı.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 500.ms, duration: 600.ms),
      ],
    );
  }

  Widget _buildResultsCard() {
    int totalProcessed = _results!['total_processed'] ?? 0;
    int deletedPhotos = _results!['deleted_photos'] ?? 0;
    int inpaintedPhotos = _results!['inpainted_photos'] ?? 0;
    int ceremonyPhotos = _results!['ceremony_photos'] ?? 0;
    
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: AppColors.primary, size: 24),
              SizedBox(width: 8),
              Text(
                'İşlem Sonuçları',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Toplam İşlenen',
                  '$totalProcessed',
                  Icons.photo_library,
                  Colors.blue,
                ),
              ),
              if (deletedPhotos > 0) ...[
                SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    'Silinen',
                    '$deletedPhotos',
                    Icons.delete_forever,
                    Colors.red,
                  ),
                ),
              ],
            ],
          ),
          
          if (inpaintedPhotos > 0 || ceremonyPhotos > 0) ...[
            SizedBox(height: 16),
            Row(
              children: [
                if (inpaintedPhotos > 0) ...[
                  Expanded(
                    child: _buildStatItem(
                      'AI Düzenlenen',
                      '$inpaintedPhotos',
                      Icons.auto_fix_high,
                      Colors.green,
                    ),
                  ),
                ],
                if (ceremonyPhotos > 0) ...[
                  if (inpaintedPhotos > 0) SizedBox(width: 16),
                  Expanded(
                    child: _buildStatItem(
                      'Sanat Eseri',
                      '$ceremonyPhotos',
                      Icons.palette,
                      Colors.purple,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    ).animate().slideY(delay: 700.ms, duration: 600.ms, begin: 0.3);
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionalMessage() {
    String message;
    Color messageColor;
    IconData messageIcon;
    
    if (_processingMethod == 'closure_ceremony') {
      message = 'Anıların güzel birer sanat eserine dönüştü. Acıları geride bırakma zamanı. Sen bu adımı attığın için güçlüsün. 💙';
      messageColor = Colors.purple;
      messageIcon = Icons.palette;
    } else {
      message = 'Geçmişte seni üzen anılar artık galerinde yok. İleriye bakma zamanı. Her yeni gün bir fırsat. 🌟';
      messageColor = Colors.blue;
      messageIcon = Icons.psychology;
    }
    
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            messageColor.withOpacity(0.1),
            messageColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: messageColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(messageIcon, color: messageColor, size: 32),
          SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: messageColor,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 900.ms, duration: 800.ms);
  }

  Widget _buildCeremonyResults() {
    List<dynamic> processedImages = _results!['results'] ?? [];
    
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎨 Dönüştürülen Anılar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          
          Container(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: processedImages.length.clamp(0, 5),
              itemBuilder: (context, index) {
                try {
                  String? processedImageBase64 = processedImages[index]['processed_image'];
                  if (processedImageBase64 != null) {
                    Uint8List imageBytes = base64Decode(processedImageBase64);
                    return Container(
                      margin: EdgeInsets.only(right: 12),
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple.withOpacity(0.3)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          imageBytes,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  // Base64 decode error
                }
                
                return Container(
                  margin: EdgeInsets.only(right: 12),
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.image, color: Colors.purple),
                );
              },
            ),
          ),
          
          SizedBox(height: 12),
          Text(
            'Anıların sanat eserine dönüştürüldü. Artık bunlar acı veren fotoğraflar değil, güzel tablolar.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    ).animate().slideX(delay: 1100.ms, duration: 600.ms, begin: 0.3);
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        CustomButton(
          text: '🏠 Ana Sayfaya Dön',
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context, 
            '/', 
            (route) => false,
          ),
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
          ),
        ),
        
        SizedBox(height: 12),
        
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/add-person'),
          child: Text(
            'Başka Birini Ekle',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ),
      ],
    ).animate().slideY(delay: 1300.ms, duration: 600.ms, begin: 0.3);
  }
} 