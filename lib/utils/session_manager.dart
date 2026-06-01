import '../models/pengguna.dart';

/// Menyimpan data pengguna yang sedang login selama app berjalan.
/// Diakses dari mana saja via SessionManager.instance
class SessionManager {
  static final SessionManager instance = SessionManager._internal();
  SessionManager._internal();

  Pengguna? _penggunaLogin;

  // Pengguna yang sedang login (null jika belum login)
  Pengguna? get penggunaLogin => _penggunaLogin;

  // ID pengguna yang login (null jika belum login)
  int? get idPengguna => _penggunaLogin?.idPengguna;

  // Nama pengguna yang login
  String get nama => _penggunaLogin?.nama ?? '';

  // Apakah sudah login
  bool get sudahLogin => _penggunaLogin != null;

  /// Dipanggil saat login berhasil
  void login(Pengguna pengguna) {
    _penggunaLogin = pengguna;
  }

  /// Dipanggil saat logout
  void logout() {
    _penggunaLogin = null;
  }
}
