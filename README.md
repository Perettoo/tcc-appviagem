# tcc_appViagem

Aplicativo de viagens (TCC). Monorepo com cliente Flutter (`Front-end/`) e API Node/Express (`Back-end/`).

## Estrutura

```
tcc_appViagem/
├── Front-end/                  Flutter (cliente)
│   └── lib/
│       ├── domain/             Entidades, casos de uso, contratos de repositório
│       ├── data/               Implementações de repositório (in-memory hoje)
│       └── presentation/       Páginas e widgets
└── Back-end/                   Node + Express + Sequelize (API)
    └── src/
        ├── config/             Configuração de infraestrutura (Sequelize)
        └── presentation/       Rotas e controllers HTTP
```

A divisão segue Clean Architecture: `presentation` depende de `domain`; `data` implementa as
interfaces de `domain`; `domain` não conhece framework algum.

## Front-end (Flutter)

Pré-requisitos: Flutter SDK ≥ 3.11.

```
cd Front-end
flutter pub get
flutter run
```

## Back-end (Node)

Pré-requisitos: Node ≥ 18 e MySQL.

```
cd Back-end
cp .env.example .env        # ajuste credenciais do MySQL
npm install
npm run dev                 # ou: npm start
```

A API sobe em `http://localhost:${PORT}` (padrão 3000). Endpoint de saúde: `GET /health`.
