class SimpanArtikel {
  final int idPengguna;
  final int idArtikel;
  final String tglDisimpan;

  SimpanArtikel({
    required this.idPengguna,
    required this.idArtikel,
    required this.tglDisimpan,
  });

  factory SimpanArtikel.fromMap(Map<String, dynamic> map) {
    return SimpanArtikel(
      idPengguna: map['idPengguna'] as int,
      idArtikel: map['idArtikel'] as int,
      tglDisimpan: map['tglDisimpan'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idPengguna': idPengguna,
      'idArtikel': idArtikel,
      'tglDisimpan': tglDisimpan,
    };
  }
}
