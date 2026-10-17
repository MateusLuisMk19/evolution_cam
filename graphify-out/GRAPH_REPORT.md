# Graph Report - evolution_cam  (2026-10-17)

## Corpus Check
- 139 files · ~56,403 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 57 file(s) not represented in the graph (top: (none) 10, .xcconfig 8, .xml 7)

## Summary
- 835 nodes · 1090 edges · 49 communities (37 shown, 12 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 17 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Alinhamento e Nivel
- Ecra da Camera
- Tema e Design System
- Comparador e Galeria
- Definicoes da Camera
- Plugins macOS
- Widgets Base da App
- Skill Android (gerador)
- Ecra da Colecao
- Plugins Linux
- Botoes da Camera
- Ecra Inicial
- Runner Windows
- Dialogos e Feedback
- Ecra de Perfil
- Servico de Colecoes
- Formulario de Colecao
- Componentes Visuais
- Servico de Autenticacao
- Janela Win32
- Runner Windows (app)
- Registo
- Login
- Arranque da App
- Adicionar Foto
- Visualizador de Foto
- Modo Cortina e Slider
- Manifest Web
- Janela Win32 (nucleo)
- Layout de Autenticacao
- Tipos Win32
- Config npm
- Registo de Plugins Windows
- Menu Lateral
- Nivel e Grelha
- Teste da Galeria
- Formatacao
- Teste de Dialogos
- Ponto
- Tamanho
- MainActivity
- Recortes

## God Nodes (most connected - your core abstractions)
1. `Win32Window` - 21 edges
2. `generate_feature_module()` - 14 edges
3. `FlutterWindow` - 10 edges
4. `to_pascal_case()` - 9 edges
5. `WindowClassRegistrar` - 7 edges
6. `to_camel_case()` - 6 edges
7. `_MyApplication` - 6 edges
8. `generate_screen()` - 5 edges
9. `generate_navigation()` - 5 edges
10. `wWinMain()` - 5 edges

## Surprising Connections (you probably didn't know these)
- `wWinMain()` --calls--> `CreateAndAttachConsole()`  [INFERRED]
  windows/runner/main.cpp → windows/runner/utils.cpp
- `my_application_activate()` --calls--> `fl_register_plugins()`  [INFERRED]
  linux/runner/my_application.cc → linux/flutter/generated_plugin_registrant.cc
- `main()` --calls--> `my_application_new()`  [INFERRED]
  linux/runner/main.cc → linux/runner/my_application.cc
- `FlutterWindow` --inherits--> `Win32Window`  [EXTRACTED]
  windows/runner/flutter_window.h → windows/runner/win32_window.h
- `wWinMain()` --calls--> `GetCommandLineArguments()`  [INFERRED]
  windows/runner/main.cpp → windows/runner/utils.cpp

## Import Cycles
- None detected.

## Communities (49 total, 12 thin omitted)

### Community 0 - "Alinhamento e Nivel"
Cohesion: 0.03
Nodes (54): aligned, available, blur, build, buildEdgeImage, bytes, client, codec (+46 more)

### Community 1 - "Ecra da Camera"
Cohesion: 0.04
Nodes (42): _baseZoom, build, _cameraError, _cameras, _capturePhoto, collectionId, _controller, createState (+34 more)

### Community 2 - "Tema e Design System"
Cohesion: 0.05
Nodes (29): accent, AppColors, AppRadius, AppSpacing, base, brand, brandDeep, brightness (+21 more)

### Community 3 - "Comparador e Galeria"
Cohesion: 0.05
Nodes (36): after, before, build, child, createState, _currentPage, didChangeDependencies, didUpdateWidget (+28 more)

### Community 4 - "Definicoes da Camera"
Cohesion: 0.05
Nodes (27): RefMode, AppController, changeTheme, instance, isDarkTheme, _angles, _arrows, CameraSettings (+19 more)

### Community 5 - "Plugins macOS"
Cohesion: 0.06
Nodes (17): app_links, Cocoa, file_selector_macos, Flutter, FlutterMacOS, Foundation, AppDelegate, RunnerTests (+9 more)

### Community 6 - "Widgets Base da App"
Cohesion: 0.06
Nodes (28): action, AppButtonVariant, AppTextField, _AppTextFieldState, autofocus, build, controller, createState (+20 more)

### Community 7 - "Skill Android (gerador)"
Cohesion: 0.12
Nodes (13): create_directory(), generate_api_build_gradle(), generate_api_navigation(), generate_feature_module(), generate_impl_build_gradle(), generate_navigation(), generate_screen(), generate_ui_state() (+5 more)

### Community 8 - "Ecra da Colecao"
Cohesion: 0.07
Nodes (23): CapturedPhoto, _addFromCamera, _addFromGallery, build, collection, collectionId, createState, _deleteImage (+15 more)

### Community 9 - "Plugins Linux"
Cohesion: 0.08
Nodes (13): fl_register_plugins(), main(), my_application_activate(), my_application_class_init(), my_application_dispose(), my_application_init(), my_application_local_command_line(), my_application_new() (+5 more)

### Community 10 - "Botoes da Camera"
Cohesion: 0.07
Nodes (23): active, activeColor, badge, build, busy, _camActive, _controller, createState (+15 more)

### Community 11 - "Ecra Inicial"
Cohesion: 0.07
Nodes (23): build, _category, collection, _collections, createState, _delete, dispose, _fetch (+15 more)

### Community 12 - "Runner Windows"
Cohesion: 0.12
Nodes (4): wWinMain(), CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16()

### Community 13 - "Dialogos e Feedback"
Cohesion: 0.09
Nodes (18): build, confirmDialog, confirmLabel, _controller, createState, destructive, dispose, false (+10 more)

### Community 14 - "Ecra de Perfil"
Cohesion: 0.09
Nodes (21): _addCategory, build, _categories, _collections, createState, _deleteCategory, _editName, _exists (+13 more)

### Community 15 - "Servico de Colecoes"
Cohesion: 0.09
Nodes (20): addImage, categories, _client, CollectionService, count, countImages, create, delete (+12 more)

### Community 16 - "Formulario de Colecao"
Cohesion: 0.11
Nodes (18): _addCategory, build, _categories, _category, collectionId, createState, dispose, _error (+10 more)

### Community 17 - "Componentes Visuais"
Cohesion: 0.11
Nodes (18): _DirectionArrow, EdgeOverlay, LevelOverlay, AppButton, EmptyState, UserAvatar, CamButton, CameraActionBar (+10 more)

### Community 18 - "Servico de Autenticacao"
Cohesion: 0.11
Nodes (14): AuthService, _client, currentUser, email, errorMessage, instance, isLoggedIn, lower (+6 more)

### Community 19 - "Janela Win32"
Cohesion: 0.18
Nodes (5): Scale(), Win32Window::Win32Window(), WindowClassRegistrar, class_registered_, instance_

### Community 20 - "Runner Windows (app)"
Cohesion: 0.12
Nodes (4): FlutterWindow, flutter_controller_, FlutterWindow::FlutterWindow(), project_

### Community 21 - "Registo"
Cohesion: 0.13
Nodes (15): build, createState, dispose, _emailController, _isLoading, _message, _messageIsError, _nameController (+7 more)

### Community 22 - "Login"
Cohesion: 0.15
Nodes (10): build, createState, dispose, _emailController, _isLoading, _login, LoginScreen, _LoginScreenState (+2 more)

### Community 23 - "Arranque da App"
Cohesion: 0.14
Nodes (4): build, initialize, main, MyApp

### Community 24 - "Adicionar Foto"
Cohesion: 0.15
Nodes (9): build, collectionId, createState, didChangeDependencies, image, _started, _upload, _uploading (+1 more)

### Community 25 - "Visualizador de Foto"
Cohesion: 0.17
Nodes (10): build, _controller, createState, didChangeDependencies, dispose, _doubleTapPosition, _handleDoubleTap, imageUrl (+2 more)

### Community 26 - "Modo Cortina e Slider"
Cohesion: 0.23
Nodes (10): SplitReference, _SplitReferenceState, BeforeAfterSlider, _BeforeAfterSliderState, ShowChangesSlide, _ShowChangesSlideState, AddImageScreen, _AddImageScreenState (+2 more)

### Community 27 - "Manifest Web"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 28 - "Janela Win32 (nucleo)"
Cohesion: 0.24
Nodes (4): Win32Window, child_content_, quit_on_close_, window_handle_

### Community 29 - "Layout de Autenticacao"
Cohesion: 0.20
Nodes (8): AuthBanner, AuthShell, build, children, isError, message, subtitle, title

### Community 31 - "Config npm"
Cohesion: 0.22
Nodes (8): path, config, commitizen, devDependencies, commitizen, cz-conventional-changelog, commitizen, cz-conventional-changelog

### Community 33 - "Menu Lateral"
Cohesion: 0.25
Nodes (5): build, _go, _logOut, MyDrawer, page

### Community 34 - "Nivel e Grelha"
Cohesion: 0.29
Nodes (4): _LevelPainter, GridPainter, paint, shouldRepaint

### Community 35 - "Teste da Galeria"
Cohesion: 0.29
Nodes (4): host, images, _img, main

### Community 36 - "Formatacao"
Cohesion: 0.40
Nodes (4): formatDate, formatDateTime, photoCount, _two

### Community 38 - "Ponto"
Cohesion: 0.50
Nodes (3): Point, x, y

### Community 39 - "Tamanho"
Cohesion: 0.50
Nodes (3): Size, height, width

## Knowledge Gaps
- **436 isolated node(s):** `title`, `subtitle`, `children`, `message`, `isError` (+431 more)
  These have ≤1 connection - possible missing edges. (Counts symbols only; 568 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **12 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `CameraSettings` connect `Definicoes da Camera` to `Botoes da Camera`?**
  _High betweenness centrality (0.004) - this node is a cross-community bridge._
- **What connects `title`, `subtitle`, `children` to the rest of the system?**
  _436 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Alinhamento e Nivel` be split into smaller, more focused modules?**
  _Cohesion score 0.03389830508474576 - nodes in this community are weakly interconnected._
- **Why does `Win32Window` connect `Janela Win32 (nucleo)` to `Ponto`, `Tamanho`, `Runner Windows`, `Janela Win32`, `Runner Windows (app)`, `Tipos Win32`?**
  _High betweenness centrality (0.004) - this node is a cross-community bridge._
- **Should `Ecra da Camera` be split into smaller, more focused modules?**
  _Cohesion score 0.0392156862745098 - nodes in this community are weakly interconnected._
- **Why does `RefMode` connect `Definicoes da Camera` to `Botoes da Camera`?**
  _High betweenness centrality (0.003) - this node is a cross-community bridge._
- **Should `Tema e Design System` be split into smaller, more focused modules?**
  _Cohesion score 0.04878048780487805 - nodes in this community are weakly interconnected._