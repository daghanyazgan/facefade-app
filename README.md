# 🎭 FaceFade - AI ile Dijital Anıları Dönüştür

FaceFade, yapay zeka teknolojisi kullanarak fotoğraflarınızdaki yüzleri tespit edip çeşitli işlemler uygulayan modern bir mobil uygulamadır.

## ✨ Özellikler

### 🤖 AI Destekli İşlevler
- **Yüz Tespiti**: Fotoğraflardaki yüzleri otomatik olarak tespit eder
- **Yüz Bulanıklaştırma**: İstenmeyen yüzleri bulanıklaştırır
- **Avatar Değiştirme**: Yüzleri AI-generated avatarlarla değiştirir
- **Sanatsal Stil Uygulama**: Van Gogh, Picasso, Monet gibi sanat stilleri
- **Arka Plan Silme**: AI ile arka planı otomatik siler

### 🔐 Güvenlik ve Kullanıcı Yönetimi
- Firebase Authentication ile güvenli giriş
- Kullanıcıya özel veri saklama
- E-posta doğrulama sistemi
- Şifre sıfırlama

### 📱 Mobil Deneyim
- Modern ve kullanıcı dostu arayüz
- Dark mode desteği
- Animasyonlu geçişler
- Responsive tasarım

### 💾 Veri Yönetimi
- Firebase Firestore ile bulut veritabanı
- Firebase Storage ile güvenli dosya saklama
- İşlem geçmişi takibi
- Otomatik yedekleme

### 📤 Paylaşım Özellikleri
- Instagram, TikTok, WhatsApp entegrasyonu
- Toplu resim işleme
- Video oluşturma (Reels/TikTok boyutunda)

## 🛠 Teknoloji Stack

### Frontend (Flutter)
- **Flutter**: Cross-platform mobil uygulama geliştirme
- **Firebase**: Authentication, Firestore, Storage
- **Provider**: State management
- **Dio**: HTTP client
- **Lottie**: Animasyonlar
- **Image Picker**: Kamera ve galeri erişimi

### Backend (FastAPI)
- **FastAPI**: Modern Python web framework
- **OpenCV**: Görüntü işleme
- **Face Recognition**: Yüz tanıma algoritmaları
- **PIL (Pillow)**: Resim manipülasyonu
- **NumPy**: Matematiksel işlemler

### AI/ML Entegrasyonları
- **Hugging Face**: Pre-trained AI modelleri
- **Stable Diffusion**: Avatar generation
- **Google ML Kit**: On-device yüz tespiti

## 📋 Kurulum

### Gereksinimler
- Flutter SDK (>=3.4.4)
- Python 3.8+
- Firebase projesi
- Android Studio / Xcode

### 1. Flutter Uygulaması

```bash
# Repoyu klonlayın
git clone https://github.com/your-username/facefade.git
cd facefade

# Bağımlılıkları yükleyin
flutter pub get

# Firebase konfigürasyonunu yapın
# firebase_options.dart dosyasında gerçek Firebase bilgilerinizi güncelleyin
```

### 2. Backend Kurulumu

```bash
# Backend dizinine gidin
cd backend

# Virtual environment oluşturun
python -m venv venv
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate   # Windows

# Bağımlılıkları yükleyin
pip install -r requirements.txt

# Sunucuyu başlatın
python main.py
```

### 3. Firebase Konfigürasyonu

1. [Firebase Console](https://console.firebase.google.com/) üzerinden yeni proje oluşturun
2. Authentication, Firestore, Storage servislerini aktifleştirin
3. Flutter uygulaması için Android/iOS konfigürasyonu yapın
4. `lib/firebase_options.dart` dosyasını gerçek değerlerle güncelleyin

### 4. Environment Variables

Backend için `.env` dosyası oluşturun:

```env
HUGGINGFACE_TOKEN=your_huggingface_token
REPLICATE_TOKEN=your_replicate_token
FIREBASE_SERVICE_ACCOUNT_KEY=path/to/service-account-key.json
```

## 🚀 Deployment

### Backend Deployment (Render/Heroku)

1. **Render.com için:**
```bash
# render.yaml oluşturun
services:
  - type: web
    name: facefade-backend
    env: python
    buildCommand: pip install -r requirements.txt
    startCommand: uvicorn main:app --host 0.0.0.0 --port $PORT
```

2. **Heroku için:**
```bash
# Procfile oluşturun
web: uvicorn main:app --host 0.0.0.0 --port $PORT

# Deploy edin
heroku create facefade-backend
git push heroku main
```

### Mobile App Deployment

```bash
# Android APK
flutter build apk --release

# iOS (macOS'ta)
flutter build ios --release

# Play Store/App Store için bundle
flutter build appbundle --release  # Android
flutter build ios --release        # iOS
```

## 📱 Kullanım

### 1. Hesap Oluşturma
- Uygulamayı açın
- "Kayıt Ol" butonuna tıklayın
- E-posta ve şifre ile hesap oluşturun

### 2. Yüz Tespiti
- Ana sayfadan "Galeri" sekmesine gidin
- Fotoğraf seçin veya çekin
- Otomatik yüz tespiti başlayacak

### 3. İşlem Uygulama
- Tespit edilen yüzler üzerinde işlem seçin
- Bulanıklaştırma, avatar değiştirme, sanat stili
- İşlenmiş resmi kaydedin veya paylaşın

## 🎨 Özelleştirme

### Avatar Stilleri
- Çizgi Film
- Anime
- Gerçekçi
- Soyut
- Emoji
- Pixel Sanatı

### Sanat Stilleri
- Van Gogh
- Picasso
- Monet
- Glitch
- Vaporwave
- Karakalem

## 🔧 Yapılandırma

### `lib/services/ai_service.dart`
Backend URL'ini production ortamınıza göre güncelleyin:

```dart
static const String baseUrl = 'https://your-backend-url.herokuapp.com';
```

### `backend/main.py`
CORS ayarlarını production için güncelleyin:

```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://your-domain.com"],  # Production'da spesifik domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

## 📊 Performans Optimizasyonu

### Frontend
- Image caching
- Lazy loading
- Progressive image loading
- Background processing

### Backend
- Image compression
- Batch processing
- Caching strategies
- GPU acceleration (opsiyonel)

## 🧪 Test

```bash
# Flutter testleri
flutter test

# Backend testleri
cd backend
python -m pytest tests/
```

## 🐛 Troubleshooting

### Yaygın Sorunlar

1. **Firebase bağlantı hatası**
   - `firebase_options.dart` dosyasını kontrol edin
   - Internet bağlantınızı kontrol edin

2. **Backend erişim hatası**
   - Backend URL'ini kontrol edin
   - CORS ayarlarını kontrol edin

3. **Yüz tespiti çalışmıyor**
   - Görüntü kalitesini kontrol edin
   - Işık koşullarını iyileştirin

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

## 🤝 Katkıda Bulunma

1. Fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## 📞 İletişim

- **Email**: support@facefade.app
- **GitHub**: [github.com/your-username/facefade](https://github.com/your-username/facefade)
- **Website**: [www.facefade.app](https://www.facefade.app)

## 🙏 Teşekkürler

- Firebase ekibi
- Flutter community
- OpenCV developers
- Hugging Face team

---

**Not**: Bu uygulama eğitim amaçlı geliştirilmiştir. Production kullanımı için ek güvenlik önlemleri alınmalıdır. 