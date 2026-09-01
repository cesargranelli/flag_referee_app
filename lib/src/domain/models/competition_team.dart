/// Inscrição de um time em uma competição.
///
/// Conforme ADR-006: Team é sub-entidade de Organization e a inscrição em
/// competições é feita via CompetitionTeam.
///
/// Shape de `GET /api/v1/competitions/{competitionId}/teams`.
class CompetitionTeam {
  final String id;
  final String competitionId;
  final String teamId;
  final String teamName;
  final String organizationId;
  final String organizationName;
  final String? divisionId;
  final DateTime? createdAt;

  const CompetitionTeam({
    required this.id,
    required this.competitionId,
    required this.teamId,
    required this.teamName,
    required this.organizationId,
    required this.organizationName,
    this.divisionId,
    this.createdAt,
  });

  factory CompetitionTeam.fromJson(Map<String, dynamic> json) => CompetitionTeam(
        id: json['id'] as String,
        competitionId: json['competitionId'] as String,
        teamId: json['teamId'] as String,
        teamName: json['teamName'] as String,
        organizationId: json['organizationId'] as String,
        organizationName: json['organizationName'] as String,
        divisionId: json['divisionId'] as String?,
        createdAt: json['createdAt'] is String
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
      );
}