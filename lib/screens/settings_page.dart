import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../providers/app_provider.dart';
import '../widgets/custom_button.dart';
import '../theme/app_colors.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Ayarlar',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
        children: [
            // User Profile Section
            _buildUserProfile(),
            
            const SizedBox(height: 32),
            
            // App Settings
            _buildAppSettings(),
            
            const SizedBox(height: 32),
            
            // Processing Settings
            _buildProcessingSettings(),
            
            const SizedBox(height: 32),
            
            // Account Settings
            _buildAccountSettings(),
            
            const SizedBox(height: 32),
            
            // About Section
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.userModel;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              // Profile Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Text(
                user?.displayName ?? 'Kullanıcı',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 4),
              
              Text(
                user?.email ?? '',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildProfileStat(
                    icon: Icons.photo,
                    label: 'İşlenmiş',
                    value: '${user?.processedImagesCount ?? 0}',
                  ),
                  _buildProfileStat(
                    icon: Icons.face,
                    label: 'Yüz',
                    value: '${user?.faceCount ?? 0}',
                  ),
                  _buildProfileStat(
                    icon: Icons.access_time,
                    label: 'Üyelik',
                    value: _getMembershipDuration(user?.createdAt),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3);
      },
    );
  }

  Widget _buildProfileStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAppSettings() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return _buildSection(
          title: 'Uygulama Ayarları',
          icon: Icons.settings,
          children: [
            _buildSwitchTile(
              title: 'Karanlık Tema',
              subtitle: 'Koyu renk temasını kullan',
              value: appProvider.isDarkMode,
              onChanged: (value) => appProvider.toggleDarkMode(),
              icon: Icons.dark_mode,
            ),
            
            _buildTile(
              title: 'Dil',
              subtitle: 'Türkçe',
              icon: Icons.language,
              onTap: () => _showLanguageDialog(),
            ),
            
            _buildSwitchTile(
              title: 'Otomatik Kaydetme',
              subtitle: 'İşlenmiş resimleri otomatik kaydet',
              value: appProvider.autoSaveProcessedImages,
              onChanged: (value) => appProvider.setAutoSaveProcessedImages(value),
              icon: Icons.save,
            ),
            
            _buildSwitchTile(
              title: 'Filigran Ekle',
              subtitle: 'İşlenmiş resimlere filigran ekle',
              value: appProvider.showWatermark,
              onChanged: (value) => appProvider.setShowWatermark(value),
              icon: Icons.branding_watermark,
            ),
          ],
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms);
      },
    );
  }

  Widget _buildProcessingSettings() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return _buildSection(
          title: 'İşleme Ayarları',
          icon: Icons.tune,
          children: [
            _buildSliderTile(
              title: 'Bulanıklık Yoğunluğu',
              subtitle: 'Varsayılan bulanıklık seviyesi',
              value: appProvider.defaultBlurIntensity.toDouble(),
              min: 5,
              max: 50,
              divisions: 9,
              onChanged: (value) => appProvider.setDefaultBlurIntensity(value.toInt()),
              icon: Icons.blur_on,
            ),
            
            _buildTile(
              title: 'Varsayılan Avatar Stili',
              subtitle: _getAvatarStyleName(appProvider.defaultAvatarStyle),
              icon: Icons.face_retouching_natural,
              onTap: () => _showAvatarStyleDialog(),
            ),
            
            _buildTile(
              title: 'Varsayılan Sanat Stili',
              subtitle: _getArtStyleName(appProvider.defaultArtStyle),
              icon: Icons.palette,
              onTap: () => _showArtStyleDialog(),
            ),
          ],
        ).animate().fadeIn(delay: 400.ms, duration: 600.ms);
      },
    );
  }

  Widget _buildAccountSettings() {
    return _buildSection(
      title: 'Hesap Ayarları',
      icon: Icons.account_circle,
      children: [
        _buildTile(
          title: 'Profili Düzenle',
          subtitle: 'Ad, e-posta ve profil resmi',
          icon: Icons.edit,
          onTap: () => _editProfile(),
        ),
        
        _buildTile(
          title: 'Şifre Değiştir',
          subtitle: 'Hesap şifrenizi güncelleyin',
          icon: Icons.lock,
          onTap: () => _changePassword(),
        ),
        
        _buildTile(
          title: 'İşlem Geçmişi',
          subtitle: 'Geçmiş işlemlerinizi görüntüleyin',
          icon: Icons.history,
          onTap: () => Navigator.pushNamed(context, '/processing-history'),
        ),
        
        _buildTile(
          title: 'Verileri Temizle',
          subtitle: 'Tüm işlem verilerini sil',
          icon: Icons.delete_sweep,
          onTap: () => _clearData(),
          textColor: AppColors.warning,
        ),
        
        _buildTile(
          title: 'Hesabı Sil',
          subtitle: 'Hesabınızı kalıcı olarak silin',
          icon: Icons.delete_forever,
          onTap: () => _deleteAccount(),
          textColor: AppColors.error,
        ),
      ],
    ).animate().fadeIn(delay: 600.ms, duration: 600.ms);
  }

  Widget _buildAboutSection() {
    return _buildSection(
      title: 'Hakkında',
      icon: Icons.info,
      children: [
        _buildTile(
          title: 'Sürüm',
          subtitle: '1.0.0 (1)',
          icon: Icons.apps,
        ),
        
        _buildTile(
          title: 'Kullanım Koşulları',
          subtitle: 'Hizmet şartlarını okuyun',
          icon: Icons.description,
          onTap: () => _showTermsOfService(),
        ),
        
        _buildTile(
          title: 'Gizlilik Politikası',
          subtitle: 'Veri koruma politikamız',
          icon: Icons.privacy_tip,
          onTap: () => _showPrivacyPolicy(),
        ),
        
        _buildTile(
          title: 'Destek',
          subtitle: 'Yardım ve iletişim',
          icon: Icons.support,
          onTap: () => _contactSupport(),
        ),
        
        _buildTile(
          title: 'Uygulamayı Değerlendir',
          subtitle: 'App Store\'da yorum yapın',
          icon: Icons.star,
          onTap: () => _rateApp(),
        ),
      ],
    ).animate().fadeIn(delay: 800.ms, duration: 600.ms);
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildTile({
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (textColor ?? AppColors.primary).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: textColor ?? AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
      ),
      trailing: onTap != null 
          ? Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            )
          : null,
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 20,
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
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                value.toInt().toString(),
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.primary.withOpacity(0.3),
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.2),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  String _getMembershipDuration(DateTime? createdAt) {
    if (createdAt == null) return '0g';
    
    final difference = DateTime.now().difference(createdAt);
    
    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}ay';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}g';
    } else {
      return 'Yeni';
    }
  }

  String _getAvatarStyleName(String style) {
    switch (style) {
      case 'cartoon': return 'Çizgi Film';
      case 'anime': return 'Anime';
      case 'realistic': return 'Gerçekçi';
      case 'abstract': return 'Soyut';
      case 'emoji': return 'Emoji';
      case 'pixel_art': return 'Pixel Sanatı';
      default: return style;
    }
  }

  String _getArtStyleName(String style) {
    switch (style) {
      case 'van_gogh': return 'Van Gogh';
      case 'picasso': return 'Picasso';
      case 'monet': return 'Monet';
      case 'glitch': return 'Glitch';
      case 'vaporwave': return 'Vaporwave';
      case 'sketch': return 'Karakalem';
      default: return style;
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Dil Seçin',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Türkçe', style: TextStyle(color: AppColors.textPrimary)),
              leading: Icon(Icons.check, color: AppColors.primary),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: Text('English', style: TextStyle(color: AppColors.textSecondary)),
              onTap: () {
                // TODO: Language implementation
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAvatarStyleDialog() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Avatar Stili',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'cartoon',
            'anime', 
            'realistic',
            'abstract',
            'emoji',
            'pixel_art'
          ].map((style) => ListTile(
            title: Text(
              _getAvatarStyleName(style), 
              style: TextStyle(color: AppColors.textPrimary),
            ),
            leading: appProvider.defaultAvatarStyle == style 
                ? Icon(Icons.check, color: AppColors.primary)
                : null,
            onTap: () {
              appProvider.setDefaultAvatarStyle(style);
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showArtStyleDialog() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Sanat Stili',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'van_gogh',
            'picasso',
            'monet',
            'glitch',
            'vaporwave',
            'sketch'
          ].map((style) => ListTile(
            title: Text(
              _getArtStyleName(style),
              style: TextStyle(color: AppColors.textPrimary),
            ),
            leading: appProvider.defaultArtStyle == style 
                ? Icon(Icons.check, color: AppColors.primary)
                : null,
            onTap: () {
              appProvider.setDefaultArtStyle(style);
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _editProfile() {
    // TODO: Profile editing implementation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profil düzenleme yakında eklenecek'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _changePassword() {
    // TODO: Password change implementation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Şifre değiştirme yakında eklenecek'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _clearData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Verileri Temizle',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Tüm işlem verileri silinecek. Bu işlem geri alınamaz.',
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
              Provider.of<AppProvider>(context, listen: false).reset();
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Veriler temizlendi'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text(
              'Temizle',
              style: TextStyle(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Hesabı Sil',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Hesabınız kalıcı olarak silinecek. Bu işlem geri alınamaz.',
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
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final success = await authProvider.deleteAccount();
              
              Navigator.pop(context);
              
              if (success) {
                Navigator.of(context).pushReplacementNamed('/login');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Hesap silinemedi: ${authProvider.errorMessage}'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
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

  void _showTermsOfService() {
    // TODO: Terms of service implementation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kullanım koşulları yakında eklenecek'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _showPrivacyPolicy() {
    // TODO: Privacy policy implementation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gizlilik politikası yakında eklenecek'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _contactSupport() {
    // TODO: Support contact implementation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Destek iletişimi yakında eklenecek'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _rateApp() {
    // TODO: App rating implementation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Uygulama değerlendirme yakında eklenecek'),
        backgroundColor: AppColors.info,
      ),
    );
  }
} 