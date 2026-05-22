class Artikel {
  final int? idArtikel;
  final int? idResep; // FK ke ResepMakanan (opsional)
  final String judulArtikel;
  final String isiArtikel;
  final String? fotoArtikel;
  final String tglDibuat;

  Artikel({
    this.idArtikel,
    this.idResep,
    required this.judulArtikel,
    required this.isiArtikel,
    this.fotoArtikel,
    required this.tglDibuat,
  });

  factory Artikel.fromMap(Map<String, dynamic> map) {
    return Artikel(
      idArtikel: map['idArtikel'] as int?,
      idResep: map['idResep'] as int?,
      judulArtikel: map['judulArtikel'] as String,
      isiArtikel: map['isiArtikel'] as String,
      fotoArtikel: map['fotoArtikel'] as String?,
      tglDibuat: map['tglDibuat'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (idArtikel != null) 'idArtikel': idArtikel,
      'idResep': idResep,
      'judulArtikel': judulArtikel,
      'isiArtikel': isiArtikel,
      'fotoArtikel': fotoArtikel,
      'tglDibuat': tglDibuat,
    };
  }
}
