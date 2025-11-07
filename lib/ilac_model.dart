import 'package:flutter/material.dart'; // TimeOfDay için gerekli

class Ilac {
  final String ad;
  final List<TimeOfDay> saatler; // Çoklu saat tutabilen liste
  final String durum; // "Aç" veya "Tok"

  Ilac({
    required this.ad,
    required this.saatler,
    required this.durum,
  });
}