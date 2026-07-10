class Pengguna {
  final int? idPengguna;
  final String nama;
  final String email;
  final String password;
  final String username;
  final String? nomorTelepon;
  final String? jenisKelamin; // 'L' atau 'P'
  final String? tglLahir;
  final String? fotoProfile;
  final String role; // 'user' atau 'admin'
  final String tglBergabung;
  final String? uid; // Supabase Auth UUID

  Pengguna({
    this.idPengguna,
    required this.nama,
    required this.email,
    required this.password,
    required this.username,
    this.nomorTelepon,
    this.jenisKelamin,
    this.tglLahir,
    this.fotoProfile,
    this.role = 'user',
    required this.tglBergabung,
    this.uid,
  });

  factory Pengguna.fromMap(Map<String, dynamic> map) {
    return Pengguna(
      idPengguna: map['idPengguna'] as int?,
      nama: map['nama'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      username: map['username'] as String,
      nomorTelepon: map['nomorTelepon'] as String?,
      jenisKelamin: map['jenisKelamin'] as String?,
      tglLahir: map['tglLahir'] as String?,
      fotoProfile: map['fotoProfile'] as String?,
      role: map['role'] as String,
      tglBergabung: map['tglBergabung'] as String,
      uid: map['uid'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (idPengguna != null) 'idPengguna': idPengguna,
      'nama': nama,
      'email': email,
      'password': password,
      'username': username,
      'nomorTelepon': nomorTelepon,
      'jenisKelamin': jenisKelamin,
      'tglLahir': tglLahir,
      'fotoProfile': fotoProfile,
      'role': role,
      'tglBergabung': tglBergabung,
      if (uid != null) 'uid': uid,
    };
  }
}
