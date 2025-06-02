import 'package:flutter/material.dart';
import 'dart:io';
import '../theme/app_colors.dart';

class ImageProcessingPage extends StatelessWidget {
  final File imageFile;
  final String processingType;
  
  const ImageProcessingPage({
    super.key,
    required this.imageFile,
    required this.processingType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Görsel İşleme',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '🔄',
              style: const TextStyle(fontSize: 80),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'Görsel İşleniyor...',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'İşlem türü: $processingType',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 