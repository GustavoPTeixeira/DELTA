# 🔺 DELTA: Uma Plataforma para Despertar o Interesse de Crianças em Ciência

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![IFSUL](https://img.shields.io/badge/IFSUL-Sapucaia%20do%20Sul-green?style=for-the-badge)](http://www.sapucaia.ifsul.edu.br/)

> **Projeto de Trabalho de Conclusão de Curso (TCC)**  
> **Autor:** Gustavo Pfeifer Teixeira  
> **Orientadora:** Prof.ª Me. Veronica Pasqualin Machado  
> **Instituição:** Instituto Federal de Educação, Ciência e Tecnologia Sul-rio-grandense (IFSUL) — Campus Sapucaia do Sul  

---

## 📖 Sobre o Projeto

Com o avanço tecnológico e a inserção cada vez mais precoce de crianças e jovens no mundo digital, observa-se uma oportunidade única para o letramento digital, mas também um desafio: a redução do interesse pela leitura literária e científica convencional.

O **DELTA** é uma plataforma educacional e gamificada voltada a estudantes do **9º ano do Ensino Fundamental** (fase de transição crítica para o Ensino Médio segundo as diretrizes da **BNCC - Base Nacional Comum Curricular**). O objetivo primordial é unir recursos tecnológicos modernos, design amigável e gamificação para despertar o gosto pela leitura e disseminar o conhecimento científico de forma lúdica, dinâmica e acessível.

---

## 🎨 Identidade Visual e Simbolismo

* **O Nome "Delta" ($\Delta$):** Representa a diferença (*Diaforá* / $\Delta\iota\alpha\phi\omicron\rho\acute{\alpha}$ em grego) e simboliza o espaço que existe entre o início e o fim — a lacuna onde habitam a ciência, o aprendizado e a evolução humana.
* **O Prisma e as Cores:** Inspirado no histórico experimento óptico de **Isaac Newton (1672)**, onde um feixe de luz branca é refratado em um prisma revelando todo o espectro visível (*spectrum*). As cores e ilustrações representam a pluralidade do conhecimento e a curiosidade científica.
* **Design da Logo:** Desenvolvido originalmente pela aluna **Giovana Carvalho Bombardelli**.

---

## 📋 Requisitos Funcionais (Escopo do TCC)

A aplicação foi planejada e especificada conforme os seguintes requisitos essenciais:

* **[RF1] Cadastro de Usuário:** Registro simplificado de novos alunos com nome completo, nome de usuário único, e-mail e senha.
* **[RF2] Autenticação / Login:** Validação de credenciais e persistência segura de sessão do usuário.
* **[RF3] Perfil do Usuário:** Consulta e atualização cadastral dos dados do aluno.
* **[RF4] Modo Leitura:** Navegação por matérias e leitura dinâmica de textos de divulgação científica com layout otimizado para concentração (*SingleChildScrollView*).
* **[RF5] Modo Questionário:** Fixação pedagógica imediata ao final da leitura, com perguntas de múltipla escolha contextualizadas, feedback visual dinâmico (acerto/erro), explicações conceituais e cálculo de pontuação final.

---

## 🛠️ Tecnologias Utilizadas

A versão atual do projeto modernizou o ecossistema original para uma arquitetura multiplataforma de alta performance:

* **Framework:** [Flutter](https://flutter.dev) (SDK Dart 3+)
* **Linguagem:** [Dart](https://dart.dev)
* **Backend as a Service:** [Google Firebase](https://firebase.google.com)
  * **Firebase Authentication:** Gestão segura de identidades e sessões.
  * **Cloud Firestore:** Armazenamento NoSQL em tempo real para usuários, matérias e questionários.
* **Gerenciamento de Estado:** Abordagem reativa nativa com `StatefulWidget`, `setState()` e `StreamBuilder`.

---

## 📂 Estrutura de Pastas

```text
lib/
├── firebase_options.dart      # Configurações do Firebase multiplataforma
├── main.dart                  # Ponto de entrada e ouvinte de estado de autenticação
├── models/                    # Modelos de dados imutáveis
│   ├── question_model.dart    # Estrutura de perguntas e alternativas
│   └── user_model.dart        # Dados do aluno
├── screens/                   # Interfaces de usuário (telas)
│   ├── login_screen.dart      # Tela de login (RF2)
│   ├── register_screen.dart   # Tela de cadastro (RF1)
│   ├── subjects_screen.dart   # Listagem de matérias
│   ├── reading_screen.dart    # Leitura de textos científicos (RF4)
│   └── question_screen.dart   # Questionário interativo (RF5)
└── services/                  # Camada de comunicação externa e lógica de negócio
    └── auth_service.dart      # Serviços de autenticação e Firestore
```

---

## 🚀 Como Executar o Projeto

### Pré-requisitos:
1. [Flutter SDK](https://flutter.dev/docs/get-started/install) instalado e configurado no PATH.
2. Projeto configurado no [Firebase Console](https://console.firebase.google.com).

### Passos:
```bash
# 1. Clone o repositório
git clone https://github.com/GustavoPTeixeira/delta_app.git

# 2. Acesse a pasta do projeto Flutter
cd delta_app/flutter_application_1

# 3. Baixe as dependências do pubspec
flutter pub get

# 4. Execute a aplicação (ex: Windows ou Chrome)
flutter run -d windows
# ou
flutter run -d chrome
```

> ⚠️ Sem nenhuma flag, o app usa o projeto de **produção** (`delta-eae4d`). Para desenvolver e testar, prefira os emuladores abaixo.

### Rodando com os emuladores (desenvolvimento)
O [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite) roda o Auth e o Firestore no seu computador, com as mesmas regras de produção. Nenhuma conta de teste vai para produção. Requer Java 21+ e o Firebase CLI.

```bash
# Terminal 1: inicia o Auth (9099), o Firestore (8080) e a interface em http://localhost:4000
firebase emulators:start --project delta-eae4d

# Terminal 2: cria os usuários de teste (apaga os dados anteriores do emulador)
dart run tool/seed_emulator.dart

# Terminal 2: roda o app conectado aos emuladores
flutter run -d chrome --dart-define=USE_EMULATORS=true
```

No VS Code, dá para fazer o último passo em **Run and Debug → "DELTA (emulators)"** (F5).

| Usuário | E-mail | Perfil | Tela inicial |
|---|---|---|---|
| `aluno` | aluno@delta.test | Aluno | Matérias |
| `pendente` | pendente@delta.test | Professor aguardando aprovação | Aguardando aprovação |
| `professor` | professor@delta.test | Professor | Área do Professor |

A senha de todos é `delta123`. Os dados do emulador somem quando ele é encerrado (Ctrl+C); é só rodar o seed de novo.

### Testes
```bash
# Testes unitários e de widget (não acessam o Firebase real)
flutter test

# Testes das regras do Firestore no emulador (requer Java 21+ e Firebase CLI)
npm --prefix firestore_tests install   # só na primeira vez
npm --prefix firestore_tests test
```

---

## 👩‍🏫 Contas de professor

Quem escolhe **Professor** no cadastro recebe o perfil `teacher_pending` e vê a tela **"Aguardando aprovação"**. As regras do Firestore impedem que alguém se cadastre ou se promova como professor pelo app.

**Para aprovar um professor:**
1. Abra o [Firebase Console](https://console.firebase.google.com) → projeto `delta-eae4d` → **Firestore Database**.
2. Na coleção `users`, abra o documento do professor (o ID é o UID dele, visível em **Authentication**).
3. Altere o campo `role` de `teacher_pending` para `teacher` e salve.

O app do professor muda para a **Área do Professor** na hora, sem precisar sair e entrar de novo. Para recusar, mude o campo `role` para `student`.

---

## 🏆 Reconhecimentos e Premiações

O projeto Delta foi apresentado em feiras de iniciação científica e conquistou credenciamentos acadêmicos de destaque:

* 🥇 **4ª FEBIC (Feira Brasileira de Iniciação Científica):** Credenciamento internacional para a *CopaScience* (Guadalajara, México).
* 🎖️ **3º SaberTec (IFSUL Campus Sapucaia do Sul):** Apresentação e validação técnica do projeto.
* 🥉 **IFCITEC (Feira de Ciências e Inovação Tecnológica - IFRS Campus Canoas):** Premiado com o **3º lugar** na categoria Informática.

---

## 📜 Licença

Este projeto é desenvolvido para fins acadêmicos e educacionais no âmbito do Instituto Federal Sul-rio-grandense (IFSUL).
