class HasilRekomendasiAI {
  final int? idHasil;
  final int idKreasi;
  final int skorKecocokan; // 0-100

  HasilRekomendasiAI({
    this.idHasil,
    required this.idKreasi,
    required this.skorKecocokan,
  });

  factory HasilRekomendasiAI.fromMap(Map<String, dynamic> map) {
    return HasilRekomendasiAI(
      idHasil: map['idHasil'] as int?,
      idKreasi: map['idKreasi'] as int,
      skorKecocokan: map['skorKecocokan'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (idHasil != null) 'idHasil': idHasil,
      'idKreasi': idKreasi,
      'skorKecocokan': skorKecocokan,
    };
  }
}
