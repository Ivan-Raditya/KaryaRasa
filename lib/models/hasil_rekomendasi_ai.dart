class HasilRekomendasiAI {
  final int? idHasil;
  final int idKreasi;
  final int idResep;        
  final int skorKecocokan; // 0-100

  HasilRekomendasiAI({
    this.idHasil,
    required this.idKreasi,
    required this.idResep,
    required this.skorKecocokan,
  });

  factory HasilRekomendasiAI.fromMap(Map<String, dynamic> map) {
    return HasilRekomendasiAI(
      idHasil: map['idHasil'] as int?,
      idKreasi: map['idKreasi'] as int,
       idResep: map['idResep'] as int, 
      skorKecocokan: map['skorKecocokan'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (idHasil != null) 'idHasil': idHasil,
      'idKreasi': idKreasi,
      'idResep': idResep,  
      'skorKecocokan': skorKecocokan,
    };
  }
}
