import 'package:flutter/material.dart';
import '../database/database.dart';
import '../utils/supabase_config.dart';

// ══════════════════════════════════════════════════════════════════════════════
// MODEL — struktur tetap sama, dipakai semua screen tanpa perubahan
// ══════════════════════════════════════════════════════════════════════════════

class BahanItem {
  final String jumlah;
  final String nama;
  const BahanItem({required this.jumlah, required this.nama});
}

class BahanSection {
  final String judul;
  final List<BahanItem> items;
  const BahanSection({required this.judul, required this.items});
}

class ResepData {
  final String id;
  final String nama;
  final String daerah;
  final String kategori; // ← field baru: kategoriResep dari DB
  final String sejarahSingkat;
  final List<String> imageUrls;
  final List<BahanSection> bahanSections;
  final List<String> langkah;
  final List<String> alatMasak;
  final String videoThumbnail;
  final int durasiMasak;
  final int porsi;
  final double rating;
  final int likeCount; // ← field baru
  bool isBookmarked;

  ResepData({
    required this.id,
    required this.nama,
    required this.daerah,
    this.kategori = 'Makanan', // ← default jika tidak ada
    required this.sejarahSingkat,
    required this.imageUrls,
    required this.bahanSections,
    required this.langkah,
    this.alatMasak = const [],
    required this.videoThumbnail,
    required this.durasiMasak,
    required this.porsi,
    this.rating = 4.5,
    this.likeCount = 0,
    this.isBookmarked = false,
  });
}

// ══════════════════════════════════════════════════════════════════════════════
// LIST GLOBAL — diisi dari database saat splash screen
// ══════════════════════════════════════════════════════════════════════════════

List<ResepData> kResepList = [];

/// Dipanggil di splash screen atau pagination — load resep dari database
Future<void> loadResepFromDatabase({int start = 0, int limit = 10, bool append = false}) async {
  final db = Database();
  // Gunakan fungsi join untuk mencegah N+1 Query
  final resepList = await db.getAllResepWithDetails(start: start, limit: limit);

  final List<ResepData> hasil = [];

  for (final resep in resepList) {
    final idResep = resep['idResep'] as int;

    // 1. Bahan Masak
    final bahanData = (resep['bahanmasak'] as List?) ?? [];
    final bahanItems = bahanData
        .map((b) => BahanItem(nama: b['namaBahan'] ?? '', jumlah: b['jumlah'] ?? ''))
        .toList();
    final bahanSections = bahanItems.isNotEmpty
        ? [BahanSection(judul: 'Bahan-Bahan', items: bahanItems)]
        : <BahanSection>[];

    // 2. Langkah Masak
    final langkahData = (resep['langkahmasak'] as List?) ?? [];
    // Urutkan langkah berdasarkan nomor urut (jika tidak otomatis dari db)
    langkahData.sort((a, b) => (a['nomorUrut'] as int? ?? 0).compareTo(b['nomorUrut'] as int? ?? 0));
    final langkah = langkahData.map((l) => l['deskripsiLangkah'] as String).toList();

    // 3. Alat Masak
    final alatData = (resep['alatmasak'] as List?) ?? [];
    final alat = alatData.map((a) => a['namaAlat'] as String).toList();

    // 4. Hitung Durasi
    final totalDurasi = langkahData.fold<int>(0, (sum, l) => sum + (l['durasi'] as int? ?? 0));

    // 5. Parse Foto
    final fotoResep = (resep['fotoResep'] as String?) ?? '';
    final imageUrls = fotoResep.isNotEmpty
        ? fotoResep.split(',').map((u) => u.trim()).toList()
        : ['https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=800&q=80'];

    // 6. Jumlah Like
    final likesData = (resep['likeresep'] as List?) ?? [];
    final jumlahLike = likesData.length;

    // 7. Kalkulasi Rating Rata-Rata
    final komentarData = (resep['komentar'] as List?) ?? [];
    double avgRating = 0.0;
    if (komentarData.isNotEmpty) {
      final totalSkor = komentarData.fold<int>(0, (sum, k) => sum + (k['skor_rating'] as int? ?? 5));
      avgRating = totalSkor / komentarData.length;
    }

    hasil.add(ResepData(
      id: idResep.toString(),
      nama: resep['namaResep'] ?? 'Resep Tanpa Nama',
      daerah: resep['asalDaerah'] ?? '-',
      kategori: resep['kategoriResep'] ?? 'Makanan',
      sejarahSingkat: resep['deskripsiResep'] ?? '',
      imageUrls: imageUrls,
      videoThumbnail: imageUrls.first,
      durasiMasak: totalDurasi > 0 ? totalDurasi : 30,
      porsi: resep['porsi'] ?? 1,
      bahanSections: bahanSections,
      langkah: langkah,
      alatMasak: alat,
      rating: avgRating > 0 ? avgRating : 0.0,

      likeCount: jumlahLike,
      isBookmarked: false,
    ));
  }

  if (append) {
    kResepList.addAll(hasil);
  } else {
    kResepList = hasil;
  }
}

/// Sync status bookmark dari database untuk pengguna yang login
Future<void> syncBookmarkState(int idPengguna) async {
  final db = Database();
  for (final resep in kResepList) {
    final idResep = int.tryParse(resep.id);
    if (idResep != null) {
      resep.isBookmarked = await db.isResepDibookmark(idResep, idPengguna);
    }
  }
}
/// Dipanggil SEKALI dari settings/tombol developer.
/// Generate embedding untuk setiap resep dari kResepList,
/// lalu simpan ke kolom `embedding` di Supabase.
///
/// Teks yang di-embed: "NamaResep. Bahan: bahan1, bahan2, ..."
Future<Map<String, int>> generateAndSaveAllEmbeddings() async {
  final db = Database();
  int berhasil = 0;
  int gagal = 0;

  for (final resep in kResepList) {
    final idResep = int.tryParse(resep.id);
    if (idResep == null) { gagal++; continue; }

    // Susun teks: nama + semua bahan
    final semuaBahan = resep.bahanSections
        .expand((s) => s.items)
        .map((i) => i.nama)
        .join(', ');
    final teks = '${resep.nama}. Bahan: $semuaBahan';

    // Generate embedding via Gemini
    final embedding = await generateEmbedding(teks);
    if (embedding == null) { gagal++; continue; }

    // Simpan ke Supabase
    try {
      await db.updateEmbeddingResep(idResep, embedding);
      berhasil++;
    } catch (_) {
      gagal++;
    }

    // Jeda kecil agar tidak throttle Gemini API
    await Future.delayed(const Duration(milliseconds: 300));
  }

  return {'berhasil': berhasil, 'gagal': gagal};
}