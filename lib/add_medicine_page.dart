import 'package:flutter/material.dart';
import 'ilac_model.dart'; // Modelimizi import ediyoruz

class AddMedicinePage extends StatefulWidget {
  // Düzenleme modu için dışarıdan 'Ilac' alabilen parametre
  final Ilac? duzenlenecekIlac;

  AddMedicinePage({Key? key, this.duzenlenecekIlac}) : super(key: key);

  @override
  _AddMedicinePageState createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicinePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ilacAdiController = TextEditingController();
  final List<TimeOfDay> _secilenSaatler = []; // Çoklu saat listesi
  String? _secilenDurum;

  // Sayfanın "Düzenleme Modu"nda olup olmadığını kontrol et
  bool get _duzenlemeModu => widget.duzenlenecekIlac != null;

  @override
  void initState() {
    super.initState();
    // Eğer düzenleme modundaysak, alanları eski ilaç bilgileriyle doldur
    if (_duzenlemeModu) {
      final ilac = widget.duzenlenecekIlac!;
      _ilacAdiController.text = ilac.ad;
      _secilenDurum = ilac.durum;
      _secilenSaatler.addAll(ilac.saatler);
    }
  }

  // Saat seçme (showTimePicker) fonksiyonu
  Future<void> _saatiSec(BuildContext context) async {
    final TimeOfDay? secilen = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (secilen != null && !_secilenSaatler.contains(secilen)) {
      setState(() {
        _secilenSaatler.add(secilen);
        // Saatleri sıraya diz (görsel güzellik için)
        _secilenSaatler.sort((a, b) {
          double aTime = a.hour + a.minute / 60.0;
          double bTime = b.hour + b.minute / 60.0;
          return aTime.compareTo(bTime);
        });
      });
    }
  }

  // Kaydetme/Güncelleme fonksiyonu
  void _ilaciKaydet() {
    final bool formGecerli = _formKey.currentState?.validate() ?? false;
    final bool saatSecili = _secilenSaatler.isNotEmpty;

    if (!saatSecili) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen en az bir saat seçin!')),
      );
      return; // İşlemi durdur
    }

    if (formGecerli && saatSecili) {
      final yeniVeyaGuncelIlac = Ilac(
        ad: _ilacAdiController.text,
        saatler: _secilenSaatler, // Listeyi yolla
        durum: _secilenDurum!,
      );
      // Bir önceki sayfaya (HomePage) bu Ilac nesnesini geri gönder
      Navigator.pop(context, yeniVeyaGuncelIlac);
    }
  }

  @override
  void dispose() {
    _ilacAdiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Başlığı moda göre ayarla
        title: Text(
          _duzenlemeModu ? 'İlacı Düzenle' : 'Yeni İlaç Ekle',
          style: TextStyle(color: Colors.white), // Yazı rengi
        ),
        // Geri oku (foregroundColor ile otomatik beyaz olur)
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- İLAÇ ADI ALANI ---
              TextFormField(
                controller: _ilacAdiController,
                decoration: _inputDecoration('İlaç Adı (Örn: Parol)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen ilaç adını girin';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),

              // --- AÇ/TOK SEÇENEĞİ (Dropdown) ---
              DropdownButtonFormField<String>(
                value: _secilenDurum,
                hint: Text('Durum (Aç / Tok)'),
                decoration: _inputDecoration(''),
                items: ['Aç', 'Tok'].map((String durum) {
                  return DropdownMenuItem<String>(
                    value: durum,
                    child: Text(durum),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _secilenDurum = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen durum seçin (Aç/Tok)';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),

              // --- ÇOKLU SAAT SEÇME ALANI ---
              Text('Kullanım Saatleri:', style: TextStyle(fontSize: 16)),
              SizedBox(height: 10.0),
              // Saat etiketleri (Chip)
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _secilenSaatler.map((saat) {
                  return Chip(
                    label: Text(saat.format(context)),
                    onDeleted: () {
                      setState(() {
                        _secilenSaatler.remove(saat);
                      });
                    },
                    deleteIcon: Icon(Icons.close, size: 18),
                  );
                }).toList(),
              ),
              // Yeni saat ekleme butonu
              TextButton.icon(
                icon: Icon(Icons.add_alarm, color: Colors.blue[700]),
                label: Text(
                  '+ Yeni Saat Ekle',
                  style: TextStyle(color: Colors.blue[700]),
                ),
                onPressed: () => _saatiSec(context),
              ),

              Spacer(), // Butonu en alta itmek için
              SizedBox(height: 20.0),

              // --- KAYDET / GÜNCELLE BUTONU ---
              ElevatedButton(
                onPressed: _ilaciKaydet,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    _duzenlemeModu ? 'GÜNCELLE' : 'KAYDET',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TextField'ları tek tip yapmak için yardımcı fonksiyon
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.blue, width: 2.0),
      ),
    );
  }
}