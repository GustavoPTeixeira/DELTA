## 📌 Descrição das Alterações
Descreva de forma clara e objetiva o que foi implementado, corrigido ou refatorado nesta Pull Request.

---

## 🔗 Issue Relacionada
- Closes #
*(Exemplo: Closes #1)*

---

## 🧪 Guia de Homologação para o QA
Instruções detalhadas para quem for testar a aplicação.

### 1. Pré-requisitos e Ambiente:
- [ ] Obter as dependências: `flutter pub get`
- [ ] Rodar o projeto: `flutter run` (no dispositivo/emulador desejado)
- [ ] Ter uma conta de testes ou registrar uma nova conta

### 2. Passo a Passo do Teste:
1. Fazer login com o usuário de teste.
2. Navegar até a funcionalidade implementada.
3. Executar os casos de teste especificados na Issue vinculada.

### 3. Casos de Teste a Validar:
- [ ] Caminho Feliz
- [ ] Validações de Formulário / Entradas Inválidas
- [ ] Tratamento de Erros de Conexão ou Duplicidade
- [ ] Persistência de Dados no Firestore

---

## 📸 Evidências do QA (Anexar Prints / Vídeos / Logs)
> *Por favor, anexe capturas de tela ou gravações demonstrando os testes realizados (sucessos e validações).*

| Cenário Testado | Evidência | Status (Passou / Falhou) |
|---|---|---|
| CT01 - Exemplo | *(anexe o print aqui)* | ✅ Passou |

---

## ✅ Checklist do Desenvolvedor
- [ ] Código formatado (`dart format .`)
- [ ] Sem avisos ou erros na análise estática (`dart analyze`)
- [ ] Testes unitários/widget criados ou atualizados (se aplicável)
- [ ] Branch atualizada com a `main`

---

## 🛡️ Checklist de Homologação do QA
- [ ] Todos os critérios de aceite da Issue foram validados
- [ ] Nenhum comportamento inesperado ou regressão foi observado
- [ ] Evidências anexadas na tabela acima
- [ ] **Aprovado para Merge** 🚀
