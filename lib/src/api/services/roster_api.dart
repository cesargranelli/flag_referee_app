import 'package:flag_referee_app/src/domain/flag_domain.dart';

import '../api_client.dart';

/// Serviço REST de elencos (roster) de times.
///
/// Conforme ADR-006, o roster é específico de uma competição e os endpoints
/// passam `competitionId` no path:
/// - `GET /api/v1/teams/{teamId}/competitions/{competitionId}/roster`
/// - `POST /api/v1/teams/{teamId}/competitions/{competitionId}/roster`
/// - `DELETE /api/v1/teams/{teamId}/competitions/{competitionId}/roster/{athleteId}`
/// - `POST /api/v1/teams/{teamId}/competitions/{competitionId}/roster/batch`
class RosterApi {
  final ApiClient _client;

  RosterApi(this._client);

  Future<List<RosterEntry>> listByTeam(
    String teamId,
    String competitionId,
  ) =>
      _client.getList(
        '/api/v1/teams/$teamId/competitions/$competitionId/roster',
        RosterEntry.fromJson,
      );

  Future<void> add({
    required String teamId,
    required String competitionId,
    required String athleteId,
    String? nickname,
    int? number,
  }) =>
      _client.post(
        '/api/v1/teams/$teamId/competitions/$competitionId/roster',
        {
          'athleteId': athleteId,
          'nickname': ?nickname,
          'number': ?number,
        },
        (json) => json,
      );

  Future<void> remove({
    required String teamId,
    required String competitionId,
    required String athleteId,
  }) =>
      _client.delete(
        '/api/v1/teams/$teamId/competitions/$competitionId/roster/$athleteId',
      );

  /// Importa uma carga em lote de atletas no time (idempotente).
  Future<RosterBatchResult> createBatch(
    String teamId,
    String competitionId,
    List<Map<String, dynamic>> athletes,
  ) =>
      _client.post(
        '/api/v1/teams/$teamId/competitions/$competitionId/roster/batch',
        {'athletes': athletes},
        RosterBatchResult.fromJson,
      );
}
