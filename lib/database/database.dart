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
import '../utils/supabase_config.dart';

class Database {
  static final Database _instance = Database._internal();
  factory Database() => _instance;
  Database._internal();

  // ══════════════════════════════════════════════════════════════════════════
  // PENGGUNA
  // ══════════════════════════════════════════════════════════════════════════

  Future<int> insertPengguna(Pengguna pengguna) async {
    final result = await supabase
        .from('pengguna')
        .insert(pengguna.toMap())
        .select('idPengguna')
        .single();
    return result['idPengguna'] as int;
  }

  Future<Pengguna?> loginPengguna(String email, String password) async {
    final result = await supabase
        .from('pengguna')
        .select()
        .eq('email', email)
        .eq('password', password)
        .maybeSingle();
    if (result == null) return null;
    return Pengguna.fromMap(result);
  }

  Future<Pengguna?> getPenggunaById(int id) async {
    final result = await supabase
        .from('pengguna')
        .select()
        .eq('idPengguna', id)
        .maybeSingle();
    if (result == null) return null;
    return Pengguna.fromMap(result);
  }

  Future<Pengguna?> getPenggunaByEmail(String email) async {
    final result = await supabase
        .from('pengguna')
        .select()
        .eq('email', email)
        .maybeSingle();
    if (result == null) return null;
    return Pengguna.fromMap(result);
  }

    Future<bool> isEmailTerdaftar(String email) async {
    final result = await supabase
        .from('pengguna')
        .select('idPengguna')
        .eq('email', email)
        .maybeSingle();
    return result != null;
  }

  Future<void> updatePengguna(Pengguna pengguna) async {
    await supabase
        .from('pengguna')
        .update(pengguna.toMap())
        .eq('idPengguna', pengguna.idPengguna!);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // RESEP MAKANAN
  // ══════════════════════════════════════════════════════════════════════════

  Future<int> insertResep(ResepMakanan resep) async {
    final result = await supabase
        .from('resepmakanan')
        .insert(resep.toMap())
        .select('idResep')
        .single();
    return result['idResep'] as int;
  }

  Future<List<ResepMakanan>> getAllResep() async {
    final result = await supabase
        .from('resepmakanan')
        .select()
        .eq('statusResep', 'disetujui');
    return (result as List).map((e) => ResepMakanan.fromMap(e)).toList();
  }

  Future<List<ResepMakanan>> getResepByKategori(String kategori) async {
    final result = await supabase
        .from('resepmakanan')
        .select()
        .eq('kategoriResep', kategori)
        .eq('statusResep', 'disetujui');
    return (result as List).map((e) => ResepMakanan.fromMap(e)).toList();
  }

  Future<List<ResepMakanan>> getResepByDaerah(String daerah) async {
    final result = await supabase
        .from('resepmakanan')
        .select()
        .eq('asalDaerah', daerah)
        .eq('statusResep', 'disetujui');
    return (result as List).map((e) => ResepMakanan.fromMap(e)).toList();
  }

  Future<List<ResepMakanan>> cariResep(String keyword) async {
    final result = await supabase
        .from('resepmakanan')
        .select()
        .eq('statusResep', 'disetujui')
        .or('namaResep.ilike.%$keyword%,asalDaerah.ilike.%$keyword%');
    return (result as List).map((e) => ResepMakanan.fromMap(e)).toList();
  }

  Future<ResepMakanan?> getResepById(int id) async {
    final result = await supabase
        .from('resepmakanan')
        .select()
        .eq('idResep', id)
        .maybeSingle();
    if (result == null) return null;
    return ResepMakanan.fromMap(result);
  }

  Future<List<ResepMakanan>> getResepMenungguVerifikasi() async {
    final result = await supabase
        .from('resepmakanan')
        .select()
        .eq('statusResep', 'menunggu');
    return (result as List).map((e) => ResepMakanan.fromMap(e)).toList();
  }

  Future<void> updateStatusResep(int idResep, String status) async {
    await supabase
        .from('resepmakanan')
        .update({
          'statusResep': status,
          'tglVerifikasi': DateTime.now().toIso8601String().substring(0, 10),
        })
        .eq('idResep', idResep);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LANGKAH MASAK
  // ══════════════════════════════════════════════════════════════════════════

  Future<int> insertLangkah(LangkahMasak langkah) async {
    final result = await supabase
        .from('langkahmasak')
        .insert(langkah.toMap())
        .select('idLangkah')
        .single();
    return result['idLangkah'] as int;
  }

  Future<List<LangkahMasak>> getLangkahByResep(int idResep) async {
    final result = await supabase
        .from('langkahmasak')
        .select()
        .eq('idResep', idResep)
        .order('nomorUrut', ascending: true);
    return (result as List).map((e) => LangkahMasak.fromMap(e)).toList();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BAHAN MASAK
  // ══════════════════════════════════════════════════════════════════════════

  Future<int> insertBahan(BahanMasak bahan) async {
    final result = await supabase
        .from('bahanmasak')
        .insert(bahan.toMap())
        .select('idBahan')
        .single();
    return result['idBahan'] as int;
  }

  Future<List<BahanMasak>> getBahanByResep(int idResep) async {
    final result = await supabase
        .from('bahanmasak')
        .select()
        .eq('idResep', idResep);
    return (result as List).map((e) => BahanMasak.fromMap(e)).toList();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ALAT MASAK
  // ══════════════════════════════════════════════════════════════════════════

  Future<int> insertAlat(AlatMasak alat) async {
    final result = await supabase
        .from('alatmasak')
        .insert(alat.toMap())
        .select('idAlat')
        .single();
    return result['idAlat'] as int;
  }

  Future<List<AlatMasak>> getAlatByResep(int idResep) async {
    final result = await supabase
        .from('alatmasak')
        .select()
        .eq('idResep', idResep);
    return (result as List).map((e) => AlatMasak.fromMap(e)).toList();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // RATING
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> insertOrUpdateRating(Rating rating) async {
    await supabase
        .from('rating')
        .upsert(rating.toMap());
  }

  Future<int> getJumlahSuka(int idResep) async {
    final result = await supabase
        .from('rating')
        .select()
        .eq('idResep', idResep)
        .eq('suka', 1);
    return (result as List).length;
  }

  Future<Rating?> getRatingUser(int idResep, int idPengguna) async {
    final result = await supabase
        .from('rating')
        .select()
        .eq('idResep', idResep)
        .eq('idPengguna', idPengguna)
        .maybeSingle();
    if (result == null) return null;
    return Rating.fromMap(result);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // KOLEKSI BOOKMARK
  // ══════════════════════════════════════════════════════════════════════════

  Future<int> insertKoleksi(KoleksiBookmark koleksi) async {
    final result = await supabase
        .from('koleksibookmark')
        .insert(koleksi.toMap())
        .select('idBookmark')
        .single();
    return result['idBookmark'] as int;
  }

  Future<List<KoleksiBookmark>> getKoleksiByPengguna(int idPengguna) async {
    final result = await supabase
        .from('koleksibookmark')
        .select()
        .eq('idPengguna', idPengguna);
    return (result as List).map((e) => KoleksiBookmark.fromMap(e)).toList();
  }

  Future<void> deleteKoleksi(int idBookmark) async {
    await supabase
        .from('koleksibookmark')
        .delete()
        .eq('idBookmark', idBookmark);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BOOKMARK
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> insertBookmark(Bookmark bookmark) async {
    await supabase
        .from('bookmark')
        .insert(bookmark.toMap());
  }

  Future<List<ResepMakanan>> getResepBookmarkByPengguna(int idPengguna) async {
    final result = await supabase
        .from('resepmakanan')
        .select('*, bookmark!inner(idPengguna)')
        .eq('bookmark.idPengguna', idPengguna);
    return (result as List).map((e) => ResepMakanan.fromMap(e)).toList();
  }

  Future<bool> isResepDibookmark(int idResep, int idPengguna) async {
    final result = await supabase
        .from('bookmark')
        .select()
        .eq('idResep', idResep)
        .eq('idPengguna', idPengguna)
        .maybeSingle();
    return result != null;
  }

  Future<void> deleteBookmark(int idResep, int idPengguna) async {
    await supabase
        .from('bookmark')
        .delete()
        .eq('idResep', idResep)
        .eq('idPengguna', idPengguna);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ARTIKEL
  // ══════════════════════════════════════════════════════════════════════════

  Future<int> insertArtikel(Artikel artikel) async {
    final result = await supabase
        .from('artikel')
        .insert(artikel.toMap())
        .select('idArtikel')
        .single();
    return result['idArtikel'] as int;
  }

  Future<List<Artikel>> getAllArtikel() async {
    final result = await supabase
        .from('artikel')
        .select()
        .order('tglDibuat', ascending: false);
    return (result as List).map((e) => Artikel.fromMap(e)).toList();
  }

  Future<Artikel?> getArtikelById(int id) async {
    final result = await supabase
        .from('artikel')
        .select()
        .eq('idArtikel', id)
        .maybeSingle();
    if (result == null) return null;
    return Artikel.fromMap(result);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SIMPAN ARTIKEL
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> simpanArtikel(SimpanArtikel simpan) async {
    await supabase
        .from('simpanartikel')
        .insert(simpan.toMap());
  }

  Future<List<Artikel>> getArtikelDisimpanByPengguna(int idPengguna) async {
    final result = await supabase
        .from('artikel')
        .select('*, simpanartikel!inner(idPengguna)')
        .eq('simpanartikel.idPengguna', idPengguna);
    return (result as List).map((e) => Artikel.fromMap(e)).toList();
  }

  Future<void> hapusSimpanArtikel(int idPengguna, int idArtikel) async {
    await supabase
        .from('simpanartikel')
        .delete()
        .eq('idPengguna', idPengguna)
        .eq('idArtikel', idArtikel);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // RIWAYAT KREASI AI
  // ══════════════════════════════════════════════════════════════════════════

  Future<int> insertKreasi(RiwayatKreasiAI kreasi) async {
    final result = await supabase
        .from('riwayatkreasiai')
        .insert(kreasi.toMap())
        .select('idKreasi')
        .single();
    return result['idKreasi'] as int;
  }

  Future<List<RiwayatKreasiAI>> getRiwayatKreasiByPengguna(int idPengguna) async {
    final result = await supabase
        .from('riwayatkreasiai')
        .select()
        .eq('idPengguna', idPengguna)
        .order('idKreasi', ascending: false);
    return (result as List).map((e) => RiwayatKreasiAI.fromMap(e)).toList();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HASIL REKOMENDASI AI
  // ══════════════════════════════════════════════════════════════════════════

  Future<int> insertHasilAI(HasilRekomendasiAI hasil) async {
    final result = await supabase
        .from('hasilrekomendaasiai')
        .insert(hasil.toMap())
        .select('idHasil')
        .single();
    return result['idHasil'] as int;
  }

  Future<List<ResepMakanan>> getResepRekomendasiAI(int idKreasi) async {
    final result = await supabase
        .from('resepmakanan')
        .select('*, hasilrekomendaasiai!inner(skorKecocokan, idKreasi)')
        .eq('hasilrekomendaasiai.idKreasi', idKreasi)
        .order('hasilrekomendaasiai.skorKecocokan', ascending: false);
    return (result as List).map((e) => ResepMakanan.fromMap(e)).toList();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PROGRES MEMASAK
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> updateProgres(ProgresMemasak progres) async {
    await supabase
        .from('progresmemasak')
        .upsert(progres.toMap());
  }

  Future<List<ProgresMemasak>> getProgresByResepDanPengguna(
      int idResep, int idPengguna) async {
    final result = await supabase
        .from('progresmemasak')
        .select('*, langkahmasak!inner(idResep)')
        .eq('langkahmasak.idResep', idResep)
        .eq('idPengguna', idPengguna);
    return (result as List).map((e) => ProgresMemasak.fromMap(e)).toList();
  }

  Future<void> resetProgres(int idResep, int idPengguna) async {
    // Ambil semua idLangkah milik resep ini dulu
    final langkahList = await getLangkahByResep(idResep);
    final ids = langkahList.map((l) => l.idLangkah!).toList();
    if (ids.isEmpty) return;
    await supabase
        .from('progresmemasak')
        .delete()
        .eq('idPengguna', idPengguna)
        .inFilter('idLangkah', ids);
  }
}