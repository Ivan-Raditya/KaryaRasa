import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../database/database.dart';
import '../models/pengguna.dart';
import '../utils/session_manager.dart';
import '../utils/supabase_config.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const _brown = Color(0xFF4A2B20);
  static const _gold = Color(0xFFD9AE23);
  static const _creamBg = Color(0xFFFAF6F1);
  
  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  Color get bgColor => isDark ? const Color(0xFF1E1E1E) : _creamBg;
  Color get cardColor => isDark ? const Color(0xFF2C2C2C) : Colors.white;
  Color get textColor => isDark ? Colors.white : Colors.black87;
  Color get secondaryTextColor => isDark ? Colors.grey[400]! : Colors.grey[600]!;

  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _namaCtrl;
  late TextEditingController _usernameCtrl;
  late TextEditingController _nomorTeleponCtrl;
  
  String? _jenisKelamin;
  String? _tglLahir;
  String? _fotoProfileUrl;
  
  File? _selectedImage;
  bool _isUploading = false;
  bool _isSaving = false;
  
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = SessionManager.instance.penggunaLogin;
    _namaCtrl = TextEditingController(text: user?.nama ?? '');
    _usernameCtrl = TextEditingController(text: user?.username ?? '');
    _nomorTeleponCtrl = TextEditingController(text: user?.nomorTelepon ?? '');
    _jenisKelamin = user?.jenisKelamin;
    _tglLahir = user?.tglLahir;
    _fotoProfileUrl = user?.fotoProfile;
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _usernameCtrl.dispose();
    _nomorTeleponCtrl.dispose();
    super.dispose();
  }

  Future<void> _pilihFoto() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked == null) return;
    
    setState(() {
      _selectedImage = File(picked.path);
      _isUploading = true;
    });
    
    // Upload to Supabase Storage
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_profile.jpg';
      final String path = 'profiles/$fileName';
      
      await supabase.storage.from('avatars').upload(
        path,
        _selectedImage!,
      );
      
      final String publicUrl = supabase.storage.from('avatars').getPublicUrl(path);
      
      setState(() {
        _fotoProfileUrl = publicUrl;
      });
    } catch (e) {
      _showSnack('Terjadi kesalahan saat upload foto: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }
  
  Future<void> _pilihTanggal() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tglLahir != null ? DateTime.tryParse(_tglLahir!) ?? DateTime.now() : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _brown,
              onPrimary: Colors.white,
              onSurface: _brown,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _tglLahir = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _simpanProfil() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    try {
      final session = SessionManager.instance;
      final currentUser = session.penggunaLogin;
      
      if (currentUser == null) throw Exception("Tidak ada sesi user");

      final updatedUser = Pengguna(
        idPengguna: currentUser.idPengguna,
        nama: _namaCtrl.text.trim(),
        email: currentUser.email,
        password: currentUser.password,
        username: _usernameCtrl.text.trim(),
        nomorTelepon: _nomorTeleponCtrl.text.trim(),
        jenisKelamin: _jenisKelamin,
        tglLahir: _tglLahir,
        fotoProfile: _fotoProfileUrl,
        role: currentUser.role,
        tglBergabung: currentUser.tglBergabung,
      );

      final db = Database();
      await db.updatePengguna(updatedUser);
      
      // Update session local
      session.login(updatedUser);
      
      if (mounted) {
        _showSnack('Profil berhasil diperbarui!');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Gagal menyimpan profil: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red[700] : Colors.green[700],
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: _brown,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Edit Profil',
          style: GoogleFonts.playfairDisplay(
            color: _gold,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: _isSaving 
        ? const Center(child: CircularProgressIndicator(color: _brown))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Avatar section
                  GestureDetector(
                    onTap: _isUploading ? null : _pilihFoto,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            shape: BoxShape.circle,
                            border: Border.all(color: _gold, width: 3),
                            image: _selectedImage != null
                              ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
                              : _fotoProfileUrl != null && _fotoProfileUrl!.isNotEmpty
                                ? DecorationImage(image: NetworkImage(_fotoProfileUrl!), fit: BoxFit.cover)
                                : null,
                          ),
                          child: (_selectedImage == null && (_fotoProfileUrl == null || _fotoProfileUrl!.isEmpty))
                              ? const Icon(Icons.person, size: 50, color: Colors.grey)
                              : null,
                        ),
                        if (_isUploading)
                          const CircularProgressIndicator(color: _gold),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _brown,
                              shape: BoxShape.circle,
                              border: Border.all(color: _creamBg, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Form Fields
                  _buildTextField(
                    controller: _namaCtrl,
                    label: 'Nama Lengkap',
                    icon: Icons.person_outline,
                    validator: (v) => v == null || v.isEmpty ? 'Nama tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildTextField(
                    controller: _usernameCtrl,
                    label: 'Username',
                    icon: Icons.alternate_email,
                    validator: (v) => v == null || v.isEmpty ? 'Username tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildTextField(
                    controller: _nomorTeleponCtrl,
                    label: 'Nomor Telepon',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  
                  // Dropdown Jenis Kelamin
                  DropdownButtonFormField<String>(
                    value: _jenisKelamin,
                    decoration: InputDecoration(
                      labelText: 'Jenis Kelamin',
                      prefixIcon: const Icon(Icons.wc, color: _brown),
                      filled: true,
                      fillColor: cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    dropdownColor: cardColor,
                    style: TextStyle(color: textColor, fontSize: 16),
                    items: const [
                      DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
                      DropdownMenuItem(value: 'P', child: Text('Perempuan')),
                    ],
                    onChanged: (val) => setState(() => _jenisKelamin = val),
                  ),
                  const SizedBox(height: 16),
                  
                  // Tanggal Lahir
                  GestureDetector(
                    onTap: _pilihTanggal,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: _brown),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tanggal Lahir', style: TextStyle(fontSize: 12, color: secondaryTextColor)),
                              const SizedBox(height: 4),
                              Text(_tglLahir ?? 'Pilih Tanggal', style: TextStyle(fontSize: 16, color: textColor)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isUploading ? null : _simpanProfil,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _brown,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Simpan Profil',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: secondaryTextColor),
        prefixIcon: Icon(icon, color: _brown),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2C2C2C) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      style: TextStyle(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
      ),
    );
  }
}
