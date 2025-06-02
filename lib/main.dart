import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/app_provider.dart';
import 'services/firebase_service.dart';
import 'services/ai_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/home_page.dart';
import 'screens/gallery_scan_page.dart';
import 'screens/identify_person_page.dart';
import 'screens/add_person_page.dart';
import 'screens/scan_results_page.dart';
import 'screens/processing_complete_page.dart';
import 'screens/processing_history_page.dart';
import 'screens/settings_page.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'screens/image_processing_page.dart';
import 'screens/person_photos_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase'i başlat
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Status bar ayarları
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const FaceFadeApp());
}

class FaceFadeApp extends StatelessWidget {
  const FaceFadeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: MaterialApp(
        title: 'FaceFade',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthWrapper(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/home': (context) => const HomePage(),
          '/gallery': (context) => const GalleryScanPage(),
          '/identify': (context) => const IdentifyPersonPage(),
          '/add-person': (context) => const AddPersonPage(),
          '/scan-results': (context) => const ScanResultsPage(),
          '/processing-complete': (context) => const ProcessingCompletePage(),
          '/settings': (context) => const SettingsPage(),
          '/processing-history': (context) => const ProcessingHistoryPage(),
        },
        onGenerateRoute: (settings) {
          // Handle dynamic routes here if needed
          switch (settings.name) {
            case '/image-processing':
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) => ImageProcessingPage(
                  imageFile: args['imageFile'],
                  processingType: args['processingType'],
                ),
              );
            case '/person-photos':
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) => PersonPhotosPage(
                  face: args['face'],
                ),
              );
            default:
              return MaterialPageRoute(
                builder: (context) => const HomePage(),
              );
          }
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Auth state dinle
        return StreamBuilder(
          stream: FirebaseService().authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }
            
            if (snapshot.hasData && snapshot.data != null) {
              // Kullanıcı giriş yapmış
              return const MainNavigationWrapper();
            } else {
              // Kullanıcı giriş yapmamış
              return const LoginScreen();
            }
          },
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Uygulama başlatma işlemleri
    await Future.delayed(const Duration(seconds: 2));
    
    // Backend sağlık kontrolü
    final isBackendHealthy = await AiService().checkBackendHealth();
    if (!isBackendHealthy) {
      print('⚠️ Backend servisi erişilebilir değil');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.face_retouching_natural,
                size: 60,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Uygulama Adı
            Text(
              'FaceFade',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'AI ile Dijital Anıları Dönüştür',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 48),
            
            // Loading Animation
            LoadingAnimationWidget.staggeredDotsWave(
              color: AppColors.primary,
              size: 50,
            ),
          ],
        ),
      ),
    );
  }
}

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _animationController;

  final List<Widget> _pages = [
    const HomePage(),
    const GalleryScanPage(),
    const IdentifyPersonPage(),
    const SettingsPage(),
  ];

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home_rounded,
      label: 'Anasayfa',
      activeColor: AppColors.primary,
    ),
    NavigationItem(
      icon: Icons.photo_library_rounded,
      label: 'Galeri',
      activeColor: AppColors.secondary,
    ),
    NavigationItem(
      icon: Icons.face_rounded,
      label: 'Yüzler',
      activeColor: AppColors.accent,
    ),
    NavigationItem(
      icon: Icons.settings_rounded,
      label: 'Ayarlar',
      activeColor: AppColors.textSecondary,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                _navigationItems.length,
                (index) => _buildNavItem(index, _navigationItems[index]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, NavigationItem item) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? item.activeColor.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                item.icon,
                color: isSelected ? item.activeColor : AppColors.textSecondary,
                size: isSelected ? 26 : 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected ? item.activeColor : AppColors.textSecondary,
                fontSize: isSelected ? 12 : 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final Color activeColor;

  NavigationItem({
    required this.icon,
    required this.label,
    required this.activeColor,
  });
}

// Temporary placeholder pages for routes
class ProcessingHistoryPage extends StatelessWidget {
  const ProcessingHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('İşlem Geçmişi')),
      body: Center(child: Text('İşlem geçmişi sayfası yakında eklenecek')),
    );
  }
}

class ImageProcessingPage extends StatelessWidget {
  final dynamic imageFile;
  final String processingType;
  
  const ImageProcessingPage({
    super.key,
    required this.imageFile,
    required this.processingType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Resim İşleme')),
      body: Center(child: Text('Resim işleme sayfası yakında eklenecek')),
    );
  }
}

class PersonPhotosPage extends StatelessWidget {
  final dynamic face;
  
  const PersonPhotosPage({super.key, required this.face});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kişi Fotoğrafları')),
      body: Center(child: Text('Kişi fotoğrafları sayfası yakında eklenecek')),
    );
  }
} 