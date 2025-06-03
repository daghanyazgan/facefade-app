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
  Map<String, dynamic>? _scanResults;
  Map<String, dynamic>? _intelligentAnalysis;
  bool _isProcessing = false;
  String _selectedProcessingMethod = 'smart';
  String _selectedCeremonyType = 'artistic';
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadResults();
    });
  }

  void _loadResults() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    
    if (appProvider.people.isNotEmpty) {
      _person = appProvider.people.last;
      setState(() {
        _scanResults = _person?.scanResults;
        _intelligentAnalysis = _person?.scanResults?['intelligent_analysis'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_person == null || _scanResults == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Tarama Sonuçları', style: TextStyle(color: AppColors.textPrimary)),
          backgroundColor: AppColors.surface,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 80, color: AppColors.textSecondary),
              SizedBox(height: 16),
              Text(
                'Tarama sonuçları bulunamadı',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final totalMatches = _scanResults?['total_matches_found'] ?? 0;
    final intelligentResults = _intelligentAnalysis as List<dynamic>? ?? [];
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('📊 Akıllı Analiz Sonuçları', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: AppColors.primary),
            onPressed: () => _showHelpDialog(),
          ),
        ],
      ),
      body: _isProcessing ? _buildProcessingView() : _buildResultsView(),
    );
  }

  Widget _buildProcessingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              strokeWidth: 6,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Akıllı işleme devam ediyor...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'AI anılarınızı dönüştürüyor 🎨',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView() {
    final intelligentResults = _intelligentAnalysis as List<dynamic>? ?? [];
    final totalMatches = _scanResults?['total_matches_found'] ?? 0;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPersonCard(),
          SizedBox(height: 20),
          _buildIntelligentSummaryCard(intelligentResults),
          SizedBox(height: 20),
          if (intelligentResults.isNotEmpty) ...[
            _buildProcessingMethodSelector(),
            SizedBox(height: 20),
            if (_selectedProcessingMethod == 'closure_ceremony') 
              _buildCeremonyTypeSelector(),
            SizedBox(height: 20),
            _buildSmartProcessingCard(intelligentResults),
            SizedBox(height: 20),
          ],
          _buildActionButtons(intelligentResults),
        ],
      ).animate().fadeIn(duration: 600.ms),
    );
  }

  Widget _buildPersonCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.1), AppColors.secondary.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.person_search, color: AppColors.primary, size: 24),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _person!.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (_person!.emotionalNote.isNotEmpty)
                      Text(
                        _person!.emotionalNote,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.psychology, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Dijital temizlik sürecinde. Her adım iyileşme yolculuğunun bir parçası. 💙',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntelligentSummaryCard(List<dynamic> intelligentResults) {
    int deletablePhotos = 0;
    int inpaintablePhotos = 0;
    
    for (var result in intelligentResults) {
      if (result['smart_suggestion'] == 'delete_photo') {
        deletablePhotos++;
      } else {
        inpaintablePhotos++;
      }
    }
    
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology, color: AppColors.primary, size: 24),
              SizedBox(width: 8),
              Text(
                'Akıllı Analiz Sonuçları',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Toplam Eşleşme',
                  '${intelligentResults.length}',
                  Icons.photo_library,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Silinecek',
                  '$deletablePhotos',
                  Icons.delete_forever,
                  Colors.red,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'AI Düzenlenecek',
                  '$inpaintablePhotos',
                  Icons.auto_fix_high,
                  Colors.green,
                ),
              ),
            ],
          ),
          
          if (intelligentResults.isNotEmpty) ...[
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      deletablePhotos > 0 
                        ? 'AI, $deletablePhotos fotoğrafı tamamen silmeyi, $inpaintablePhotos fotoğrafı ise akıllıca düzenlemeyi öneriyor.'
                        : 'Tüm fotoğraflar akıllı AI teknolojisiyle düzenlenecek.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingMethodSelector() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'İşleme Yöntemini Seçin',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          
          _buildMethodOption(
            'smart',
            '🤖 Akıllı İşleme',
            'AI en iyi yöntemi seçer: tek kişi = sil, çok kişi = düzenle',
            Colors.blue,
          ),
          SizedBox(height: 12),
          _buildMethodOption(
            'closure_ceremony',
            '🎨 Kapanış Seremonisi',
            'Anıları sanat eserine dönüştürerek duygusal iyileşme',
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildMethodOption(String value, String title, String description, Color color) {
    bool isSelected = _selectedProcessingMethod == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedProcessingMethod = value;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
                color: isSelected ? color : Colors.transparent,
              ),
              child: isSelected 
                ? Icon(Icons.check, color: Colors.white, size: 14)
                : null,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCeremonyTypeSelector() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kapanış Seremonisi Türü',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(child: _buildCeremonyOption('artistic', '🎨 Sanatsal', Colors.red)),
              SizedBox(width: 8),
              Expanded(child: _buildCeremonyOption('dreamy', '☁️ Rüya Gibi', Colors.blue)),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildCeremonyOption('abstract', '🎭 Soyut', Colors.orange)),
              SizedBox(width: 8),
              Expanded(child: _buildCeremonyOption('healing', '💚 İyileştirici', Colors.green)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCeremonyOption(String value, String title, Color color) {
    bool isSelected = _selectedCeremonyType == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCeremonyType = value;
        });
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 20)
            else
              Icon(Icons.radio_button_unchecked, color: Colors.grey, size: 20),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartProcessingCard(List<dynamic> intelligentResults) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Akıllı İşleme Planı',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          
          ...intelligentResults.take(3).map((result) {
            String action = result['smart_suggestion'] == 'delete_photo' ? 'Sil' : 'Düzenle';
            Color actionColor = result['smart_suggestion'] == 'delete_photo' ? Colors.red : Colors.green;
            IconData actionIcon = result['smart_suggestion'] == 'delete_photo' ? Icons.delete_forever : Icons.auto_fix_high;
            
            return Container(
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: actionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(actionIcon, color: actionColor, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Fotoğraf ${result['image_index'] + 1}: $action (${result['total_people']} kişi)',
                      style: TextStyle(
                        fontSize: 14,
                        color: actionColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          
          if (intelligentResults.length > 3) ...[
            SizedBox(height: 8),
            Text(
              '... ve ${intelligentResults.length - 3} fotoğraf daha',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(List<dynamic> intelligentResults) {
    return Column(
      children: [
        CustomButton(
          text: _selectedProcessingMethod == 'smart' 
            ? '🤖 Akıllı İşlemeyi Başlat'
            : '🎨 Kapanış Seremonisini Başlat',
          onPressed: intelligentResults.isNotEmpty ? () => _startIntelligentProcessing(intelligentResults) : null,
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
          ),
        ),
        SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Geri Dön',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Future<void> _startIntelligentProcessing(List<dynamic> intelligentResults) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final aiService = AiService();
      Map<String, dynamic> processingParams = {};
      
      if (_selectedProcessingMethod == 'closure_ceremony') {
        processingParams = {
          'person_name': _person!.name,
          'ceremony_type': _selectedCeremonyType,
          'art_style': 'van_gogh',
        };
      }

      Map<String, dynamic> result = await aiService.batchIntelligentProcessing(
        intelligentResults.cast<Map<String, dynamic>>(),
        _selectedProcessingMethod,
        parameters: processingParams,
      );

      if (result['success']) {
        // Sonuçları provider'a kaydet
        final appProvider = Provider.of<AppProvider>(context, listen: false);
        await appProvider.saveProcessingResults(_person!, result);

        // Processing complete sayfasına yönlendir
        Navigator.pushReplacementNamed(
          context,
          '/processing-complete',
          arguments: {
            'person': _person,
            'results': result,
            'processing_method': _selectedProcessingMethod,
          },
        );
      }
    } catch (e) {
      _showErrorDialog('İşleme Hatası', e.toString());
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Akıllı İşleme Nasıl Çalışır?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🤖 Akıllı İşleme:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• Tek kişi = Fotoğraf tamamen silinir'),
            Text('• Birden fazla kişi = AI ile kişi çıkarılır'),
            SizedBox(height: 12),
            Text('🎨 Kapanış Seremonisi:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• Anılar sanat eserine dönüştürülür'),
            Text('• Duygusal iyileşme sağlanır'),
            Text('• Acı veren anılar güzel tablolara dönüşür'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Anladım'),
          ),
        ],
      ),
    );
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