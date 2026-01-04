import 'package:flutter/material.dart';
import 'dart:convert';

class Ilac {
  final String id;
  final String ad;
  final String doz;
  final String tur;
  final List<TimeOfDay> saatler;
  final String durum; // Aç/Tok
  bool alindiMi;

  Ilac({
    String? id,
    required this.ad,
    this.doz = '',
    this.tur = 'Hap',
    required this.saatler,
    required this.durum,
    this.alindiMi = false,
  }) : id = id ?? DateTime.now().toIso8601String();

  String saatleriGoster(BuildContext context) {
    if (saatler.isEmpty) return "Saat Girilmedi";
    return saatler.map((s) => s.format(context)).join(', ');
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ad': ad,
      'doz': doz,
      'tur': tur,
      // TimeOfDay doğrudan kaydedilmez, "10:30" gibi string'e çeviriyoruz
      'saatler': saatler.map((s) => '${s.hour}:${s.minute}').toList(),
      'durum': durum,
      'alindiMi': alindiMi,
    };
  }

  factory Ilac.fromMap(Map<String, dynamic> map) {
    return Ilac(
      id: map['id'],
      ad: map['ad'],
      doz: map['doz'] ?? '',
      tur: map['tur'] ?? 'Hap',
      saatler: List<TimeOfDay>.from(
        (map['saatler'] as List).map((s) {
          final parts = s.split(':');
          return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }),
      ),
      durum: map['durum'],
      alindiMi: map['alindiMi'] ?? false,
    );
  }

  // Listeyi JSON String'e çevirme (Kaydetmek için)
  static String encode(List<Ilac> ilaclar) => json.encode(
    ilaclar.map<Map<String, dynamic>>((ilac) => ilac.toMap()).toList(),
  );

  // JSON String'i Listeye çevirme (Geri Yüklemek için)
  static List<Ilac> decode(String ilaclarString) =>
      (json.decode(ilaclarString) as List<dynamic>)
          .map<Ilac>((item) => Ilac.fromMap(item))
          .toList();
}