import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_provider.dart';
import '../widgets/custom_button.dart';
import '../theme/app_colors.dart';

class IdentifyPersonPage extends StatefulWidget {
  const IdentifyPersonPage({super.key});

  @override
  State<IdentifyPersonPage> createState() => _IdentifyPersonPageState();
}

class _IdentifyPersonPageState extends State<IdentifyPersonPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Yüz Tanıma',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_a_photo, color: AppColors.primary),
            onPressed: _addNewPerson,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(),
          
          // Detected Faces
          Expanded(
            child: Consumer<AppProvider>(
              builder: (context, appProvider, child) {
                final faces = appProvider.detectedFaces
                    .where((face) => face.name.toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                    .toList();
                
                if (faces.isEmpty) {
                  return _buildEmptyState();
                }
                
                return _buildFacesList(faces);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        style: TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Kişi ara...',
          hintStyle: TextStyle(color: AppColors.textSecondary),
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: AppColors.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
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
              Icons.face_outlined,
              size: 60,
              color: AppColors.textSecondary,
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          
          const SizedBox(height: 24),
          
          Text(
            _searchQuery.isNotEmpty 
                ? 'Arama sonucu bulunamadı'
                : 'Henüz tanımlı kişi yok',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
          
          const SizedBox(height: 8),
          
          Text(
            _searchQuery.isNotEmpty
                ? 'Farklı bir arama terimi deneyin'
                : 'Yeni kişi eklemek için + butonuna tıklayın',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 500.ms, duration: 600.ms),
          
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 32),
            
            CustomButton(
              text: 'Yeni Kişi Ekle',
              icon: Icons.person_add,
              onPressed: _addNewPerson,
              backgroundColor: AppColors.primary,
              textColor: Colors.white,
            ).animate().fadeIn(delay: 700.ms, duration: 600.ms).slideY(begin: 0.3),
          ],
        ],
      ),
    );
  }

  Widget _buildFacesList(List faces) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: faces.length,
      itemBuilder: (context, index) {
        final face = faces[index];
        return _buildPersonCard(face, index);
      },
    );
  }

  Widget _buildPersonCard(dynamic face, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.person,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Person Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  face.name ?? 'Bilinmeyen Kişi',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  '${face.faceCoordinates.length} fotoğrafta görüldü',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    _buildInfoChip(
                      icon: Icons.visibility,
                      label: '${(face.confidence * 100).toInt()}%',
                      color: AppColors.success,
                    ),
                    
                    const SizedBox(width: 8),
                    
                    _buildInfoChip(
                      icon: Icons.access_time,
                      label: _formatDate(face.createdAt),
                      color: AppColors.info,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Actions
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: AppColors.textSecondary,
            ),
            onSelected: (value) => _handlePersonAction(value, face),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'view',
                child: Row(
                  children: [
                    Icon(Icons.visibility, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text('Fotoğrafları Gör'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Text('Düzenle'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: AppColors.error),
                    const SizedBox(width: 8),
                    Text('Sil'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate()
        .fadeIn(delay: (index * 100).ms, duration: 600.ms)
        .slideX(begin: 0.3);
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 7) {
      return '${date.day}/${date.month}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}g';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}s';
    } else {
      return 'Şimdi';
    }
  }

  void _addNewPerson() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _AddPersonBottomSheet(),
    );
  }

  void _handlePersonAction(String action, dynamic face) {
    switch (action) {
      case 'view':
        _viewPersonPhotos(face);
        break;
      case 'edit':
        _editPerson(face);
        break;
      case 'delete':
        _deletePerson(face);
        break;
    }
  }

  void _viewPersonPhotos(dynamic face) {
    Navigator.pushNamed(
      context,
      '/person-photos',
      arguments: {'face': face},
    );
  }

  void _editPerson(dynamic face) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _EditPersonBottomSheet(face: face),
    );
  }

  void _deletePerson(dynamic face) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Kişiyi Sil',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          '${face.name} kişisini silmek istediğinizden emin misiniz?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AppProvider>(context, listen: false)
                  .removeDetectedFace(face);
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${face.name} silindi'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text(
              'Sil',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddPersonBottomSheet extends StatefulWidget {
  @override
  State<_AddPersonBottomSheet> createState() => _AddPersonBottomSheetState();
}

class _AddPersonBottomSheetState extends State<_AddPersonBottomSheet> {
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(height: 20),
          
          Text(
            'Yeni Kişi Ekle',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 20),
          
          TextField(
            controller: _nameController,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Kişi Adı',
              hintText: 'Örn: Ahmet Yılmaz',
              prefixIcon: Icon(Icons.person, color: AppColors.primary),
            ),
          ),
          
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'İptal',
                  onPressed: () => Navigator.pop(context),
                  outlined: true,
                  backgroundColor: AppColors.textSecondary,
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: CustomButton(
                  text: 'Ekle',
                  onPressed: _isLoading ? null : _addPerson,
                  isLoading: _isLoading,
                  backgroundColor: AppColors.primary,
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _addPerson() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lütfen bir isim girin'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Burada gerçek kişi ekleme işlemi yapılacak
      await Future.delayed(Duration(seconds: 1)); // Simülasyon
      
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_nameController.text} eklendi'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

class _EditPersonBottomSheet extends StatefulWidget {
  final dynamic face;
  
  const _EditPersonBottomSheet({required this.face});

  @override
  State<_EditPersonBottomSheet> createState() => _EditPersonBottomSheetState();
}

class _EditPersonBottomSheetState extends State<_EditPersonBottomSheet> {
  late TextEditingController _nameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.face.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(height: 20),
          
          Text(
            'Kişiyi Düzenle',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 20),
          
          TextField(
            controller: _nameController,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Kişi Adı',
              prefixIcon: Icon(Icons.person, color: AppColors.primary),
            ),
          ),
          
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'İptal',
                  onPressed: () => Navigator.pop(context),
                  outlined: true,
                  backgroundColor: AppColors.textSecondary,
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: CustomButton(
                  text: 'Güncelle',
                  onPressed: _isLoading ? null : _updatePerson,
                  isLoading: _isLoading,
                  backgroundColor: AppColors.primary,
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _updatePerson() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lütfen bir isim girin'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Burada gerçek güncelleme işlemi yapılacak
      await Future.delayed(Duration(seconds: 1)); // Simülasyon
      
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_nameController.text} güncellendi'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
} 