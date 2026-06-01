class ProgresMemasak {
  final int idLangkah;
  final int idPengguna;
  final int statusSelesai; // 1 = selesai, 0 = belum
  final String? tglSelesai;

  ProgresMemasak({
    required this.idLangkah,
    required this.idPengguna,
    required this.statusSelesai,
    this.tglSelesai,
  });

  factory ProgresMemasak.fromMap(Map<String, dynamic> map) {
    return ProgresMemasak(
      idLangkah: map['idLangkah'] as int,
      idPengguna: map['idPengguna'] as int,
      statusSelesai: map['statusSelesai'] as int,
      tglSelesai: map['tglSelesai'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idLangkah': idLangkah,
      'idPengguna': idPengguna,
      'statusSelesai': statusSelesai,
      'tglSelesai': tglSelesai,
    };
  }
}
