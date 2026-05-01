import '../models/article.dart';

const ArticleSeries featuredSeries = ArticleSeries(
  id: 'dasar-hukum-perdata',
  title: 'Mengenal hukum perdata: panduan untuk semua orang',
  subtitle: 'Seri · Dasar Hukum',
  totalChapters: 12,
  completedChapters: 3,
  totalMinutes: 45,
);

const List<Article> mockArticles = [
  Article(
    id: 'perceraian-sendiri',
    title: 'Cara mengajukan gugatan perceraian sendiri',
    category: ArticleCategory.perceraian,
    readMinutes: 7,
    difficulty: 'Mudah dibaca',
    preview:
        'Proses perceraian di Indonesia bisa dilakukan tanpa pengacara. Pelajari langkah-langkah '
        'mengajukan gugatan ke Pengadilan Agama atau Negeri.',
    content:
        'Untuk mengajukan gugatan perceraian, Anda perlu menyiapkan: (1) Fotokopi KTP suami-istri, '
        '(2) Buku nikah asli, (3) Surat gugatan yang berisi alasan perceraian. '
        'Menurut KUHPerdata Pasal 207, alasan sah perceraian antara lain perzinaan, '
        'penelantaran, dan perselisihan terus-menerus.',
  ),
  Article(
    id: 'hak-waris-perempuan',
    title: 'Hak waris anak perempuan menurut KUHPerdata',
    category: ArticleCategory.waris,
    readMinutes: 5,
    difficulty: 'Mudah dibaca',
    preview:
        'Banyak yang salah paham soal hak waris anak perempuan. KUHPerdata menjamin hak yang sama '
        'antara anak laki-laki dan perempuan.',
    content:
        'KUHPerdata Pasal 832 menyatakan bahwa semua anak sah — baik laki-laki maupun perempuan — '
        'adalah ahli waris dan berhak atas bagian yang sama dari harta warisan orang tua. '
        'Pembagian hanya bisa berbeda jika ada wasiat tertulis yang sah.',
  ),
  Article(
    id: 'utang-ditagih-kasar',
    title: 'Apa yang harus dilakukan jika utang ditagih kasar?',
    category: ArticleCategory.utang,
    readMinutes: 6,
    difficulty: 'Mudah dibaca',
    preview:
        'Penagih utang tidak boleh mengancam, mempermalukan, atau datang di luar jam kerja. '
        'Ketahui hak Anda dan cara melaporkannya.',
    content:
        'OJK Peraturan No. 22/2020 mengatur bahwa penagihan utang dilarang: mengancam, '
        'menggunakan kata-kata kasar, menagih ke pihak ketiga, atau menghubungi di luar '
        'jam 08.00–20.00. Laporkan pelanggaran ke OJK di 157.',
  ),
  Article(
    id: 'sertifikat-tanah',
    title: 'Cek sertifikat tanah: 5 langkah penting',
    category: ArticleCategory.tanah,
    readMinutes: 6,
    difficulty: 'Mudah dibaca',
    preview:
        'Sebelum membeli atau mewarisi tanah, pastikan sertifikat bersih dari sengketa. '
        'Berikut cara mengeceknya di BPN.',
    content:
        'Langkah cek sertifikat: (1) Kunjungi kantor BPN setempat, (2) Bawa fotokopi sertifikat, '
        '(3) Isi formulir permohonan pengecekan, (4) Bayar PNBP Rp 50.000, (5) Tunggu 1-3 hari '
        'untuk hasil. Atau gunakan aplikasi Sentuh Tanahku dari BPN.',
  ),
  Article(
    id: 'mediasi-sengketa',
    title: 'Mediasi sebelum sidang: mengapa penting?',
    category: ArticleCategory.umum,
    readMinutes: 4,
    difficulty: 'Mudah dibaca',
    preview:
        'Pengadilan mewajibkan mediasi sebelum sidang utama. Proses ini lebih cepat, murah, '
        'dan sering menghasilkan kesepakatan lebih baik.',
    content:
        'Perma No. 1/2016 mewajibkan mediasi di semua perkara perdata. Mediasi dilakukan oleh '
        'mediator bersertifikat, gratis jika pakai mediator hakim. Jika berhasil, putusan '
        'perdamaian mengikat seperti putusan pengadilan.',
  ),
  Article(
    id: 'lbh-cara-daftar',
    title: 'Cara mendaftar bantuan hukum gratis di LBH',
    category: ArticleCategory.umum,
    readMinutes: 4,
    difficulty: 'Mudah dibaca',
    preview:
        'LBH memberikan bantuan hukum gratis untuk masyarakat tidak mampu. Ini syarat dan '
        'cara pendaftarannya.',
    content:
        'Syarat bantuan hukum gratis (UU No. 16/2011): penghasilan di bawah UMR daerah, '
        'memiliki KTP, kasus perdata atau pidana. Daftar di kantor LBH terdekat dengan membawa '
        'KTP, surat keterangan tidak mampu dari kelurahan, dan dokumen kasus.',
  ),
];
