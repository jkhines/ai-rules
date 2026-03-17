---
comando: /feature-branch
descrição: Cria um branch de funcionalidade seguindo as convenções de nomenclatura da equipe com rastreabilidade de tickets do Jira
alwaysApply: false
---

## Criação de branch de funcionalidade

Cria um novo branch seguindo as convenções de nomenclatura da equipe definidas nos Padrões de Desenvolvimento da Equipe.

### Convenção de nomenclatura de branches

```
<type>/<jira-id>-<short-description>
```

- `<type>` (Obrigatório): Um dos seguintes: `feature`, `fix`, `chore`, `refactor`, `docs`, `test`, `ci`, `build`, `hotfix`.
  Use `feature` para novos recursos (não `feat`).
- `<jira-id>` (Obrigatório): O ID do ticket do Jira (por exemplo, `PROJ-451`). Deve ser incluído para rastreabilidade.
  Unido à descrição por um hífen, não por um separador de caminho.
- `<short-description>` (Obrigatório): Resumo curto em inglês — letras minúsculas, palavras separadas por hífens,
  sem acentos ou caracteres especiais (apenas `a-z`, `0-9` e `-`). Breve e claro.

### Exemplos

```
feature/PROJ-451-implement-social-login
fix/APP-112-fix-shopping-cart-bug
refactor/PROJ-501-simplify-notification-service
```

## Etapas de execução

Quando `/feature-branch` é invocado:

1. **Verificar se há um ticket do Jira**
   - Se o usuário não forneceu um número de ticket do Jira (por exemplo, `PROJ-123`), solicite-o e interrompa o processo. Não
     prossiga até que um número de ticket seja fornecido.
   - Verifique se o formato corresponde ao padrão de um ticket do Jira: uma ou mais letras maiúsculas, um hífen, seguido de um ou
     mais dígitos (por exemplo, `PROJ-123`, `APP-42`).

2. **Buscar o resumo do ticket no Jira**
   - Use a API do Jira para buscar o resumo do ticket. Use `JIRA_BASE_URL`, `JIRA_EMAIL` e `JIRA_API_TOKEN`
     do ambiente para autenticação (HTTP Basic Auth).
   - Endpoint: `GET {JIRA_BASE_URL}/rest/api/3/issue/{jira-id}?fields=summary,issuetype`
   - Extraia o resumo e o tipo de issue para definir o tipo de branch e a descrição.

3. **Determinar o tipo de branch**
   - Mapeie o tipo de issue do Jira para um tipo de branch:
     - Bug -&gt; `fix`
     - Story, Task ou tipos semelhantes a feature -&gt; `feature`
     - Sub-tarefa -&gt; deduzir a partir do pai ou usar `feature` como padrão
     - Outros -&gt; `chore`
   - Se o mapeamento for ambíguo, pergunte ao usuário qual tipo usar.

4. **Gerar nome do branch**
   - Converta o resumo do ticket em uma descrição curta no formato kebab-case:
     - Apenas letras minúsculas.
     - Substitua espaços e caracteres especiais por hífens.
     - Remova acentos e caracteres não ASCII.
     - Remova hífens iniciais, finais e consecutivos.
     - Mantenha-o conciso (tente usar de 3 a 6 palavras).
   - Montagem: `<type>/<jira-id>-<short-description>`
   - **Não solicite confirmação.** Prossiga imediatamente para a criação do branch.

5. **Determinar o branch base**
   - O branch base é `main`.
   - Busque a versão mais recente de `main` antes de criar o novo branch.

6. **Criar e alternar para o branch**
   - Execute `git fetch origin`
   - Execute `git checkout -b <branch-name> --no-track origin/<base-branch>`
   - Execute `git push -u origin <branch-name>` para definir o branch de rastreamento upstream.
   - Confirme se o branch foi criado e está ativo.

7. **Resumo**
   - Exiba o nome do novo branch, o branch base e o link do ticket do Jira.
