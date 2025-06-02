## Proje Adı: FaceFade – Dijital Anılardan Yüzünü Sil

Flutter ile bir mobil uygulama geliştiriyoruz. Bu uygulama, kullanıcının galerideki belirli kişileri tespit edip, bu kişilerin yüzlerini bulanıklaştırmasına, AI avatarla değiştirmesine veya fotoğrafı sanatsal bir hale dönüştürmesine olanak tanır.

Aşağıda detaylı şekilde açıklanmış şekilde **sadece frontend kısmını** Flutter ile yazmanı istiyorum. Kodları component bazlı olacak şekilde ayır ve modern, sade, sosyal medya tarzına uygun bir UI tasarımı yap.

---

### 📱 Ana Sayfa (HomePage)

- Üstte logo ve uygulama adı (FaceFade)
- Altında şu seçenekleri içeren 3 büyük buton (card görünümü):
  1. 📸 “Galerimden Yüz Seç”
  2. 🔍 “Kişiyi Tanımla ve Bul”
  3. 🎨 “AI ile Anıyı Dönüştür”

---

### 🧠 Yüz Tanımlama Sayfası (IdentifyPersonPage)

- Kullanıcıdan bir yüz tanımlaması istenecek (fotoğraf ekle veya kamerayla çek)
- Altında kişi ismini girmesi için bir TextField
- “Kaydet” butonu
- Uyarı metni: "Yalnızca kendi galerinizdeki veriler işlenir. Veriler gizli kalır."

---

### 📂 Galeri Görüntüleme Sayfası (GalleryScanPage)

- Tüm fotoğraflar grid yapısında gösterilir (örn. 3 sütun)
- Her fotoğrafın üzerinde, eğer tanımlanan kişi tespit edilirse:
  - Üstüne “Yüz bulundu” yazısı düşer
  - Fotoğraf tıklanınca 3 seçenek içeren modal açılır:
    1. Yüzü Bulanıklaştır
    2. AI Avatar ile Değiştir
    3. Sanatsal Dönüştür

---

### 🖼️ Dönüştürülmüş Fotoğraf Önizleme (ProcessedPhotoPage)

- Seçilen görsel tam ekran
- Altında “Kaydet”, “Paylaş”, “Yeniden Uygula” butonları
- Fotoğrafı Reels/TikTok formatına getirecek bir “Video Olarak Kaydet” seçeneği

---

### ⚙️ Ayarlar Sayfası (SettingsPage)

- Kişi listesi: Daha önce eklenen yüz tanımları listelenir (adı + minik yüz fotoğrafı)
- Hangi uygulamalarda sansür uygulanacağını belirlemek için toggle listesi:
  - Galeri
  - WhatsApp Medya
  - Instagram screenshot klasörü
  - (Not: frontend için gösterim yeterlidir, işlem backend'de yapılacak)

---

### 🧭 Alt Navigasyon

- 4 butonlu bottom navbar:
  - 🏠 Anasayfa
  - 📂 Galeri
  - 🧠 Tanımlamalar
  - ⚙️ Ayarlar

---

### 🎨 Tasarım

- Tema: Modern, koyu mod ağırlıklı (Instagram X karışımı)
- Butonlar: Sade, ikon destekli
- Font: OpenSans veya benzeri
- Gölgelendirme ve geçiş animasyonları (Hero Animation, FadeIn)
- Kullanıcı deneyimini artıracak micro animation’lar kullan (Lottie olabilir)

---

Kodları modern Flutter standartlarına göre yaz. State yönetimi için Riverpod kullanabilirsin (ama zorunlu değil). Component’leri ayırarak reusable olacak şekilde yazmanı istiyorum. 

Backend işlemler, AI yüz silme vb. daha sonra eklenecek. Şimdilik sadece kullanıcı arayüzünü ve ekran geçişlerini oluştur.
