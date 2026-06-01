import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/database.dart';
import '../models/pengguna.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = false;
  bool _agreeToTerms = false;
  bool _isLoading = false; // ← tambahan: loading state
  String _selectedGender = 'Laki-laki';
  DateTime? _selectedDate;

  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _pekerjaanController = TextEditingController();

  static const _fieldColor = Color(0xFFEEC170);
  static const _fieldFillColor = Color(0x80EEC170);
  static const _labelStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _pekerjaanController.dispose();
    super.dispose();
  }

  // ── Logika Register ───────────────────────────────────────────────────────
  Future<void> _handleRegister() async {
    final nama = _namaController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validasi field wajib
    if (nama.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackbar('Nama, email, dan password tidak boleh kosong.');
      return;
    }

    // Validasi format email sederhana
    if (!email.contains('@') || !email.contains('.')) {
      _showSnackbar('Format email tidak valid.');
      return;
    }

    // Validasi password minimal 6 karakter
    if (password.length < 6) {
      _showSnackbar('Password minimal 6 karakter.');
      return;
    }

    // Validasi konfirmasi password
    if (password != confirmPassword) {
      _showSnackbar('Password dan konfirmasi password tidak cocok.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final db = Database();

      // Cek email sudah terdaftar
      final emailTerdaftar = await db.isEmailTerdaftar(email);
      if (emailTerdaftar) {
        if (mounted) _showSnackbar('Email sudah terdaftar. Silakan login.');
        return;
      }

      // Buat username dari nama (nama tanpa spasi + angka random kecil)
      final username = nama.toLowerCase().replaceAll(' ', '_') +
          DateTime.now().millisecondsSinceEpoch.toString().substring(9);

      // Buat objek Pengguna baru
      final pengguna = Pengguna(
        nama: nama,
        email: email,
        password: password,
        username: username,
        nomorTelepon: phone.isEmpty ? null : phone,
        jenisKelamin: _selectedGender == 'Laki-laki' ? 'L' : 'P',
        tglLahir: _selectedDate != null ? _formatDate(_selectedDate!) : null,
        role: 'user',
        tglBergabung: DateTime.now().toIso8601String(),
      );

      // Simpan ke database
      await db.insertPengguna(pengguna);

      if (!mounted) return;

      // Tampilkan sukses lalu ke login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Akun berhasil dibuat! Silakan login.'),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      if (mounted) _showSnackbar('Terjadi kesalahan. Silakan coba lagi.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan),
        backgroundColor: const Color(0xFF772F1A),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    String? hint,
    Widget? prefix,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Colors.black54,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: _fieldFillColor,
      prefixIcon: prefix,
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF975A49), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    );
  }

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: _labelStyle),
      );

  Widget _buildTextField(
    TextEditingController controller, {
    String? hint,
    Widget? prefix,
    Widget? suffix,
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      inputFormatters: inputFormatters,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      decoration: _fieldDecoration(hint: hint, prefix: prefix, suffix: suffix),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF772F1A),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  String _formatDateDisplay(DateTime? dt) {
    if (dt == null) return '12/12/2004';
    return _formatDate(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFAF7),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      elevation: 2,
                      shadowColor: Colors.black12,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          Navigator.of(context).pushReplacementNamed('/login');
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.arrow_back,
                            color: Color(0xFF172033),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    'Daftar',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF772F1A),
                    ),
                  ),
                ],
              ),
            ),

            // ── Scrollable Form ──────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama
                    _buildLabel('Nama'),
                    _buildTextField(_namaController, hint: 'Fulan bin Fulan'),
                    const SizedBox(height: 14),

                    // Alamat email
                    _buildLabel('Alamat email'),
                    _buildTextField(
                      _emailController,
                      hint: 'fulanoeser@example.com',
                      keyboard: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),

                    // Nomor Telepon
                    _buildLabel('Nomor Telepon'),
                    _buildTextField(
                      _phoneController,
                      hint: '08123123123',
                      keyboard: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 14),

                    // Password
                    _buildLabel('Password'),
                    _buildTextField(
                      _passwordController,
                      hint: '***********',
                      obscure: _obscurePassword,
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.black54,
                          size: 20,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Konfirmasi Password
                    _buildLabel('Konfirmasi Password'),
                    _buildTextField(
                      _confirmPasswordController,
                      hint: 'Ulangi password',
                      obscure: _obscureConfirmPassword,
                      suffix: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.black54,
                          size: 20,
                        ),
                        onPressed: () => setState(
                          () =>
                              _obscureConfirmPassword = !_obscureConfirmPassword,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Jenis Kelamin
                    _buildLabel('Jenis Kelamin'),
                    Container(
                      decoration: BoxDecoration(
                        color: _fieldFillColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedGender,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.black54,
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          items: ['Laki-laki', 'Perempuan']
                              .map(
                                (g) => DropdownMenuItem(
                                  value: g,
                                  child: Text(g),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _selectedGender = v);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Tanggal Lahir
                    _buildLabel('Tanggal Lahir'),
                    GestureDetector(
                      onTap: _pickDate,
                      child: AbsorbPointer(
                        child: TextField(
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          controller: TextEditingController(
                            text: _formatDateDisplay(_selectedDate),
                          ),
                          decoration: _fieldDecoration(
                            hint: '12/12/2004',
                            prefix: const Icon(
                              Icons.date_range_rounded,
                              color: Colors.black54,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Pekerjaan
                    _buildLabel('Pekerjaan'),
                    _buildTextField(_pekerjaanController, hint: 'Mahasiswa'),
                    const SizedBox(height: 20),

                    // Terms & Conditions
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: Checkbox(
                            value: _agreeToTerms,
                            onChanged: (v) =>
                                setState(() => _agreeToTerms = v ?? false),
                            activeColor: const Color(0xFF772F1A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            side: BorderSide(color: Colors.grey.shade400),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Saya menyetujui Syarat dan Ketentuan serta Kebijakan Privasi yang berlaku.',
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Daftar Button
                    Center(
                      child: SizedBox(
                        width: 160,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: (_agreeToTerms && !_isLoading)
                              ? _handleRegister
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF772F1A),
                            disabledBackgroundColor:
                                const Color(0xFF772F1A).withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'Daftar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}