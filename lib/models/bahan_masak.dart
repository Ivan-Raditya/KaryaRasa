class BahanMasak {
  final int? idBahan;
  final int idResep;
  final String namaBahan;
  final String jumlah;

  BahanMasak({
    this.idBahan,
    required this.idResep,
    required this.namaBahan,
    required this.jumlah,
  });

  factory BahanMasak.fromMap(Map<String, dynamic> map) {
    return BahanMasak(
      idBahan: map['idBahan'] as int?,
      idResep: map['idResep'] as int,
      namaBahan: map['namaBahan'] as String,
      jumlah: map['jumlah'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (idBahan != null) 'idBahan': idBahan,
      'idResep': idResep,
      'namaBahan': namaBahan,
      'jumlah': jumlah,
    };
  }
}
