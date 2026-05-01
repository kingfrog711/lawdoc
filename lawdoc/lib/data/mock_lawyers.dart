import '../models/lawyer.dart';

const List<Lawyer> mockLawyers = [
  Lawyer(
    id: 'wibowo',
    name: 'Sdr. Wibowo, S.H., M.H.',
    initials: 'WB',
    specialization: 'Spesialis Perceraian & Hukum Waris',
    areas: ['Perceraian', 'Waris'],
    yearsExp: 12,
    rating: 4.9,
    reviewCount: 312,
    casesCompleted: 284,
    isProBono: false,
    isVerifiedPeradi: true,
    priceLabel: 'Rp 75rb / 30 mnt',
    bio:
        'Pengacara senior dengan fokus pada gugatan perceraian, hak asuh anak, dan pembagian waris. '
        'Berpengalaman mendampingi klien dari beragam latar belakang ekonomi.',
    languages: ['Bahasa Indonesia', 'Bahasa Jawa', 'English'],
    practiceAreas: [
      'Perceraian & hak asuh',
      'Hukum waris',
      'Perjanjian pra-nikah',
    ],
  ),
  Lawyer(
    id: 'kartika',
    name: 'Sdri. Kartika, S.H.',
    initials: 'KR',
    specialization: 'Spesialis Utang Piutang',
    areas: ['Utang Piutang'],
    yearsExp: 8,
    rating: 4.8,
    reviewCount: 184,
    casesCompleted: 201,
    isProBono: true,
    isVerifiedPeradi: true,
    priceLabel: null,
    bio:
        'Pengacara LBH Jakarta dengan spesialisasi sengketa utang piutang dan perlindungan konsumen. '
        'Melayani klien berpenghasilan rendah secara gratis melalui jaringan LBH.',
    languages: ['Bahasa Indonesia', 'English'],
    practiceAreas: [
      'Utang piutang & kredit',
      'Perlindungan konsumen',
      'Sengketa perbankan',
    ],
    organization: 'LBH Jakarta',
  ),
  Lawyer(
    id: 'pranoto',
    name: 'Sdr. Hadi Pranoto, S.H.',
    initials: 'HP',
    specialization: 'Spesialis Sengketa Tanah',
    areas: ['Sengketa Tanah'],
    yearsExp: 15,
    rating: 4.9,
    reviewCount: 421,
    casesCompleted: 398,
    isProBono: false,
    isVerifiedPeradi: true,
    priceLabel: 'Rp 100rb / 30 mnt',
    bio:
        'Pakar hukum agraria dengan pengalaman luas dalam sengketa tanah, sertifikasi, dan gugatan '
        'ke Badan Pertanahan Nasional. Mantan hakim ad hoc Pengadilan Negeri.',
    languages: ['Bahasa Indonesia', 'Bahasa Sunda'],
    practiceAreas: [
      'Sengketa kepemilikan tanah',
      'Sertifikasi & BPN',
      'Gugatan tanah warisan',
    ],
  ),
  Lawyer(
    id: 'ratna',
    name: 'Sdri. Ratna A., S.H.',
    initials: 'RA',
    specialization: 'Spesialis Perceraian · KDRT',
    areas: ['Perceraian'],
    yearsExp: 6,
    rating: 4.7,
    reviewCount: 98,
    casesCompleted: 112,
    isProBono: true,
    isVerifiedPeradi: true,
    priceLabel: null,
    bio:
        'Pengacara muda spesialis hukum keluarga dan perlindungan korban KDRT. '
        'Berkolaborasi dengan Komnas Perempuan dan LBH APIK dalam kasus-kasus kekerasan dalam rumah tangga.',
    languages: ['Bahasa Indonesia'],
    practiceAreas: [
      'Gugatan perceraian',
      'Perlindungan korban KDRT',
      'Hak asuh & nafkah',
    ],
    organization: 'LBH APIK',
  ),
];
