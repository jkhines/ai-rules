---
comando: /pull-request
descrição: Cria uma solicitação de pull seguindo os padrões da equipe com integração com o Jira
alwaysApply: false
---

## Criação de solicitação de pull

Cria uma solicitação de pull seguindo os padrões da equipe definidos nos Padrões de Desenvolvimento da Equipe.

### Formato do título da solicitação de pull

Para solicitações de pull de desenvolvimento, use o formato de commits convencionais com o ID do ticket do Jira na posição do escopo:

```
<type>(<jira-id>): <description>
```

Exemplo: `feat(PROJ-451): implementar login social`

Se não houver um ticket do Jira disponível, mas um escopo de módulo for apropriado:

```
<type>(<scope>): <description>
```

Exemplo: `feat(ci): refinar configurações de concorrência no fluxo de trabalho de publicação`

Mantenha o título conciso, mas não imponha um limite rígido de caracteres. Busque a brevidade; até ~100 caracteres são
aceitáveis quando a descrição assim o exigir.

### Modelo de descrição do PR

O arquivo `.github/pull_request_template.md` do repositório fornece a estrutura da descrição do PR. O GitHub preenche
esse modelo automaticamente ao criar um PR. O comando deve preencher as seções do modelo com conteúdo
derivado da análise de diferenças, em vez de substituir o modelo por um formato personalizado.

O modelo padrão em todos os repositórios da equipe é:

```markdown
### Atividade no Jira

[<jira-id>](<jira-browse-url>)

### O que foi feito?

<!-- Clearly and concisely describe the changes made in this Pull Request, focusing on the purpose of the change. -->

### Como testar?

<!-- Provide a clear step-by-step guide for the reviewer to validate your changes. Be specific. -->

### Resultado esperado:

<!-- Describe what the reviewer should see or what should happen at the end of the tests. -->

### Riscos e impactos

<!-- List any risks or impacts that this change may cause (e.g., in other parts of the system, performance, etc.). If none, write "None". -->

### Capturas de tela / GIFs (se aplicável)

### Lista de verificação do autor

[ ] Meu branch está atualizado com `<base-branch>`.
[ ] Adicionei testes que cobrem minhas alterações.
[ ] A documentação relevante foi atualizada.
```

Observação: A Lista de Verificação do Autor deve referenciar o branch base real (por exemplo, `main`), não um espaço reservado.

## Etapas de execução

Quando `/pull-request` é invocado:

1. **Verificar alterações não confirmadas**
   - Execute `git status` para verificar se há alterações preparadas ou não preparadas (incluindo arquivos não rastreados).
   - Se houver alterações não confirmadas, informe o usuário: “Existem alterações não confirmadas neste ramo.
     Por favor, confirme e envie suas alterações primeiro (por exemplo, `/commit-push`), depois execute novamente `/pull-request`.”
   - Interrompa a execução. Não prossiga até que a árvore de trabalho esteja limpa.

2. **Verifique se o ramo foi enviado**
   - Verifique se o ramo atual possui um ramo de rastreamento upstream: `git rev-parse --abbrev-ref --symbolic-full-name @{u}`
   - Se não houver upstream, envie o ramo: `git push -u origin <current-branch>`
   - Se houver um upstream, verifique se há commits não enviados: `git log @{u}..HEAD --oneline`
   - Se houver commits não enviados, envie-os: `git push`

3. **Determine o ramo base (alvo da fusão)**

   O Git não armazena metadados do ramo pai, portanto, todo método de detecção é heurístico. A estratégia abaixo
   combina vários sinais, do mais confiável ao menos confiável, para chegar à resposta correta.

   - **Etapa A — Dica do reflog (esforço máximo, pode não estar disponível):**
     - Execute: `git reflog show <current-branch> --format='%gs' | tail -1`
     - Procure por padrões: `branch: Created from origin/<branch>` ou `branch: Created from <branch>`.
     - Se `<branch>` for um nome de ramificação (não um SHA bruto), registre-o como candidato ao reflog.
     - O reflog expira (padrão de 90 dias) e o formato varia entre as versões do Git, portanto, trate isso como uma
       **apenas uma dica** -- isso deve ser confirmado na Etapa B.

   - **Etapa B -- Comparação topológica da base de mesclagem (método principal):**
     - Busque o estado remoto mais recente: `git fetch origin`
     - Crie uma lista de candidatos de ramificações remotas, priorizadas nesta ordem:
       1. O candidato de reflog da Etapa A (se houver).
       2. `main` (a ramificação de longa duração da equipe).
       3. Quaisquer outras ramificações remotas que não sejam a ramificação atual.
     - Para cada candidato, calcule a base de mesclagem:
       ```
       git merge-base origin/<candidate> HEAD
       ```
     - Colete todos os commits de base de mesclagem únicos e, em seguida, determine qual deles é **topologicamente mais próximo** do HEAD:
       ```
       git rev-list --topo-order --max-count=1 <merge-base-1> <merge-base-2>...
       ```
       O commit retornado é o ancestral comum mais recente entre todos os candidatos. O branch candidato
       que produziu essa base de mesclagem é o branch base.
     - **Desempate:** Se vários candidatos compartilharem o mesmo commit de base de mesclagem, dê preferência nesta ordem:
       o candidato do reflog da Etapa A, depois `main`, e depois os outros branches em ordem alfabética.

   - **Etapa C — Valide com o log de commits:**
     - Execute: `git log origin/<base>..HEAD --oneline`
     - Verifique se os commits listados pertencem ao trabalho de funcionalidade atual. Se aparecerem commits não relacionados de outros
       ramos, a base escolhida provavelmente está errada — reexamine os candidatos da Etapa B, excluindo a
       escolha atual, e repita.

   - **Etapa D — Lidar com ramos pais excluídos:**
     - Se o candidato do reflog da Etapa A não existir mais no remoto (`git ls-remote --heads origin <name>`
       retornar vazio), o ramo pai provavelmente foi mesclado e excluído.
     - Nesse caso, recorra ao vencedor da base de mesclagem da Etapa B entre os ramos remanescentes de longa duração
       (`main`).

   - O ramo base determinado é o destino da fusão do PR. Pode ser `main` ou outro ramo de recurso.
     Não solicite confirmação; prossiga automaticamente.

4. **Extrair o ticket do Jira a partir do nome do ramo**
   - Analise o nome do ramo atual em busca de um ID de ticket do Jira que corresponda ao padrão `[A-Z]+-[0-9]+`.
   - Se encontrado, busque o resumo do ticket no Jira usando `JIRA_BASE_URL`, `JIRA_EMAIL` e `JIRA_API_TOKEN`
     (autenticação HTTP Basic). Endpoint: `GET {JIRA_BASE_URL}/rest/api/3/issue/{jira-id}?fields=summary,issuetype`
   - Se nenhum ID de ticket for encontrado no nome do branch, solicite um ao usuário ou prossiga sem ele.

5. **Analisar alterações para o PR**
   - Calcule a diferença entre o branch atual e o branch base determinado na etapa 3:
     `git diff <base-branch>...HEAD`
   - Revise o log completo de commits desde a divergência: `git log <base-branch>..HEAD --oneline`
   - Entenda o escopo completo das alterações — todos os commits, não apenas o mais recente.

6. **Gerar título do PR**
   - Siga o formato: `<type>(<jira-id>): <description>`
   - O `<type>` deve corresponder ao prefixo do tipo de ramificação, mapeado para os tipos de commit convencionais:
     `feature/` -&gt; `feat`, `fix/` -&gt; `fix`, `hotfix/` -&gt; `fix`, `chore/` -&gt; `chore`, etc.
   - Coloque o ID do ticket do Jira na posição (parênteses).
   - Se não houver nenhum ticket do Jira disponível, use um escopo de módulo ou omita o escopo por completo.
   - Mantenha o título conciso. Procure ser breve, mas até ~100 caracteres é aceitável.

7. **Crie o PR com o modelo padrão**
   - Verifique se o repositório possui um modelo de PR em `.github/pull_request_template.md`.
   - Se o modelo existir, crie o PR usando-o como corpo inicial:
     ```
     gh pr create --base <base-branch> --title "<title>" --body-file .github/pull_request_template.md
     ```
   - Se não houver modelo, crie o PR com o corpo vazio:
     ```
     gh pr create --base <base-branch> --title "<title>" --body ""
     ```
   - Anote o número do PR na saída.
   - Atribua o PR ao usuário atual: `gh pr edit <pr-number> --add-assignee @me`

8. **Aplicar rótulos**
   - Listar rótulos disponíveis: `gh label list --repo <owner>/<repo>`
   - Selecione a(s) etiqueta(s) que melhor correspondam à natureza do PR e da tarefa do Jira (por exemplo, `bug`, `enhancement`,
     `documentation`). Use o tipo de commit convencional e o tipo de issue do Jira como referência.
   - Aplique as etiquetas: `gh pr edit <pr-number> --add-label "<label1>,<label2>"`
   - Se nenhuma etiqueta for uma correspondência razoável, pule esta etapa.

9. **Adicionar revisores**
   - Se o usuário especificar revisores (por meio de argumentos de comando ou conversa), adicione-os:
     `gh pr edit <pr-number> --add-reviewer <user1>,<user2>`
   - Se o usuário não especificar revisores, pergunte quem deve revisar o PR antes de prosseguir.
   - Não pule a atribuição de revisores sem avisar.

10. **Gerar descrição completa do PR**
   - Escreva em um **tom coloquial, de desenvolvedor para desenvolvedor** — da mesma forma que um engenheiro explicaria
     a alteração a um colega de equipe. Inglês simples, frases curtas, voz ativa. Evite nomes de recursos,
     chaves de configuração ou detalhes de implementação que só fazem sentido ao ler o diff.
   - Se um modelo de PR foi usado na etapa 7, preserve os títulos das seções. Se não houver modelo, use
     o modelo padrão definido neste comando.
   - Preencha cada seção da seguinte forma:
     - **Atividade no Jira** — Link para o ticket do Jira: `[<jira-id>](https://<jira-base-url>/browse/<jira-id>)`.
       Se não houver ticket no Jira, escreva “Nenhum”.
     - **O que foi feito?** -- Resuma o *objetivo* e o *efeito* das alterações em uma breve lista com marcadores.
       Escreva como se estivesse explicando para um colega de equipe que não viu o código. Concentre-se em *o que mudou e por quê*,
       não em nomes de recursos do Terraform, definições de variáveis ou caminhos de arquivos. Use **introduções em negrito** apenas
       quando várias áreas não relacionadas forem afetadas.
     - **Como testar?** -- Escreva etapas numeradas que um **engenheiro de QA** possa seguir sem ler o
       código. Cada etapa deve indicar *quem* faz *o quê*, *onde* e *como*. Para alterações de infraestrutura (Terraform)
      , os testes são realizados por meio do **Terraform Cloud** (plan/apply no espaço de trabalho apropriado),
       não por comandos CLI locais. Para alterações na aplicação, descreva ações concretas voltadas para o usuário
       (clicar, navegar, chamar um endpoint, etc.).
     - **Resultado esperado:** -- Descreva o que o testador deve observar após seguir as etapas do teste.
     - **Riscos e impactos** -- Anote quaisquer riscos, alterações que causem quebra de compatibilidade ou efeitos colaterais. Escreva "Nenhum" se não houver.
     - **Capturas de tela / GIFs** -- Escreva "N/A" se não for aplicável.
     - **Lista de verificação do autor** -- Inclua os três itens da lista de verificação (desmarcados), com o nome do branch base
       substituído no primeiro item: `[ ] Meu branch está atualizado com \`<base-branch>\`.`

11. **Atualize a descrição do PR**
   - Atualize o corpo do PR com a descrição completa:
     ```
     gh pr edit <pr-number> --body "<full-description>"
     ```
   - Use um HEREDOC para formatação correta.

12. **Limpe os arquivos temporários**
    - Se algum arquivo foi criado ou modificado exclusivamente para auxiliar na criação do PR (por exemplo, arquivos diff temporários,
      notas de rascunho), remova-os do sistema de arquivos local.
    - Não remova arquivos que façam parte do repositório ou da árvore de trabalho do usuário.
    - Execute `git status` para confirmar se a árvore de trabalho ainda está limpa após a limpeza.

13. **Resumo**
    - Exiba a URL do PR, o título, o branch base e o link do ticket do Jira (se aplicável).
    - Lembre o usuário dos requisitos de revisão:
      - PRs para `main`: Requer envolvimento de um membro sênior (como autor ou revisor).
      - SLA de revisão: 2 dias úteis para `main`.
