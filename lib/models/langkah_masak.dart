class LangkahMasak {
  final int? idLangkah;
  final int idResep;
  final int nomorUrut;
  final String judulLangkah;
  final String deskripsiLangkah;
  final int? durasi; // dalam menit

  LangkahMasak({
    this.idLangkah,
    required this.idResep,
    required this.nomorUrut,
    required this.judulLangkah,
    required this.deskripsiLangkah,
    this.durasi,
  });

  factory LangkahMasak.fromMap(Map<String, dynamic> map) {
    return LangkahMasak(
      idLangkah: map['idLangkah'] as int?,
      idResep: map['idResep'] as int,
      nomorUrut: map['nomorUrut'] as int,
      judulLangkah: map['judulLangkah'] as String,
      deskripsiLangkah: map['deskripsiLangkah'] as String,
      durasi: map['durasi'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (idLangkah != null) 'idLangkah': idLangkah,
      'idResep': idResep,
      'nomorUrut': nomorUrut,
      'judulLangkah': judulLangkah,
      'deskripsiLangkah': deskripsiLangkah,
      'durasi': durasi,
    };
  }
}
