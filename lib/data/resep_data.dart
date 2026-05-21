import 'package:flutter/material.dart';

class ResepData {
  final String id;
  final String nama;
  final String daerah;
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

class BahanSection {
  final String judul;
  final List<BahanItem> items;
  const BahanSection({required this.judul, required this.items});
}

class BahanItem {
  final String jumlah;
  final String nama;
  const BahanItem({required this.jumlah, required this.nama});
}

final List<ResepData> kResepList = [
  ResepData(
    id: 'soto-gading',
    nama: 'Soto Gading Solo',
    daerah: 'Solo, Jawa Tengah',
    sejarahSingkat:
        'Soto Gading Solo bukanlah masakan khas dari daerah tertentu, melainkan sebuah resep soto yang diperkenalkan oleh Siswo Martono sejak tahun 1974. Nama \'Gading\' sendiri berasal dari nama daerah tempat kedai soto ini berada.',
    imageUrls: [
      'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1565557623262-b51c2513a641?auto=format&fit=crop&w=800&q=80',
    ],
    bahanSections: [
      BahanSection(
        judul: 'Bahan-Bahan',
        items: [
          BahanItem(jumlah: '250 gram', nama: 'paha ayam'),
          BahanItem(jumlah: '1500 ml', nama: 'air'),
          BahanItem(jumlah: '1 batang', nama: 'serai'),
          BahanItem(jumlah: '1 ruas', nama: 'lengkuas'),
          BahanItem(jumlah: '3 lembar', nama: 'daun jeruk purut'),
          BahanItem(jumlah: '2 lembar', nama: 'daun salam'),
          BahanItem(jumlah: '1 batang', nama: 'seledri'),
          BahanItem(jumlah: '1 batang', nama: 'daun bawang'),
        ],
      ),
      BahanSection(
        judul: 'Bumbu halus',
        items: [
          BahanItem(jumlah: '5 buah', nama: 'bawang merah'),
          BahanItem(jumlah: '3 siung', nama: 'bawang putih'),
          BahanItem(jumlah: '3 butir', nama: 'kemiri sangrai'),
          BahanItem(jumlah: '1/2 sdt', nama: 'ketumbar bubuk'),
          BahanItem(jumlah: '1 ruas', nama: 'jahe'),
          BahanItem(jumlah: '1 cm', nama: 'pala'),
          BahanItem(jumlah: '1 cm', nama: 'kunyit (opsional)'),
        ],
      ),
      BahanSection(
        judul: 'Seasoning',
        items: [
          BahanItem(jumlah: '1 sdt', nama: 'garam'),
          BahanItem(jumlah: '1/2 sdt', nama: 'gula pasir'),
          BahanItem(jumlah: '1/4 sdt', nama: 'merica'),
          BahanItem(jumlah: '1 sdt', nama: 'kaldu ayam bubuk'),
        ],
      ),
      BahanSection(
        judul: 'Pelengkap',
        items: [
          BahanItem(jumlah: 'Secukupnya', nama: 'kentang goreng'),
          BahanItem(jumlah: 'Irisan', nama: 'daun bawang & seledri'),
          BahanItem(jumlah: 'Secukupnya', nama: 'taoge pendek'),
          BahanItem(jumlah: '1 buah', nama: 'tomat, potong sesuai selera'),
          BahanItem(jumlah: 'Secukupnya', nama: 'bawang goreng'),
          BahanItem(jumlah: '1 buah', nama: 'jeruk nipis, potong jadi 8'),
          BahanItem(jumlah: 'Secukupnya', nama: 'sambal rebus'),
        ],
      ),
    ],
    langkah: [
      'Rebus ayam dengan air mendidih hingga mengeluarkan darah dan kotoran, kemudian bilas. Rebus 1000ml hingga mendidih, masukkan ayam dan daun salam. rebus ayam hingga lunak.',
      'Ulek bumbu yang dihaluskan, kemudian tumis dengan serai, lengkuas dan daun jeruk purut hingga bumbu matang dan tanak.',
      'Pindahkan ke dalam air rebusan ayam, tambahkan daun seledri, potongan daun bawang dan sisa air. Masak sampai mendidih.',
      'Kemudian beri seasoning, koreksi rasa. Masak dengan api kecil hingga bumbu meresap. Angkat ayam, setelah dingin suwir suwir.',
      'Sajikan soto ayam gading dengan bahan pelengkap selagi panas',
    ],
    videoThumbnail:
        'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=800&q=80',
    durasiMasak: 60,
    porsi: 4,
    rating: 4.8,
    isBookmarked: true,
  ),
  ResepData(
    id: 'rendang-padang',
    nama: 'Rendang Padang',
    daerah: 'Sumatera Barat',
    sejarahSingkat: 'Rendang adalah masakan daging asli Indonesia yang berasal dari Minangkabau. Masakan ini dihasilkan dari proses memasak suhu rendah dalam waktu lama menggunakan aneka rempah-rempah dan santan.',
    imageUrls: [
      'https://images.unsplash.com/photo-1574653853027-5382a3d23a15?auto=format&fit=crop&w=800&q=80',
    ],
    bahanSections: [
      BahanSection(
        judul: 'Bahan Utama',
        items: [
          BahanItem(jumlah: '1 kg', nama: 'daging sapi (potong kotak)'),
          BahanItem(jumlah: '1 liter', nama: 'santan kental'),
          BahanItem(jumlah: '1 liter', nama: 'santan encer'),
          BahanItem(jumlah: '3 lembar', nama: 'daun kunyit (ikat simpul)'),
          BahanItem(jumlah: '5 lembar', nama: 'daun jeruk purut'),
          BahanItem(jumlah: '2 lembar', nama: 'daun salam'),
          BahanItem(jumlah: '2 batang', nama: 'serai (memarkan)'),
        ],
      ),
      BahanSection(
        judul: 'Bumbu Halus',
        items: [
          BahanItem(jumlah: '150 gram', nama: 'cabai merah keriting'),
          BahanItem(jumlah: '15 butir', nama: 'bawang merah'),
          BahanItem(jumlah: '7 siung', nama: 'bawang putih'),
          BahanItem(jumlah: '2 cm', nama: 'jahe'),
          BahanItem(jumlah: '3 cm', nama: 'lengkuas'),
          BahanItem(jumlah: '2 cm', nama: 'kunyit'),
          BahanItem(jumlah: '1 sdt', nama: 'ketumbar bubuk'),
          BahanItem(jumlah: '1 sdt', nama: 'garam'),
        ],
      ),
    ],
    langkah: [
      'Panaskan santan encer bersama bumbu halus, daun kunyit, daun jeruk, daun salam, dan serai. Aduk terus hingga mendidih agar santan tidak pecah.',
      'Masukkan potongan daging sapi, aduk rata. Masak dengan api sedang hingga kuah menyusut dan daging mulai empuk.',
      'Tuangkan santan kental, aduk perlahan. Kurangi api menjadi kecil.',
      'Masak terus sambil sesekali diaduk hingga bumbu mengering, berwarna cokelat gelap, dan mengeluarkan minyak (proses ini bisa memakan waktu 3-4 jam).',
      'Angkat dan sajikan bersama nasi hangat.'
    ],
    videoThumbnail: 'https://images.unsplash.com/photo-1574653853027-5382a3d23a15?auto=format&fit=crop&w=800&q=80',
    durasiMasak: 180,
    porsi: 8,
    rating: 4.9,
    isBookmarked: true,
  ),
  ResepData(
    id: 'gudeg-jogja',
    nama: 'Gudeg Yogyakarta',
    daerah: 'Yogyakarta',
    sejarahSingkat: 'Gudeg adalah makanan khas Yogyakarta dan Jawa Tengah yang terbuat dari nangka muda yang dimasak dengan santan. Warnanya yang coklat biasanya dihasilkan oleh daun jati yang dimasak bersamaan.',
    imageUrls: [
      'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=800&q=80',
    ],
    bahanSections: [
      BahanSection(
        judul: 'Bahan Utama',
        items: [
          BahanItem(jumlah: '1 kg', nama: 'nangka muda (potong-potong)'),
          BahanItem(jumlah: '1 liter', nama: 'santan'),
          BahanItem(jumlah: '5 lembar', nama: 'daun jati'),
          BahanItem(jumlah: '3 lembar', nama: 'daun salam'),
          BahanItem(jumlah: '1 batang', nama: 'serai'),
          BahanItem(jumlah: '5 butir', nama: 'telur rebus'),
        ],
      ),
      BahanSection(
        judul: 'Bumbu Halus',
        items: [
          BahanItem(jumlah: '10 butir', nama: 'bawang merah'),
          BahanItem(jumlah: '4 siung', nama: 'bawang putih'),
          BahanItem(jumlah: '5 butir', nama: 'kemiri'),
          BahanItem(jumlah: '1 sdt', nama: 'ketumbar'),
          BahanItem(jumlah: '150 gram', nama: 'gula aren/merah'),
          BahanItem(jumlah: '1 sdt', nama: 'garam'),
        ],
      ),
    ],
    langkah: [
      'Alasi dasar panci dengan daun jati.',
      'Masukkan nangka muda, telur rebus, bumbu halus, daun salam, dan serai.',
      'Tuangkan santan hingga semua bahan terendam.',
      'Masak dengan api kecil selama berjam-jam hingga kuah menyusut habis dan nangka berwarna cokelat kemerahan serta empuk.',
      'Sajikan dengan krecek dan opor ayam.'
    ],
    videoThumbnail: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=800&q=80',
    durasiMasak: 120,
    porsi: 6,
    rating: 4.7,
  ),
  ResepData(
    id: 'soto-betawi',
    nama: 'Soto Betawi',
    daerah: 'DKI Jakarta',
    sejarahSingkat: 'Soto Betawi merupakan soto yang populer di Jakarta. Ciri khasnya adalah kuah yang terbuat dari campuran santan dan susu, membuat rasanya sangat gurih.',
    imageUrls: [
      'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=800&q=80',
    ],
    bahanSections: [
      BahanSection(
        judul: 'Bahan Utama',
        items: [
          BahanItem(jumlah: '500 gram', nama: 'daging sapi'),
          BahanItem(jumlah: '250 gram', nama: 'jeroan sapi (babat/paru)'),
          BahanItem(jumlah: '500 ml', nama: 'santan kental'),
          BahanItem(jumlah: '250 ml', nama: 'susu cair segar'),
          BahanItem(jumlah: '2 batang', nama: 'serai'),
          BahanItem(jumlah: '3 lembar', nama: 'daun jeruk'),
        ],
      ),
      BahanSection(
        judul: 'Bumbu Halus',
        items: [
          BahanItem(jumlah: '8 butir', nama: 'bawang merah'),
          BahanItem(jumlah: '4 siung', nama: 'bawang putih'),
          BahanItem(jumlah: '3 butir', nama: 'kemiri sangrai'),
          BahanItem(jumlah: '1 sdt', nama: 'ketumbar'),
          BahanItem(jumlah: '1/2 sdt', nama: 'jintan'),
        ],
      ),
    ],
    langkah: [
      'Rebus daging dan jeroan hingga empuk. Angkat, potong dadu, lalu goreng sebentar.',
      'Tumis bumbu halus bersama serai dan daun jeruk hingga harum.',
      'Masukkan tumisan bumbu ke dalam air kaldu sisa rebusan daging (sekitar 1 liter).',
      'Tuangkan santan dan susu. Masak sambil diaduk agar santan tidak pecah.',
      'Sajikan potongan daging di mangkuk, siram dengan kuah panas, tambahkan tomat, kentang, emping, dan daun bawang.'
    ],
    videoThumbnail: 'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=800&q=80',
    durasiMasak: 90,
    porsi: 5,
    rating: 4.6,
  ),
  ResepData(
    id: 'ayam-betutu',
    nama: 'Ayam Betutu',
    daerah: 'Bali',
    sejarahSingkat: 'Ayam Betutu adalah makanan khas Gilimanuk, Bali. Ayam utuh yang diisi bumbu, lalu dibungkus daun pisang dan dipanggang atau direbus dalam waktu lama.',
    imageUrls: [
      'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?auto=format&fit=crop&w=800&q=80',
    ],
    bahanSections: [
      BahanSection(
        judul: 'Bahan Utama',
        items: [
          BahanItem(jumlah: '1 ekor', nama: 'ayam kampung (utuh)'),
          BahanItem(jumlah: 'Daun pisang', nama: 'untuk membungkus'),
          BahanItem(jumlah: '1 buah', nama: 'jeruk nipis'),
        ],
      ),
      BahanSection(
        judul: 'Bumbu Base Genep',
        items: [
          BahanItem(jumlah: '15 butir', nama: 'bawang merah'),
          BahanItem(jumlah: '7 siung', nama: 'bawang putih'),
          BahanItem(jumlah: '10 buah', nama: 'cabai rawit'),
          BahanItem(jumlah: '3 cm', nama: 'kencur'),
          BahanItem(jumlah: '3 cm', nama: 'lengkuas'),
          BahanItem(jumlah: '3 cm', nama: 'jahe'),
          BahanItem(jumlah: '3 cm', nama: 'kunyit'),
          BahanItem(jumlah: '1 sdt', nama: 'terasi bakar'),
        ],
      ),
    ],
    langkah: [
      'Lumuri ayam utuh dengan perasan jeruk nipis dan garam. Diamkan 15 menit.',
      'Haluskan semua bumbu Base Genep secara kasar (rajang).',
      'Tumis bumbu rajangan hingga harum, lalu bagi dua.',
      'Sebagian bumbu dimasukkan ke dalam rongga perut ayam, sebagian lagi dilumurkan ke seluruh permukaan ayam.',
      'Bungkus ayam dengan daun pisang berlapis-lapis.',
      'Kukus ayam selama 2 jam hingga empuk, kemudian panggang sebentar agar aromanya keluar.'
    ],
    videoThumbnail: 'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?auto=format&fit=crop&w=800&q=80',
    durasiMasak: 150,
    porsi: 4,
    rating: 4.8,
  ),
  ResepData(
    id: 'pempek-palembang',
    nama: 'Pempek Palembang',
    daerah: 'Sumatera Selatan',
    sejarahSingkat: 'Pempek merupakan makanan khas Palembang yang terbuat dari daging ikan dan sagu, disajikan dengan kuah cuka (cuko) yang asam, manis, dan pedas.',
    imageUrls: [
      'https://images.unsplash.com/photo-1512058454905-6b841e7ad132?auto=format&fit=crop&w=800&q=80',
    ],
    bahanSections: [
      BahanSection(
        judul: 'Bahan Pempek',
        items: [
          BahanItem(jumlah: '500 gram', nama: 'daging ikan tenggiri giling'),
          BahanItem(jumlah: '400 gram', nama: 'tepung sagu/tapioka'),
          BahanItem(jumlah: '200 ml', nama: 'air es'),
          BahanItem(jumlah: '1 sdm', nama: 'garam'),
          BahanItem(jumlah: '1 sdt', nama: 'gula pasir'),
        ],
      ),
      BahanSection(
        judul: 'Bahan Cuko',
        items: [
          BahanItem(jumlah: '500 gram', nama: 'gula batok Palembang'),
          BahanItem(jumlah: '50 gram', nama: 'asam jawa'),
          BahanItem(jumlah: '100 gram', nama: 'bawang putih halus'),
          BahanItem(jumlah: '50 gram', nama: 'cabai rawit halus'),
          BahanItem(jumlah: '1 liter', nama: 'air'),
        ],
      ),
    ],
    langkah: [
      'Campur ikan giling dengan air es, uleni hingga menyatu. Masukkan garam dan gula, uleni hingga adonan mengental.',
      'Masukkan tepung sagu sedikit demi sedikit. Jangan diuleni terlalu kuat agar pempek tidak alot.',
      'Bentuk adonan menjadi lenjer atau kapal selam.',
      'Rebus dalam air mendidih yang sudah diberi sedikit minyak hingga mengapung. Angkat dan tiriskan.',
      'Untuk cuko: rebus gula batok dan asam jawa dengan air. Saring. Rebus kembali bersama bawang putih dan cabai rawit hingga mendidih.',
      'Goreng pempek, potong-potong, sajikan dengan siraman cuko dan irisan timun.'
    ],
    videoThumbnail: 'https://images.unsplash.com/photo-1512058454905-6b841e7ad132?auto=format&fit=crop&w=800&q=80',
    durasiMasak: 60,
    porsi: 5,
    rating: 4.7,
  ),
  ResepData(
    id: 'sate-madura',
    nama: 'Sate Madura',
    daerah: 'Jawa Timur',
    sejarahSingkat: 'Sate khas dari Pulau Madura ini sangat populer di seluruh Indonesia. Ciri khasnya adalah bumbu kacang yang dihaluskan bersama kemiri dan bawang merah.',
    imageUrls: [
      'https://images.unsplash.com/photo-1529042410759-befb1204b468?auto=format&fit=crop&w=800&q=80',
    ],
    bahanSections: [
      BahanSection(
        judul: 'Bahan Sate',
        items: [
          BahanItem(jumlah: '500 gram', nama: 'daging ayam (potong dadu)'),
          BahanItem(jumlah: 'Tusuk', nama: 'sate secukupnya'),
          BahanItem(jumlah: '3 sdm', nama: 'kecap manis (untuk olesan)'),
          BahanItem(jumlah: '1 sdm', nama: 'margarine cair'),
        ],
      ),
      BahanSection(
        judul: 'Bumbu Kacang',
        items: [
          BahanItem(jumlah: '200 gram', nama: 'kacang tanah (goreng)'),
          BahanItem(jumlah: '4 butir', nama: 'bawang merah'),
          BahanItem(jumlah: '3 siung', nama: 'bawang putih'),
          BahanItem(jumlah: '3 buah', nama: 'cabai merah'),
          BahanItem(jumlah: '2 butir', nama: 'kemiri'),
          BahanItem(jumlah: 'Secukupnya', nama: 'kecap manis & air'),
        ],
      ),
    ],
    langkah: [
      'Tusuk daging ayam pada tusuk sate, 4-5 potong per tusuk.',
      'Haluskan kacang tanah, bawang merah, bawang putih, cabai, dan kemiri. Tumis hingga mengeluarkan minyak.',
      'Tambahkan air, kecap manis, dan garam pada tumisan bumbu. Masak hingga mengental.',
      'Ambil 2 sdm bumbu kacang, campur dengan kecap manis dan margarin cair. Gunakan sebagai olesan sate.',
      'Bakar sate hingga matang.',
      'Sajikan sate dengan siraman sisa bumbu kacang, perasan jeruk limau, dan irisan bawang merah.'
    ],
    videoThumbnail: 'https://images.unsplash.com/photo-1529042410759-befb1204b468?auto=format&fit=crop&w=800&q=80',
    durasiMasak: 45,
    porsi: 4,
    rating: 4.8,
    isBookmarked: true,
  ),
  ResepData(
    id: 'gado-gado',
    nama: 'Gado-Gado Betawi',
    daerah: 'DKI Jakarta',
    sejarahSingkat: 'Gado-gado adalah salah satu makanan khas Betawi berupa sayur-sayuran yang direbus dan dicampur jadi satu, dengan bumbu kacang yang diulek langsung.',
    imageUrls: [
      'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?auto=format&fit=crop&w=800&q=80',
    ],
    bahanSections: [
      BahanSection(
        judul: 'Bahan Sayuran',
        items: [
          BahanItem(jumlah: '1 ikat', nama: 'kangkung (rebus)'),
          BahanItem(jumlah: '100 gram', nama: 'taoge (seduh)'),
          BahanItem(jumlah: '100 gram', nama: 'kacang panjang (rebus)'),
          BahanItem(jumlah: '1 buah', nama: 'labu siam (rebus)'),
          BahanItem(jumlah: '1 buah', nama: 'jagung manis (rebus/pipil)'),
        ],
      ),
      BahanSection(
        judul: 'Bumbu Kacang',
        items: [
          BahanItem(jumlah: '150 gram', nama: 'kacang tanah goreng'),
          BahanItem(jumlah: '2 buah', nama: 'cabai merah'),
          BahanItem(jumlah: '1 siung', nama: 'bawang putih'),
          BahanItem(jumlah: '1 sdt', nama: 'terasi bakar'),
          BahanItem(jumlah: '1 sdm', nama: 'gula merah'),
          BahanItem(jumlah: '1/2 sdt', nama: 'air asam jawa'),
        ],
      ),
    ],
    langkah: [
      'Siapkan cobek besar. Ulek cabai, bawang putih, terasi, dan garam hingga halus.',
      'Tambahkan kacang tanah goreng dan gula merah, ulek kembali hingga kacang cukup halus.',
      'Tuangkan air matang dan air asam jawa sedikit demi sedikit sambil diaduk rata hingga kekentalan yang pas.',
      'Masukkan potongan sayuran rebus ke dalam cobek, aduk rata bersama bumbu kacang.',
      'Sajikan di piring, taburi bawang goreng dan lengkapi dengan kerupuk serta irisan telur rebus.'
    ],
    videoThumbnail: 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?auto=format&fit=crop&w=800&q=80',
    durasiMasak: 30,
    porsi: 2,
    rating: 4.4,
    isBookmarked: true,
  ),
  ResepData(
    id: 'coto-makassar',
    nama: 'Coto Makassar',
    daerah: 'Sulawesi Selatan',
    sejarahSingkat: 'Coto Makassar adalah hidangan tradisional Suku Makassar yang terbuat dari jeroan sapi yang direbus dalam waktu lama, dicampur daging sapi.',
    imageUrls: [
      'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=800&q=80',
    ],
    bahanSections: [
      BahanSection(
        judul: 'Bahan Utama',
        items: [
          BahanItem(jumlah: '500 gram', nama: 'daging sapi'),
          BahanItem(jumlah: '500 gram', nama: 'jeroan sapi (paru/babat/usus)'),
          BahanItem(jumlah: '2 liter', nama: 'air cucian beras putih'),
          BahanItem(jumlah: '3 batang', nama: 'serai'),
          BahanItem(jumlah: '5 cm', nama: 'lengkuas'),
          BahanItem(jumlah: '100 gram', nama: 'kacang tanah (sangrai, haluskan)'),
        ],
      ),
      BahanSection(
        judul: 'Bumbu Halus',
        items: [
          BahanItem(jumlah: '10 butir', nama: 'bawang merah'),
          BahanItem(jumlah: '6 siung', nama: 'bawang putih'),
          BahanItem(jumlah: '5 butir', nama: 'kemiri sangrai'),
          BahanItem(jumlah: '1 sdm', nama: 'ketumbar sangrai'),
          BahanItem(jumlah: '1 sdt', nama: 'jintan sangrai'),
        ],
      ),
    ],
    langkah: [
      'Rebus daging dan jeroan menggunakan air cucian beras bersama serai dan lengkuas hingga empuk.',
      'Angkat daging dan jeroan, potong dadu. Saring kaldu sisa rebusan.',
      'Tumis bumbu halus hingga harum dan matang. Masukkan ke dalam air kaldu.',
      'Tambahkan kacang tanah yang sudah dihaluskan. Masak kaldu hingga mendidih dan bumbu meresap.',
      'Siapkan mangkuk, tata potongan daging. Siram dengan kuah coto yang mendidih.',
      'Sajikan dengan ketupat, irisan daun bawang, bawang goreng, dan sambal tauco.'
    ],
    videoThumbnail: 'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=800&q=80',
    durasiMasak: 120,
    porsi: 6,
    rating: 4.6,
  ),
];
