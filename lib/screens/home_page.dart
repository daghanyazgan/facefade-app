import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../providers/app_provider.dart';
import '../widgets/custom_button.dart';
import '../theme/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              
              const SizedBox(height: 32),
              
              // Quick Actions
              _buildQuickActions(),
              
              const SizedBox(height: 32),
              
              // Stats Cards
              _buildStatsCards(),
              
              const SizedBox(height: 32),
              
              // Recent Activity
              _buildRecentActivity(),
              
              const SizedBox(height: 32),
              
              // Features Showcase
              _buildFeaturesShowcase(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.userModel;
        return Container(
          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
          child: Row(
            children: [
              // Profile Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                            color: Colors.white,
                  size: 30,
                          ),
                        ),
              
              const SizedBox(width: 16),
              
              // Welcome Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                        Text(
                      'Hoş geldiniz,',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                          ),
                        ),
                    const SizedBox(height: 4),
                        Text(
                      user?.displayName ?? 'Kullanıcı',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                        ),
                      ],
                    ),
              ),
              
              // Notification Bell
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3);
      },
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı İşlemler',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                            
                            const SizedBox(height: 16),
                            
        Row(
          children: [
                            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.photo_library,
                title: 'Galeri Tara',
                subtitle: 'Fotoğrafları işle',
                onTap: () => Navigator.pushNamed(context, '/gallery'),
              ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideX(begin: -0.3),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.camera_alt,
                title: 'Fotoğraf Çek',
                subtitle: 'Yeni resim ekle',
                onTap: () => _openCamera(),
              ).animate().fadeIn(delay: 600.ms, duration: 600.ms).slideX(begin: 0.3),
                                ),
          ],
                            ),
                            
                            const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.face,
                title: 'Yüz Tanıma',
                subtitle: 'Kişileri belirle',
                onTap: () => Navigator.pushNamed(context, '/identify'),
              ).animate().fadeIn(delay: 800.ms, duration: 600.ms).slideX(begin: -0.3),
            ),
            
            const SizedBox(width: 16),
                            
                            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.history,
                title: 'Geçmiş',
                subtitle: 'İşlem tarihçesi',
                onTap: () => Navigator.pushNamed(context, '/processing-history'),
              ).animate().fadeIn(delay: 1000.ms, duration: 600.ms).slideX(begin: 0.3),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
                                  ),
            
            const SizedBox(height: 12),
            
            Text(
              title,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 4),
            
            Text(
              subtitle,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                              ),
              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
  }

  Widget _buildStatsCards() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'İstatistikler',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                ),
            ).animate().fadeIn(delay: 1200.ms, duration: 600.ms),
              
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.photo,
                    value: '${appProvider.totalProcessedImages}',
                    label: 'İşlenmiş Fotoğraf',
                    color: AppColors.primary,
                  ).animate().fadeIn(delay: 1400.ms, duration: 600.ms).slideY(begin: 0.3),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.face,
                    value: '${appProvider.totalDetectedFaces}',
                    label: 'Tespit Edilen Yüz',
                    color: AppColors.secondary,
                  ).animate().fadeIn(delay: 1600.ms, duration: 600.ms).slideY(begin: 0.3),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
                  border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
                  ),
                ),
      child: Column(
                  children: [
                    Icon(
            icon,
            color: color,
            size: 32,
                    ),
          
          const SizedBox(height: 12),
          
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
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
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Son Aktiviteler',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                        ),
                      ),
            
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/processing-history'),
              child: Text(
                'Tümünü Gör',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                ),
                ),
              ),
            ],
        ).animate().fadeIn(delay: 1800.ms, duration: 600.ms),
        
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              'Henüz aktivite yok',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
          ),
        ),
      ),
        ).animate().fadeIn(delay: 2000.ms, duration: 600.ms),
      ],
    );
  }

  Widget _buildFeaturesShowcase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Özellikler',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(delay: 2200.ms, duration: 600.ms),
        
        const SizedBox(height: 16),
        
        _buildFeatureCard(
          icon: Icons.face_retouching_natural,
          title: 'AI Yüz Tespiti',
          description: 'Gelişmiş yapay zeka ile yüzleri otomatik tespit eder',
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
          ),
        ).animate().fadeIn(delay: 2400.ms, duration: 600.ms).slideX(begin: -0.3),
        
        const SizedBox(height: 12),
        
        _buildFeatureCard(
          icon: Icons.palette,
          title: 'Sanatsal Filtreler',
          description: 'Van Gogh, Picasso gibi ünlü sanatçı stillerini uygula',
          gradient: LinearGradient(
            colors: [AppColors.accent, AppColors.secondary],
          ),
        ).animate().fadeIn(delay: 2600.ms, duration: 600.ms).slideX(begin: 0.3),
        
        const SizedBox(height: 12),
        
        _buildFeatureCard(
          icon: Icons.share,
          title: 'Kolay Paylaşım',
          description: 'Instagram, TikTok ve diğer sosyal medyada paylaş',
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.accent],
          ),
        ).animate().fadeIn(delay: 2800.ms, duration: 600.ms).slideX(begin: -0.3),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openCamera() {
    // Camera açma functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kamera özelliği yakında eklenecek!'),
        backgroundColor: AppColors.info,
      ),
    );
  }
} 