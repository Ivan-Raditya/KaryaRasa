class ResepMakanan {
  final int? idResep;
  final int? idHasil; // FK ke HasilRekomendasiAI
  final String namaResep;
  final String deskripsiResep;
  final String tglDibuat;
  final String kategoriResep; // 'Makanan', 'Minuman', 'Camilan'
  final String asalDaerah;
  final String? fotoResep;
  final String statusResep; // 'draft', 'menunggu', 'disetujui', 'ditolak'
  final String? tglVerifikasi;

  ResepMakanan({
    this.idResep,
    this.idHasil,
    required this.namaResep,
    required this.deskripsiResep,
    required this.tglDibuat,
    required this.kategoriResep,
    required this.asalDaerah,
    this.fotoResep,
    this.statusResep = 'draft',
    this.tglVerifikasi,
  });

  factory ResepMakanan.fromMap(Map<String, dynamic> map) {
    return ResepMakanan(
      idResep: map['idResep'] as int?,
      idHasil: map['idHasil'] as int?,
      namaResep: map['namaResep'] as String,
      deskripsiResep: map['deskripsiResep'] as String,
      tglDibuat: map['tglDibuat'] as String,
      kategoriResep: map['kategoriResep'] as String,
      asalDaerah: map['asalDaerah'] as String,
      fotoResep: map['fotoResep'] as String?,
      statusResep: map['statusResep'] as String,
      tglVerifikasi: map['tglVerifikasi'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (idResep != null) 'idResep': idResep,
      'idHasil': idHasil,
      'namaResep': namaResep,
      'deskripsiResep': deskripsiResep,
      'tglDibuat': tglDibuat,
      'kategoriResep': kategoriResep,
      'asalDaerah': asalDaerah,
      'fotoResep': fotoResep,
      'statusResep': statusResep,
      'tglVerifikasi': tglVerifikasi,
    };
  }
}
