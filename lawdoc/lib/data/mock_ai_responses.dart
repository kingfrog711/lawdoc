import '../models/legal_response.dart';

// Keyword-matched mock responses that mirror exact Gemma 4 output schema.
// Used as fallback when backend is unavailable.
final List<_MockEntry> _entries = [
  _MockEntry(
    keywords: ['waris', 'warisan', 'ahli waris', 'tanah warisan', 'harta warisan'],
    response: LegalResponse(
      summary:
          'Iya, Anda berhak menggugat pembagian waris. Sebagai ahli waris sah, Anda memiliki '
          'hak atas bagian yang setara dari harta warisan.',
      legalBasis: LegalBasis(
        pasal: 'KUHPerdata Pasal 832',
        text:
            'Semua anak sah — baik laki-laki maupun perempuan — adalah ahli waris dan '
            'berhak atas bagian yang sama dari harta peninggalan orang tua.',
      ),
      steps: [
        'Kumpulkan akta kelahiran & surat kematian pewaris (orang tua/saudara)',
        'Coba mediasi keluarga atau RT/RW terlebih dahulu',
        'Jika mediasi gagal, ajukan gugatan waris ke Pengadilan Negeri setempat',
      ],
      disclaimer:
          'Jawaban ini bersifat informasi umum, bukan nasihat hukum resmi. '
          'Hubungi pengacara untuk pendampingan kasus spesifik Anda.',
    ),
  ),
  _MockEntry(
    keywords: ['cerai', 'perceraian', 'gugat cerai', 'suami', 'istri', 'nikah'],
    response: LegalResponse(
      summary:
          'Anda dapat mengajukan gugatan perceraian. Proses dapat dilakukan di Pengadilan '
          'Agama (pernikahan Islam) atau Pengadilan Negeri (non-Muslim).',
      legalBasis: LegalBasis(
        pasal: 'KUHPerdata Pasal 207–232a',
        text:
            'Perceraian hanya dapat terjadi atas dasar alasan yang sah: perzinaan, '
            'penelantaran, penghukuman pidana berat, atau perselisihan terus-menerus '
            'yang tidak dapat didamaikan.',
      ),
      steps: [
        'Siapkan: KTP, buku nikah asli, dan akta kelahiran anak (jika ada)',
        'Tulis surat gugatan yang mencantumkan alasan perceraian secara jelas',
        'Daftarkan gugatan ke Pengadilan Agama/Negeri di wilayah tempat tinggal Anda',
        'Ikuti proses mediasi wajib sebelum sidang pertama dimulai',
      ],
      disclaimer:
          'Jawaban ini bersifat informasi umum, bukan nasihat hukum resmi. '
          'Hubungi pengacara untuk pendampingan kasus spesifik Anda.',
    ),
  ),
  _MockEntry(
    keywords: ['utang', 'hutang', 'tagih', 'penagih', 'pinjaman', 'kredit'],
    response: LegalResponse(
      summary:
          'Penagih utang tidak boleh mengancam atau mempermalukan Anda. Ada aturan hukum '
          'yang melindungi hak Anda sebagai debitur.',
      legalBasis: LegalBasis(
        pasal: 'POJK No. 22/POJK.07/2020',
        text:
            'Penagihan utang dilarang menggunakan ancaman, kata-kata kasar, atau '
            'penagihan kepada pihak ketiga yang tidak bertanggung jawab atas utang. '
            'Jam penagihan dibatasi pukul 08.00–20.00 WIB.',
      ),
      steps: [
        'Dokumentasikan setiap penagihan yang melanggar (rekam atau screenshot)',
        'Kirim surat keberatan tertulis kepada kreditur/fintech',
        'Laporkan pelanggaran ke OJK melalui kontak 157 atau email konsumen@ojk.go.id',
        'Konsultasikan dengan LBH jika perlu pendampingan hukum lebih lanjut',
      ],
      disclaimer:
          'Jawaban ini bersifat informasi umum, bukan nasihat hukum resmi. '
          'Hubungi pengacara untuk pendampingan kasus spesifik Anda.',
    ),
  ),
  _MockEntry(
    keywords: ['tanah', 'sertifikat', 'lahan', 'kavling', 'bpn', 'agraria'],
    response: LegalResponse(
      summary:
          'Sengketa tanah dapat diselesaikan melalui mediasi di BPN atau gugatan ke '
          'Pengadilan Tata Usaha Negara / Pengadilan Negeri.',
      legalBasis: LegalBasis(
        pasal: 'UU Agraria No. 5 Tahun 1960 Pasal 19',
        text:
            'Untuk menjamin kepastian hukum, pemerintah mengadakan pendaftaran tanah di '
            'seluruh Indonesia. Sertifikat tanah merupakan tanda bukti hak yang berlaku '
            'sebagai alat pembuktian yang kuat.',
      ),
      steps: [
        'Kumpulkan semua bukti kepemilikan: sertifikat, girik, AJB, atau saksi',
        'Ajukan mediasi di kantor BPN (Badan Pertanahan Nasional) setempat — gratis',
        'Jika mediasi gagal, ajukan gugatan ke Pengadilan Negeri wilayah tanah berada',
      ],
      disclaimer:
          'Jawaban ini bersifat informasi umum, bukan nasihat hukum resmi. '
          'Hubungi pengacara untuk pendampingan kasus spesifik Anda.',
    ),
  ),
];

LegalResponse? getMockResponse(String query) {
  final lower = query.toLowerCase();
  for (final entry in _entries) {
    if (entry.keywords.any((k) => lower.contains(k))) {
      return entry.response;
    }
  }
  return null;
}

LegalResponse get defaultMockResponse => LegalResponse(
      summary:
          'Saya memahami situasi Anda. Berdasarkan informasi yang diberikan, ini mungkin '
          'termasuk dalam kategori hukum perdata yang dapat ditangani.',
      legalBasis: LegalBasis(
        pasal: 'KUHPerdata Pasal 1 – Ketentuan Umum',
        text:
            'Hukum perdata mengatur hubungan antar individu dalam masyarakat, termasuk '
            'hak dan kewajiban yang timbul dari peristiwa hukum sehari-hari.',
      ),
      steps: [
        'Kumpulkan semua dokumen yang relevan dengan kasus Anda',
        'Catat kronologi kejadian secara tertulis',
        'Konsultasikan lebih lanjut dengan pengacara atau LBH untuk analisis kasus spesifik',
      ],
      disclaimer:
          'Jawaban ini bersifat informasi umum, bukan nasihat hukum resmi. '
          'Hubungi pengacara untuk pendampingan kasus spesifik Anda.',
    );

class _MockEntry {
  final List<String> keywords;
  final LegalResponse response;
  const _MockEntry({required this.keywords, required this.response});
}
