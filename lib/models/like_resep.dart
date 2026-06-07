class LikeResep {
  final int? idLike;
  final int idResep;
  final int idPengguna;
  final String tglLike;

  LikeResep({
    this.idLike,
    required this.idResep,
    required this.idPengguna,
    required this.tglLike,
  });

  factory LikeResep.fromMap(Map<String, dynamic> map) {
    return LikeResep(
      idLike: map['idLike'] as int?,
      idResep: map['idResep'] as int,
      idPengguna: map['idPengguna'] as int,
      tglLike: map['tglLike'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (idLike != null) 'idLike': idLike,
      'idResep': idResep,
      'idPengguna': idPengguna,
      'tglLike': tglLike,
    };
  }
}