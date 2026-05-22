import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart';
import '../models/pengguna.dart';
import '../models/resep_makanan.dart';
import '../models/langkah_masak.dart';
import '../models/bahan_masak.dart';
import '../models/alat_masak.dart';
import '../models/rating.dart';
import '../models/koleksi_bookmark.dart';
import '../models/bookmark.dart';
import '../models/artikel.dart';
import '../models/simpan_artikel.dart';
import '../models/riwayat_kreasi_ai.dart';
import '../models/hasil_rekomendasi_ai.dart';
import '../models/progres_memasak.dart';

class Database {
  static final Database _instance = Database._internal();
  factory Database() => _instance;
  Database._internal();

  static sql.Database? _db;

  Future<sql.Database> get db async {
    _db ??= await _initDB();
    return _db!;
  }

  Future<sql.Database> _initDB() async {
    final path = join(await sql.getDatabasesPath(), 'karyarasa.db');
    return await sql.openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  // ── Buat Semua Tabel ─────────────────────────────────────────────────────
  Future<void> _createTables(sql.Database db, int version) async {
    await db.execute('''
      CREATE TABLE Pengguna (
        idPengguna    INTEGER PRIMARY KEY AUTOINCREMENT,
        nama          TEXT    NOT NULL,
        email         TEXT    NOT NULL UNIQUE,
        password      TEXT    NOT NULL,
        username      TEXT    NOT NULL UNIQUE,
        nomorTelepon  TEXT,
        jenisKelamin  TEXT,
        tglLahir      TEXT,
        fotoProfile   TEXT,
        role          TEXT    NOT NULL DEFAULT 'user',
        tglBergabung  TEXT    NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE HasilRekomendasiAI (
        idHasil       INTEGER PRIMARY KEY AUTOINCREMENT,
        idKreasi      INTEGER NOT NULL,
        skorKecocokan INTEGER NOT NULL,
        FOREIGN KEY (idKreasi) REFERENCES RiwayatKreasiAI(idKreasi)
      )
    ''');

    await db.execute('''
      CREATE TABLE ResepMakanan (
        idResep       INTEGER PRIMARY KEY AUTOINCREMENT,
        idHasil       INTEGER,
        namaResep     TEXT    NOT NULL,
        deskripsiResep TEXT   NOT NULL,
        tglDibuat     TEXT    NOT NULL,
        kategoriResep TEXT    NOT NULL,
        asalDaerah    TEXT    NOT NULL,
        fotoResep     TEXT,
        statusResep   TEXT    NOT NULL DEFAULT 'draft',
        tglVerifikasi TEXT,
        FOREIGN KEY (idHasil) REFERENCES HasilRekomendasiAI(idHasil)
      )
    ''');

    await db.execute('''
      CREATE TABLE LangkahMasak (
        idLangkah         INTEGER PRIMARY KEY AUTOINCREMENT,
        idResep           INTEGER NOT NULL,
        nomorUrut         INTEGER NOT NULL,
        judulLangkah      TEXT    NOT NULL,
        deskripsiLangkah  TEXT    NOT NULL,
        durasi            INTEGER,
        FOREIGN KEY (idResep) REFERENCES ResepMakanan(idResep)
      )
    ''');

    await db.execute('''
      CREATE TABLE BahanMasak (
        idBahan     INTEGER PRIMARY KEY AUTOINCREMENT,
        idResep     INTEGER NOT NULL,
        namaBahan   TEXT    NOT NULL,
        jumlah      TEXT    NOT NULL,
        FOREIGN KEY (idResep) REFERENCES ResepMakanan(idResep)
      )
    ''');

    await db.execute('''
      CREATE TABLE AlatMasak (
        idAlat    INTEGER PRIMARY KEY AUTOINCREMENT,
        idResep   INTEGER NOT NULL,
        namaAlat  TEXT    NOT NULL,
        FOREIGN KEY (idResep) REFERENCES ResepMakanan(idResep)
      )
    ''');

    await db.execute('''
      CREATE TABLE Rating (
        idResep     INTEGER NOT NULL,
        idPengguna  INTEGER NOT NULL,
        suka        INTEGER NOT NULL,
        PRIMARY KEY (idResep, idPengguna),
        FOREIGN KEY (idResep)    REFERENCES ResepMakanan(idResep),
        FOREIGN KEY (idPengguna) REFERENCES Pengguna(idPengguna)
      )
    ''');

    await db.execute('''
      CREATE TABLE KoleksiBookmark (
        idBookmark      INTEGER PRIMARY KEY AUTOINCREMENT,
        idPengguna      INTEGER NOT NULL,
        judulBookmark   TEXT    NOT NULL,
        deskripsi       TEXT,
        FOREIGN KEY (idPengguna) REFERENCES Pengguna(idPengguna)
      )
    ''');

    await db.execute('''
      CREATE TABLE Bookmark (
        idResep     INTEGER NOT NULL,
        idPengguna  INTEGER NOT NULL,
        idBookmark  INTEGER NOT NULL,
        tglDibuat   TEXT    NOT NULL,
        PRIMARY KEY (idResep, idPengguna, idBookmark),
        FOREIGN KEY (idResep)    REFERENCES ResepMakanan(idResep),
        FOREIGN KEY (idPengguna) REFERENCES Pengguna(idPengguna),
        FOREIGN KEY (idBookmark) REFERENCES KoleksiBookmark(idBookmark)
      )
    ''');

    await db.execute('''
      CREATE TABLE Artikel (
        idArtikel     INTEGER PRIMARY KEY AUTOINCREMENT,
        idResep       INTEGER,
        judulArtikel  TEXT NOT NULL,
        isiArtikel    TEXT NOT NULL,
        fotoArtikel   TEXT,
        tglDibuat     TEXT NOT NULL,
        FOREIGN KEY (idResep) REFERENCES ResepMakanan(idResep)
      )
    ''');

    await db.execute('''
      CREATE TABLE SimpanArtikel (
        idPengguna  INTEGER NOT NULL,
        idArtikel   INTEGER NOT NULL,
        tglDisimpan TEXT    NOT NULL,
        PRIMARY KEY (idPengguna, idArtikel),
        FOREIGN KEY (idPengguna) REFERENCES Pengguna(idPengguna),
        FOREIGN KEY (idArtikel)  REFERENCES Artikel(idArtikel)
      )
    ''');

    await db.execute('''
      CREATE TABLE RiwayatKreasiAI (
        idKreasi    INTEGER PRIMARY KEY AUTOINCREMENT,
        idPengguna  INTEGER NOT NULL,
        bahanInput  TEXT    NOT NULL,
        FOREIGN KEY (idPengguna) REFERENCES Pengguna(idPengguna)
      )
    ''');

    await db.execute('''
      CREATE TABLE ProgresMemasak (
        idLangkah     INTEGER NOT NULL,
        idPengguna    INTEGER NOT NULL,
        statusSelesai INTEGER NOT NULL DEFAULT 0,
        tglSelesai    TEXT,
        PRIMARY KEY (idLangkah, idPengguna),
        FOREIGN KEY (idLangkah)  REFERENCES LangkahMasak(idLangkah),
        FOREIGN KEY (idPengguna) REFERENCES Pengguna(idPengguna)
      )
    ''');

    // Isi data awal
    await _seedData(db);
  }

  // ── Seed Data ─────────────────────────────────────────────────────────────
  Future<void> _seedData(sql.Database db) async {
    // Admin
    await db.insert('Pengguna', {
      'nama': 'Admin KaryaRasa',
      'email': 'admin@karyarasa.com',
      'password': 'admin123',
      'username': 'admin',
      'role': 'admin',
      'tglBergabung': '2026-01-01',
    });

    // Resep 1 - Rendang
    final idRendang = await db.insert('ResepMakanan', {
      'namaResep': 'Rendang Daging Sapi',
      'deskripsiResep': 'Masakan daging sapi berbumbu rempah khas Minangkabau yang dimasak perlahan hingga kering dan berwarna cokelat kehitaman.',
      'tglDibuat': '2026-01-01',
      'kategoriResep': 'Makanan',
      'asalDaerah': 'Sumatera Barat',
      'fotoResep': 'https://images.unsplash.com/photo-1574653853027-5382a3d23a15?auto=format&fit=crop&w=800&q=80',
      'statusResep': 'disetujui',
      'tglVerifikasi': '2026-01-02',
    });

    await db.insert('BahanMasak', {'idResep': idRendang, 'namaBahan': 'Daging sapi', 'jumlah': '1 kg'});
    await db.insert('BahanMasak', {'idResep': idRendang, 'namaBahan': 'Santan kental', 'jumlah': '1 liter'});
    await db.insert('BahanMasak', {'idResep': idRendang, 'namaBahan': 'Cabai merah', 'jumlah': '200 gram'});
    await db.insert('BahanMasak', {'idResep': idRendang, 'namaBahan': 'Bawang merah', 'jumlah': '10 siung'});
    await db.insert('BahanMasak', {'idResep': idRendang, 'namaBahan': 'Bawang putih', 'jumlah': '5 siung'});
    await db.insert('BahanMasak', {'idResep': idRendang, 'namaBahan': 'Serai', 'jumlah': '3 batang'});
    await db.insert('BahanMasak', {'idResep': idRendang, 'namaBahan': 'Daun jeruk', 'jumlah': '5 lembar'});
    await db.insert('BahanMasak', {'idResep': idRendang, 'namaBahan': 'Lengkuas', 'jumlah': '3 cm'});

    await db.insert('AlatMasak', {'idResep': idRendang, 'namaAlat': 'Wajan besar'});
    await db.insert('AlatMasak', {'idResep': idRendang, 'namaAlat': 'Cobek dan ulekan'});
    await db.insert('AlatMasak', {'idResep': idRendang, 'namaAlat': 'Spatula kayu'});

    await db.insert('LangkahMasak', {'idResep': idRendang, 'nomorUrut': 1, 'judulLangkah': 'Haluskan bumbu', 'deskripsiLangkah': 'Haluskan cabai merah, bawang merah, bawang putih, dan lengkuas menggunakan cobek atau blender.', 'durasi': 10});
    await db.insert('LangkahMasak', {'idResep': idRendang, 'nomorUrut': 2, 'judulLangkah': 'Tumis bumbu', 'deskripsiLangkah': 'Panaskan wajan, tumis bumbu halus bersama serai dan daun jeruk hingga harum dan matang.', 'durasi': 15});
    await db.insert('LangkahMasak', {'idResep': idRendang, 'nomorUrut': 3, 'judulLangkah': 'Masukkan daging', 'deskripsiLangkah': 'Masukkan potongan daging sapi, aduk hingga berubah warna dan tercampur rata dengan bumbu.', 'durasi': 10});
    await db.insert('LangkahMasak', {'idResep': idRendang, 'nomorUrut': 4, 'judulLangkah': 'Tuang santan', 'deskripsiLangkah': 'Tuangkan santan kental, aduk perlahan dan masak dengan api sedang. Jangan biarkan santan pecah.', 'durasi': 20});
    await db.insert('LangkahMasak', {'idResep': idRendang, 'nomorUrut': 5, 'judulLangkah': 'Masak hingga kering', 'deskripsiLangkah': 'Kecilkan api dan masak terus sambil diaduk sesekali hingga santan menyusut dan daging berwarna cokelat kehitaman.', 'durasi': 120});

    // Resep 2 - Soto Betawi
    final idSoto = await db.insert('ResepMakanan', {
      'namaResep': 'Soto Betawi',
      'deskripsiResep': 'Soto khas Betawi dengan kuah santan gurih yang kaya rempah, berisi daging sapi dan jeroan.',
      'tglDibuat': '2026-01-01',
      'kategoriResep': 'Makanan',
      'asalDaerah': 'DKI Jakarta',
      'fotoResep': 'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=800&q=80',
      'statusResep': 'disetujui',
      'tglVerifikasi': '2026-01-02',
    });

    await db.insert('BahanMasak', {'idResep': idSoto, 'namaBahan': 'Daging sapi', 'jumlah': '500 gram'});
    await db.insert('BahanMasak', {'idResep': idSoto, 'namaBahan': 'Santan', 'jumlah': '500 ml'});
    await db.insert('BahanMasak', {'idResep': idSoto, 'namaBahan': 'Bawang merah', 'jumlah': '8 siung'});
    await db.insert('BahanMasak', {'idResep': idSoto, 'namaBahan': 'Bawang putih', 'jumlah': '4 siung'});
    await db.insert('BahanMasak', {'idResep': idSoto, 'namaBahan': 'Jahe', 'jumlah': '2 cm'});

    await db.insert('AlatMasak', {'idResep': idSoto, 'namaAlat': 'Panci besar'});
    await db.insert('AlatMasak', {'idResep': idSoto, 'namaAlat': 'Blender'});

    await db.insert('LangkahMasak', {'idResep': idSoto, 'nomorUrut': 1, 'judulLangkah': 'Rebus daging', 'deskripsiLangkah': 'Rebus daging sapi hingga empuk, sisihkan kaldu rebusannya.', 'durasi': 60});
    await db.insert('LangkahMasak', {'idResep': idSoto, 'nomorUrut': 2, 'judulLangkah': 'Haluskan bumbu', 'deskripsiLangkah': 'Haluskan bawang merah, bawang putih, dan jahe.', 'durasi': 5});
    await db.insert('LangkahMasak', {'idResep': idSoto, 'nomorUrut': 3, 'judulLangkah': 'Tumis dan kuah', 'deskripsiLangkah': 'Tumis bumbu halus hingga harum, masukkan ke kaldu, tuang santan dan masak hingga mendidih.', 'durasi': 20});

    // Resep 3 - Gudeg
    final idGudeg = await db.insert('ResepMakanan', {
      'namaResep': 'Gudeg Jogja',
      'deskripsiResep': 'Masakan khas Yogyakarta dari nangka muda yang dimasak dengan santan dan gula merah hingga berwarna cokelat manis.',
      'tglDibuat': '2026-01-01',
      'kategoriResep': 'Makanan',
      'asalDaerah': 'Yogyakarta',
      'fotoResep': 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?auto=format&fit=crop&w=800&q=80',
      'statusResep': 'disetujui',
      'tglVerifikasi': '2026-01-02',
    });

    await db.insert('BahanMasak', {'idResep': idGudeg, 'namaBahan': 'Nangka muda', 'jumlah': '1 kg'});
    await db.insert('BahanMasak', {'idResep': idGudeg, 'namaBahan': 'Santan', 'jumlah': '500 ml'});
    await db.insert('BahanMasak', {'idResep': idGudeg, 'namaBahan': 'Gula merah', 'jumlah': '200 gram'});
    await db.insert('BahanMasak', {'idResep': idGudeg, 'namaBahan': 'Daun salam', 'jumlah': '3 lembar'});

    await db.insert('AlatMasak', {'idResep': idGudeg, 'namaAlat': 'Panci presto'});
    await db.insert('AlatMasak', {'idResep': idGudeg, 'namaAlat': 'Wajan'});

    await db.insert('LangkahMasak', {'idResep': idGudeg, 'nomorUrut': 1, 'judulLangkah': 'Siapkan nangka', 'deskripsiLangkah': 'Potong nangka muda menjadi potongan kecil, rebus sebentar untuk menghilangkan getah.', 'durasi': 15});
    await db.insert('LangkahMasak', {'idResep': idGudeg, 'nomorUrut': 2, 'judulLangkah': 'Masak dengan santan', 'deskripsiLangkah': 'Masukkan nangka, santan, gula merah, dan daun salam. Masak dengan api kecil sambil sesekali diaduk.', 'durasi': 90});
    await db.insert('LangkahMasak', {'idResep': idGudeg, 'nomorUrut': 3, 'judulLangkah': 'Masak hingga meresap', 'deskripsiLangkah': 'Lanjutkan memasak hingga santan menyusut dan bumbu meresap sempurna ke nangka.', 'durasi': 60});

    // Resep 4 - Ayam Betutu
    final idBetutu = await db.insert('ResepMakanan', {
      'namaResep': 'Ayam Betutu',
      'deskripsiResep': 'Masakan ayam khas Bali yang dibumbui base genep dan dimasak dengan cara dipanggang atau dikukus hingga bumbu meresap sempurna.',
      'tglDibuat': '2026-01-01',
      'kategoriResep': 'Makanan',
      'asalDaerah': 'Bali',
      'fotoResep': 'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?auto=format&fit=crop&w=800&q=80',
      'statusResep': 'disetujui',
      'tglVerifikasi': '2026-01-02',
    });

    await db.insert('BahanMasak', {'idResep': idBetutu, 'namaBahan': 'Ayam utuh', 'jumlah': '1 ekor'});
    await db.insert('BahanMasak', {'idResep': idBetutu, 'namaBahan': 'Cabai rawit', 'jumlah': '50 gram'});
    await db.insert('BahanMasak', {'idResep': idBetutu, 'namaBahan': 'Kunyit', 'jumlah': '3 cm'});
    await db.insert('BahanMasak', {'idResep': idBetutu, 'namaBahan': 'Kencur', 'jumlah': '2 cm'});

    await db.insert('AlatMasak', {'idResep': idBetutu, 'namaAlat': 'Daun pisang'});
    await db.insert('AlatMasak', {'idResep': idBetutu, 'namaAlat': 'Kukusan'});

    await db.insert('LangkahMasak', {'idResep': idBetutu, 'nomorUrut': 1, 'judulLangkah': 'Haluskan bumbu', 'deskripsiLangkah': 'Haluskan semua bumbu base genep termasuk cabai, kunyit, dan kencur.', 'durasi': 15});
    await db.insert('LangkahMasak', {'idResep': idBetutu, 'nomorUrut': 2, 'judulLangkah': 'Lumuri ayam', 'deskripsiLangkah': 'Lumuri seluruh bagian ayam dengan bumbu halus, masukkan juga bumbu ke dalam rongga ayam.', 'durasi': 10});
    await db.insert('LangkahMasak', {'idResep': idBetutu, 'nomorUrut': 3, 'judulLangkah': 'Bungkus dan kukus', 'deskripsiLangkah': 'Bungkus ayam dengan daun pisang lalu kukus selama 2 jam hingga matang sempurna.', 'durasi': 120});

    // Artikel
    await db.insert('Artikel', {
      'idResep': idRendang,
      'judulArtikel': 'Rendang: Warisan Kuliner Dunia dari Minangkabau',
      'isiArtikel': 'Rendang adalah masakan tradisional Minangkabau yang telah diakui sebagai salah satu makanan terlezat di dunia. Proses memasaknya yang panjang dan penggunaan rempah yang melimpah menjadikan rendang memiliki cita rasa yang khas dan tahan lama.',
      'fotoArtikel': 'https://images.unsplash.com/photo-1574653853027-5382a3d23a15?auto=format&fit=crop&w=800&q=80',
      'tglDibuat': '2026-01-01',
    });

    await db.insert('Artikel', {
      'idResep': idBetutu,
      'judulArtikel': 'Ayam Betutu: Puncak Kelezatan Rempah dari Pulau Dewata',
      'isiArtikel': 'Ayam Betutu adalah hidangan legendaris Bali dengan bumbu rempah yang kaya dan meresap sempurna. Nama "betutu" berasal dari kata "tunu" yang berarti dibakar dalam bahasa Bali.',
      'fotoArtikel': 'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?auto=format&fit=crop&w=800&q=80',
      'tglDibuat': '2026-01-02',
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PENGGUNA
  // ══════════════════════════════════════════════════════════════════════════

  Future<int> insertPengguna(Pengguna pengguna) async {
    final database = await db;
    return await database.insert('Pengguna', pengguna.toMap());
  }

  Future<Pengguna?> loginPengguna(String email, String password) async {
    final database = await db;
    final result = await database.query(
      'Pengguna',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (result.isEmpty) return null;
    return Pengguna.fromMap(result.first);
  }

  Future<Pengguna?> getPenggunaById(int id) async {
    final database = await db;
    final result = await database.query(
      'Pengguna',
      where: 'idPengguna = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Pengguna.fromMap(result.first);
  }

  Future<bool> isEmailTerdaftar(String email) async {
    final database = await db;
    final result = await database.query(
      'Pengguna',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }

  Future<int> updatePengguna(Pengguna pengguna) async {
    final database = await db;
    return await database.update(
      'Pengguna',
      pengguna.toMap(),
      where: 'idPengguna = ?',
      whereArgs: [pengguna.idPengguna],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // RESEP MAKANAN
  // ══════════════════════════════════════════════════════════════════════════

  Future<int> insertResep(ResepMakanan resep) async {
    final database = await db;
    return await database.insert('ResepMakanan', resep.toMap());
  }

  Future<List<ResepMakanan>> getAllResep() async {
    final database = await db;
    final result = await database.query(
      'ResepMakanan',
      where: 'statusResep = ?',
      whereArgs: ['disetujui'],
    );
    return result.map((e) => ResepMakanan.fromMap(e)).toList();
  }

  Future<List<ResepMakanan>> getResepByKategori(String kategori) async {
    final database = await db;
    final result = await database.query(
      'ResepMakanan',
      where: 'kategoriResep = ? AND statusResep = ?',
      whereArgs: [kategori, 'disetujui'],
    );
    return result.map((e) => ResepMakanan.fromMap(e)).toList();
  }

  Future<List<ResepMakanan>> getResepByDaerah(String daerah) async {
    final database = await db;
    final result = await database.query(
      'ResepMakanan',
      where: 'asalDaerah = ? AND statusResep = ?',
      whereArgs: [daerah, 'disetujui'],
    );
    return result.map((e) => ResepMakanan.fromMap(e)).toList();
  }

  Future<List<ResepMakanan>> cariResep(String keyword) async {
    final database = await db;
    final result = await database.query(
      'ResepMakanan',
      where: '(namaResep LIKE ? OR asalDaerah LIKE ?) AND statusResep = ?',
      whereArgs: ['%$keyword%', '%$keyword%', 'disetujui'],
    );
    return result.map((e) => ResepMakanan.fromMap(e)).toList();
  }

  Future<ResepMakanan?> getResepById(int id) async {
    final database = await db;
    final result = await database.query(
      'ResepMakanan',
      where: 'idResep = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return ResepMakanan.fromMap(result.first);
  }

  Future<List<ResepMakanan>> getResepMenungguVerifikasi() async {
    final database = await db;
    final result = await database.query(
      'ResepMakanan',
      where: 'statusResep = ?',
      whereArgs: ['menunggu'],
    );
    return result.map((e) => ResepMakanan.fromMap(e)).toList();
  }

  Future<int> updateStatusResep(int idResep, String status) async {
    final database = await db;
    return await database.update(
      'ResepMakanan',
      {
        'statusResep': status,
        'tglVerifikasi': DateTime.now().toIso8601String().substring(0, 10),
      },
      where: 'idResep = ?',
      whereArgs: [idResep],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LANGKAH MASAK
  // ══════════════════════════════════════════════════════════════════════════

  Future<int> insertLangkah(LangkahMasak langkah) async {
    final database = await db;
    return await database.insert('LangkahMasak', langkah.toMap());
  }

  Future<List<LangkahMasak>> getLangkahByResep(int idResep) async {
    final database = await db;
    final result = await database.query(
      'LangkahMasak',
      where: 'idResep = ?',
      whereArgs: [idResep],
      orderBy: 'nomorUrut ASC',
    );
    return result.map((e) => LangkahMasak.fromMap(e)).toList();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BAHAN MASAK
  // ══════════════════════════════════════════════════════════════════════════

  Future<int> insertBahan(BahanMasak bahan) async {
    final database = await db;
    return await database.insert('BahanMasak', bahan.toMap());
  }

  Future<List<BahanMasak>> getBahanByResep(int idResep) async {
    final database = await db;
    final result = await database.query(
      'BahanMasak',
      where: 'idResep = ?',
      whereArgs: [idResep],
    );
    return result.map((e) => BahanMasak.fromMap(e)).toList();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ALAT MASAK
  // ══════════════════════════════════════════════════════════════════════════

  Future<int> insertAlat(AlatMasak alat) async {
    final database = await db;
    return await database.insert('AlatMasak', alat.toMap());
  }

  Future<List<AlatMasak>> getAlatByResep(int idResep) async {
    final database = await db;
    final result = await database.query(
      'AlatMasak',
      where: 'idResep = ?',
      whereArgs: [idResep],
    );
    return result.map((e) => AlatMasak.fromMap(e)).toList();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // RATING
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> insertOrUpdateRating(Rating rating) async {
    final database = await db;
    await database.insert(
      'Rating',
      rating.toMap(),
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );
  }

  Future<int> getJumlahSuka(int idResep) async {
    final database = await db;
    final result = await database.query(
      'Rating',
      where: 'idResep = ? AND suka = 1',
      whereArgs: [idResep],
    );
    return result.length;
  }

  Future<Rating?> getRatingUser(int idResep, int idPengguna) async {
    final database = await db;
    final result = await database.query(
      'Rating',
      where: 'idResep = ? AND idPengguna = ?',
      whereArgs: [idResep, idPengguna],
    );
    if (result.isEmpty) return null;
    return Rating.fromMap(result.first);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // KOLEKSI BOOKMARK
  // ══════════════════════════════════════════════════════════════════════════

  Future<int> insertKoleksi(KoleksiBookmark koleksi) async {
    final database = await db;
    return await database.insert('KoleksiBookmark', koleksi.toMap());
  }

  Future<List<KoleksiBookmark>> getKoleksiByPengguna(int idPengguna) async {
    final database = await db;
    final result = await database.query(
      'KoleksiBookmark',
      where: 'idPengguna = ?',
      whereArgs: [idPengguna],
    );
    return result.map((e) => KoleksiBookmark.fromMap(e)).toList();
  }

  Future<int> deleteKoleksi(int idBookmark) async {
    final database = await db;
    return await database.delete(
      'KoleksiBookmark',
      where: 'idBookmark = ?',
      whereArgs: [idBookmark],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BOOKMARK
  // ══════════════════════════════════════════════════════════════════════════

  Future<int> insertBookmark(Bookmark bookmark) async {
    final database = await db;
    return await database.insert('Bookmark', bookmark.toMap());
  }

  Future<List<ResepMakanan>> getResepBookmarkByPengguna(int idPengguna) async {
    final database = await db;
    final result = await database.rawQuery('''
      SELECT r.* FROM ResepMakanan r
      INNER JOIN Bookmark b ON r.idResep = b.idResep
      WHERE b.idPengguna = ?
    ''', [idPengguna]);
    return result.map((e) => ResepMakanan.fromMap(e)).toList();
  }

  Future<bool> isResepDibookmark(int idResep, int idPengguna) async {
    final database = await db;
    final result = await database.query(
      'Bookmark',
      where: 'idResep = ? AND idPengguna = ?',
      whereArgs: [idResep, idPengguna],
    );
    return result.isNotEmpty;
  }

  Future<int> deleteBookmark(int idResep, int idPengguna) async {
    final database = await db;
    return await database.delete(
      'Bookmark',
      where: 'idResep = ? AND idPengguna = ?',
      whereArgs: [idResep, idPengguna],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ARTIKEL
  // ══════════════════════════════════════════════════════════════════════════

  Future<int> insertArtikel(Artikel artikel) async {
    final database = await db;
    return await database.insert('Artikel', artikel.toMap());
  }

  Future<List<Artikel>> getAllArtikel() async {
    final database = await db;
    final result = await database.query('Artikel', orderBy: 'tglDibuat DESC');
    return result.map((e) => Artikel.fromMap(e)).toList();
  }

  Future<Artikel?> getArtikelById(int id) async {
    final database = await db;
    final result = await database.query(
      'Artikel',
      where: 'idArtikel = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Artikel.fromMap(result.first);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SIMPAN ARTIKEL
  // ══════════════════════════════════════════════════════════════════════════

  Future<int> simpanArtikel(SimpanArtikel simpan) async {
    final database = await db;
    return await database.insert('SimpanArtikel', simpan.toMap());
  }

  Future<List<Artikel>> getArtikelDisimpanByPengguna(int idPengguna) async {
    final database = await db;
    final result = await database.rawQuery('''
      SELECT a.* FROM Artikel a
      INNER JOIN SimpanArtikel s ON a.idArtikel = s.idArtikel
      WHERE s.idPengguna = ?
    ''', [idPengguna]);
    return result.map((e) => Artikel.fromMap(e)).toList();
  }

  Future<int> hapusSimpanArtikel(int idPengguna, int idArtikel) async {
    final database = await db;
    return await database.delete(
      'SimpanArtikel',
      where: 'idPengguna = ? AND idArtikel = ?',
      whereArgs: [idPengguna, idArtikel],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // RIWAYAT KREASI AI
  // ══════════════════════════════════════════════════════════════════════════

  Future<int> insertKreasi(RiwayatKreasiAI kreasi) async {
    final database = await db;
    return await database.insert('RiwayatKreasiAI', kreasi.toMap());
  }

  Future<List<RiwayatKreasiAI>> getRiwayatKreasiByPengguna(int idPengguna) async {
    final database = await db;
    final result = await database.query(
      'RiwayatKreasiAI',
      where: 'idPengguna = ?',
      whereArgs: [idPengguna],
      orderBy: 'idKreasi DESC',
    );
    return result.map((e) => RiwayatKreasiAI.fromMap(e)).toList();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HASIL REKOMENDASI AI
  // ══════════════════════════════════════════════════════════════════════════

  Future<int> insertHasilAI(HasilRekomendasiAI hasil) async {
    final database = await db;
    return await database.insert('HasilRekomendasiAI', hasil.toMap());
  }

  Future<List<ResepMakanan>> getResepRekomendasiAI(int idKreasi) async {
    final database = await db;
    final result = await database.rawQuery('''
      SELECT r.*, h.skorKecocokan FROM ResepMakanan r
      INNER JOIN HasilRekomendasiAI h ON r.idHasil = h.idHasil
      WHERE h.idKreasi = ?
      ORDER BY h.skorKecocokan DESC
    ''', [idKreasi]);
    return result.map((e) => ResepMakanan.fromMap(e)).toList();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PROGRES MEMASAK
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> updateProgres(ProgresMemasak progres) async {
    final database = await db;
    await database.insert(
      'ProgresMemasak',
      progres.toMap(),
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );
  }

  Future<List<ProgresMemasak>> getProgresByResepDanPengguna(
      int idResep, int idPengguna) async {
    final database = await db;
    final result = await database.rawQuery('''
      SELECT p.* FROM ProgresMemasak p
      INNER JOIN LangkahMasak l ON p.idLangkah = l.idLangkah
      WHERE l.idResep = ? AND p.idPengguna = ?
    ''', [idResep, idPengguna]);
    return result.map((e) => ProgresMemasak.fromMap(e)).toList();
  }

  Future<void> resetProgres(int idResep, int idPengguna) async {
    final database = await db;
    await database.rawDelete('''
      DELETE FROM ProgresMemasak
      WHERE idPengguna = ? AND idLangkah IN (
        SELECT idLangkah FROM LangkahMasak WHERE idResep = ?
      )
    ''', [idPengguna, idResep]);
  }
}
