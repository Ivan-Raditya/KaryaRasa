class Komentar {
  final int? idKomentar;
  final int idResep;
  final int idPengguna;
  final String isiKomentar;
  final int skorRating;
  final String? tglKomentar;

  // Data tambahan untuk UI (didapat dari JOIN)
  final String? namaPengguna;
  final String? fotoProfile;

  Komentar({
    this.idKomentar,
    required this.idResep,
    required this.idPengguna,
    required this.isiKomentar,
    this.skorRating = 5,
    this.tglKomentar,
    this.namaPengguna,
    this.fotoProfile,
  });

  factory Komentar.fromMap(Map<String, dynamic> map) {
    // Menangani data pengguna yang di-join oleh Supabase
    final penggunaData = map['pengguna'] as Map<String, dynamic>?;

    return Komentar(
      idKomentar: map['idKomentar'] as int?,
      idResep: map['idResep'] as int,
      idPengguna: map['idPengguna'] as int,
      isiKomentar: map['isiKomentar'] as String,
      skorRating: map['skor_rating'] as int? ?? 5,
      tglKomentar: map['tglKomentar'] as String?,
      namaPengguna: penggunaData?['nama'] as String?,
      fotoProfile: penggunaData?['fotoProfile'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (idKomentar != null) 'idKomentar': idKomentar,
      'idResep': idResep,
      'idPengguna': idPengguna,
      'isiKomentar': isiKomentar,
      'skor_rating': skorRating,
    };
  }
}
