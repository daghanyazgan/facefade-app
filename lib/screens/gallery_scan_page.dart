import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io';
import '../providers/app_provider.dart';
import '../widgets/custom_button.dart';
import '../theme/app_colors.dart';

class GalleryScanPage extends StatefulWidget {
  const GalleryScanPage({super.key});

  @override
  State<GalleryScanPage> createState() => _GalleryScanPageState();
}

class _GalleryScanPageState extends State<GalleryScanPage> {
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];
  bool _isSelectionMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _isSelectionMode 
              ? '${_selectedImages.length} Seçili'
              : 'Galeri Tarama',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isSelectionMode) ...[
            IconButton(
              icon: Icon(Icons.select_all, color: AppColors.primary),
              onPressed: _selectAll,
            ),
            IconButton(
              icon: Icon(Icons.clear, color: AppColors.error),
              onPressed: _clearSelection,
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Header Actions
          _buildHeaderActions(),
          
          // Gallery Grid
          Expanded(
            child: _selectedImages.isEmpty 
                ? _buildEmptyState()
                : _buildImageGrid(),
          ),
          
          // Bottom Actions
          if (_selectedImages.isNotEmpty)
            _buildBottomActions(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImages,
        backgroundColor: AppColors.primary,
        child: Icon(Icons.add_photo_alternate, color: Colors.white),
      ),
    );
  }

  Widget _buildHeaderActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Fotoğraflarınızı seçin ve AI ile işleyin',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Kameradan Çek',
                  icon: Icons.camera_alt,
                  onPressed: _takePhoto,
                  outlined: true,
                  backgroundColor: AppColors.primary,
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: CustomButton(
                  text: 'Galeriden Seç',
                  icon: Icons.photo_library,
                  onPressed: _pickImages,
                  backgroundColor: AppColors.primary,
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.photo_library_outlined,
              size: 60,
              color: AppColors.textSecondary,
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          
          const SizedBox(height: 24),
          
          Text(
            'Henüz fotoğraf seçilmedi',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
          
          const SizedBox(height: 8),
          
          Text(
            'Fotoğraf eklemek için + butonuna\nveya üstteki butonlara tıklayın',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 500.ms, duration: 600.ms),
        ],
      ),
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: _selectedImages.length,
      itemBuilder: (context, index) {
        return _buildImageCard(_selectedImages[index], index);
      },
    );
  }

  Widget _buildImageCard(File imageFile, int index) {
    return GestureDetector(
      onTap: () => _showImagePreview(imageFile),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Image
              Container(
                width: double.infinity,
                height: double.infinity,
                child: Image.file(
                  imageFile,
                  fit: BoxFit.cover,
                ),
              ),
              
              // Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
              
              // Remove Button
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _removeImage(index),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
              
              // Index Badge
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 100).ms, duration: 600.ms).scale();
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.info,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_selectedImages.length} fotoğraf seçildi',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Yüz Tespit Et',
                  icon: Icons.face,
                  onPressed: _detectFaces,
                  backgroundColor: AppColors.primary,
                  textColor: Colors.white,
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: CustomButton(
                  text: 'Sanat Filtresi',
                  icon: Icons.palette,
                  onPressed: _applyArtFilter,
                  outlined: true,
                  backgroundColor: AppColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().slideY(begin: 1, duration: 600.ms);
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(
            images.map((xFile) => File(xFile.path)).toList(),
          );
        });
        
        // Update app provider
        Provider.of<AppProvider>(context, listen: false)
            .setSelectedImages(_selectedImages);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fotoğraf seçimi hatası: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
        
        Provider.of<AppProvider>(context, listen: false)
            .setSelectedImages(_selectedImages);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fotoğraf çekimi hatası: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
    
    Provider.of<AppProvider>(context, listen: false)
        .setSelectedImages(_selectedImages);
  }

  void _selectAll() {
    setState(() {
      _isSelectionMode = true;
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedImages.clear();
      _isSelectionMode = false;
    });
    
    Provider.of<AppProvider>(context, listen: false)
        .clearSelectedImages();
  }

  void _showImagePreview(File imageFile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ImagePreviewScreen(imageFile: imageFile),
      ),
    );
  }

  Future<void> _detectFaces() async {
    if (_selectedImages.isEmpty) return;
    
    try {
      // Navigate to face detection processing
      Navigator.pushNamed(
        context,
        '/image-processing',
        arguments: {
          'imageFile': _selectedImages.first,
          'processingType': 'face_detection',
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Yüz tespiti hatası: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _applyArtFilter() async {
    if (_selectedImages.isEmpty) return;
    
    try {
      // Navigate to art filter processing
      Navigator.pushNamed(
        context,
        '/image-processing',
        arguments: {
          'imageFile': _selectedImages.first,
          'processingType': 'art_filter',
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sanat filtresi hatası: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

class _ImagePreviewScreen extends StatelessWidget {
  final File imageFile;
  
  const _ImagePreviewScreen({required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.file(imageFile),
        ),
      ),
    );
  }
} 