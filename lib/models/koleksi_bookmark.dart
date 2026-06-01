class KoleksiBookmark {
  final int? idBookmark;
  final int idPengguna;
  final String judulBookmark;
  final String? deskripsi;

  KoleksiBookmark({
    this.idBookmark,
    required this.idPengguna,
    required this.judulBookmark,
    this.deskripsi,
  });

  factory KoleksiBookmark.fromMap(Map<String, dynamic> map) {
    return KoleksiBookmark(
      idBookmark: map['idBookmark'] as int?,
      idPengguna: map['idPengguna'] as int,
      judulBookmark: map['judulBookmark'] as String,
      deskripsi: map['deskripsi'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (idBookmark != null) 'idBookmark': idBookmark,
      'idPengguna': idPengguna,
      'judulBookmark': judulBookmark,
      'deskripsi': deskripsi,
    };
  }
}
