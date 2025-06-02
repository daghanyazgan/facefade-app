import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_provider.dart';
import '../widgets/custom_button.dart';
import '../theme/app_colors.dart';
import '../models/person_model.dart';

class ProcessingCompletePage extends StatefulWidget {
  const ProcessingCompletePage({super.key});

  @override
  State<ProcessingCompletePage> createState() => _ProcessingCompletePageState();
}

class _ProcessingCompletePageState extends State<ProcessingCompletePage> {
  PersonModel? _person;
  String _processingType = '';
  int _totalProcessed = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          _person = args['person'] as PersonModel;
          _processingType = args['processing_type'] as String;
          _totalProcessed = args['total_processed'] as int;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              
              _buildSuccessAnimation(),
              
              const SizedBox(height: 40),
              
              _buildSuccessMessage(),
              
              const SizedBox(height: 32),
              
              _buildStatsCard(),
              
              const SizedBox(height: 32),
              
              _buildEmotionalMessage(),
              
              const Spacer(),
              
              _buildActionButtons(),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessAnimation() {
    return Container(
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
      child: const Icon(
        Icons.check,
        size: 60,
        color: Colors.white,
      ),
    ).animate()
        .scale(duration: 800.ms, curve: Curves.elasticOut)
        .then()
        .shimmer(duration: 2.seconds);
  }

  Widget _buildSuccessMessage() {
    String title = '';
    String subtitle = '';
    
    switch (_processingType) {
      case 'blur':
        title = 'Yüzler Bulanıklaştırıldı ✨';
        subtitle = 'Artık o kişiyi görmezden gelebilirsin';
        break;
      case 'avatar':
        title = 'Avatar ile Değiştirildi 🎭';
        subtitle = 'Anıların artık daha güvenli hissettiriyor';
        break;
      case 'ceremony':
        title = 'Kapanış Seremonin Tamamlandı 🎨';
        subtitle = 'Anıların sanat eserine dönüştü, iyileşme başladı';
        break;
      default:
        title = 'İşlem Tamamlandı ✅';
        subtitle = 'Dijital temizliğin başarıyla gerçekleştirildi';
    }

    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
        
        const SizedBox(height: 12),
        
        Text(
          subtitle,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 500.ms, duration: 600.ms),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('📸', '$_totalProcessed', 'İşlenmiş Fotoğraf'),
              _buildStatItem('👤', '1', 'Temizlenen Kişi'),
              _buildStatItem('💙', '100%', 'İyileşme Başladı'),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Text(
            '${_person?.name ?? "Kişi"} artık galerinde görünmeyecek',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().slideY(delay: 700.ms, duration: 600.ms, begin: 0.3);
  }

  Widget _buildStatItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmotionalMessage() {
    List<String> messages = [
      "İyileşme yolculuğun başladı. Her adım seni daha güçlü kılacak. 💪",
      "Geçmiş artık geçmişte kaldı. Geleceğin seni bekliyor. ✨",
      "Dijital anıların artık temiz. Kalbinde yer açtın. 💙",
      "Bu cesaret gösterdiğin için kendini kutla. 🎉",
      "Artık o anılar seni üzmeyecek. Huzur bulacaksın. 🕊️",
    ];
    
    String selectedMessage = messages[DateTime.now().millisecond % messages.length];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            '💝',
            style: const TextStyle(fontSize: 40),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            selectedMessage,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 900.ms, duration: 600.ms);
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        CustomButton(
          text: 'İşlenmiş Fotoğrafları Gör',
          icon: Icons.photo_library,
          onPressed: () => _viewProcessedPhotos(),
          backgroundColor: AppColors.primary,
          textColor: Colors.white,
        ).animate().slideY(delay: 1100.ms, duration: 600.ms, begin: 0.3),
        
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
        ).animate().slideY(delay: 1200.ms, duration: 600.ms, begin: 0.3),
        
        const SizedBox(height: 12),
        
        TextButton(
          onPressed: () => _shareExperience(),
          child: Text(
            'Deneyimini Paylaş 📢',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 14,
            ),
          ),
        ).animate().fadeIn(delay: 1400.ms, duration: 600.ms),
      ],
    );
  }

  void _viewProcessedPhotos() {
    // TODO: İşlenmiş fotoğrafları göster
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('İşlenmiş fotoğraflar galeri sayfasında görüntülenecek'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _shareExperience() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Deneyimini Paylaş',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'FaceFade ile dijital temizlik deneyimini sosyal medyada paylaşmak ister misin?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hayır', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Share functionality
            },
            child: Text('Evet', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
} 