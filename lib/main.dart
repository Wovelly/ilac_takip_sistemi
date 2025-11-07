import 'package:flutter/material.dart';
import 'home_page.dart'; // Ana sayfamızı import ediyoruz

// Temiz, hatasız, bildirim ayarı olmayan başlangıç
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'İlaç Takip',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light, // Koyu temayı zorla kapat

      // Mavi-Beyaz Tema
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white, // Tüm ekran arka planları beyaz

        // AppBar teması (Tüm başlıklara uygular)
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue[700], // Koyu mavi başlık
          foregroundColor: Colors.white, // Beyaz ikonlar ve geri oku
          elevation: 0,
        ),

        // Buton teması
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
      ),
      home: HomePage(), // Başlangıç ekranı
    );
  }
}