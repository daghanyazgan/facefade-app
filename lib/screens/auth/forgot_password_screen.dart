import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../theme/app_colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.resetPassword(_emailController.text.trim());

      if (success && mounted) {
        setState(() => _emailSent = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Şifre sıfırlama e-postası gönderildi!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Şifre sıfırlama hatası: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Logo ve Animasyon
                SizedBox(
                  height: 200,
                  child: Lottie.asset(
                    _emailSent 
                        ? 'assets/animations/email_sent.json'
                        : 'assets/animations/forgot_password.json',
                    repeat: !_emailSent,
                    animate: true,
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3),
                
                const SizedBox(height: 40),
                
                // Başlık
                Text(
                  _emailSent ? 'E-posta Gönderildi!' : 'Şifremi Unuttum',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                
                const SizedBox(height: 16),
                
                Text(
                  _emailSent 
                      ? 'E-posta adresinize şifre sıfırlama bağlantısı gönderildi. E-postanızı kontrol edin ve talimatları takip edin.'
                      : 'E-posta adresinizi girin, size şifre sıfırlama bağlantısı gönderelim.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
                
                const SizedBox(height: 48),
                
                if (!_emailSent) ...[
                  // Email Field
                  CustomTextField(
                    controller: _emailController,
                    labelText: 'E-posta',
                    hintText: 'ornek@email.com',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'E-posta adresi gerekli';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Geçerli bir e-posta adresi girin';
                      }
                      return null;
                    },
                  ).animate().fadeIn(delay: 600.ms, duration: 600.ms).slideX(begin: -0.3),
                  
                  const SizedBox(height: 32),
                  
                  // Reset Button
                  CustomButton(
                    text: 'Şifre Sıfırlama Bağlantısı Gönder',
                    onPressed: _isLoading ? null : _resetPassword,
                    isLoading: _isLoading,
                    backgroundColor: AppColors.primary,
                    textColor: Colors.white,
                  ).animate().fadeIn(delay: 800.ms, duration: 600.ms).slideY(begin: 0.3),
                  
                  const SizedBox(height: 24),
                  
                  // Güvenlik Bilgisi
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.info.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.info,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Güvenlik nedeniyle, şifre sıfırlama bağlantısı sadece kayıtlı e-posta adresinize gönderilir.',
                            style: TextStyle(
                              color: AppColors.info,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 1000.ms, duration: 600.ms),
                ] else ...[
                  // Success Actions
                  CustomButton(
                    text: 'E-postayı Tekrar Gönder',
                    onPressed: () {
                      setState(() => _emailSent = false);
                    },
                    outlined: true,
                    backgroundColor: AppColors.primary,
                  ).animate().fadeIn(delay: 600.ms, duration: 600.ms),
                  
                  const SizedBox(height: 16),
                  
                  CustomButton(
                    text: 'Giriş Sayfasına Dön',
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    backgroundColor: AppColors.primary,
                    textColor: Colors.white,
                  ).animate().fadeIn(delay: 800.ms, duration: 600.ms),
                  
                  const SizedBox(height: 24),
                  
                  // E-posta bulunamadı bilgisi
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.warning.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.help_outline,
                              color: AppColors.warning,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'E-posta gelmediyse:',
                              style: TextStyle(
                                color: AppColors.warning,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Spam/önemsiz klasörünüzü kontrol edin\n• E-posta adresinizin doğru olduğundan emin olun\n• Birkaç dakika bekleyin, bazen gecikmeli gelebilir',
                          style: TextStyle(
                            color: AppColors.warning,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 1000.ms, duration: 600.ms),
                ],
                
                const SizedBox(height: 32),
                
                // Geri Dön
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Giriş sayfasına dön',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ).animate().fadeIn(delay: 1200.ms, duration: 600.ms),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 