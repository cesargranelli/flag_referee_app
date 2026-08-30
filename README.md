# Flag Referee App

Referee App do Flag Platform — operação de partidas pela mesa (placar e validação de atletas).

## Estrutura

```
├── lib/                    # Código do app
├── android/                # Projeto Android
├── ios/                    # Projeto iOS
├── packages/
│   ├── api/                # Cliente HTTP (dio) e serviços da API
│   ├── core/               # Widgets Kickster, tema, utilitários
│   └── domain/             # Models, enums, exceptions
├── pubspec.yaml            # Workspace root
└── .github/workflows/      # CI/CD
```

## Setup

```bash
# Bootstrap (instala dependências de todos os packages)
dart pub global activate melos
melos bootstrap

# Analyze
melos analyze

# Run
flutter run
```

## CI

Flutter 3.41.6 pinado no GitHub Actions. Roda `melos analyze` em PRs e pushes para `main`/`develop`.
