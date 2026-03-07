---
comando: /feature-branch
descrição: Cria um branch de recurso seguindo as convenções de nomenclatura da equipe com rastreabilidade de tickets Jira.
alwaysApply: false
---

## Criação de branch de recurso

Cria um novo branch seguindo as convenções de nomenclatura da equipe definidas nos Padrões de Desenvolvimento da Equipe.

### Convenção de nomenclatura de branch

```<type>/<jira-id>-<short-description>```

- `<type>` (obrigatório): Um dos seguintes: `feature`, `fix`, `chore`, `refactor`, `docs`, `test`, `ci`, `build`, `hotfix`.
  Use `feature` para novos recursos (não `feat`).
- `<jira-id>` (obrigatório): O ID do ticket Jira (por exemplo, `PROJ-451`). Deve ser incluído para rastreabilidade.
  Juntado à descrição com um hífen, não com um separador de caminho.
- `<short-description>` (obrigatório): breve resumo em inglês — letras minúsculas, palavras separadas por hífens,
  sem acentos ou caracteres especiais (apenas `a-z`, `0-9` e `-`). Breve e claro.

### Exemplos

```
feature/PROJ-451-implement-social-login
fix/APP-112-fix-shopping-cart-bug
refactor/PROJ-501-simplify-notification-service
```

## Etapas de execução

Quando `/feature-branch` é invocado:

1. **Verifique o ticket Jira**
   - Se o usuário não forneceu um número de ticket Jira (por exemplo, `PROJ-123`), solicite-o e pare. Não
     prossiga até que um número de ticket seja fornecido.
   - Valide se o formato corresponde a um padrão de ticket Jira: uma ou mais letras maiúsculas, um hífen e, em seguida, um ou
     mais dígitos (por exemplo, `PROJ-123`, `APP-42`).

2. **Busque o resumo do ticket no Jira**
   - Use a API do Jira para buscar o resumo do ticket. Use `JIRA_BASE_URL`, `JIRA_EMAIL` e `JIRA_API_TOKEN`
     do ambiente para autenticação (HTTP Basic Auth).
   - Endpoint: `GET {JIRA_BASE_URL}/rest/api/3/issue/{jira-id}?fields=summary,issuetype`
   - Extraia o resumo e o tipo de problema para informar o tipo de ramificação e a descrição.

3. **Determinar o tipo de ramificação**
   - Mapeie o tipo de problema do Jira para um tipo de ramificação:
     - Bug -&gt; `fix`
     - Tipos como história, tarefa ou recurso -&gt; `feature`
     - Subtarefa -&gt; inferir a partir do pai ou padrão para `feature`
     - Outros -&gt; `chore`
   - Se o mapeamento for ambíguo, pergunte ao usuário qual tipo usar.

4. **Gerar nome da ramificação**
- Converta o resumo do ticket em uma descrição curta em kebab-case:
- Apenas letras minúsculas.
- Substitua espaços e caracteres especiais por hífens.
- Remova acentos e caracteres não ASCII.
- Remova hífens iniciais/finais/consecutivos.
- Seja conciso (tente usar de 3 a 6 palavras).
   - Monte: `<type>/<jira-id>-<short-description>`
   - Apresente o nome da ramificação proposto ao usuário para confirmação.

5. **Determine a ramificação base**
   - A ramificação base é `main`.
   - Busque a versão mais recente de `main` antes de criar a nova ramificação.

6. **Crie e mude para a ramificação**
   - Execute `git fetch origin`
   - Execute `git checkout -b <branch-name> --no-track origin/<base-branch>`
   - Execute `git push -u origin <branch-name>` para definir o ramo de rastreamento upstream.
   - Confirme se o ramo foi criado e está ativo.

7. **Resumo**
   - Exiba o nome do novo ramo, o ramo base e o link do ticket Jira.
