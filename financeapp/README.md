# 💰 FinanceApp — Controle Financeiro

Aplicativo Flutter completo de controle financeiro pessoal.

---

## 🏗️ Arquitetura

```
lib/
├── core/
│   ├── di/          # Injeção de Dependência (GetIt + Injectable)
│   └── theme/       # Material Design 3 (light + dark theme)
├── data/
│   ├── datasources/
│   │   ├── local/   # Floor (SQLite) - persistência local
│   │   └── remote/  # Firebase Auth + Firestore + API de Notícias
│   ├── models/      # DTOs (TransactionModel, UserModel, NewsArticle)
│   └── repositories/ # Implementações dos repositórios
├── domain/
│   ├── entities/    # Entidades de negócio (TransactionEntity, UserEntity)
│   ├── repositories/ # Interfaces (contratos)
│   └── usecases/
└── presentation/
    ├── screens/     # Telas (Login, Cadastro, Dashboard)
    ├── viewmodels/  # Riverpod providers + StateNotifiers
    └── widgets/     # Widgets reutilizáveis + Skeleton screens
```

**Padrão:** MVVM + Clean Architecture  
**State Management:** Riverpod  
**DI:** GetIt + Injectable  
**Local DB:** Floor (SQLite)  
**Remote:** Firebase Auth + Firestore  
**API Externa:** GNews (notícias financeiras em pt-BR)

---

## 🚀 Setup no GitHub Codespaces

### 1. Criar repositório e abrir no Codespaces
```bash
# No GitHub, crie um novo repositório e cole todos os arquivos
# Depois clique em "Code" > "Codespaces" > "Create codespace on main"
```

### 2. Instalar Flutter no Codespace
```bash
# Instalar Flutter via snap
sudo snap install flutter --classic

# Verificar instalação
flutter --version
flutter doctor
```

### 3. Configurar Firebase
```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Login
firebase login --no-localhost

# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurar Firebase no projeto (cria google-services.json e firebase_options.dart)
flutterfire configure
```

> ⚠️ Você precisa ter um projeto no [Firebase Console](https://console.firebase.google.com):
> - Ativar **Authentication** (Email/Senha)
> - Criar banco **Firestore** no modo teste
> - Adicionar app Android com package `com.example.finance_app`

### 4. Configurar API de Notícias (opcional)
Edite `lib/data/datasources/remote/news_datasource.dart` e substitua:
```dart
static const _apiKey = 'YOUR_GNEWS_API_KEY';
```
Pelo seu token em [gnews.io](https://gnews.io) (plano gratuito disponível).  
> **Sem a chave, o app usa notícias mock automaticamente.**

### 5. Instalar dependências e rodar
```bash
flutter pub get
flutter run -d web-server --web-port 8080
```

---

## 💻 Rodar Localmente (após Codespaces)

```bash
# Clonar o repositório
git clone https://github.com/SEU_USUARIO/SEU_REPO.git
cd SEU_REPO

# Instalar dependências
flutter pub get

# Rodar no Android (com emulador ou dispositivo conectado)
flutter run

# Rodar no iOS (apenas Mac)
flutter run -d ios

# Rodar na web
flutter run -d chrome
```

---

## 📦 Gerar APK (para entrega)

```bash
# APK de release
flutter build apk --release

# O arquivo estará em:
# build/app/outputs/flutter-apk/app-release.apk
```

---

## ✅ Checklist de Funcionalidades

### Parte 1 — Obrigatório (6 pts)
- [x] Tela de Login com validação (GlobalKey<FormState> + TextFormField)
- [x] Tela de Cadastro com navegação a partir do Login
- [x] Dashboard com saldo calculado automaticamente
- [x] CRUD de transações (adicionar, listar, editar, excluir)
- [x] Tipo (Receita/Despesa), Título, Valor, Data em cada transação
- [x] Filtro por tipo (Todas / Receitas / Despesas)
- [x] Operações via BottomSheet (sem mudar de rota)
- [x] SQLite (Floor) para persistência local
- [x] Provider/Riverpod para gerenciamento de estado reativo
- [x] 3 telas funcionando com navegação
- [x] Padrão MVVM
- [x] Material Design 3

### Parte 2 — Extra (até 16 pts)
- [x] Riverpod (StateNotifier + StreamProvider + Provider.family)
- [x] BLoC-like architecture com Riverpod
- [x] Injeção de Dependência com GetIt + Injectable
- [x] Firebase Auth (login/cadastro/logout real)
- [x] Firestore (transações na nuvem + sync offline)
- [x] Floor/SQLite robusto como fallback offline
- [x] API externa real (GNews — notícias financeiras em pt-BR)
- [x] Skeleton Screens (shimmer) durante carregamento
- [x] Animações de transição (flutter_animate)
- [x] Swipe to delete com confirmação
- [x] Gráfico de pizza (fl_chart) no dashboard
- [x] Tratamento de erros de rede
- [x] Dark mode / Light mode
- [x] APK gerado

---

## 🔗 Dependências Principais

| Pacote | Versão | Uso |
|--------|--------|-----|
| flutter_riverpod | ^2.5.1 | State Management |
| firebase_auth | ^4.20.0 | Autenticação |
| cloud_firestore | ^4.17.5 | Banco remoto |
| floor | ^1.4.0 | SQLite local |
| flutter_animate | ^4.5.0 | Animações |
| shimmer | ^3.0.0 | Skeleton screens |
| fl_chart | ^0.68.0 | Gráficos |
| google_fonts | ^6.2.1 | Tipografia |
| get_it + injectable | ^7.7.0 | Injeção de dependência |
| dio | ^5.4.3 | HTTP client |
