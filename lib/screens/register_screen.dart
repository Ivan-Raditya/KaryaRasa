import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = false;
  bool _agreeToTerms = false;
  final String _selectedGender = 'Laki-laki';

  // Helper function to build form fields
  Widget _buildField({
    required String label,
    required String hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Georgia',
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(238, 193, 112, 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            obscureText: obscureText,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(
                left: prefixIcon == null ? 16 : 0,
                right: 16,
                top: 10,
                bottom: 12,
              ),
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFAF7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              // Header with back button and Title
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF172033),
                        ),
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed('/login');
                        },
                      ),
                    ),
                  ),
                  const Text(
                    'Daftar',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Georgia',
                      color: Color(0xFF772F1A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Form Fields
              _buildField(label: 'Nama', hint: 'Fulan bin Fulan'),
              _buildField(
                label: 'Alamat email',
                hint: 'fulanoeser@example.com',
              ),
              _buildField(label: 'Nomor Telepon', hint: '08123123123'),

              // Password
              _buildField(
                label: 'Password',
                hint: '***********',
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black54,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),

              // Konfirmasi Password
              _buildField(
                label: 'Konfirmasi Password',
                hint: 'fulan123asik',
                obscureText: _obscureConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.black54,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),

              // Jenis Kelamin (Dropdown simulated as field for UI match)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jenis Kelamin',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Georgia',
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(238, 193, 112, 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedGender,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),

              // Tanggal Lahir
              _buildField(
                label: 'Tanggal Lahir',
                hint: '12/12/2004',
                prefixIcon: const Icon(
                  Icons.date_range_rounded,
                  color: Colors.black87,
                  size: 20,
                ),
              ),

              // Pekerjaan
              _buildField(label: 'Pekerjaan', hint: 'Mahasiswa'),

              const SizedBox(height: 8),

              // Terms and Conditions Checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _agreeToTerms,
                      onChanged: (value) {
                        setState(() {
                          _agreeToTerms = value ?? false;
                        });
                      },
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
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Daftar Button
              SizedBox(
                width: 160,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigasi ke layar selanjutnya
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF772F1A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Daftar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
