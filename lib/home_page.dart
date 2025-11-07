import 'package:flutter/material.dart';
import 'add_medicine_page.dart';
import 'ilac_model.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // İlaçları tutan ana (dinamik) liste
  final List<Ilac> ilacListesi = [];

  // 1. YENİ İLAÇ EKLEMEK İÇİN
  void _ilacEklemeSayfasinaGit() async {
    // Sayfayı "Ekleme Modu"nda aç (boş parametre)
    final yeniIlac = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddMedicinePage()),
    );

    if (yeniIlac != null && yeniIlac is Ilac) {
      setState(() {
        ilacListesi.add(yeniIlac); // Listeye ekle
      });
    }
  }

  // 2. MEVCUT İLACI DÜZENLEMEK İÇİN
  void _ilacDuzenlemeSayfasinaGit(int index) async {
    final Ilac duzenlenecekIlac = ilacListesi[index];

    // Sayfayı "Düzenleme Modu"nda aç (dolu parametre)
    final guncellenmisIlac = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMedicinePage(duzenlenecekIlac: duzenlenecekIlac),
      ),
    );

    if (guncellenmisIlac != null && guncellenmisIlac is Ilac) {
      setState(() {
        ilacListesi[index] = guncellenmisIlac; // Listedekiyle değiştir
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("'${guncellenmisIlac.ad}' güncellendi.")),
      );
    }
  }

  // 3. SEÇENEK MENÜSÜ GÖSTERME (DÜZENLE/SİL)
  void _secenekleriGoster(int index) {
    // Silme fonksiyonu (menünün içine)
    void _ilaciSil() {
      setState(() {
        ilacListesi.removeAt(index);
      });
      Navigator.of(context).pop(); // Seçenek menüsünü kapat
    }

    // Alttan açılan menü
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.edit, color: Colors.blue[700]),
              title: Text('Düzenle'),
              onTap: () {
                Navigator.of(context).pop(); // Menüyü kapat
                _ilacDuzenlemeSayfasinaGit(index); // Düzenleme sayfasını aç
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red[700]),
              title: Text('Sil'),
              onTap: _ilaciSil,
            ),
            ListTile(
              leading: Icon(Icons.cancel),
              title: Text('İptal'),
              onTap: () {
                Navigator.of(context).pop(); // Menüyü kapat
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('İlaç Takip Sistemim', style: TextStyle(color: Colors.white)),
      ),
      backgroundColor: Colors.white,

      // İlaç Listesi
      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: ilacListesi.length,
        itemBuilder: (context, index) {
          final ilac = ilacListesi[index];

          // Saat listesini "09:00, 15:00" gibi bir metne dönüştür
          final saatlerMetni = ilac.saatler
              .map((saat) => saat.format(context))
              .join(', ');

          return Card(
            elevation: 4.0,
            margin: EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ListTile(
              leading: Icon(Icons.medical_services, color: Colors.blue[600], size: 40.0),
              title: Text(ilac.ad, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                'Saatler: $saatlerMetni  -  Durum: ${ilac.durum}',
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
              // Tıklayınca seçenek menüsünü aç
              onTap: () {
                _secenekleriGoster(index);
              },
            ),
          );
        },
      ),

      // İlaç Ekleme Butonu
      floatingActionButton: FloatingActionButton(
        onPressed: _ilacEklemeSayfasinaGit,
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.blue[700],
      ),
    );
  }
}