import 'package:flutter/material.dart';
import '../models/face_data_model.dart';
import '../theme/app_colors.dart';

class PersonPhotosPage extends StatelessWidget {
  final FaceDataModel face;
  
  const PersonPhotosPage({
    super.key,
    required this.face,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Kişi Fotoğrafları',
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
              '👤',
              style: const TextStyle(fontSize: 80),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'Kişi Fotoğrafları',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Bu özellik yakında eklenecek...',
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