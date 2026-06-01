class Rating {
  final int idResep;
  final int idPengguna;
  final int suka; // 1 = suka, 0 = tidak suka

  Rating({
    required this.idResep,
    required this.idPengguna,
    required this.suka,
  });

  factory Rating.fromMap(Map<String, dynamic> map) {
    return Rating(
      idResep: map['idResep'] as int,
      idPengguna: map['idPengguna'] as int,
      suka: map['suka'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idResep': idResep,
      'idPengguna': idPengguna,
      'suka': suka,
    };
  }
}
