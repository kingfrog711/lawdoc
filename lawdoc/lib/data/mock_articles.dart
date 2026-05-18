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
  // ── PERCERAIAN ─────────────────────────────────────────────────────────────

  Article(
    id: 'perceraian-sendiri',
    title: 'Cara mengajukan gugatan perceraian sendiri',
    category: ArticleCategory.perceraian,
    readMinutes: 7,
    difficulty: 'Mudah dibaca',
    preview:
        'Tidak harus pakai pengacara. Kalau Anda Muslim, gugatan masuk ke Pengadilan Agama; '
        'kalau bukan, ke Pengadilan Negeri. Berikut yang perlu disiapkan.',
    content:
        'Perceraian di Indonesia diatur oleh UU No. 1 Tahun 1974 tentang Perkawinan. Yang Muslim mengajukan '
        'gugatan ke Pengadilan Agama, yang non-Muslim ke Pengadilan Negeri. Anda bisa mengajukan sendiri tanpa '
        'pengacara.\n\n'
        'Yang perlu disiapkan: fotokopi KTP suami dan istri, buku nikah asli plus fotokopinya, fotokopi akta '
        'kelahiran anak kalau ada, surat gugatan yang menjelaskan alasan, dan bukti pendukung apa pun yang '
        'menguatkan (foto, screenshot WhatsApp, surat keterangan, dan sebagainya).\n\n'
        'Alasan apa saja yang diakui hukum? PP No. 9/1975 Pasal 19 dan KHI Pasal 116 menyebutkan beberapa: '
        'salah satu pihak berzina, jadi pemabuk, pemadat, atau penjudi yang sulit disembuhkan, '
        'meninggalkan pasangan dua tahun berturut-turut tanpa izin, dihukum penjara lima tahun atau lebih, '
        'melakukan kekejaman atau penganiayaan berat (KDRT termasuk di sini), cacat badan atau penyakit yang '
        'membuat tidak bisa memenuhi kewajiban sebagai suami istri, dan perselisihan terus-menerus tanpa '
        'harapan rukun kembali.\n\n'
        'Biaya panjar perkara berkisar Rp 300rb sampai Rp 700rb tergantung pengadilan. Yang tidak mampu '
        'bisa mengajukan permohonan berperkara secara prodeo (gratis), cukup melampirkan surat keterangan '
        'tidak mampu dari kelurahan. Rata-rata proses memakan waktu 3 sampai 6 bulan, dimulai dengan '
        'mediasi wajib di awal (PERMA No. 1/2016).',
    sources: [
      'UU No. 1 Tahun 1974 tentang Perkawinan, Pasal 39',
      'PP No. 9 Tahun 1975, Pasal 19',
      'Kompilasi Hukum Islam (Inpres No. 1/1991), Pasal 116',
      'PERMA No. 1 Tahun 2016 tentang Mediasi',
    ],
  ),

  Article(
    id: 'hak-asuh-anak',
    title: 'Hak asuh anak setelah perceraian',
    category: ArticleCategory.perceraian,
    readMinutes: 6,
    difficulty: 'Mudah dibaca',
    preview:
        'Anak di bawah 12 tahun biasanya ikut ibu. Anak yang sudah 12 ke atas berhak memilih. '
        'Tapi ada syarat dan pengecualiannya.',
    content:
        'UU No. 1/1974 Pasal 41 menegaskan bahwa setelah perceraian, kedua orang tua tetap bertanggung jawab '
        'memelihara dan mendidik anak. Biaya pemeliharaan dibebankan ke bapak; kalau bapak tidak mampu, '
        'ibu turut menanggung.\n\n'
        'Untuk warga Muslim, KHI Pasal 105 mengatur lebih spesifik. Anak yang belum mumayyiz (di bawah 12 '
        'tahun) hak asuhnya ke ibu. Anak yang sudah mumayyiz (12 tahun ke atas) berhak memilih sendiri mau '
        'ikut ibu atau ayah. Biaya hidup anak tetap kewajiban ayah, terlepas dari siapa yang mendapat hak asuh.\n\n'
        'Ada pengecualian. Ibu bisa kehilangan hak hadhanah kalau murtad, berkelakuan buruk, atau dinilai '
        'tidak mampu menjaga kepentingan anak. Pihak yang merasa keberatan boleh mengajukan permohonan ke '
        'Pengadilan Agama untuk mengalihkan hak asuh.\n\n'
        'Satu hal yang penting diluruskan: hak asuh itu bukan hak milik atas anak. Orang tua yang tidak '
        'mendapat hak asuh tetap punya hak akses (bertemu anak) dan tetap wajib memberi nafkah. Kalau ayah '
        'lalai membayar nafkah anak, itu bisa dilaporkan secara pidana berdasarkan UU No. 23/2002 tentang '
        'Perlindungan Anak.',
    sources: [
      'UU No. 1 Tahun 1974 tentang Perkawinan, Pasal 41',
      'Kompilasi Hukum Islam (Inpres No. 1/1991), Pasal 105 & 156',
      'UU No. 23 Tahun 2002 tentang Perlindungan Anak',
    ],
  ),

  Article(
    id: 'nafkah-iddah-mutah',
    title: 'Nafkah iddah dan mut\'ah: hak istri setelah cerai',
    category: ArticleCategory.perceraian,
    readMinutes: 5,
    difficulty: 'Mudah dibaca',
    preview:
        'Setelah cerai talak, mantan istri berhak nafkah selama masa iddah ditambah uang pisah '
        '(mut\'ah). Sering dilupakan, padahal jelas diatur di KHI.',
    content:
        'Dalam hukum Islam (KHI Pasal 149), kalau perceraian dijatuhkan oleh suami lewat cerai talak, '
        'mantan suami wajib membayar beberapa hal kepada mantan istri.\n\n'
        'Pertama, nafkah mut\'ah. Ini semacam uang pisah, bisa berbentuk uang tunai atau barang. '
        'Besarnya layak dan disesuaikan dengan kemampuan suami, biasanya ditetapkan hakim setelah '
        'mempertimbangkan lama pernikahan dan penghasilan suami.\n\n'
        'Kedua, nafkah iddah. Ini nafkah harian selama masa iddah, yang biasanya berlangsung tiga kali suci '
        'atau sekitar tiga bulan untuk yang tidak hamil, atau sampai melahirkan kalau hamil. Cakupannya '
        'makan, tempat tinggal (maskan), dan pakaian (kiswah).\n\n'
        'Yang terpisah dan tetap berjalan walaupun di luar iddah adalah nafkah anak. Ini tanggung jawab ayah '
        'sampai anak dewasa atau mandiri (KHI Pasal 156).\n\n'
        'Pengecualian: nafkah iddah tidak wajib kalau istri terbukti nusyuz (tidak taat tanpa alasan sah) '
        'sebelum talak dijatuhkan. Yang menentukan ada-tidaknya nusyuz itu hakim Pengadilan Agama, bukan '
        'klaim sepihak.\n\n'
        'Kalau mantan suami menolak membayar setelah ada putusan pengadilan, istri bisa mengajukan eksekusi '
        'putusan lewat pengadilan yang sama. Eksekusi ini bisa berupa penyitaan harta mantan suami.',
    sources: [
      'Kompilasi Hukum Islam (Inpres No. 1/1991), Pasal 149 & 152',
      'Kompilasi Hukum Islam Pasal 156 (nafkah anak)',
      'Yurisprudensi Mahkamah Agung tentang nafkah iddah',
    ],
  ),

  Article(
    id: 'kdrt-cerai',
    title: 'KDRT sebagai alasan perceraian, dan perlindungan untuk korban',
    category: ArticleCategory.perceraian,
    readMinutes: 6,
    difficulty: 'Mudah dibaca',
    preview:
        'Kekerasan dalam rumah tangga adalah alasan kuat untuk cerai, dan korban berhak '
        'perlindungan resmi dari pengadilan.',
    content:
        'KDRT punya undang-undang sendiri: UU No. 23 Tahun 2004 tentang Penghapusan Kekerasan Dalam Rumah '
        'Tangga (UU PKDRT). Pasal 5 mengakui empat bentuk: kekerasan fisik, kekerasan psikis, kekerasan '
        'seksual, dan penelantaran rumah tangga.\n\n'
        'Untuk perceraian, KDRT masuk kategori "penganiayaan berat" yang menjadi alasan sah cerai (PP No. '
        '9/1975 Pasal 19 huruf d, dan KHI Pasal 116 huruf d). Bukti yang menguatkan gugatan biasanya '
        'visum dari rumah sakit, Laporan Polisi, atau keterangan saksi.\n\n'
        'Yang sering tidak diketahui korban, UU PKDRT juga menyediakan perlindungan langsung. Anda bisa '
        'meminta perlindungan sementara dari pengadilan, yang dikeluarkan dalam waktu 7 hari sejak '
        'permohonan masuk. Isinya bisa berupa perintah agar pelaku menjauh dari korban (Pasal 28-32). '
        'Setelah itu, hakim bisa mengeluarkan perintah perlindungan yang berlaku sampai 1 tahun dan bisa '
        'diperpanjang. Perintah ini melarang pelaku mendekati korban, rumah, atau tempat kerja.\n\n'
        'Hak korban yang lain mencakup pelayanan kesehatan, pendampingan rohaniwan atau advokat, konseling, '
        'dan akses ke rumah aman.\n\n'
        'Mau lapor ke mana? Kalau pidana, ke polisi atau Unit PPA (Perlindungan Perempuan dan Anak) di '
        'Polres. Untuk pendampingan hukum, LBH APIK atau Komnas Perempuan. Ada juga hotline darurat di 129 '
        '(Sahabat Perempuan dan Anak / SAPA).',
    sources: [
      'UU No. 23 Tahun 2004 tentang Penghapusan KDRT, Pasal 5, 28–32',
      'PP No. 9 Tahun 1975, Pasal 19 huruf d',
      'Kompilasi Hukum Islam, Pasal 116 huruf d',
      'Komnas Perempuan — laporan tahunan kekerasan',
    ],
  ),

  // ── WARIS ──────────────────────────────────────────────────────────────────

  Article(
    id: 'hak-waris-perempuan',
    title: 'Hak waris anak perempuan menurut KUHPerdata',
    category: ArticleCategory.waris,
    readMinutes: 5,
    difficulty: 'Mudah dibaca',
    preview:
        'Salah satu mitos waris yang masih sering muncul: anak perempuan dapat lebih sedikit. '
        'Untuk non-Muslim, KUHPerdata bilang tidak.',
    content:
        'Untuk warga non-Muslim, sistem waris yang berlaku adalah KUHPerdata. KUHPerdata Pasal 832 '
        'menyatakan bahwa keluarga sedarah adalah ahli waris menurut hukum.\n\n'
        'Yang sering disalahpahami: KUHPerdata tidak membedakan bagian anak laki-laki dan anak perempuan. '
        'Semua anak sah, baik laki-laki maupun perempuan, mendapat bagian yang sama dari harta warisan '
        'orang tua. Pembagian baru bisa berbeda kalau ada wasiat tertulis yang sah, dan wasiat itu pun '
        'tidak boleh melanggar legitime portie (bagian mutlak yang dijamin untuk anak) yang diatur '
        'KUHPerdata Pasal 913-929.\n\n'
        'Catatan penting buat yang sering tertukar: untuk warga Muslim sistemnya berbeda. Hukum Islam yang '
        'tertuang di KHI Pasal 174-214 memang membagi anak laki-laki dan perempuan dengan rasio 2:1. '
        'Itu bahasan tersendiri.\n\n'
        'Kalau ada sengketa, perkaranya diajukan ke Pengadilan Negeri untuk non-Muslim, atau Pengadilan '
        'Agama untuk Muslim. Pengadilan Agama mendapat kewenangan menangani sengketa waris Muslim sejak '
        'UU No. 3/2006.',
    sources: [
      'KUHPerdata (Burgerlijk Wetboek), Pasal 832, 850, 852',
      'KUHPerdata Pasal 913–929 tentang legitime portie',
      'UU No. 3 Tahun 2006 tentang Pengadilan Agama',
    ],
  ),

  Article(
    id: 'sistem-waris-indonesia',
    title: 'Tiga sistem waris di Indonesia: yang mana berlaku untuk Anda?',
    category: ArticleCategory.waris,
    readMinutes: 7,
    difficulty: 'Mudah dibaca',
    preview:
        'Tidak ada satu kode waris tunggal di Indonesia. Ada tiga, dan yang berlaku tergantung '
        'agama dan asal-usul pewaris.',
    content:
        'Tidak seperti negara dengan satu kode waris tunggal, Indonesia memelihara tiga sistem yang '
        'berjalan paralel. Yang berlaku ditentukan oleh agama pewaris dan pilihan hukum semasa hidupnya.\n\n'
        'Pertama, KUHPerdata (Burgerlijk Wetboek). Sistem ini berlaku untuk keturunan Eropa, Tionghoa '
        'sebelum 1963, dan siapa pun yang menundukkan diri pada hukum perdata Barat (misalnya pasangan beda '
        'agama yang menikah di Catatan Sipil). KUHPerdata Pasal 850 dan seterusnya membagi ahli waris ke '
        'empat golongan: (1) anak dan pasangan, (2) orang tua dan saudara, (3) kakek nenek, (4) saudara '
        'dalam derajat lebih jauh. Penyelesaian sengketa di Pengadilan Negeri.\n\n'
        'Kedua, Kompilasi Hukum Islam (KHI) yang ditetapkan lewat Inpres No. 1/1991. Berlaku untuk warga '
        'Muslim, mengikuti pembagian faraidh dari Al-Qur\'an dan Sunnah. Diatur di Pasal 174-214. Sengketa '
        'ditangani Pengadilan Agama.\n\n'
        'Ketiga, hukum adat. Variasinya banyak, tergantung asal komunitas pewaris. Di Minangkabau sistemnya '
        'matrilineal, harta pusaka tinggi turun lewat garis ibu, sengketa diselesaikan di KAN (Kerapatan '
        'Adat Nagari). Batak sebaliknya, patrilineal, dengan forum Dalihan na Tolu. Bali pakai sistem '
        'purusa (anak laki-laki), khususnya untuk pekarangan. Jawa lebih bilateral, dengan istilah '
        '"sepikul segendong" — laki-laki dua bagian, perempuan satu — meskipun sifatnya informal.\n\n'
        'Yang menentukan akhirnya: kalau pewaris Muslim, tunduk pada KHI dan Pengadilan Agama (UU No. '
        '3/2006). Kalau non-Muslim, bisa pilih KUHPerdata atau hukum adat asalnya. Kalau dalam satu '
        'keluarga ada konflik sistem (misalnya anak Muslim, orang tua non-Muslim), hakim yang memutus '
        'sistem mana yang dipakai.',
    sources: [
      'KUHPerdata, Pasal 850–873',
      'Kompilasi Hukum Islam (Inpres No. 1/1991), Pasal 174–214',
      'UU No. 3 Tahun 2006 tentang Peradilan Agama',
      'Yurisprudensi MA tentang waris adat',
    ],
  ),

  Article(
    id: 'waris-islam-faraidh',
    title: 'Bagian waris dalam hukum Islam: mengapa anak laki-laki 2:1?',
    category: ArticleCategory.waris,
    readMinutes: 8,
    difficulty: 'Sedang',
    preview:
        'Dalam waris Islam, bagian anak laki-laki memang dua kali anak perempuan. '
        'Alasannya menarik, dan ada cara untuk membagi lebih merata kalau itu yang Anda mau.',
    content:
        'KHI (Inpres No. 1/1991) mengatur sistem waris Islam di Indonesia berdasarkan kaidah faraidh dari '
        'Al-Qur\'an Surat An-Nisa.\n\n'
        'Pasal 176 KHI menyatakan: "Anak perempuan bila hanya seorang ia mendapat separoh bagian, bila dua '
        'orang atau lebih mereka bersama-sama mendapat dua pertiga bagian, dan apabila anak perempuan '
        'bersama-sama dengan anak laki-laki, maka bagian anak laki-laki adalah dua berbanding satu dengan '
        'anak perempuan."\n\n'
        'Logikanya dari mana? Dalam doktrin Islam klasik, anak laki-laki menanggung kewajiban finansial '
        'yang lebih besar: nafkah istri, anak, sampai orang tua. Bagian waris yang lebih besar diberikan '
        'untuk mengimbangi tanggung jawab itu. Konteks ini sering hilang ketika orang hanya melihat angka 2:1 '
        'tanpa kewajiban pelengkapnya.\n\n'
        'Selain pembagian anak, ada bagian pasti (furudh) untuk ahli waris utama. Suami dapat seperempat '
        'kalau ada anak, setengah kalau tidak ada anak (KHI Pasal 179). Istri dapat seperdelapan kalau ada '
        'anak, seperempat kalau tidak ada anak (Pasal 180). Ibu dapat seperenam kalau ada anak, sepertiga '
        'kalau tidak. Ayah dapat seperenam plus sisa.\n\n'
        'Buat keluarga yang ingin pembagian lebih merata, hukum Islam sebenarnya menyediakan dua jalur: '
        'hibah dan wasiat. Hibah adalah pemberian semasa hidup (KHI Pasal 210), bebas dari batas faraidh '
        'karena dilakukan saat pewaris masih hidup. Wasiat maksimal sepertiga harta untuk pihak non-ahli '
        'waris (Pasal 195). Wasiat untuk sesama ahli waris boleh, asal disetujui ahli waris lain.\n\n'
        'Penyelesaian sengketa waris Islam ada di Pengadilan Agama. Sebelum litigasi, KHI Pasal 183 '
        'mengizinkan pembagian damai kalau seluruh ahli waris sepakat.',
    sources: [
      'Kompilasi Hukum Islam (Inpres No. 1/1991), Pasal 174–214',
      'KHI Pasal 176, 179–183 (bagian ahli waris)',
      'KHI Pasal 195, 210 (hibah & wasiat)',
      'Al-Qur\'an Surat An-Nisa: 11, 12, 176',
    ],
  ),

  Article(
    id: 'wasiat-legitime-portie',
    title: 'Wasiat: berapa maksimal harta yang bisa diwariskan ke non-keluarga?',
    category: ArticleCategory.waris,
    readMinutes: 5,
    difficulty: 'Sedang',
    preview:
        'Anda tidak bebas menulis wasiat apa pun. Hukum menjamin "bagian mutlak" untuk anak dan '
        'pasangan yang tidak bisa dipangkas wasiat.',
    content:
        'Wasiat (testament) adalah pernyataan tertulis soal pembagian harta setelah pewaris meninggal. '
        'Tapi Anda tidak bisa sembarang menulis wasiat: hukum membatasi seberapa banyak harta yang boleh '
        'diwariskan ke pihak di luar ahli waris alami.\n\n'
        'Untuk warga non-Muslim, KUHPerdata Pasal 913-929 mengatur konsep legitime portie atau bagian mutlak. '
        'Anak sah dan pasangan punya jatah yang tidak boleh dikurangi oleh wasiat. Kalau Anda punya satu '
        'anak, bagian mutlaknya setengah dari bagian wajar tanpa wasiat. Dua anak: dua pertiga. Tiga anak '
        'atau lebih: tiga perempat. Praktisnya, kalau Anda punya dua anak, hanya sepertiga harta yang bisa '
        'diwasiatkan ke pihak lain seperti yayasan atau sahabat. Sisanya wajib jadi hak anak-anak.\n\n'
        'Untuk warga Muslim, KHI Pasal 195 lebih ringkas: wasiat untuk pihak non-ahli waris maksimal '
        'sepertiga harta. Wasiat untuk sesama ahli waris perlu persetujuan ahli waris lain. Pengecualian: '
        'wasiat lebih dari sepertiga tetap bisa berlaku kalau seluruh ahli waris setuju setelah pewaris '
        'meninggal.\n\n'
        'Bentuk wasiat yang sah ada beberapa. Yang paling kuat adalah wasiat di hadapan notaris. Bisa juga '
        'wasiat olographis (ditulis dan ditandatangani sendiri, lalu disimpan di notaris), atau wasiat '
        'dalam keadaan darurat (kekuatannya terbatas dan mudah digugat).\n\n'
        'Kalau Anda butuh pembagian harta yang lebih fleksibel tanpa harus berhadapan dengan legitime '
        'portie, banyak orang memilih hibah (KUHPerdata Pasal 1666 untuk non-Muslim, KHI Pasal 210 untuk '
        'Muslim). Karena dilakukan saat pewaris masih hidup, hibah bebas dari pembatasan waris.',
    sources: [
      'KUHPerdata, Pasal 875–912 tentang wasiat',
      'KUHPerdata, Pasal 913–929 tentang legitime portie',
      'KUHPerdata, Pasal 1666 tentang hibah',
      'Kompilasi Hukum Islam, Pasal 194–209 (wasiat), Pasal 210 (hibah)',
    ],
  ),

  // ── UTANG PIUTANG ──────────────────────────────────────────────────────────

  Article(
    id: 'utang-ditagih-kasar',
    title: 'Apa yang harus dilakukan kalau utang ditagih kasar?',
    category: ArticleCategory.utang,
    readMinutes: 6,
    difficulty: 'Mudah dibaca',
    preview:
        'Debt collector tidak boleh mengancam, mempermalukan Anda di depan tetangga, atau datang '
        'pukul sebelas malam. Itu ada aturannya.',
    content:
        'Penagihan utang dari lembaga keuangan resmi (bank, multifinance, pinjol terdaftar) diatur oleh '
        'OJK. POJK No. 22/2023 tentang Pelindungan Konsumen Sektor Jasa Keuangan, pengganti POJK No. 22/2020, '
        'menetapkan aturan yang cukup jelas.\n\n'
        'Yang dilarang: mengancam atau melakukan kekerasan fisik dan verbal, mempermalukan konsumen '
        '(misalnya menyebar foto atau data ke seluruh kontak HP), pakai kata-kata kasar atau intimidasi, '
        'menagih ke pihak ketiga seperti keluarga atau atasan tanpa izin, dan menagih di luar jam 08.00-20.00 '
        'waktu setempat. Petugas penagih juga dilarang memakai identitas palsu atau berpura-pura sebagai aparat.\n\n'
        'Untuk pinjaman online (pinjol), aturan yang sama berlaku, plus POJK No. 10/2022. Catatan penting: '
        'pinjol yang tidak terdaftar OJK alias ilegal tidak punya kekuatan hukum untuk menagih. Pengadilan '
        'tidak akan mengeluarkan putusan yang memaksa Anda membayar pinjol ilegal. Mereka biasanya hanya '
        'mengandalkan teror dan intimidasi.\n\n'
        'Kalau Anda diteror, beberapa kanal pelaporan bisa dipakai. OJK punya call center 157 dan WhatsApp '
        '081-157-157-157. Kalau ada ancaman pidana seperti pemerasan, langsung ke polisi. YLKI menerima '
        'pengaduan konsumen umum, dan AFPI menangani pinjol resmi.\n\n'
        'Yang perlu disadari: utang yang sah memang harus dibayar. Tapi cara penagihannya wajib manusiawi '
        'dan legal. Kalau Anda kesulitan, jalan yang lebih baik daripada lari adalah mengajukan '
        'restrukturisasi atau cicilan ulang ke lembaga pinjaman. Banyak yang mau bernegosiasi.',
    sources: [
      'POJK No. 22 Tahun 2023 tentang Pelindungan Konsumen Sektor Jasa Keuangan',
      'POJK No. 10 Tahun 2022 tentang Layanan Pendanaan Bersama Berbasis TI',
      'UU No. 8 Tahun 1999 tentang Perlindungan Konsumen',
      'Daftar pinjol terdaftar OJK: ojk.go.id',
    ],
  ),

  Article(
    id: 'gugatan-sederhana',
    title: 'Gugatan sederhana: cara cepat menggugat utang di bawah Rp500jt',
    category: ArticleCategory.utang,
    readMinutes: 6,
    difficulty: 'Sedang',
    preview:
        'Sengketa utang piutang sampai Rp500jt bisa diselesaikan dalam 25 hari kerja, hakim tunggal, '
        'tanpa pengacara. Banyak orang belum tahu jalur ini.',
    content:
        'PERMA No. 4 Tahun 2019 (perubahan dari PERMA No. 2/2015) menyediakan jalur cepat untuk sengketa '
        'perdata bernilai kecil. Sangat berguna kalau Anda mau menagih utang atau wanprestasi sederhana '
        'tanpa harus melewati jalur biasa yang bisa berbulan-bulan.\n\n'
        'Syarat utamanya: nilai gugatan maksimal Rp 500 juta (sebelumnya Rp 200 juta), para pihak berdomisili '
        'di wilayah hukum pengadilan yang sama, dan pihak penggugat maupun tergugat masing-masing tidak '
        'lebih dari satu (kecuali ada kepentingan hukum yang sama, misalnya beberapa kreditur ke satu '
        'debitur). Yang bisa diajukan: kasus perdata wanprestasi atau perbuatan melawan hukum. Yang tidak '
        'bisa: sengketa tanah, perceraian, dan perkara yang penyelesaiannya wajib lewat lembaga khusus '
        '(seperti ketenagakerjaan, yang ada di PHI).\n\n'
        'Yang membuat jalur ini cepat: hakim tunggal alih-alih majelis tiga hakim, maksimal 25 hari kerja '
        'dari sidang pertama sampai putusan, pemeriksaan singkat tanpa replik-duplik atau kesimpulan, dan '
        'biaya panjar lebih rendah (mulai Rp 200rb tergantung pengadilan). Anda juga tidak wajib pakai '
        'pengacara, para pihak bisa hadir sendiri. Setelah putusan, eksekusinya juga lebih sederhana.\n\n'
        'Langkah praktisnya: datang ke Pengadilan Negeri setempat, isi formulir gugatan sederhana di meja '
        'Posbakum kalau perlu bantuan, bayar panjar, tunggu panggilan sidang. Kalau tergugat tidak sukarela '
        'membayar setelah putusan, ajukan eksekusi ke pengadilan yang sama.',
    sources: [
      'PERMA No. 4 Tahun 2019 tentang Perubahan PERMA Gugatan Sederhana',
      'PERMA No. 2 Tahun 2015 tentang Tata Cara Penyelesaian Gugatan Sederhana',
      'HIR/RBg (hukum acara perdata) sebagai pelengkap',
    ],
  ),

  Article(
    id: 'wanprestasi-vs-pmh',
    title: 'Wanprestasi vs Perbuatan Melawan Hukum: apa bedanya?',
    category: ArticleCategory.utang,
    readMinutes: 6,
    difficulty: 'Sedang',
    preview:
        'Dua jenis gugatan utang yang sering tertukar di kepala orang awam. '
        'Memilih yang salah bisa bikin gugatan kandas di awal.',
    content:
        'Hukum perdata Indonesia mengenal dua dasar gugatan ganti rugi yang paling sering dipakai: '
        'wanprestasi dan perbuatan melawan hukum (PMH). Keduanya beda asal-usul dan beda strategi pembuktian.\n\n'
        'Wanprestasi (KUHPerdata Pasal 1243-1252) intinya "tidak memenuhi prestasi atau kewajiban dalam '
        'suatu perjanjian." Jadi syarat pertamanya: ada perjanjian, baik lisan maupun tertulis, antara '
        'para pihak. Salah satu pihak kemudian tidak melaksanakan kewajibannya, terlambat, atau '
        'melaksanakan tapi tidak sesuai perjanjian. Sebelum gugat, biasanya harus didahului somasi yaitu '
        'peringatan tertulis ke debitur, kecuali tenggat sudah jelas dalam perjanjian itu sendiri '
        '(KUHPerdata Pasal 1238). Bentuk wanprestasi bisa berupa tidak melaksanakan sama sekali, '
        'melaksanakan tapi terlambat, melaksanakan tapi tidak sesuai, atau malah melaksanakan apa yang '
        'justru dilarang perjanjian. Ganti ruginya mencakup biaya, kerugian, dan bunga (Pasal 1243).\n\n'
        'Perbuatan Melawan Hukum / PMH (KUHPerdata Pasal 1365) jauh lebih luas. Bunyi pasalnya: "Tiap '
        'perbuatan melawan hukum yang menimbulkan kerugian kepada orang lain mewajibkan orang yang karena '
        'salahnya menyebabkan kerugian itu mengganti kerugian tersebut." Tidak perlu ada perjanjian '
        'sebelumnya. Yang harus dipenuhi (berdasarkan yurisprudensi): ada perbuatan baik aktif maupun pasif, '
        'perbuatan itu melawan hukum (melanggar UU, hak orang lain, kepatutan, atau kebiasaan), ada '
        'kesalahan baik sengaja maupun lalai, ada kerugian, dan ada hubungan sebab akibat. Contoh kasus '
        'PMH: tabrakan lalu lintas, pencemaran nama baik, sengketa tetangga.\n\n'
        'Cara memilih sederhana: kalau ada perjanjian yang dilanggar, gugat lewat wanprestasi. Kalau tidak '
        'ada perjanjian sebelumnya, gugat lewat PMH. Kadang satu kasus bisa keduanya, dan strategi yang '
        'lazim adalah pilih dasar yang buktinya lebih kuat.',
    sources: [
      'KUHPerdata, Pasal 1243–1252 tentang wanprestasi',
      'KUHPerdata, Pasal 1365 tentang perbuatan melawan hukum',
      'KUHPerdata, Pasal 1238 tentang somasi',
      'Yurisprudensi MA tentang unsur-unsur PMH',
    ],
  ),

  Article(
    id: 'force-majeure',
    title: 'Force majeure: bisakah Anda bebas dari kewajiban karena bencana?',
    category: ArticleCategory.utang,
    readMinutes: 5,
    difficulty: 'Sedang',
    preview:
        'Bencana alam, pandemi, atau perang bisa membatalkan kewajiban. Tapi syaratnya ketat, '
        'dan tidak semua "kesulitan" diterima hakim.',
    content:
        'Force majeure atau keadaan memaksa diatur di KUHPerdata Pasal 1244 dan 1245. Pasal 1244 intinya '
        'menyatakan bahwa debitur tetap dihukum mengganti biaya, rugi, dan bunga, kecuali ia bisa '
        'membuktikan bahwa kewajibannya tidak terlaksana karena hal tak terduga yang tidak bisa '
        'dipertanggungjawabkan padanya, dan tidak ada iktikad buruk. Pasal 1245 menambahkan bahwa biaya, '
        'rugi, dan bunga tidak harus diganti kalau keadaan memaksa atau kejadian tak disengaja menghalangi '
        'debitur memenuhi kewajibannya.\n\n'
        'Yurisprudensi MA menetapkan empat syarat agar suatu peristiwa diakui sebagai force majeure: tidak '
        'terduga, dalam arti tidak bisa diantisipasi saat perjanjian dibuat; tidak bisa dihindari, meski '
        'sudah berupaya wajar; bukan kesalahan debitur, tidak ada unsur kelalaian; dan memang menghalangi '
        'pemenuhan, dalam arti membuat pemenuhan jadi mustahil atau sangat berat.\n\n'
        'Contoh yang biasanya diterima hakim: gempa bumi merusak gudang, bencana alam yang ditetapkan '
        'resmi oleh pemerintah, atau kebijakan pemerintah tiba-tiba (misalnya PSBB awal Covid yang melarang '
        'operasional). Yang biasanya ditolak: kondisi ekonomi memburuk, pendapatan turun, atau kesulitan '
        'keuangan umum tanpa peristiwa konkret yang menyebabkannya.\n\n'
        'Ada juga pembedaan antara force majeure absolut dan relatif. Yang absolut bikin pemenuhan jadi '
        'mustahil selamanya, sehingga perjanjian batal. Yang relatif hanya menunda atau membuat lebih '
        'berat, jadi kewajibannya tertunda bukan hilang.\n\n'
        'Di kontrak modern, biasanya ada klausul force majeure yang merinci apa yang dianggap force majeure '
        'untuk perjanjian itu, mulai dari perang, pandemi, sampai bencana. Kalau tidak ada klausul, hakim '
        'akan menafsirkan berdasarkan Pasal 1244-1245 dan yurisprudensi.',
    sources: [
      'KUHPerdata, Pasal 1244–1245 tentang keadaan memaksa',
      'Yurisprudensi MA tentang force majeure',
      'Diskursus akademik hukum kontrak Indonesia',
    ],
  ),

  // ── SENGKETA TANAH ─────────────────────────────────────────────────────────

  Article(
    id: 'sertifikat-tanah',
    title: 'Cek sertifikat tanah: 5 langkah di BPN',
    category: ArticleCategory.tanah,
    readMinutes: 6,
    difficulty: 'Mudah dibaca',
    preview:
        'Sebelum beli atau menerima warisan tanah, cek dulu sertifikatnya di BPN. '
        'Sertifikat asli pun bisa bermasalah — sertifikat ganda, wakaf tidak terdaftar, sengketa tersembunyi.',
    content:
        'Sertifikat tanah adalah tanda bukti hak paling kuat menurut UU No. 5/1960 (UUPA) dan PP No. 24/1997 '
        'tentang Pendaftaran Tanah. Tapi sertifikat asli pun bisa bermasalah: sertifikat ganda, wakaf yang '
        'tidak terdaftar, atau objek tanah yang sebenarnya sedang disengketakan.\n\n'
        'Cara mengecek tidak rumit. Datang ke Kantor BPN sesuai lokasi tanah (bukan domisili pemilik). '
        'Bawa fotokopi sertifikat asli dan KTP pemohon. Kalau Anda bukan pemiliknya, perlu surat kuasa dari '
        'pemilik di atas materai. Di kantor BPN, isi formulir permohonan pengecekan sertifikat di loket, '
        'lalu bayar PNBP sekitar Rp 50.000 per sertifikat sesuai PP No. 128/2015. Hasilnya keluar 1 sampai 3 '
        'hari kerja, dalam bentuk Surat Keterangan Pendaftaran Tanah (SKPT) yang menunjukkan status terkini: '
        'aktif, dibebani hak tanggungan, atau dalam sengketa.\n\n'
        'Sudah ada alternatif digital. Aplikasi resmi BPN namanya Sentuh Tanahku, memungkinkan pengecekan '
        'online kalau sertifikat sudah ter-elektronik (e-sertifikat). Cek juga website atrbpn.go.id.\n\n'
        'Beberapa tanda sertifikat bermasalah yang bisa Anda lihat dengan mata sendiri: nomor hak ganda '
        'atau tidak terdaftar di BPN, ada catatan "dalam sengketa" pada SKPT, batas tanah di sertifikat '
        'tidak sesuai kondisi fisik (perlu pengukuran ulang), atau tanda tangan pejabat dan cap BPN '
        'kelihatan janggal. Yang terakhir ini wajib diautentikasi langsung ke BPN.\n\n'
        'Kalau ternyata sertifikat bermasalah, langkahnya bukan ke pengadilan perdata biasa. Konsultasikan '
        'dengan pengacara agraria, atau ajukan permohonan pembatalan sertifikat ke Pengadilan Tata Usaha '
        'Negara (PTUN). Banyak orang salah pintu dan akhirnya gugatannya ditolak.',
    sources: [
      'UU No. 5 Tahun 1960 tentang Pokok Agraria (UUPA)',
      'PP No. 24 Tahun 1997 tentang Pendaftaran Tanah',
      'PP No. 128 Tahun 2015 tentang PNBP Kementerian ATR/BPN',
      'Aplikasi Sentuh Tanahku — Kementerian ATR/BPN',
    ],
  ),

  Article(
    id: 'jenis-hak-tanah',
    title: 'SHM, HGB, HGU, Hak Pakai: apa bedanya?',
    category: ArticleCategory.tanah,
    readMinutes: 7,
    difficulty: 'Mudah dibaca',
    preview:
        'Tidak semua "sertifikat tanah" sama kuatnya. Empat jenis hak utama menurut UUPA, '
        'dan bedanya menentukan apa yang bisa Anda lakukan dengan tanah itu.',
    content:
        'UU No. 5/1960 (UUPA) menetapkan beberapa jenis hak atas tanah. Empat yang paling sering ditemui '
        'untuk perorangan adalah SHM, HGB, HGU, dan Hak Pakai.\n\n'
        'Sertifikat Hak Milik (SHM, UUPA Pasal 20) adalah hak paling kuat dan berlaku selamanya tanpa batas '
        'waktu. Bisa diwariskan, dijual, dihibahkan, dijadikan jaminan kredit. Tapi ada batasan kepemilikan: '
        'hanya untuk WNI perorangan, atau badan hukum tertentu yang ditunjuk pemerintah seperti bank '
        'pemerintah. WNA tidak bisa memiliki SHM.\n\n'
        'Hak Guna Bangunan (HGB, UUPA Pasal 35) adalah hak untuk mendirikan dan memiliki bangunan di atas '
        'tanah yang bukan milik sendiri. Jangka waktunya 30 tahun, bisa diperpanjang 20 tahun, kemudian '
        'diperbarui 30 tahun. HGB umum dipakai untuk perumahan developer, termasuk apartemen dan rumah '
        'komersial. Bisa dimiliki WNI atau badan hukum Indonesia. Bagi pemegang WNI, HGB bisa ditingkatkan '
        'ke SHM dengan biaya BPHTB.\n\n'
        'Hak Guna Usaha (HGU, UUPA Pasal 28) adalah hak untuk mengusahakan tanah negara untuk pertanian, '
        'perkebunan, peternakan, atau perikanan. Jangka waktunya 25 sampai 35 tahun, dapat diperpanjang '
        'maksimal 25 tahun. Untuk perorangan, syarat minimumnya 5 hektar. HGU biasanya dipegang perusahaan '
        'perkebunan atau pertanian besar.\n\n'
        'Hak Pakai (UUPA Pasal 41) adalah hak menggunakan atau memungut hasil dari tanah yang dikuasai '
        'negara atau milik orang lain. Bisa dimiliki WNA untuk hunian (sesuai PP No. 18/2021). Jangka '
        'waktunya 30 tahun, diperpanjang 20 tahun, diperbarui 30 tahun. Bagi pemegang WNI, Hak Pakai juga '
        'bisa ditingkatkan ke SHM.\n\n'
        'Ada hak lain yang jarang ditemui untuk perorangan: Hak Tanggungan untuk jaminan kredit (UU No. '
        '4/1996), Hak Sewa, Hak Membuka Tanah dan Memungut Hasil Hutan untuk tanah adat, dan Hak Wakaf '
        'untuk kepentingan keagamaan.\n\n'
        'Tip praktis sebelum beli rumah: selalu cek jenis hak di sertifikat. Rumah dengan HGB perlu '
        'diperpanjang setiap 30 tahun, dan biaya perpanjangan bisa lumayan. SHM lebih aman jangka panjang, '
        'tapi harganya juga biasanya lebih mahal.',
    sources: [
      'UU No. 5 Tahun 1960 (UUPA), Pasal 20, 28, 35, 41',
      'PP No. 40 Tahun 1996 tentang HGU, HGB, dan Hak Pakai',
      'PP No. 18 Tahun 2021 tentang Hak Pakai untuk WNA',
      'UU No. 4 Tahun 1996 tentang Hak Tanggungan',
    ],
  ),

  Article(
    id: 'ptsl-sertifikat-gratis',
    title: 'PTSL: cara dapat sertifikat tanah gratis dari pemerintah',
    category: ArticleCategory.tanah,
    readMinutes: 5,
    difficulty: 'Mudah dibaca',
    preview:
        'Program nasional Pendaftaran Tanah Sistematis Lengkap memberi sertifikat gratis untuk '
        'tanah yang belum bersertifikat. Cek dulu apakah desa Anda sudah masuk program.',
    content:
        'PTSL adalah program nasional pemerintah untuk mensertifikatkan seluruh bidang tanah di Indonesia. '
        'Dasar hukumnya Perpres No. 13/2017 yang diperbarui Perpres No. 1/2018, plus Permen ATR/BPN No. '
        '6/2018.\n\n'
        'Yang sering jadi pertanyaan: benar-benar gratis? Sertifikatnya iya, tapi ada biaya yang tetap '
        'dibebankan pemohon: materai Rp 10.000, patok batas tanah opsional sekitar Rp 50-100rb per patok, '
        'fotokopi dokumen, dan di beberapa daerah ada biaya operasional sekitar Rp 150-250rb untuk '
        'transport surveyor.\n\n'
        'Syarat ikut PTSL: tanah sudah dikuasai atau dimiliki secara sah, dengan bukti girik, letter C, '
        'akta jual beli, surat waris, atau dokumen sejenis. Tanahnya berada di wilayah desa atau kelurahan '
        'yang ditetapkan masuk PTSL tahun berjalan. Tidak dalam sengketa. Pemilik atau ahli waris hadir '
        'saat pengukuran.\n\n'
        'Dokumen yang dibutuhkan: KTP dan KK pemohon, bukti perolehan tanah (girik, akta jual beli, surat '
        'waris, atau yang setara), bukti pembayaran PBB tahun terakhir, surat pernyataan penguasaan tanah '
        'secara sporadis dari kepala desa atau lurah, dan kadang surat persetujuan tetangga batas.\n\n'
        'Cara mendaftar: datang ke kepala desa atau lurah, atau langsung ke Kantor BPN setempat. Tanyakan '
        'apakah desa atau kelurahan Anda sudah ditetapkan masuk PTSL tahun ini. Kalau sudah, daftar dan '
        'tunggu jadwal pengukuran kolektif. Hasil akhirnya berupa sertifikat dengan jenis hak yang sesuai, '
        'biasanya SHM kalau Anda WNI dan menguasai sebagai milik. Penyerahan sertifikat biasanya dilakukan '
        'secara kolektif oleh BPN.\n\n'
        'Awas penipuan. Beberapa oknum mengaku-aku petugas PTSL dan meminta biaya tidak resmi. PTSL asli '
        'hanya berkoordinasi via kantor BPN dan kepala desa. Kalau ragu, konfirmasi langsung ke BPN kabupaten.',
    sources: [
      'Perpres No. 13 Tahun 2017 jo. Perpres No. 1 Tahun 2018 tentang PTSL',
      'Permen ATR/BPN No. 6 Tahun 2018 tentang Pendaftaran Tanah Sistematis Lengkap',
      'UU No. 5 Tahun 1960 (UUPA), Pasal 19 tentang pendaftaran tanah',
      'Kementerian ATR/BPN — info program PTSL: atrbpn.go.id',
    ],
  ),

  // ── UMUM ───────────────────────────────────────────────────────────────────

  Article(
    id: 'mediasi-sengketa',
    title: 'Mediasi sebelum sidang: mengapa wajib, dan bagaimana cara kerjanya',
    category: ArticleCategory.umum,
    readMinutes: 5,
    difficulty: 'Mudah dibaca',
    preview:
        'Setiap perkara perdata wajib lewat mediasi sebelum sidang utama. Bukan formalitas — '
        'banyak kasus selesai damai di tahap ini.',
    content:
        'PERMA No. 1 Tahun 2016 tentang Prosedur Mediasi di Pengadilan mewajibkan semua perkara perdata, '
        'termasuk perceraian (kecuali perceraian dengan alasan zina), untuk dimediasi sebelum sidang pokok. '
        'Banyak yang menganggap ini formalitas, padahal di tahap inilah banyak perkara selesai damai tanpa '
        'perlu sampai putusan paksa hakim.\n\n'
        'Mediasi adalah proses penyelesaian sengketa lewat perundingan dengan bantuan mediator bersertifikat. '
        'Tujuannya mencapai kesepakatan bersama. Jangka waktunya maksimal 30 hari sejak sidang pertama, '
        'bisa diperpanjang 30 hari lagi kalau para pihak setuju (Pasal 24). Kalau tidak ada kesepakatan, '
        'mediator menyatakan mediasi gagal dan perkara berlanjut ke sidang pokok.\n\n'
        'Mediator bisa hakim dari pengadilan itu sendiri (gratis), atau mediator profesional di luar '
        'pengadilan (biayanya ditanggung para pihak, Pasal 8 ayat 3).\n\n'
        'Prosesnya pendek. Di sidang pertama, hakim memerintahkan mediasi dan menunjuk mediator. Mediator '
        'lalu memanggil kedua pihak untuk pertemuan. Para pihak menjelaskan posisinya, mediator membantu '
        'mencari titik temu. Kalau ada kesepakatan, dibuat Akta Perdamaian yang ditandatangani para pihak '
        'dan disahkan hakim. Akta ini punya kekuatan hukum sama seperti putusan pengadilan yang '
        'berkekuatan tetap. Kalau gagal, mediator membuat laporan, perkara dilanjutkan.\n\n'
        'Alasan banyak orang menyarankan serius soal mediasi sederhana. Waktu yang dihabiskan jauh lebih '
        'pendek dibanding sidang pokok yang biasanya 6 sampai 12 bulan. Kalau mediatornya hakim, biayanya '
        'nol. Hasilnya juga bisa lebih fleksibel daripada putusan hakim, misalnya pembagian harta bersama '
        'tidak harus 50:50. Yang sering luput dari hitungan: hubungan keluarga atau bisnis kadang masih '
        'bisa diselamatkan kalau diselesaikan damai, beda dengan kalau sudah saling gugat sampai akhir.\n\n'
        'Beberapa perkara dikecualikan dari kewajiban mediasi: gugatan sederhana (PERMA 4/2019), perceraian '
        'karena zina, dan perkara yang sifatnya memang tidak dapat dimediasi seperti status hukum.',
    sources: [
      'PERMA No. 1 Tahun 2016 tentang Prosedur Mediasi di Pengadilan',
      'PERMA No. 1 Tahun 2016 Pasal 8 (mediator), Pasal 24 (waktu)',
      'PERMA No. 4 Tahun 2019 (pengecualian untuk gugatan sederhana)',
    ],
  ),

  Article(
    id: 'lbh-cara-daftar',
    title: 'Cara mendapat bantuan hukum gratis di LBH',
    category: ArticleCategory.umum,
    readMinutes: 4,
    difficulty: 'Mudah dibaca',
    preview:
        'LBH memberi pendampingan hukum gratis untuk masyarakat tidak mampu. '
        'Syarat dan caranya tidak rumit, asal dokumennya lengkap.',
    content:
        'Bantuan hukum gratis diatur oleh UU No. 16 Tahun 2011 tentang Bantuan Hukum. Negara wajib '
        'menyediakan pendampingan hukum bagi pencari keadilan yang miskin, baik dalam perkara pidana, '
        'perdata, maupun tata usaha negara, dan baik di pengadilan (litigasi) maupun di luar pengadilan '
        '(konsultasi, mediasi, dan sebagainya).\n\n'
        'Syarat penerima bantuan hukum menurut UU 16/2011 Pasal 14: WNI, tidak mampu (penghasilan di bawah '
        'garis kemiskinan setempat), punya Surat Keterangan Tidak Mampu (SKTM) dari kelurahan atau desa, '
        'punya KTP dan KK, dan kasus belum diselesaikan atau masih dalam proses.\n\n'
        'Dokumen yang dibawa: SKTM dari kepala desa, lurah, atau kepala dinsos; fotokopi KTP dan KK; '
        'surat permohonan bantuan hukum (LBH akan bantu membuatkan); dan dokumen kasus seperti laporan '
        'polisi, surat panggilan, atau gugatan.\n\n'
        'Lembaga yang memberikan bantuan hukum ada beberapa. LBH (Lembaga Bantuan Hukum) ada di hampir '
        'setiap kota besar, terhubung dengan YLBHI. Spesialisasinya luas: pidana, ketenagakerjaan, '
        'agraria, KDRT. LBH APIK lebih fokus pada perempuan dan korban kekerasan berbasis gender. Posbakum '
        '(Pos Bantuan Hukum) ada di setiap pengadilan untuk konsultasi singkat dan bantuan membuat surat '
        'gugatan, dasarnya PERMA No. 1/2014. Selain itu ada OBH (Organisasi Bantuan Hukum) yang '
        'terakreditasi Kemenkumham, totalnya lebih dari 500 OBH di seluruh Indonesia.\n\n'
        'Cara daftar sederhana. Datang langsung ke kantor LBH atau OBH terdekat dengan dokumen. Akan ada '
        'konsultasi awal di mana petugas menilai apakah kasus Anda bisa diterima. Kalau diterima, Anda '
        'akan diberi pendamping advokat atau paralegal yang menangani dari awal sampai putusan atau '
        'penyelesaian. Biaya hukum (jasa pengacara) ditanggung negara. Biaya operasional seperti '
        'transport, materai, dan panjar pengadilan kadang masih dibebankan ke pemohon, jadi tanyakan '
        'di awal.\n\n'
        'Untuk daftar OBH terakreditasi, cek di situs Badan Pembinaan Hukum Nasional (BPHN) Kemenkumham '
        'di bphn.go.id/sidbankum.',
    sources: [
      'UU No. 16 Tahun 2011 tentang Bantuan Hukum',
      'PP No. 42 Tahun 2013 tentang Pelaksanaan Bantuan Hukum',
      'PERMA No. 1 Tahun 2014 tentang Pedoman Pemberian Layanan Hukum bagi Masyarakat Tidak Mampu',
      'BPHN Kemenkumham — daftar OBH terakreditasi: bphn.go.id',
    ],
  ),

  Article(
    id: 'surat-kuasa',
    title: 'Surat kuasa: kapan wajib, kapan tidak?',
    category: ArticleCategory.umum,
    readMinutes: 4,
    difficulty: 'Mudah dibaca',
    preview:
        'Tidak semua urusan butuh surat kuasa, dan tidak semua surat kuasa sama kuat. '
        'Pelajari bedanya sebelum bertindak.',
    content:
        'Surat kuasa adalah pemberian wewenang dari satu pihak (pemberi kuasa) ke pihak lain (penerima '
        'kuasa) untuk melakukan tindakan hukum atas nama pemberi kuasa. Dasarnya KUHPerdata Pasal 1792 dan '
        'seterusnya.\n\n'
        'Ada tiga jenis. Surat Kuasa Umum (KUHPerdata Pasal 1796) memberi wewenang mengurus harta pemberi '
        'kuasa secara umum. Tapi hanya untuk tindakan mengelola, tidak untuk menjual, menggadaikan, atau '
        'melepaskan hak. Surat Kuasa Khusus juga di Pasal 1796, tapi memberi wewenang untuk tindakan '
        'tertentu yang disebutkan eksplisit. Wajib dipakai untuk menjual atau membeli tanah/rumah, '
        'menggadaikan atau menjaminkan harta, mewakili di pengadilan, mengambil uang dari bank dalam '
        'jumlah besar, dan mengajukan permohonan ke pemerintah (misalnya perpanjangan HGB). Surat Kuasa '
        'Insidentil untuk satu peristiwa tertentu, misalnya mengambil paket di kantor pos.\n\n'
        'Untuk berperkara di pengadilan, kalau Anda diwakili advokat, wajib pakai surat kuasa khusus yang '
        'menyebut nama perkara, nama lawan, nomor perkara kalau sudah ada, dan kewenangan yang '
        'dilimpahkan. Hanya advokat berlisensi PERADI yang bisa menerima kuasa (UU No. 18/2003 tentang '
        'Advokat). Tapi para pihak tetap boleh hadir sendiri di pengadilan, terutama untuk gugatan '
        'sederhana atau perceraian — dalam hal itu tidak perlu surat kuasa.\n\n'
        'Format minimal surat kuasa: identitas lengkap pemberi dan penerima, tujuan atau tindakan yang '
        'dikuasakan dijelaskan jelas dan terbatas, batas waktu kalau ada, tanda tangan pemberi kuasa di '
        'atas materai Rp 10.000, plus tanggal dan tempat dibuat.\n\n'
        'Wajib notaris atau tidak? Untuk surat kuasa biasa, tidak wajib. Wajib notaris untuk kuasa '
        'menjual tanah atau rumah (PPAT), kuasa membebani hak tanggungan, dan kuasa pada akta autentik '
        'tertentu.\n\n'
        'Pemberi kuasa boleh mencabut surat kuasa kapan saja (KUHPerdata Pasal 1813), kecuali ada perjanjian '
        'khusus. Cabut secara tertulis, kirim ke penerima kuasa dan pihak ketiga yang relevan supaya '
        'mereka tahu kuasa sudah tidak berlaku lagi.',
    sources: [
      'KUHPerdata, Pasal 1792–1819 tentang pemberian kuasa',
      'KUHPerdata, Pasal 1796 (kuasa umum vs khusus)',
      'KUHPerdata, Pasal 1813 (pencabutan kuasa)',
      'UU No. 18 Tahun 2003 tentang Advokat',
      'UU No. 13 Tahun 1985 jo. PP No. 24/2000 tentang Bea Materai',
    ],
  ),
];
