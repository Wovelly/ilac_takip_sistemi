import 'package:flutter/material.dart';
import 'ilac_model.dart';

class AddMedicinePage extends StatefulWidget {
  final Ilac? duzenlenecekIlac;

  AddMedicinePage({Key? key, this.duzenlenecekIlac}) : super(key: key);

  @override
  _AddMedicinePageState createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicinePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ilacAdiController = TextEditingController();
  final TextEditingController _dozController = TextEditingController(); // YENİ: Doz girişi
  final List<TimeOfDay> _secilenSaatler = [];
  String? _secilenDurum;
  String _secilenTur = 'Hap';

  final List<String> _ilacTurleri = ['Hap', 'Şurup', 'İğne', 'Krem', 'Damla'];

  bool get _duzenlemeModu => widget.duzenlenecekIlac != null;

  @override
  void initState() {
    super.initState();
    if (_duzenlemeModu) {
      final ilac = widget.duzenlenecekIlac!;
      _ilacAdiController.text = ilac.ad;
      _dozController.text = ilac.doz;
      _secilenDurum = ilac.durum;
      _secilenTur = ilac.tur;
      _secilenSaatler.addAll(ilac.saatler);
    }
  }

  Future<void> _saatiSec(BuildContext context) async {
    final TimeOfDay? secilen = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[700]!,
              onPrimary: Colors.white,
              onSurface: Colors.blue[900]!,
            ),
          ),
          child: child!,
        );
      },
    );

    if (secilen != null && !_secilenSaatler.contains(secilen)) {
      setState(() {
        _secilenSaatler.add(secilen);
        _secilenSaatler.sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
      });
    }
  }

  void _ilaciKaydet() {
    final bool formGecerli = _formKey.currentState?.validate() ?? false;
    final bool saatSecili = _secilenSaatler.isNotEmpty;

    if (!saatSecili) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lütfen en az bir kullanım saati seçin!'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (formGecerli) {
      final yeniIlac = Ilac(
        id: _duzenlemeModu ? widget.duzenlenecekIlac!.id : null,
        ad: _ilacAdiController.text,
        doz: _dozController.text,
        tur: _secilenTur,
        durum: _secilenDurum!,
        saatler: _secilenSaatler,
      );

      Navigator.pop(context, yeniIlac);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_duzenlemeModu ? 'İlacı Düzenle' : 'Yeni İlaç Ekle'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("İlaç Bilgileri"),
              SizedBox(height: 16),

              // İsim Alanı
              TextFormField(
                controller: _ilacAdiController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'İlaç Adı',
                  hintText: 'Örn: Parol',
                  prefixIcon: Icon(Icons.medication),
                ),
                validator: (val) => val!.isEmpty ? 'İlaç adı gerekli' : null,
              ),
              SizedBox(height: 16),

              // Doz Alanı
              TextFormField(
                controller: _dozController,
                decoration: InputDecoration(
                  labelText: 'Doz / Miktar',
                  hintText: 'Örn: 500mg veya 1 Ölçek',
                  prefixIcon: Icon(Icons.local_pharmacy_outlined),
                ),
              ),
              SizedBox(height: 24),

              // Tür Seçimi
              _buildSectionTitle("İlaç Formu"),
              SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: _ilacTurleri.map((tur) {
                  final secili = _secilenTur == tur;
                  return ChoiceChip(
                    label: Text(tur),
                    selected: secili,
                    selectedColor: Colors.blue[100],
                    labelStyle: TextStyle(
                      color: secili ? Colors.blue[900] : Colors.black,
                      fontWeight: secili ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (bool selected) {
                      if (selected) {
                        setState(() {
                          _secilenTur = tur;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 24),

              // Aç/Tok Durumu
              _buildSectionTitle("Kullanım Şekli"),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text("Aç"),
                      value: "Aç",
                      groupValue: _secilenDurum,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) => setState(() => _secilenDurum = val),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text("Tok"),
                      value: "Tok",
                      groupValue: _secilenDurum,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) => setState(() => _secilenDurum = val),
                    ),
                  ),
                ],
              ),
              // Eğer seçim yapılmadıysa gizli bir hata mesajı alanı
              if (_secilenDurum == null)
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text("Lütfen Aç/Tok durumunu seçin", style: TextStyle(color: Colors.red[700], fontSize: 12)),
                ),

              SizedBox(height: 24),

              // Saat Seçimi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle("Hatırlatma Saatleri"),
                  TextButton.icon(
                    onPressed: () => _saatiSec(context),
                    icon: Icon(Icons.add_circle),
                    label: Text("Saat Ekle"),
                  ),
                ],
              ),

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: _secilenSaatler.isEmpty
                    ? Center(child: Text("Henüz saat eklenmedi", style: TextStyle(color: Colors.grey)))
                    : Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _secilenSaatler.map((saat) {
                    return Chip(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.blue[200]!),
                      avatar: Icon(Icons.access_time, size: 18, color: Colors.blue[700]),
                      label: Text(saat.format(context), style: TextStyle(fontWeight: FontWeight.bold)),
                      deleteIcon: Icon(Icons.cancel, size: 18, color: Colors.red[300]),
                      onDeleted: () => setState(() => _secilenSaatler.remove(saat)),
                    );
                  }).toList(),
                ),
              ),

              SizedBox(height: 32),

              // Kaydet Butonu
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _ilaciKaydet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _duzenlemeModu ? 'Değişiklikleri Kaydet' : 'İlacı Oluştur',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Başlık stili için yardımcı widget
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue[900]
      ),
    );
  }
}