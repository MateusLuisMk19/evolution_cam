# EvolutionCam

**EvolutionCam** é um aplicativo multiplataforma desenvolvido com Flutter e Firebase que permite capturar fotos de "antes" e "depois" de maneira alinhada, garantindo que a foto "depois" seja tirada na mesma posição que a foto "antes". Ideal para acompanhar transformações, evolução pessoal ou projetos ao longo do tempo.

## 🚀 Funcionalidades
- **Cadastro e Login**: Autenticação de usuários com Firebase.
- **CRUD de Registros**: Criação, visualização, atualização e exclusão de registros organizados como pastas de fotos.
- **Sistema de Categorias**: Organização dos registros por categorias personalizáveis.
- **Captura de Fotos Alinhadas**: Use a foto anterior como referência para alinhar a câmera na nova captura.
- **Upload e Download de Arquivos**: Salve e recupere suas fotos no Firebase Storage.
- **Notificações de Lembrete (opcional)**: Configure lembretes para capturar novas fotos ou revisar progresso.

## 🛠️ Tecnologias Utilizadas
- **Linguagem**: Dart  
- **Framework**: Flutter  
- **Back-end**: Firebase (Firestore, Authentication, Storage, Notifications)

## 📌 Estrutura Inicial do Projeto
1. **Tela de Login e Cadastro**: Autenticação usando Firebase.
2. **CRUD de Registros**: Permita criar pastas de "Antes e Depois" com fotos alinhadas.
3. **Upload e Armazenamento**: Implemente upload de fotos no Firebase Storage.


--------------------------------------------------------------------------------------------------------------------------

## 🌟 Objetivo Final
Criar um aplicativo funcional que será publicado nas plataformas digitais (Google Play Store e App Store).

## 📂 Estrutura do Repositório
EvolutionCam/ ├── lib/ │ ├── main.dart # Arquivo principal do Flutter │ ├── screens/ # Telas do aplicativo │ ├── models/ # Modelos de dados │ ├── services/ # Integração com Firebase e outros serviços │ └── widgets/ # Componentes reutilizáveis ├── assets/ # Recursos estáticos (imagens, ícones) ├── pubspec.yaml # Arquivo de dependências do Flutter └── README.md # Informações do projeto


## ⚙️ Configuração do Ambiente de Desenvolvimento
1. Instale o Flutter e configure o ambiente seguindo a [documentação oficial](https://docs.flutter.dev/get-started/install).
2. Configure o Firebase no projeto:
   - Adicione os arquivos de configuração (`google-services.json` e `GoogleService-Info.plist`).
   - Ative Authentication, Firestore e Storage no Firebase Console.
3. Clone este repositório:
   ```bash
   git clone https://github.com/seu-usuario/EvolutionCam.git
   cd EvolutionCam
   flutter pub get
