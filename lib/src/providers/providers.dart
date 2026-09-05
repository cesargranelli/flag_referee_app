import 'package:flag_referee_app/src/api/flag_api.dart';
import 'package:flag_referee_app/src/auth/auth_controller.dart';
import 'package:flag_referee_app/src/auth/firebase_auth_service.dart';
import 'package:flag_referee_app/src/core/flag_core.dart';
import 'package:flag_referee_app/src/domain/flag_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';

/// Gerenciador de sessão do Referee App (persiste dados de sessão Firebase/JWT).
final sessionManagerProvider = Provider<SessionManager>(
  (ref) => SessionManager(),
);

/// Cliente HTTP da API REST com o Firebase ID Token injetado.
final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(),
);

/// Serviço de autenticação Firebase (issue #33).
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>(
  (ref) => FirebaseAuthService(),
);

/// Serviço de autenticação (API REST).
final authApiProvider = Provider<AuthApi>(
  (ref) => AuthApi(ref.watch(apiClientProvider)),
);

/// Controlador de autenticação (restaura a sessão ao iniciar).
final authControllerProvider = ChangeNotifierProvider<AuthController>((ref) {
  final controller = AuthController(
    session: ref.watch(sessionManagerProvider),
    api: ref.watch(authApiProvider),
    firebaseAuth: ref.watch(firebaseAuthServiceProvider),
  );
  controller.restore();
  return controller;
});

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.read(authControllerProvider);
  return AppRouter.build(auth);
});

final teamApiProvider = Provider<TeamApi>(
  (ref) => TeamApi(ref.watch(apiClientProvider)),
);

final rosterApiProvider = Provider<RosterApi>(
  (ref) => RosterApi(ref.watch(apiClientProvider)),
);

final competitionApiProvider = Provider<CompetitionApi>(
  (ref) => CompetitionApi(ref.watch(apiClientProvider)),
);

/// Contexto de seleção compartilhado entre as telas de operação e check-in
/// (padrão admin_web), para não re-selecionar a cascata a cada visita.
final selectedCompetitionProvider = StateProvider<String?>((ref) => null);
final selectedRoundProvider = StateProvider<String?>((ref) => null);
final selectedGameProvider = StateProvider<String?>((ref) => null);

final competitionsProvider = FutureProvider<List<Competition>>(
  (ref) => ref.watch(competitionApiProvider).listAll(),
);

final roundApiProvider = Provider<RoundApi>(
  (ref) => RoundApi(ref.watch(apiClientProvider)),
);

/// Rodadas de um campeonato (fluxo único, sem categorias).
final roundsProvider = FutureProvider.family<List<Round>, String>(
  (ref, competitionId) =>
      ref.watch(roundApiProvider).listByCompetition(competitionId),
);

final gameApiProvider = Provider<GameApi>(
  (ref) => GameApi(ref.watch(apiClientProvider)),
);

final gamesByRoundProvider = FutureProvider.family<List<Game>, String>(
  (ref, roundId) => ref.watch(gameApiProvider).listByRound(roundId),
);

/// Eventos de pontuação (timeline) de um jogo.
final gameScoreEventsProvider = FutureProvider.family<List<ScoreEvent>, String>(
  (ref, gameId) => ref.watch(gameApiProvider).listScoreEvents(gameId),
);

final checkInApiProvider = Provider<CheckInApi>(
  (ref) => CheckInApi(ref.watch(apiClientProvider)),
);

final checkinProvider = FutureProvider.family<List<CheckIn>, String>(
  (ref, gameId) => ref.watch(checkInApiProvider).getList(gameId),
);
