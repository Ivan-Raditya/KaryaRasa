import 'package:flutter/material.dart';
import '../database/database.dart';

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
  final String videoThumbnail;
  final int durasiMasak;
  final int porsi;
  final double rating;
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
    required this.videoThumbnail,
    required this.durasiMasak,
    required this.porsi,
    this.rating = 4.5,
    this.isBookmarked = false,
  });
}

// ══════════════════════════════════════════════════════════════════════════════
// LIST GLOBAL — diisi dari database saat splash screen
// ══════════════════════════════════════════════════════════════════════════════

List<ResepData> kResepList = [];

/// Dipanggil di splash screen — load semua resep dari database
Future<void> loadResepFromDatabase() async {
  final db = Database();
  final resepList = await db.getAllResep();

  final List<ResepData> hasil = [];

  for (final resep in resepList) {
    final idResep = resep.idResep!;

    // Ambil bahan
    final bahanList = await db.getBahanByResep(idResep);
    final bahanItems = bahanList
        .map((b) => BahanItem(nama: b.namaBahan, jumlah: b.jumlah))
        .toList();

    final bahanSections = bahanItems.isNotEmpty
        ? [BahanSection(judul: 'Bahan-Bahan', items: bahanItems)]
        : <BahanSection>[];

    // Ambil langkah masak
    final langkahList = await db.getLangkahByResep(idResep);
    final langkah = langkahList
        .map((l) => l.deskripsiLangkah)
        .toList();

    // Hitung total durasi
    final totalDurasi =
        langkahList.fold<int>(0, (sum, l) => sum + (l.durasi ?? 0));

    // Parse URL foto (bisa lebih dari 1, dipisah koma)
    final fotoResep = resep.fotoResep ?? '';
    final imageUrls = fotoResep.isNotEmpty
        ? fotoResep.split(',').map((u) => u.trim()).toList()
        : [
            'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=800&q=80'
          ];

    hasil.add(ResepData(
      id: idResep.toString(),
      nama: resep.namaResep,
      daerah: resep.asalDaerah,
      kategori: resep.kategoriResep, // ← ambil dari DB
      sejarahSingkat: resep.deskripsiResep,
      imageUrls: imageUrls,
      videoThumbnail: imageUrls.first,
      durasiMasak: totalDurasi > 0 ? totalDurasi : 30,
     porsi: resep.porsi,
      bahanSections: bahanSections,
      langkah: langkah,
      rating: 4.5,
      isBookmarked: false,
    ));
  }

  kResepList = hasil;
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