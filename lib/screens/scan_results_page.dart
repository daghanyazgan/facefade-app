import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_provider.dart';
import '../widgets/custom_button.dart';
import '../theme/app_colors.dart';
import '../models/person_model.dart';
import '../services/ai_service.dart';
import 'dart:io';

class ScanResultsPage extends StatefulWidget {
  const ScanResultsPage({super.key});

  @override
  State<ScanResultsPage> createState() => _ScanResultsPageState();
}

class _ScanResultsPageState extends State<ScanResultsPage> {
  PersonModel? _person;
  Map<String, dynamic>? _scanResult;
  List<String> _processingOptions = [];
  String _selectedProcessingType = '';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          _person = args['person'] as PersonModel;
          _scanResult = args['scan_result'] as Map<String, dynamic>;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_person == null || _scanResult == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final scanData = _scanResult!['scan_result'] as Map<String, dynamic>;
    final totalMatches = scanData['total_matches_found'] as int;
    final imagesWithMatches = scanData['images_with_matches'] as int;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Tarama Sonuçları',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context, 
            '/home', 
            (route) => false,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildResultsHeader(totalMatches, imagesWithMatches),
            const SizedBox(height: 32),
            _buildPersonInfo(),
            const SizedBox(height: 32),
            if (totalMatches > 0) ...[
              _buildProcessingOptions(),
              const SizedBox(height: 32),
              _buildActionButtons(),
            ] else ...[
              _buildNoMatchesFound(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultsHeader(int totalMatches, int imagesWithMatches) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: totalMatches > 0 
              ? [AppColors.primary.withOpacity(0.1), AppColors.primary.withOpacity(0.05)]
              : [Colors.grey.withOpacity(0.1), Colors.grey.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: totalMatches > 0 ? AppColors.primary.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            totalMatches > 0 ? '🎯' : '🔍',
            style: const TextStyle(fontSize: 60),
          ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
          
          const SizedBox(height: 16),
          
          Text(
            totalMatches > 0 ? 'Kişi Bulundu!' : 'Kişi Bulunamadı',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
          
          const SizedBox(height: 8),
          
          if (totalMatches > 0) ...[
            Text(
              '$imagesWithMatches fotoğrafta $totalMatches yüz tespit edildi',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            Text(
              '${_person!.name} isimli kişi galerinde bulunamadı',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    ).animate().slideY(duration: 600.ms, begin: 0.3);
  }

  Widget _buildPersonInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Kişi fotoğrafı
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: ClipOval(
              child: Image.file(
                File(_person!.referenceImageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Kişi bilgisi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _person!.name,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                if (_person!.emotionalNote.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _person!.emotionalNote,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                const SizedBox(height: 8),
                
                Text(
                  'Eklendi: ${_formatDate(_person!.addedAt)}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 600.ms);
  }

  Widget _buildProcessingOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bu Anılarla Ne Yapmak İstiyorsun?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(delay: 600.ms, duration: 600.ms),
        
        const SizedBox(height: 16),
        
        Text(
          'Duygusal iyileşme için en uygun seçeneği belirle:',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ).animate().fadeIn(delay: 700.ms, duration: 600.ms),
        
        const SizedBox(height: 24),
        
        _buildProcessingOptionCard(
          '🌫️',
          'Yüzleri Bulanıklaştır',
          'Kişiyi görmezden gel, ama anıyı koru',
          'Hafif bir mesafe koy',
          'blur',
        ).animate().slideX(delay: 800.ms, duration: 600.ms, begin: -0.3),
        
        const SizedBox(height: 16),
        
        _buildProcessingOptionCard(
          '🎭',
          'Avatar ile Değiştir',
          'Kişiyi tamamen sil, yerine avatar koy',
          'Daha güçlü bir değişim',
          'avatar',
        ).animate().slideX(delay: 900.ms, duration: 600.ms, begin: -0.3),
        
        const SizedBox(height: 16),
        
        _buildProcessingOptionCard(
          '🎨',
          'Kapanış Seremonisi',
          'Tüm anıları sanat eserine dönüştür',
          'Tam iyileşme ve kapanış',
          'ceremony',
        ).animate().slideX(delay: 1000.ms, duration: 600.ms, begin: -0.3),
      ],
    );
  }

  Widget _buildProcessingOptionCard(
    String emoji,
    String title,
    String description,
    String subtitle,
    String value,
  ) {
    bool isSelected = _selectedProcessingType == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedProcessingType = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 32),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    description,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        CustomButton(
          text: _isProcessing ? 'İşleniyor...' : 'İşlemi Başlat',
          icon: _isProcessing ? Icons.hourglass_empty : Icons.auto_fix_high,
          onPressed: _selectedProcessingType.isNotEmpty && !_isProcessing
              ? _startProcessing
              : null,
          backgroundColor: AppColors.primary,
          textColor: Colors.white,
        ).animate().slideY(delay: 1200.ms, duration: 600.ms, begin: 0.3),
        
        const SizedBox(height: 16),
        
        CustomButton(
          text: 'Daha Sonra Karar Ver',
          icon: Icons.schedule,
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context, 
            '/home', 
            (route) => false,
          ),
          backgroundColor: AppColors.surface,
          textColor: AppColors.textPrimary,
        ).animate().slideY(delay: 1300.ms, duration: 600.ms, begin: 0.3),
      ],
    );
  }

  Widget _buildNoMatchesFound() {
    return Column(
      children: [
        const SizedBox(height: 40),
        
        Text(
          '💭',
          style: const TextStyle(fontSize: 80),
        ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
        
        const SizedBox(height: 24),
        
        Text(
          'Belki Bu İyi Bir Haber',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
        
        const SizedBox(height: 16),
        
        Text(
          'Bu kişiyle ilgili dijital anın galerin de zaten temiz. Ya da farklı bir fotoğraf deneyebilirsin.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 500.ms, duration: 600.ms),
        
        const SizedBox(height: 40),
        
        CustomButton(
          text: 'Farklı Fotoğraf Dene',
          icon: Icons.refresh,
          onPressed: () => Navigator.pop(context),
          backgroundColor: AppColors.primary,
          textColor: Colors.white,
        ).animate().slideY(delay: 700.ms, duration: 600.ms, begin: 0.3),
        
        const SizedBox(height: 16),
        
        CustomButton(
          text: 'Ana Sayfaya Dön',
          icon: Icons.home,
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context, 
            '/home', 
            (route) => false,
          ),
          backgroundColor: AppColors.surface,
          textColor: AppColors.textPrimary,
        ).animate().slideY(delay: 800.ms, duration: 600.ms, begin: 0.3),
      ],
    );
  }

  Future<void> _startProcessing() async {
    if (_selectedProcessingType.isEmpty) return;
    
    setState(() {
      _isProcessing = true;
    });

    try {
      // Burada gerçek işleme mantığı olacak
      // Şimdilik mock delay
      await Future.delayed(const Duration(seconds: 3));
      
      // İşlem tamamlandı sayfasına git
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/processing-complete',
          arguments: {
            'person': _person,
            'processing_type': _selectedProcessingType,
            'total_processed': _scanResult!['scan_result']['images_with_matches'],
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('İşlem hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() {
      _isProcessing = false;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 