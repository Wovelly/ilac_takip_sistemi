import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Kayıt paketi
import 'add_medicine_page.dart';
import 'ilac_model.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Ilac> ilacListesi = [];
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _verileriYukle();
  }

  Future<void> _verileriYukle() async {
    final prefs = await SharedPreferences.getInstance();
    final String? ilaclarString = prefs.getString('kayitli_ilaclar');

    if (ilaclarString != null) {
      setState(() {
        ilacListesi = Ilac.decode(ilaclarString);
      });
    }
    setState(() {
      _yukleniyor = false;
    });
  }

  Future<void> _verileriKaydet() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = Ilac.encode(ilacListesi);
    await prefs.setString('kayitli_ilaclar', encodedData);
  }


  void _ilacEklemeSayfasinaGit() async {
    final yeniIlac = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddMedicinePage()),
    );

    if (yeniIlac != null && yeniIlac is Ilac) {
      setState(() {
        ilacListesi.add(yeniIlac);
      });
      _verileriKaydet(); // Yeni ekleyince kaydet
    }
  }

  void _ilacDuzenlemeSayfasinaGit(int index) async {
    final Ilac duzenlenecekIlac = ilacListesi[index];
    final guncellenmisIlac = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMedicinePage(duzenlenecekIlac: duzenlenecekIlac),
      ),
    );

    if (guncellenmisIlac != null && guncellenmisIlac is Ilac) {
      setState(() {
        ilacListesi[index] = guncellenmisIlac;
      });
      _verileriKaydet(); // Düzenleyince kaydet
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("'${guncellenmisIlac.ad}' güncellendi.")),
      );
    }
  }

  void _secenekleriGoster(int index) {
    void _ilaciSil() {
      setState(() {
        ilacListesi.removeAt(index);
      });
      _verileriKaydet(); // Silince kaydet
      Navigator.of(context).pop();
    }

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.edit, color: Colors.blue[700]),
              title: Text('Düzenle'),
              onTap: () {
                Navigator.of(context).pop();
                _ilacDuzenlemeSayfasinaGit(index);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red[700]),
              title: Text('Sil', style: TextStyle(color: Colors.red[700])),
              onTap: _ilaciSil,
            ),
          ],
        );
      },
    );
  }

  // Checkbox'a basınca çalışacak fonksiyon
  void _ilacDurumunuDegistir(int index, bool? deger) {
    setState(() {
      ilacListesi[index].alindiMi = deger ?? false;
    });
    _verileriKaydet(); // Checkbox değişince de kaydet
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(title: Text('İlaç Takip Sistemi')),

      body: _yukleniyor
          ? Center(child: CircularProgressIndicator()) // Yükleniyorsa dönen daire
          : Column(
        children: [
          _buildSummaryCard(),
          Expanded(
            child: ilacListesi.isEmpty ? _buildEmptyState() : _buildMedicineList(),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _ilacEklemeSayfasinaGit,
        icon: Icon(Icons.add),
        label: Text("İlaç Ekle"),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildSummaryCard() {
    // Alınmayan ilaç sayısını hesapla
    int kalanIlac = ilacListesi.where((i) => !i.alindiMi).length;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[800]!, Colors.blue[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Hoş Geldiniz 👋", style: TextStyle(color: Colors.white, fontSize: 18)),
          SizedBox(height: 10),
          Text(
            ilacListesi.isEmpty
                ? "İlaç ekleyerek başlayın."
                : (kalanIlac == 0
                ? "Tebrikler! 🎉\nTüm ilaçlarını aldın."
                : "Bugün alınacak\n$kalanIlac ilacın kaldı."),
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medication_outlined, size: 80, color: Colors.grey[300]),
          SizedBox(height: 16),
          Text("Listeniz şu an boş", style: TextStyle(fontSize: 18, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildMedicineList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: ilacListesi.length,
      itemBuilder: (context, index) {
        final ilac = ilacListesi[index];
        final alindi = ilac.alindiMi;

        // İlaç alındıysa kartı biraz soluklaştır
        return Opacity(
          opacity: alindi ? 0.6 : 1.0,
          child: Card(
            margin: EdgeInsets.only(bottom: 12),
            elevation: alindi ? 0 : 2, // Alındıysa gölgesini kaldır
            color: alindi ? Colors.grey[100] : Colors.white, // Alındıysa gri yap
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: EdgeInsets.all(12),

              // Sol Taraftaki İkon
              leading: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: alindi ? Colors.grey[300] : Colors.blue[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                    _ikonSec(ilac.tur),
                    color: alindi ? Colors.grey : Colors.blue[700]
                ),
              ),

              // İlaç Bilgileri
              title: Text(
                ilac.ad,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  decoration: alindi ? TextDecoration.lineThrough : null, // Alındıysa üzerini çiz
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${ilac.tur} • ${ilac.doz}'),
                  SizedBox(height: 4),
                  Text('⏰ ${ilac.saatleriGoster(context)}', style: TextStyle(fontSize: 12)),
                ],
              ),

              // Sağ Taraftaki Checkbox
              trailing: Checkbox(
                value: alindi,
                activeColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                onChanged: (val) => _ilacDurumunuDegistir(index, val),
              ),

              onTap: () => _secenekleriGoster(index),
            ),
          ),
        );
      },
    );
  }

  IconData _ikonSec(String tur) {
    switch (tur) {
      case 'Şurup': return Icons.water_drop;
      case 'İğne': return Icons.vaccines;
      case 'Krem': return Icons.healing;
      default: return Icons.medication;
    }
  }
}