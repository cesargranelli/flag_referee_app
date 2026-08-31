import 'package:flag_referee_app/src/domain/flag_domain.dart';

import '../api_client.dart';

/// Serviço REST de times.
///
/// Conforme ADR-006:
/// - Team é sub-entidade de Organization (não mais vinculado a Competition).
/// - Inscrição em competições é feita via CompetitionTeam.
class TeamApi {
  final ApiClient _client;

  TeamApi(this._client);

  /// Lista os times inscritos em uma competição (via competition_team).
  Future<List<Team>> listByCompetition(String competitionId) => _client.getList(
        '/api/v1/competitions/$competitionId/teams',
        Team.fromJson,
      );

  /// Detalhes de um time pelo ID.
  Future<Team> getById(String id) =>
      _client.getOne('/api/v1/teams/$id', Team.fromJson);

  /// Cria um time dentro de uma organização.
  Future<Team> create({
    required String organizationId,
    required String name,
    String? shortName,
    String? sportName,
    String? logoUrl,
    String status = 'ACTIVE',
  }) =>
      _client.post(
        '/api/v1/organizations/$organizationId/teams',
        {
          'name': name,
          if (shortName != null) 'shortName': shortName,
          if (sportName != null) 'sportName': sportName,
          if (logoUrl != null) 'logoUrl': logoUrl,
          'status': status,
        },
        Team.fromJson,
      );

  /// Atualiza um time existente.
  Future<Team> update(
    String id, {
    required String name,
    String? shortName,
    String? sportName,
    String? logoUrl,
    String status = 'ACTIVE',
  }) =>
      _client.put(
        '/api/v1/teams/$id',
        {
          'name': name,
          if (shortName != null) 'shortName': shortName,
          if (sportName != null) 'sportName': sportName,
          if (logoUrl != null) 'logoUrl': logoUrl,
          'status': status,
        },
        Team.fromJson,
      );

  /// Remove um time.
  Future<void> delete(String id) => _client.delete('/api/v1/teams/$id');

  /// Inscreve um time existente em uma competição.
  Future<void> enrollTeam({
    required String competitionId,
    required String teamId,
  }) =>
      _client.post(
        '/api/v1/competitions/$competitionId/teams/$teamId',
        {},
        (json) => json,
      );

  /// Remove a inscrição de um time em uma competição (desinscrever).
  Future<void> unenrollTeam({
    required String competitionId,
    required String teamId,
  }) =>
      _client.delete(
        '/api/v1/competitions/$competitionId/teams/$teamId',
      );
}
