# Tchê Organiza

> ⚠️ **Aviso importante:** Este aplicativo não possui relação oficial com a UFRGS e é fornecido no estado em que se encontra (as is).

Um aplicativo móvel para estudantes da UFRGS consultarem seus tickets do RU (Restaurante Universitário) e verificarem o cardápio disponível.

## 📱 O que é

O **Tchê Organiza** é um aplicativo desenvolvido em Flutter que facilita o acesso a informações do Restaurante Universitário da UFRGS. Com ele, você pode:

- Consultar o saldo e quantidade de tickets do RU disponíveis
- Visualizar o cardápio do dia dos restaurantes universitários
- Acessar as informações de forma rápida e prática

O aplicativo utiliza suas credenciais do portal da UFRGS para autenticação. Suas credenciais ficam armazenadas apenas no seu dispositivo e não são enviadas para terceiros.

## ⚡ Funcionalidades

- **Visualização de Tickets**: Consulte a quantidade de tickets disponíveis para almoço e janta
- **Cardápio do RU**: Veja o cardápio completo dos restaurantes universitários
- **Autenticação Segura**: Login utilizando suas credenciais do portal UFRGS
- **Armazenamento Local**: Suas credenciais ficam salvas apenas no seu dispositivo
- **Modo Claro/Escuro**: Interface adaptável ao tema do sistema
- **Cache Inteligente**: Informações armazenadas localmente para acesso mais rápido

## 📥 Como instalar?

### Android

1. Acesse o Google Groups do aplicativo (link em breve)
2. Após entrar no grupo, acesse o link da Play Store
3. Instale o aplicativo normalmente

### iOS

1. Acesse o link do [TestFlight](https://testflight.apple.com/join/EmJCRjn4)
2. Instale o TestFlight caso ainda não tenha
3. Instale o aplicativo através do TestFlight

## 🛠️ Instruções para desenvolvedores

### Pré-requisitos

- Flutter SDK 3.9.2 ou superior
- Dart SDK
- Android Studio / Xcode (para desenvolvimento mobile)
- Git

### Como baixar e executar localmente

1. Clone o repositório:
```bash
git clone https://github.com/dsadriel/tche_organiza.git
cd tche_organiza
```

2. Instale as dependências:
```bash
flutter pub get
```

3. Execute o aplicativo:
```bash
# Para Android
flutter run

# Para iOS (apenas em macOS)
flutter run -d ios

# Para web
flutter run -d chrome
```


### Estrutura do Projeto

```
lib/
├── main.dart              # Ponto de entrada do aplicativo
├── models/                # Modelos de dados
├── pages/                 # Telas do aplicativo
│   ├── components/        # Componentes reutilizáveis
│   ├── consent_gate.dart  # Tela de termos e condições
│   ├── login.dart         # Tela de login
│   ├── main_page.dart     # Tela principal
│   └── ru_menu_page.dart  # Tela do cardápio
└── services/              # Serviços e APIs
    ├── credential_storage.dart
    └── ru_ticket.dart
```

### Dependências Principais

- `dio`: Cliente HTTP para requisições
- `shared_preferences`: Armazenamento local de dados
- `html`: Parser HTML para extração de dados
- `cookie_jar`: Gerenciamento de cookies para autenticação
- `intl`: Internacionalização e formatação

### Importante

- Este aplicativo **não possui relação oficial** com a Universidade Federal do Rio Grande do Sul (UFRGS)
- O aplicativo é fornecido **"como está" (as is)**, sem garantias de qualquer tipo
- As credenciais são armazenadas apenas localmente no dispositivo do usuário