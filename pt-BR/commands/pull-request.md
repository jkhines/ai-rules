---
comando: /pull-request
descrição: Cria uma solicitação pull seguindo os padrões da equipe com integração Jira.
alwaysApply: false
---

## Criação de solicitação pull

Cria uma solicitação pull seguindo os padrões da equipe definidos nos Padrões de Desenvolvimento da Equipe.

### Formato do título da solicitação pull

Para solicitações pull de desenvolvimento, use o formato Conventional Commits com o ID do ticket Jira na posição do escopo:

```<type>(<jira-id>): <description>```

Exemplo: `feat(PROJ-451): implementar login social`

Se nenhum ticket Jira estiver disponível, mas um escopo de módulo for apropriado:

```<type>(<scope>): <description>```

Exemplo: `feat(ci): refinar configurações de concorrência no fluxo de trabalho de publicação`

Mantenha o título conciso, mas não imponha um limite rígido de caracteres. Busque a brevidade; até ~100 caracteres são
aceitáveis quando a descrição assim o exigir.

### Modelo de descrição de PR

O `.github/pull_request_template.md` do repositório fornece a estrutura da descrição do PR. O GitHub preenche
esse modelo automaticamente ao criar um PR. O comando deve preencher as seções do modelo com conteúdo
derivado da análise de diferenças, em vez de substituir o modelo por um formato personalizado.

O modelo padrão em todos os repositórios da equipe é:

```markdown
### Atividade do Jira

[<jira-id>](<jira-browse-url>)

### O que foi feito?

<!-- Clearly and concisely describe the changes made in this Pull Request, focusing on the purpose of the change. -->

### Como testar?
<!-- Provide a clear step-by-step guide for the reviewer to validate your changes. Be specific. -->
### Resultado esperado:
<!-- Describe what the reviewer should see or what should happen at the end of the tests. -->
### Riscos e impactos
<!-- List any risks or impacts that this change may cause (e.g., in other parts of the system, performance, etc.). If none, write "None". -->
### Capturas de tela/GIFs (se aplicável)

### Lista de verificação do autor

[ ] Minha ramificação está atualizada com `<base-branch>`.
[ ] Adicionei testes que cobrem minhas alterações.
[ ] A documentação relevante foi atualizada.
```

Observação: a lista de verificação do autor deve fazer referência ao branch base real (por exemplo, `main`), não a um espaço reservado.

## Etapas de execução

Quando `/pull-request` é invocado:

1. **Verifique se há alterações não confirmadas**
   - Execute `git status` para verificar se há alterações preparadas ou não preparadas (incluindo arquivos não rastreados).
   - Se houver alterações não confirmadas, informe ao usuário: “Existem alterações não confirmadas neste ramo.
     Primeiro, confirme e envie suas alterações (por exemplo, `/commit-push`), depois execute novamente `/pull-request`.”
   - Interrompa a execução. Não continue até que a árvore de trabalho esteja limpa.

2. **Certifique-se de que o branch foi enviado**
   - Verifique se o branch atual tem um branch de rastreamento upstream: `git rev-parse --abbrev-ref --symbolic-full-name @{u}`
   - Se não existir nenhum upstream, envie o branch: `git push -u origin <current-branch>`
   - Se existir um upstream, verifique se há commits não enviados: `git log @{u}..HEAD --oneline`
   - Se houver commits não enviados, envie-os: `git push`

3. **Determine o branch base (destino da mesclagem)**

O Git não armazena metadados do branch pai, portanto, todos os métodos de detecção são heurísticos. A estratégia abaixo
organiza vários sinais, do mais confiável ao menos confiável, para chegar à resposta correta.

- **Etapa A — Dica do reflog (melhor esforço, pode não estar disponível):**
     - Execute: `git reflog show <current-branch> --format='%gs' | tail -1`
- Procure por padrões: `branch: Created from origin/<branch>` ou `branch: Created from <branch>`.
- Se `<branch>` for um nome de ramo (não um SHA bruto), registre-o como candidato a reflog.
     - O reflog expira (padrão de 90 dias) e o formato varia entre as versões do Git, portanto, trate isso apenas como uma
       **dica** — deve ser confirmado pela Etapa B.

   - **Etapa B — Comparação topológica da base de mesclagem (método principal):**
     - Obtenha o estado remoto mais recente: `git fetch origin`
     - Crie uma lista de candidatos de branches remotos, priorizados nesta ordem:
       1. O candidato a reflog da Etapa A (se houver).
       2. `main` (o branch de longa duração da equipe).
       3. Quaisquer outros branches remotos que não sejam o branch atual.
     - Para cada candidato, calcule a base de mesclagem:
       ```
       git merge-base origin/<candidate> HEAD
       ```
- Colete todos os commits de base de mesclagem exclusivos e, em seguida, determine qual deles é **topologicamente mais próximo** do HEAD:
       ```
       git rev-list --topo-order --max-count=1 <merge-base-1> <merge-base-2>...
       ```
       O commit retornado é o ancestral comum mais recente entre todos os candidatos. O branch candidato
       que produziu essa base de mesclagem é o branch base.
- **Desempate:** se vários candidatos compartilharem o mesmo commit da base de mesclagem, dê preferência nesta ordem:
       o candidato do reflog da Etapa A, depois `main` e, em seguida, outros branches em ordem alfabética.

   - **Etapa C — Validar com o log de commit:**
- Execute: `git log origin/<base>..HEAD --oneline`
- Verifique se os commits listados pertencem ao trabalho de recurso atual. Se commits não relacionados de outros
  ramos aparecerem, a base escolhida provavelmente está errada — reexamine os candidatos da Etapa B, excluindo a
  escolha atual, e repita.

   - **Etapa D — Lidar com ramos pai excluídos:**
     - Se o candidato do reflog da Etapa A não existir mais no remoto (`git ls-remote --heads origin <name>`
       retorna vazio), o ramo pai provavelmente foi mesclado e excluído.
     - Nesse caso, recorra ao vencedor da base de mesclagem da Etapa B entre os ramos remanescentes de longa duração
       (`main`).

   - **Confirmação final:** exiba o ramo base determinado para o usuário e peça confirmação antes de
     prosseguir. Exemplo: “Ramo base detectado: `main`. Está correto? (s/n)”
   - O ramo base confirmado é o destino da mesclagem do PR. Pode ser `main` ou outro ramo de recurso.

4. **Extrair ticket Jira do nome do ramo**
   - Analise o nome do ramo atual para um ID de ticket Jira que corresponda ao padrão `[A-Z]+-[0-9]+`.
   - Se encontrado, busque o resumo do ticket do Jira usando `JIRA_BASE_URL`, `JIRA_EMAIL` e `JIRA_API_TOKEN`
     (HTTP Basic Auth). Endpoint: `GET {JIRA_BASE_URL}/rest/api/3/issue/{jira-id}?fields=summary,issuetype`
   - Se nenhum ID de ticket for encontrado no nome do branch, solicite um ao usuário ou prossiga sem ele.

5. **Analise as alterações para o PR**
   - Calcule a diferença entre o branch atual e o branch base determinado na etapa 3:
     `git diff <base-branch>...HEAD`
   - Revise o log de commit completo desde a divergência: `git log <base-branch>..HEAD --oneline`
   - Entenda o escopo completo das alterações — todos os commits, não apenas o mais recente.

6. **Gerar título do PR**
   - Siga o formato: `<type>(<jira-id>): <description>`
   - O `<type>` deve corresponder ao prefixo do tipo de ramificação, mapeado para os tipos de commit convencionais:
     `feature/` -&gt; `feat`, `fix/` -&gt; `fix`, `hotfix/` -&gt; `fix`, `chore/` -&gt; `chore`, etc.
   - Coloque o ID do ticket Jira na posição do escopo (parênteses).
   - Se nenhum ticket Jira estiver disponível, use um escopo de módulo ou omita o escopo completamente.
   - Mantenha o título conciso. Procure ser breve, mas até ~100 caracteres é aceitável.

7. **Crie o PR com o modelo padrão**
   - Verifique se o repositório tem um modelo de PR em `.github/pull_request_template.md`.
   - Se o modelo existir, crie o PR usando-o como corpo inicial:
 ```
     gh pr create --base <base-branch> --title "<title>" --body-file .github/pull_request_template.md
     ```
   - Se não houver modelo, crie o PR com um corpo vazio:
     ```
     gh pr create --base <base-branch> --title "<title>" --body ""
     ```
   - Registre o número do PR da saída.

8. **Gere a descrição completa do PR**
   - Escreva toda a descrição em inglês simples e direto. Use frases curtas, palavras comuns e
     voz ativa. Evite expressões idiomáticas, jargões, abreviações e referências culturais específicas para que falantes não nativos
     de inglês possam lê-la facilmente.
   - Se um modelo de PR foi usado na etapa 7, use seus títulos de seção e comentários de espaço reservado como estrutura base
    . Preencha cada seção com o conteúdo da análise de diferenças da etapa 5, preservando os títulos do modelo
    . Se não houver modelo, use o modelo padrão definido neste comando.
   - Preencha cada seção da seguinte forma:
     - **Atividade do Jira** — Link para o ticket do Jira: `[<jira-id>](https://<jira-base-url>/browse/<jira-id>)`.
       Se não houver ticket do Jira, escreva “Nenhum”.
     - **O que foi feito?** — Resuma as alterações como uma lista com marcadores. Use **negrito** para cada item
       quando várias áreas forem afetadas (por exemplo, `- **Módulo de autenticação**: Validação JWT refatorada...`).
       Concentre-se no objetivo da alteração, não nas diferenças linha por linha.
- **Como testar?** — Forneça etapas numeradas específicas para validar as alterações.
     - **Resultado esperado:** — Descreva o que o revisor deve observar após seguir as etapas do teste.
- **Riscos e impactos** — Anote quaisquer riscos, alterações significativas ou efeitos colaterais. Escreva “Nenhum” se não houver.
- **Capturas de tela/GIFs** — Escreva “N/A” se não for aplicável.
     - **Lista de verificação do autor** — Inclua os três itens da lista de verificação (desmarcados), com o nome do branch base
       substituído no primeiro item: `[ ] Meu branch está atualizado com \`<base-branch>\`.`

9. **Atualize a descrição do PR**
- Atualize o corpo do PR com a descrição completa:
```
gh pr edit <pr-number> --body "<full-description>"
```
   - Use um HEREDOC para a formatação correta.

10. **Resumo**
    - Exiba a URL do PR, o título, o branch base e o link do ticket Jira (se aplicável).
    - Lembre o usuário dos requisitos de revisão:
      - PRs para `main`: Requer envolvimento sênior (como autor ou revisor).
      - SLA de revisão: 2 dias úteis para `main`.
