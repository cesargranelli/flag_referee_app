/// Time de uma organização (clube/universidade).
///
/// Conforme ADR-006: Team é sub-entidade de Organization.
/// A inscrição em competições é feita via CompetitionTeam.
class Team {
  final String id;
  final String organizationId;
  final String name;
  final String? shortName;
  final String? sportName;
  final String? logoUrl;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Team({
    required this.id,
    required this.organizationId,
    required this.name,
    this.shortName,
    this.sportName,
    this.logoUrl,
    this.status = 'ACTIVE',
    this.createdAt,
    this.updatedAt,
  });

  factory Team.fromJson(Map<String, dynamic> json) => Team(
        id: json['id'] as String,
        organizationId: json['organizationId'] as String,
        name: json['name'] as String,
        shortName: json['shortName'] as String?,
        sportName: json['sportName'] as String?,
        logoUrl: json['logoUrl'] as String?,
        status: json['status'] as String? ?? 'ACTIVE',
        createdAt: json['createdAt'] is String
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
        updatedAt: json['updatedAt'] is String
            ? DateTime.tryParse(json['updatedAt'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'organizationId': organizationId,
        'name': name,
        if (shortName != null) 'shortName': shortName,
        if (sportName != null) 'sportName': sportName,
        if (logoUrl != null) 'logoUrl': logoUrl,
        'status': status,
      };
}
