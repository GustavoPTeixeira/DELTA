# 🛡️ Guia do Fluxo de QA & Testes — Projeto DELTA

Bem-vindo(a) à área de **Quality Assurance (QA)** do projeto **DELTA**!  
Este guia foi preparado para orientar o fluxo de trabalho de testes e homologação das novas funcionalidades da aplicação.

---

## 🧭 O Ciclo de Desenvolvimento e QA

No DELTA, seguimos o fluxo padrão de engenharia de software:

```text
[1. Issue no GitHub] 
       │ (Regras de negócio e casos de teste mapeados)
       ▼
[2. Branch de Feature] 
       │ (Desenvolvimento do código e testes automatizados)
       ▼
[3. Abertura do Pull Request (PR)] 
       │ (Notificação com a label "qa:ready-for-test")
       ▼
[4. Homologação pelo QA] 
       │ ├── Execução dos Casos de Teste (Caminho Feliz, Borda, Erros)
       │ └── Coleta de Evidências (Prints, Gravações)
       ▼
   ┌───┴────────────────────────┐
   │                            │
[Se Aprovado]            [Se Houver Bugs]
   │                            │
   ▼                            ▼
Aprova o PR             Reporta os bugs no PR ou Issue
(Label: qa:approved)    (Label: qa:changes-requested)
   │                            │
   ▼                            ▼
Merge na main           Correção pelo Desenvolvedor
(Issue fechada)         e novo ciclo de teste
```

---

## 💻 1. Como Preparar o Ambiente para Testar

Para testar uma nova branch localmente em sua máquina:

1. **Atualize o repositório local:**
   ```bash
   git fetch origin
   ```

2. **Mude para a branch da funcionalidade:**
   ```bash
   # Exemplo: testar a branch do RF3
   git checkout feat/rf3-perfil-usuario
   git pull origin feat/rf3-perfil-usuario
   ```

3. **Instale as dependências do Flutter:**
   ```bash
   flutter pub get
   ```

4. **Execute o aplicativo:**
   ```bash
   # Para rodar no Windows Desktop:
   flutter run -d windows

   # Ou no navegador Google Chrome:
   flutter run -d chrome

   # Ou em um emulador/dispositivo Android conectado:
   flutter run
   ```

---

## 🧪 2. Como Homologar um Pull Request (PR)

Ao receber a notificação de que um PR está pronto para teste (`qa:ready-for-test`):

1. **Abra a Issue vinculada:** Leia atentamente a seção **Histórias de Usuário & Critérios de Aceite (BDD)** e a **Matriz de Casos de Teste**.
2. **Execute cada caso de teste no aplicativo:**
   - **Caminho Feliz (Happy Path):** O fluxo principal funciona como esperado?
   - **Cenários Negativos:** O sistema impede ações inválidas com mensagens amigáveis? (ex: campos vazios, usuário duplicado).
   - **Consistência:** Os dados persistem se você fechar e reabrir o app?
   - **Usabilidade e Layout:** Há textos cortados, elementos sobrepostos ou botões sem resposta?
3. **Capture Evidências:** Tire prints ou faça gravações curtas dos testes realizados.

---

## 📝 3. Como Registrar a Homologação no Pull Request

No próprio Pull Request do GitHub:

1. Role até a caixa de comentários ou edite a seção **Checklist de Homologação do QA**.
2. Anexe os prints/evidências na tabela de testes.
3. Marque os checkboxes de verificação:
   - `[x] Todos os critérios de aceite da Issue foram validados`
   - `[x] Aprovado para Merge`
4. Na aba **Files Changed** (Arquivos alterados) ou **Review Changes**:
   - Se tudo estiver correto: selecione **Approve** e adicione a label `qa:approved`.
   - Se houver falhas: selecione **Request Changes**, descreva com clareza o que falhou, anexe os prints e aplique a label `qa:changes-requested`.

---

## 🐞 4. O que fazer ao Encontrar um Bug?

Se o erro for pontual da funcionalidade sendo testada, descreva-o como comentário no próprio **Pull Request**.

Se for um bug mais complexo ou em outra parte do sistema:
1. Vá até a aba **Issues** do repositório.
2. Clique em **New Issue** e escolha o template **🐛 Reporte de Bug (QA)**.
3. Preencha o passo a passo com clareza para que qualquer desenvolvedor consiga reproduzir e corrigir rapidamente.
