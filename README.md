# 💊 İlaç Takip Sistemi

Bu proje, kullanıcıların günlük ilaç takiplerini yapabilmeleri, dozaj ve saat hatırlatmalarını yönetebilmeleri amacıyla **Flutter** kullanılarak geliştirilmiş bir mobil uygulamadır.

## 🚀 Proje Hakkında
Uygulama, kullanıcı dostu arayüzü ile ilaçların ismini, dozunu, türünü (Hap, Şurup, İğne vb.) ve kullanım durumunu (Aç/Tok) kaydeder. Kullanıcılar ilaçlarını aldıklarında işaretleyebilir ve veriler uygulama kapansa bile kaybolmaz.

## 🛠 Kullanılan Teknolojiler
Proje geliştirilirken aşağıdaki teknoloji ve kütüphaneler kullanılmıştır:

* **Framework:** Flutter (3.x)
* **Dil:** Dart (3.x)
* **Veri Kaydı (Local Storage):** `shared_preferences` (Verilerin kalıcılığı için)
* **Tasarım:** Material Design 3

## 📱 Test Edilen Platformlar
Uygulama aşağıdaki ortamlarda test edilmiş ve başarıyla çalışmıştır:

* **Android Emulator:** Pixel 6 (API 34)
* **Geliştirme Ortamı:** Visual Studio Code / Windows

## ✨ Temel Özellikler

1.  **İlaç Ekleme:** İsim, doz, tür ve saat bilgisiyle ilaç kaydı.
2.  **Veri Kalıcılığı:** Uygulama kapatılıp açıldığında veriler silinmez.
3.  **Görsel Kategorizasyon:** Şurup, İğne, Hap gibi türlere göre özel ikonlar.
4.  **Takip Sistemi:** İlaç alındığında kutucuk işaretlenir ve ilaç "alındı" olarak görünür.
5.  **Düzenleme/Silme:** Kayıtlı ilaçlar güncellenebilir veya silinebilir.

## 📦 Kurulum ve Çalıştırma

Terminalde proje klasörüne geldikten sonra şu komutları uygulayınız:

1.  Gerekli paketleri indirin:
    ```bash
    flutter pub get
    ```

2.  Uygulamayı çalıştırın:
    ```bash
    flutter run
    ```