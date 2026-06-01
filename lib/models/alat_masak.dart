class AlatMasak {
  final int? idAlat;
  final int idResep;
  final String namaAlat;

  AlatMasak({
    this.idAlat,
    required this.idResep,
    required this.namaAlat,
  });

  factory AlatMasak.fromMap(Map<String, dynamic> map) {
    return AlatMasak(
      idAlat: map['idAlat'] as int?,
      idResep: map['idResep'] as int,
      namaAlat: map['namaAlat'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (idAlat != null) 'idAlat': idAlat,
      'idResep': idResep,
      'namaAlat': namaAlat,
    };
  }
}
