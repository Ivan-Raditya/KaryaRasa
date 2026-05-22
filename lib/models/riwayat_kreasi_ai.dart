class RiwayatKreasiAI {
  final int? idKreasi;
  final int idPengguna;
  final String bahanInput;

  RiwayatKreasiAI({
    this.idKreasi,
    required this.idPengguna,
    required this.bahanInput,
  });

  factory RiwayatKreasiAI.fromMap(Map<String, dynamic> map) {
    return RiwayatKreasiAI(
      idKreasi: map['idKreasi'] as int?,
      idPengguna: map['idPengguna'] as int,
      bahanInput: map['bahanInput'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (idKreasi != null) 'idKreasi': idKreasi,
      'idPengguna': idPengguna,
      'bahanInput': bahanInput,
    };
  }
}
