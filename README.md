# EvolutionCam

**EvolutionCam** é um aplicativo multiplataforma desenvolvido com Flutter e Supabase que permite capturar fotos de "antes" e "depois" de maneira alinhada, garantindo que a foto "depois" seja tirada na mesma posição que a foto "antes". Ideal para acompanhar transformações, evolução pessoal ou projetos ao longo do tempo.

## 🚀 Funcionalidades
- **Cadastro e Login**: Autenticação de usuários com Supabase Auth.
- **CRUD de Registros**: Criação, visualização, atualização e exclusão de registros organizados como pastas de fotos.
- **Sistema de Categorias**: Organização dos registros por categorias personalizáveis.
- **Captura de Fotos Alinhadas**: Use a foto anterior como referência para alinhar a câmera na nova captura.
- **Upload e Download de Arquivos**: Salve e recupere suas fotos no Supabase Storage (bucket privado, URLs assinados).
- **Notificações de Lembrete (opcional)**: Configure lembretes para capturar novas fotos ou revisar progresso.

## 🛠️ Tecnologias Utilizadas
- **Linguagem**: Dart  
- **Framework**: Flutter  
- **Back-end**: Supabase (Postgres com RLS, Auth, Storage)

## 📌 Estrutura Inicial do Projeto
1. **Tela de Login e Cadastro**: Autenticação usando Supabase.
2. **CRUD de Registros**: Permita criar pastas de "Antes e Depois" com fotos alinhadas.
3. **Upload e Armazenamento**: Upload de fotos no Supabase Storage.


--------------------------------------------------------------------------------------------------------------------------

## 📂 Estrutura do Repositório
EvolutionCam/ ├── lib/ │ ├── main.dart # Arquivo principal do Flutter │ ├── screens/ # Telas do aplicativo │ ├── models/ # Modelos de dados │ ├── services/ # Integração com o Supabase (auth e coleções) │ └── widgets/ # Componentes reutilizáveis ├── assets/ # Recursos estáticos (imagens, ícones) ├── pubspec.yaml # Arquivo de dependências do Flutter └── README.md # Informações do projeto


## 🎨 Design

- Material 3 gerado a partir do azul da marca (`#009EEB`), com o vermelho do logótipo como acento; tema claro e escuro em `lib/configs/theme.dart`.
- Tipografia Plus Jakarta Sans (`google_fonts`, descarregada em tempo de execução; com `assets` locais funciona offline).
- Componentes partilhados em `lib/components/` (`AppButton`, `AppTextField`, `EmptyState`, `confirmDialog`, `promptDialog`, `showAppSnack`). Os ecrãs usam sempre `colorScheme`, nunca cores fixas.
- A página de cada coleção tem dois modos: **Evolução** (apresentação das fotos selecionadas) e **Comparar** (primeira vs. última foto, arrastando a linha).
- Texto da interface em português do Brasil.

## 🧪 Testes

`flutter test` cobre o slideshow, o comparador antes/depois, a grelha de seleção e os diálogos.

## ⚙️ Configuração do Ambiente de Desenvolvimento
1. Instale o Flutter e configure o ambiente seguindo a [documentação oficial](https://docs.flutter.dev/get-started/install).
2. Configure o Supabase:
   - Crie um projeto e execute `supabase/migrations/0001_init.sql` no SQL Editor (tabelas, RLS, triggers e bucket `photos`).
   - Em Project Settings → API copie o URL e a *publishable key* (nunca a `secret`/`service_role`).
   - Pode passá-los na compilação: `flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_PUBLISHABLE_KEY=...`
     (os valores por omissão em `lib/configs/supabase_config.dart` apontam para o projeto `evolution-cam`).
   - Se quiser login imediato após o registo, desative *Confirm email* em Authentication → Sign In / Providers → Email.
3. Para compilar em Android use um **JDK 17** (Flutter 3.27 / Gradle 8.0 não aceitam o JDK 25 que vem com o Android Studio recente):
   `flutter config --jdk-dir "<caminho do jdk-17>"`.
4. Clone este repositório:
   ```bash
   git clone https://github.com/seu-usuario/EvolutionCam.git
   cd EvolutionCam
   flutter pub get
