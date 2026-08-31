import 'package:flag_referee_app/src/domain/flag_domain.dart';

import '../api_client.dart';

/// Serviço REST de elencos (roster) de times.
class RosterApi {
  final ApiClient _client;

  RosterApi(this._client);

  Future<List<RosterEntry>> listByTeam(
    String teamId, {
    String? competitionId,
  }) {
    final queryParams = competitionId != null ? '?competitionId=$competitionId' : '';
    return _client.getList(
      '/api/v1/teams/$teamId/roster$queryParams',
      RosterEntry.fromJson,
    );
  }

  Future<void> add({
    required String teamId,
    required String athleteId,
    String? competitionId,
    String? nickname,
    int? number,
  }) =>
      _client.post(
        '/api/v1/teams/$teamId/roster',
        {
          'athleteId': athleteId,
          if (competitionId != null) 'competitionId': competitionId,
          'nickname': ?nickname,
          'number': ?number,
        },
        (json) => json,
      );

  Future<void> remove({
    required String teamId,
    required String athleteId,
  }) =>
      _client.delete('/api/v1/teams/$teamId/roster/$athleteId');

  /// Importa uma carga em lote de atletas no time (idempotente).
  Future<RosterBatchResult> createBatch(
    String teamId,
    List<Map<String, dynamic>> athletes,
  ) =>
      _client.post(
        '/api/v1/teams/$teamId/roster/batch',
        {'athletes': athletes},
        RosterBatchResult.fromJson,
      );
}
