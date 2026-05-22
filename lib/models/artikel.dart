class Artikel {
  final int? idArtikel;
  final int? idResep;
  final String judulArtikel;
  final String isiArtikel;
  final String? fotoArtikel;
  final String tglDibuat;
  final String penulis;
  final String kategori;
  final String excerpt;
  final int menitBaca;
  bool isSaved;

  Artikel({
    this.idArtikel,
    this.idResep,
    required this.judulArtikel,
    required this.isiArtikel,
    this.fotoArtikel,
    required this.tglDibuat,
    required this.penulis,
    required this.kategori,
    required this.excerpt,
    required this.menitBaca,
    this.isSaved = false,
  });

  factory Artikel.fromMap(Map<String, dynamic> map) {
    return Artikel(
      idArtikel: map['idArtikel'] as int?,
      idResep: map['idResep'] as int?,
      judulArtikel: map['judulArtikel'] as String,
      isiArtikel: map['isiArtikel'] as String,
      fotoArtikel: map['fotoArtikel'] as String?,
      tglDibuat: map['tglDibuat'] as String,
      penulis: map['penulis'] as String? ?? '',
      kategori: map['kategori'] as String? ?? '',
      excerpt: map['excerpt'] as String? ?? '',
      menitBaca: map['menitBaca'] as int? ?? 0,
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
      'penulis': penulis,
      'kategori': kategori,
      'excerpt': excerpt,
      'menitBaca': menitBaca,
    };
  }
}