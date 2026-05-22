class Bookmark {
  final int idResep;
  final int idPengguna;
  final int idBookmark; // FK ke KoleksiBookmark
  final String tglDibuat;

  Bookmark({
    required this.idResep,
    required this.idPengguna,
    required this.idBookmark,
    required this.tglDibuat,
  });

  factory Bookmark.fromMap(Map<String, dynamic> map) {
    return Bookmark(
      idResep: map['idResep'] as int,
      idPengguna: map['idPengguna'] as int,
      idBookmark: map['idBookmark'] as int,
      tglDibuat: map['tglDibuat'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idResep': idResep,
      'idPengguna': idPengguna,
      'idBookmark': idBookmark,
      'tglDibuat': tglDibuat,
    };
  }
}
