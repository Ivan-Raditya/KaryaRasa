class LangkahMasak {
  final int? idLangkah;
  final int idResep;
  final int nomorUrut;
  final String deskripsiLangkah;
  final int? durasi; // dalam menit
  final String? fotoLangkah;

  LangkahMasak({
    this.idLangkah,
    required this.idResep,
    required this.nomorUrut,
    required this.deskripsiLangkah,
    this.durasi,
    this.fotoLangkah,
  });

  factory LangkahMasak.fromMap(Map<String, dynamic> map) {
    return LangkahMasak(
      idLangkah: map['idLangkah'] as int?,
      idResep: map['idResep'] as int,
      nomorUrut: map['nomorUrut'] as int,
      deskripsiLangkah: map['deskripsiLangkah'] as String,
      durasi: map['durasi'] as int?,
      fotoLangkah: map['fotolangkah'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (idLangkah != null) 'idLangkah': idLangkah,
      'idResep': idResep,
      'nomorUrut': nomorUrut,
      'deskripsiLangkah': deskripsiLangkah,
      'durasi': durasi,
      'fotolangkah': fotoLangkah,
    };
  }
}