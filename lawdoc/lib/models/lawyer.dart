class Lawyer {
  final String id;
  final String name;
  final String initials;
  final String specialization;
  final List<String> areas;
  final int yearsExp;
  final double rating;
  final int reviewCount;
  final int casesCompleted;
  final bool isProBono;
  final bool isVerifiedPeradi;
  final String? priceLabel;
  final String bio;
  final List<String> languages;
  final List<String> practiceAreas;
  final String? organization;

  const Lawyer({
    required this.id,
    required this.name,
    required this.initials,
    required this.specialization,
    required this.areas,
    required this.yearsExp,
    required this.rating,
    required this.reviewCount,
    required this.casesCompleted,
    required this.isProBono,
    required this.isVerifiedPeradi,
    this.priceLabel,
    required this.bio,
    required this.languages,
    required this.practiceAreas,
    this.organization,
  });
}
