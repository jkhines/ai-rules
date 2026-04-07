---
comando: /code-review
descrição: Analisa dois ramos e fornece feedback
alwaysApply: false
---
Analisa as alterações de código entre dois ramos especificados pelo usuário. O usuário fornece os nomes de ambos os ramos (por exemplo, `feature/auth` e `main`).

## Definições de gravidade

Classifique cada resultado em exatamente um destes níveis:

| Gravidade | Definição | Exemplos |
|----------|-----------|----------|
| **Crítico** | Causará perda de dados, violação de segurança ou interrupção total do serviço em produção. Deve ser corrigido antes da fusão. | Injeção de SQL, redirecionamento não validado para URL controlada pelo invasor, falta de autenticação em um endpoint de mutação, exceção não capturada que causa falha no processo |
| **Grave** | Causará comportamento incorreto, vulnerabilidade de segurança, degradação significativa do desempenho ou risco à integridade dos dados. Deve ser corrigido antes da integração. | Condição de corrida em gravações simultâneas, falta de validação de entrada no limite da API externa, consulta N+1 em um endpoint de lista, erro ignorado silenciosamente, ocultando falhas dos operadores |
| **Menor** | Problema de qualidade do código, manutenção ou estilo que não afeta a correção ou a segurança em tempo de execução. A correção é desejável, mas não é obrigatória. | Nomenclatura inconsistente, falta de anotação de tipo em uma API pública, constante duplicada, nome de variável pouco claro |
| **Aprimoramento** | Sugestão de melhoria ou abordagem alternativa. Não é um defeito. | Sugere-se extrair um helper, propor um padrão mais idiomático, recomendar a adição de uma métrica |

Em caso de dúvida entre dois níveis adjacentes, prefira a gravidade mais alta. Uma descoberta que se situe entre Crítico e Grave deve ser classificada como Crítica; uma que se situe entre Grave e Menor deve ser classificada como Grave.

## Processo

### 1. Buscar e definir o escopo do diff
```bash
git fetch origin
git diff --name-only origin/<base>...origin/<feature>
```
Para cada arquivo, verifique se existem alterações reais com `git diff --quiet`. Ignore arquivos sem trechos de diferença.

**Crítico**: Use comandos do Git para ler o conteúdo do branch, não ferramentas do sistema de arquivos. O diretório de trabalho pode estar em um branch diferente.
- Verifique a existência do arquivo: `git ls-tree -r --name-only origin/<branch> -- <path>`
- Leia o conteúdo do arquivo: `git show origin/<branch>:<path>`

Para cada arquivo alterado, leia o arquivo completo com `git show origin/<feature>:<path>` para entender:
- A função, classe ou módulo completo que contém cada alteração
- Importações e dependências afetadas pela alteração
- Como os chamadores ou consumidores usam o código modificado
- Se existem padrões semelhantes em outros lugares que devam ser alterados de forma consistente

Não analise o diff isoladamente. Uma alteração que pareça correta em um trecho pode quebrar invariantes visíveis apenas no arquivo completo.

Se uma alteração modificar uma interface, tipo, chave de configuração ou exportação, use `git ls-tree` e `git show` para ler todos os arquivos que a importam ou consomem e verificar se permanecem compatíveis.

### 2. Reúna o contexto organizacional

Se uma ferramenta do mecanismo de contexto Unblocked estiver disponível (por exemplo, `unblocked_context_engine`), consulte-a para obter o contexto que uma revisão baseada em diff deixaria passar. Se a ferramenta não estiver disponível, pule esta etapa e prossiga para a etapa 3.

Chame a ferramenta com:
- `projectPath`: o diretório de trabalho atual
- `question`: uma consulta que inclua o nome do branch de recurso e a lista de arquivos alterados da etapa 1, solicitando:
  - Padrões ou convenções da equipe documentados em wikis ou bases de conhecimento
  - Discussões relevantes de PRs anteriores, feedback de revisores ou decisões
  - Tópicos relacionados no Slack ou em mensagens sobre esses módulos ou padrões
  - Problemas conhecidos, tickets ou restrições de rastreadores de problemas
  - Decisões arquitetônicas ou justificativas de projeto de qualquer fonte

Concentre a consulta no que os revisores precisam saber que NÃO está visível no próprio diff.

Salve a resposta como **CONTEXTO ORGANIZACIONAL** para uso na etapa 3.

### 3. Avalie cada alteração
Para cada bloco alterado, use seu entendimento do arquivo completo e de seus dependentes para avaliar a alteração. Identifique como as entradas são derivadas, como as saídas são consumidas e se a alteração introduz efeitos colaterais.

Avalie com base nestes critérios (marque N/A se não for aplicável a esta alteração):

| Categoria | Verificação |
|----------|-------|
| Design | Se encaixa nos padrões arquitetônicos, evita acoplamento, separação clara de responsabilidades |
| Complexidade | Fluxo de controle plano, baixa complexidade ciclomática, DRY, sem código morto |
| Correção | Lida com entradas válidas/inválidas, casos extremos, caminhos de erro, idempotência |
| Legibilidade | Nomenclatura clara, comentários explicam o porquê e não o quê, ordenação lógica |
| Padrões | Expressões idiomáticas da linguagem, princípios SOLID, limpeza de recursos, registro em log |
| Testes | Cobertura de unidade + integração, asserções significativas, nomes descritivos |
| Estilo | Em conformidade com o guia de estilo, sem novos avisos do linter |
| Documentação | APIs públicas documentadas, README/CHANGELOG atualizados se necessário |
| Segurança | Validação de entradas, codificação de saídas, gerenciamento de segredos, authZ/authN |
| Desempenho | Sem consultas N+1, E/S eficiente, cache/processamento em lote adequados |
| Observabilidade | Métricas/rastreamento para eventos-chave, níveis de log adequados, sem registro de dados confidenciais |
| Acessibilidade | HTML semântico, atributos ARIA, navegação por teclado, strings i18n externalizadas |
| CI/CD | Integridade do pipeline, declarações de dependências, estratégia de implantação |
| Qualidade do código | Estilo consistente, sem dependências ocultas, testes e documentação incluídos |

Se o CONTEXTO ORGANIZACIONAL foi coletado na etapa 2, trate-o como orientação oficial específica da equipe. Prefira as convenções organizacionais em detrimento das melhores práticas genéricas quando houver conflito. Sinalize desvios dos padrões documentados da equipe como, no mínimo, Menores.

### 4. Aplique a Lente “O que poderia dar errado”
Após avaliar cada alteração em relação à tabela de critérios, procure ativamente pelos modos de falha abaixo. Se você já relatou um problema da tabela de critérios que abrange a mesma causa raiz, não o relate novamente aqui — essa lente é uma segunda verificação para detectar o que a tabela deixou passar, não uma fonte de duplicatas.
- **Limites de entrada**: entradas não validadas ou parcialmente validadas, ausência de proteções de tipo, valores nulos/indefinidos não tratados
- **Casos extremos**: coleções vazias, acesso simultâneo, erros de deslocamento de um, valores de limite
- **Caminhos de erro**: exceções ignoradas, ausência de reversão após falha parcial, limpeza que mascara erros
- **Autorização e segredos**: Caminhos de escalonamento de privilégios, credenciais em logs ou mensagens de erro, verificações de autorização ausentes em novos endpoints
- **Lacunas de observabilidade**: Operações-chave sem registro, dados confidenciais na saída de log, contexto de erro ausente
- **Segurança de implantação**: Ordem de migração, alterações de configuração incompatíveis com versões anteriores, sinalizadores de recurso não conectados

Para cada item, verifique o arquivo completo e os arquivos relacionados usando `git show` — não apenas o trecho de diff. Se a alteração introduzir uma nova função, leia seus chamadores. Se modificar o tratamento de erros, leia os blocos catch do chamador. Se alterar um tipo, leia todos os consumidores.

### 5. Preservar a intenção do branch
Identifique o objetivo principal do branch a partir do diff (por exemplo, adicionar um novo recurso, introduzir uma integração, implementar um recurso). Problemas que recomendam **substituir ou remover** a abordagem fundamental — em vez de melhorá-la — devem ser rotulados como **Recomendatórios** e colocados em Melhorias, não em Críticos ou Graves. Uma constatação é Recomendatória quando a única correção é abandonar a abordagem que o branch existe para implementar.

As descobertas Críticas e Graves devem ser **exequíveis dentro da abordagem atual**. Por exemplo, se o branch introduz um certificado importado externamente, “adicionar proteções de ciclo de vida” é exequível; “importar o certificado fora do Terraform” é Consultivo porque nega o propósito do branch.

### 6. Formato das questões
Para cada questão:
```
- Arquivo: `<path>:<line-range>`
  - Problema: [Problema principal em uma linha]
  - Correção: [Alteração sugerida ou trecho de código]
```

## Formato de saída

### Resumo de alto nível
2 a 3 frases cobrindo:
- **Impacto no produto**: O que isso proporciona para usuários/clientes
- **Abordagem de engenharia**: Padrões ou frameworks principais utilizados

### Problemas priorizados
Agrupe todos os problemas por gravidade. Inclua todas as quatro seções, mesmo que estejam vazias.

#### Crítico
- ...

#### Grave
- ...

#### Menor
- ...

#### Melhoria
- ...

### Destaques
Lista com marcadores de descobertas positivas ou padrões bem implementados.
