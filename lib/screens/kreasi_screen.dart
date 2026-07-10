import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../utils/supabase_config.dart';
import '../utils/session_manager.dart';
import '../widgets/bottom_nav_bar.dart';

// ─── Cloudinary Config ───────────────────────────────────────────────────────
const _cloudName = 'dtcuuqhqh';
const _uploadPreset = 'karyarasa_upload';

// ─── Color Palette (konsisten dengan app) ────────────────────────────────────
const _brown = Color(0xFF4A2B20);
const _terracotta = Color(0xFFC6572F);
const _gold = Color(0xFFD9AE23);
const _creamBg = Color(0xFFFDFAF7);
const _cardBg = Color(0xFFFFFFFF);
const _softGold = Color(0xFFF4EBD0);

// ─── Model sementara untuk state UI ──────────────────────────────────────────
class _BahanItem {
  TextEditingController namaCtrl = TextEditingController();
  TextEditingController jumlahCtrl = TextEditingController();
  _BahanItem();
  void dispose() {
    namaCtrl.dispose();
    jumlahCtrl.dispose();
  }
}

class _LangkahItem {
  TextEditingController deskripsiCtrl = TextEditingController();
  File? foto;
  String? fotoUrl; // URL setelah upload ke Cloudinary
  bool isUploadingFoto = false;
  _LangkahItem();
  void dispose() {
    deskripsiCtrl.dispose();
  }
}

// ─── Screen ──────────────────────────────────────────────────────────────────
class KreasiScreen  extends StatefulWidget {
  const KreasiScreen({super.key});

  @override
  State<KreasiScreen> createState() => _KreasiScreenState();
}

class _KreasiScreenState extends State<KreasiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _deskripsiCtrl = TextEditingController();
  final _asalDaerahCtrl = TextEditingController();
  final _porsiCtrl = TextEditingController();
  final _picker = ImagePicker();

  String _kategori = 'Makanan';
  File? _fotoResep;
  String? _fotoResepUrl;
  String? _fotoResepPublicId;
  bool _isUploadingFotoResep = false;
  bool _isSubmitting = false;

  final List<_BahanItem> _bahanList = [_BahanItem()];
  final List<_LangkahItem> _langkahList = [_LangkahItem()];

  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  Color get bgColor => isDark ? const Color(0xFF1E1E1E) : _creamBg;
  Color get cardColor => isDark ? const Color(0xFF2C2C2C) : _cardBg;
  Color get textColor => isDark ? Colors.white : _brown;
  Color get secondaryTextColor => isDark ? Colors.grey[400]! : _brown.withOpacity(0.6);

  @override
  void dispose() {
    _namaCtrl.dispose();
    _deskripsiCtrl.dispose();
    _asalDaerahCtrl.dispose();
    _porsiCtrl.dispose();
    for (final b in _bahanList) b.dispose();
    for (final l in _langkahList) l.dispose();
    super.dispose();
  }

  // ─── Upload ke Cloudinary ─────────────────────────────────────────────────
Future<Map<String, String>?> _uploadToCloudinary(File file) async {
  try {
    final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
    final req = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));
    final res = await req.send();
    if (res.statusCode == 200) {
      final body = jsonDecode(await res.stream.bytesToString());
      return {
        'url': body['secure_url'] as String,
        'public_id': body['public_id'] as String,
      };
    }
    return null;
  } catch (e) {
    return null;
  }
}

  // ─── Pilih & Upload Foto Resep ────────────────────────────────────────────
  Future<void> _pilihFotoResep() async {
    final picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (picked == null) return;
    setState(() {
      _fotoResep = File(picked.path);
      _isUploadingFotoResep = true;
    });
final result = await _uploadToCloudinary(_fotoResep!);
setState(() {
  _fotoResepUrl = result?['url'];
  _fotoResepPublicId = result?['public_id'];
  _isUploadingFotoResep = false;
});
    if (_fotoResepUrl == null && mounted) {
      _showSnack('Gagal mengupload foto resep. Coba lagi.', isError: true);
    }
  }

  // ─── Pilih & Upload Foto Langkah ──────────────────────────────────────────
  Future<void> _pilihFotoLangkah(int index) async {
    final picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked == null) return;
    setState(() {
      _langkahList[index].foto = File(picked.path);
      _langkahList[index].isUploadingFoto = true;
    });
    final result = await _uploadToCloudinary(_langkahList[index].foto!);
setState(() {
  _langkahList[index].fotoUrl = result?['url'];
      _langkahList[index].isUploadingFoto = false;
    });
    if (result == null && mounted) {  
      _showSnack('Gagal mengupload foto langkah. Coba lagi.', isError: true);
    }
  }

  // ─── Submit ke Supabase ───────────────────────────────────────────────────
  Future<void> _publikasikan() async {
    if (!_formKey.currentState!.validate()) return;

    // Validasi minimal 1 bahan
    final bahanValid = _bahanList.any((b) =>
        b.namaCtrl.text.trim().isNotEmpty &&
        b.jumlahCtrl.text.trim().isNotEmpty);
    if (!bahanValid) {
      _showSnack('Tambahkan minimal 1 bahan dengan nama dan jumlah.',
          isError: true);
      return;
    }

    // Validasi minimal 1 langkah
    final langkahValid =
        _langkahList.any((l) => l.deskripsiCtrl.text.trim().isNotEmpty);
    if (!langkahValid) {
      _showSnack('Tambahkan minimal 1 langkah memasak.', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final idPengguna = SessionManager.instance.idPengguna;
      final now = DateTime.now().toIso8601String();

      // 1. Insert resep utama
      final resepRes = await supabase
          .from('resepmakanan')
          .insert({
            'namaResep': _namaCtrl.text.trim(),
            'deskripsiResep': _deskripsiCtrl.text.trim(),
            'kategoriResep': _kategori,
            'asalDaerah': _asalDaerahCtrl.text.trim(),
            'porsi': int.tryParse(_porsiCtrl.text.trim()) ?? 4,
            'fotoResep': _fotoResepUrl,
            'fotoreseppublicid': _fotoResepPublicId,
            'statusResep': 'menunggu',
            'tglDibuat': now,
            'idpengguna': idPengguna,
          })
          .select('idResep')
          .single();

      final idResep = resepRes['idResep'] as int;

      // 2. Insert bahan-bahan
      final bahanData = _bahanList
          .where((b) =>
              b.namaCtrl.text.trim().isNotEmpty &&
              b.jumlahCtrl.text.trim().isNotEmpty)
          .map((b) => {
                'idResep': idResep,
                'namaBahan': b.namaCtrl.text.trim(),
                'jumlah': b.jumlahCtrl.text.trim(),
              })
          .toList();
      if (bahanData.isNotEmpty) {
        await supabase.from('bahanmasak').insert(bahanData);
      }

      // 3. Insert langkah-langkah
      final langkahData = <Map<String, dynamic>>[];
      for (int i = 0; i < _langkahList.length; i++) {
        final l = _langkahList[i];
        if (l.deskripsiCtrl.text.trim().isEmpty) continue;
        langkahData.add({
          'idResep': idResep,
          'nomorUrut': i + 1,
          'deskripsiLangkah': l.deskripsiCtrl.text.trim(),
          'fotolangkah': l.fotoUrl,
        });
      }
      if (langkahData.isNotEmpty) {
        await supabase.from('langkahmasak').insert(langkahData);
      }

      if (mounted) {
        _showSnack('Resep berhasil dikirim! Menunggu verifikasi admin.');
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Terjadi kesalahan: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red[700] : _terracotta,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          children: [
            _buildFotoResepSection(),
            const SizedBox(height: 28),
            _buildInfoUtamaSection(),
            const SizedBox(height: 28),
            _buildBahanSection(),
            const SizedBox(height: 28),
            _buildLangkahSection(),
            const SizedBox(height: 32),
            _buildPublikasiButton(),
          ],
        ),
      ),
    );
  }

  // ─── AppBar ───────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _creamBg,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: const Icon(Icons.arrow_back, color: _brown),
      ),
      title: Text(
        'Kreasi',
        style: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: Colors.grey.shade200),
      ),
    );
  }

  // ─── Section Label ────────────────────────────────────────────────────────
  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
          color: secondaryTextColor,
        ),
      ),
    );
  }

  // ─── Foto Resep ───────────────────────────────────────────────────────────
  Widget _buildFotoResepSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('FOTO RESEP'),
        GestureDetector(
          onTap: _isUploadingFotoResep ? null : _pilihFotoResep,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: _isUploadingFotoResep
                  ? Container(
                      color: _softGold,
                      child: const Center(
                        child: CircularProgressIndicator(color: _gold),
                      ),
                    )
                  : _fotoResep != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(_fotoResep!, fit: BoxFit.cover),
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Ganti Foto',
                                  style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            if (_fotoResepUrl != null)
                              const Positioned(
                                top: 10,
                                right: 10,
                                child: CircleAvatar(
                                  backgroundColor: Colors.green,
                                  radius: 12,
                                  child: Icon(Icons.check,
                                      color: Colors.white, size: 14),
                                ),
                              ),
                          ],
                        )
                      : Container(
                          color: _softGold,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined,
                                  size: 48,
                                  color: _gold.withOpacity(0.8)),
                              const SizedBox(height: 8),
                              Text(
                                'Tap untuk tambah foto',
                                style: GoogleFonts.inter(
                                    color: _brown.withOpacity(0.5),
                                    fontSize: 13),
                              ),
                            ],
                          ),
                        ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Informasi Utama ──────────────────────────────────────────────────────
  Widget _buildInfoUtamaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('INFORMASI UTAMA'),
        _buildTextField(
          controller: _namaCtrl,
          hint: 'Contoh: Rendang Daging Sapi Khas Minang',
          label: 'Nama Masakan',
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Nama masakan wajib diisi' : null,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          controller: _deskripsiCtrl,
          hint: 'Ceritakan sedikit tentang resep ini...',
          label: 'Deskripsi',
          maxLines: 3,
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Deskripsi wajib diisi' : null,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          controller: _asalDaerahCtrl,
          hint: 'Contoh: Sumatera Barat, Jawa Tengah...',
          label: 'Asal Daerah',
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Asal daerah wajib diisi' : null,
        ),
        const SizedBox(height: 14),
        _buildTextField(
         controller: _porsiCtrl,
         hint: 'Contoh: 4',
         label: 'Porsi (orang)',
     keyboardType: TextInputType.number,
     
),  
        const SizedBox(height: 14),
        Text('Kategori',
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor)),
        const SizedBox(height: 8),
        Row(
          children: ['Makanan', 'Jajanan', 'Minuman'].map((k) {
            final active = _kategori == k;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _kategori = k),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: active ? _gold : cardColor,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: active ? _gold : Colors.grey.shade200,
                      ),
                      boxShadow: active
                          ? [
                              BoxShadow(
                                  color: _gold.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3))
                            ]
                          : [],
                    ),
                    child: Text(
                      k,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: active ? Colors.white : secondaryTextColor,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─── Bahan-Bahan ──────────────────────────────────────────────────────────
  Widget _buildBahanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionLabel('BAHAN-BAHAN'),
            GestureDetector(
              onTap: () => setState(() => _bahanList.add(_BahanItem())),
              child: Text('+ Tambah',
                  style: GoogleFonts.inter(
                      color: _gold,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ),
          ],
        ),
        ..._bahanList.asMap().entries.map((e) {
          final i = e.key;
          final bahan = e.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: _buildTextField(
                    controller: bahan.namaCtrl,
                    hint: 'Nama bahan',
                    compact: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: _buildTextField(
                    controller: bahan.jumlahCtrl,
                    hint: 'Jumlah',
                    compact: true,
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: _bahanList.length > 1
                      ? () {
                          bahan.dispose();
                          setState(() => _bahanList.removeAt(i));
                        }
                      : null,
                  icon: Icon(Icons.delete_outline,
                      color: _bahanList.length > 1
                          ? Colors.grey.shade400
                          : Colors.grey.shade200),
                  iconSize: 22,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ─── Langkah Memasak ──────────────────────────────────────────────────────
  Widget _buildLangkahSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionLabel('LANGKAH MEMASAK'),
            GestureDetector(
              onTap: () => setState(() => _langkahList.add(_LangkahItem())),
              child: Text('+ Langkah Baru',
                  style: GoogleFonts.inter(
                      color: _gold,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ),
          ],
        ),
        ..._langkahList.asMap().entries.map((e) {
          final i = e.key;
          final langkah = e.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nomor langkah
                Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(top: 12, right: 12),
                  decoration: const BoxDecoration(
                    color: _softGold,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _brown),
                    ),
                  ),
                ),
                // Konten langkah
                Expanded(
                  child: Column(
                    children: [
                      // Textarea deskripsi
                      _buildTextField(
                        controller: langkah.deskripsiCtrl,
                        hint: 'Deskripsikan langkah ini...',
                        maxLines: 3,
                        compact: true,
                      ),
                      const SizedBox(height: 8),
                      // Area upload foto langkah
                      GestureDetector(
                        onTap: langkah.isUploadingFoto
                            ? null
                            : () => _pilihFotoLangkah(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: langkah.foto != null ? 140 : 56,
                          decoration: BoxDecoration(
                            color: _softGold.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: langkah.foto != null
                                  ? _gold.withOpacity(0.4)
                                  : Colors.grey.shade200,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: langkah.isUploadingFoto
                              ? const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        color: _gold, strokeWidth: 2),
                                  ),
                                )
                              : langkah.foto != null
                                  ? Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          child: Image.file(langkah.foto!,
                                              fit: BoxFit.cover),
                                        ),
                                        Positioned(
                                          bottom: 8,
                                          right: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text('Ganti',
                                                style: GoogleFonts.inter(
                                                    color: Colors.white,
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                          ),
                                        ),
                                        if (langkah.fotoUrl != null)
                                          const Positioned(
                                            top: 8,
                                            right: 8,
                                            child: CircleAvatar(
                                              backgroundColor: Colors.green,
                                              radius: 10,
                                              child: Icon(Icons.check,
                                                  color: Colors.white,
                                                  size: 12),
                                            ),
                                          ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.image_outlined,
                                            size: 18,
                                            color: _brown.withOpacity(0.4)),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Tambah foto langkah (opsional)',
                                          style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: _brown.withOpacity(0.4)),
                                        ),
                                      ],
                                    ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Tombol hapus langkah
                IconButton(
                  onPressed: _langkahList.length > 1
                      ? () {
                          langkah.dispose();
                          setState(() => _langkahList.removeAt(i));
                        }
                      : null,
                  icon: Icon(Icons.delete_outline,
                      color: _langkahList.length > 1
                          ? Colors.grey.shade400
                          : Colors.grey.shade200),
                  iconSize: 22,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ─── Tombol Publikasi ─────────────────────────────────────────────────────
  Widget _buildPublikasiButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _publikasikan,
        style: ElevatedButton.styleFrom(
          backgroundColor: _gold,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _gold.withOpacity(0.5),
          elevation: 4,
          shadowColor: _gold.withOpacity(0.4),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : Text(
                'Publikasikan Karya Rasa',
                style: GoogleFonts.inter(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }

  // ─── TextField Helper ─────────────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? label,
    int maxLines = 1,
    bool compact = false,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor)),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
           keyboardType: keyboardType,
          style: GoogleFonts.inter(fontSize: 13, color: textColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
                fontSize: 13, color: secondaryTextColor),
            filled: true,
            fillColor: cardColor,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: compact ? 12 : 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: Colors.grey.shade100, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _gold, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: Colors.red.shade300, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
            ),
          ),
        ),
        if (label != null) const SizedBox(height: 2),
      ],
    );
  }
}
