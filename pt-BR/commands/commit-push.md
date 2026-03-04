---
command: /commit-push
description: Confirma alterações de código seguindo o Conventional Commits v1.0.0 e valida a nomenclatura do branch
alwaysApply: false
---

## Conventional Commits (v1.0.0)

### Formato da mensagem de commit
```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Tipos de commit (OBRIGATÓRIO)
- `feat`: Novo recurso para o usuário (correlaciona-se com MINOR no SemVer)
- `fix`: Correção de bug para o usuário (correlaciona-se com PATCH no SemVer)
- `docs`: Apenas alterações na documentação
- `style`: Alterações no estilo do código (formatação, ponto-e-vírgulas ausentes, espaços em branco, etc.) que não afetam o significado do código
- `refactor`: Alteração no código que não corrige um bug nem adiciona um recurso
- `perf`: Alteração no código que melhora o desempenho
- `test`: Adição de testes ausentes ou correção de testes existentes
- `build`: Alterações no sistema de compilação ou dependências externas (por exemplo, npm, webpack, gradle)
- `ci`: Alterações nos arquivos e scripts de configuração de CI (por exemplo, GitHub Actions, CircleCI)
- `chore`: Outras alterações que não modificam os arquivos src ou de teste (por exemplo, atualização de dependências, ferramentas)
- `revert`: Reverte um commit anterior

### Escopo (OPCIONAL)
- Substantivo que descreve uma seção da base de código entre parênteses
- Exemplos: `feat(parser):`, `fix(api):`, `refactor(auth):`

### Descrição (OBRIGATÓRIO)
- Resumo curto no tempo presente (modo imperativo)
- Sem letra maiúscula inicial
- Sem ponto final
- Exemplos: “adicionar autenticação de usuário”, “corrigir vazamento de memória no analisador”

### Corpo (OPCIONAL)
- Forneça informações contextuais adicionais
- Use o modo imperativo
- Pode conter vários parágrafos
- Separe da descrição com uma linha em branco

### Rodapé (OPCIONAL)
- Um ou mais rodapés separados do corpo por uma linha em branco
- Formato: `<token>: <value>` ou `<token> #<issue-number>`
- Tokens comuns: `BREAKING CHANGE`, `Refs`, `Closes`, `Fixes`
- O rodapé BREAKING CHANGE aciona um aumento de versão MAJOR (ou acrescente `!` após o tipo/escopo)

### Mudanças significativas
- DEVE ser indicado acrescentando `!` após o tipo/escopo: `feat!:` ou `feat(api)!:`
- OU incluindo o rodapé `BREAKING CHANGE:` com a descrição
- Exemplo:
  ```
  feat!: remove deprecated v1 API

  BREAKING CHANGE: v1 API endpoints have been removed. Use v2 instead.
  ```

### Exemplos
```
feat(auth): add OAuth2 support

fix: resolve race condition in event loop

docs(readme): update installation instructions

feat!: remove support for Node 12

BREAKING CHANGE: Node 12 is no longer supported. Minimum version is now Node 14.

refactor(core)!: simplify API surface

BREAKING CHANGE: The `initialize()` method now requires a config object.

chore: update dependencies

test(parser): add tests for edge cases

ci: add automated release workflow
```

## Nomenclatura convencional de ramificações

### Formato da ramificação
```
<type>/<description>
```

### Tipos de ramificação (OBRIGATÓRIO)
- `main` ou `master` ou `develop`: Ramificação principal de desenvolvimento (sem prefixo de tipo)
- `feature/` ou `feat/`: Novos recursos
- `bugfix/` ou `fix/`: Correções de bugs
- `hotfix/`: Correções urgentes de produção
- `release/`: Ramificações de preparação de lançamento
- `chore/`: Tarefas de manutenção, atualizações de dependências, ferramentas
- `docs/`: Apenas alterações na documentação
- `refactor/`: Refatoração de código sem alteração de comportamento
- `test/`: Adições ou correções de teste
- `perf/`: Melhorias de desempenho
- `ci/`: Alterações na configuração de CI/CD

### Descrição (OBRIGATÓRIO)
- Use apenas letras minúsculas (a-z), números (0-9) e hífens (-)
- Separe as palavras com hífens
- Sem caracteres especiais, sublinhados ou espaços
- Sem hífens ou pontos consecutivos, iniciais ou finais
- Seja conciso e descritivo
- Inclua números de tickets/problemas, quando aplicável
- Para ramificações de lançamento, pontos (.) são permitidos para números de versão

### Exemplos
```
feature/user-authentication
feat/add-payment-gateway
bugfix/fix-login-timeout
fix/resolve-memory-leak
hotfix/security-patch-cve-2024
release/v1.2.0
chore/update-dependencies
docs/api-documentation
refactor/simplify-error-handling
test/add-integration-tests
perf/optimize-database-queries
ci/add-deployment-pipeline
feature/issue-123-add-dark-mode
```

## Etapas de execução

Quando `/commit-push` é invocado:

- Prepare automaticamente todas as alterações, faça o commit com uma mensagem de commit convencional autodeterminada e envie para o remoto. Não solicite nenhuma confirmação.

1. **Verifique o status do Git**
   - Execute `git status` para identificar alterações preparadas e não preparadas
   - Se não houver alterações, informe o usuário e saia

2. **Valide o branch atual**
   - Execute `git branch --show-current` para obter o nome do ramo atual
   - Verifique se o nome do ramo corresponde ao padrão: `<type>/<description>`
   - Tipos válidos: `feature/`, `feat/`, `bugfix/`, `fix/`, `hotfix/`, `release/`, `chore/`, `docs/`, `refactor/`, `test/`, `perf/`, `ci/`
   - Exceção: `main`, `master`, `develop` são válidos sem prefixo

3. **Se o branch não for padrão**
   - Aviso: “O branch '[nome-do-branch]' não segue a nomenclatura convencional. Continuando mesmo assim.”
   - Continue para a etapa de commit

4. **Analise as alterações**
   - Revise as alterações preparadas/não preparadas
   - Determine o tipo de commit apropriado com base nas alterações:
     - `feat`: Nova funcionalidade adicionada
     - `fix`: Correções de bugs
     - `docs`: Apenas alterações na documentação
     - `style`: Formatação, alterações em espaços em branco
     - `refactor`: Reestruturação do código sem alteração no comportamento
     - `perf`: Melhorias de desempenho
     - `test`: Adições ou modificações de teste
     - `build`: Alterações no sistema de compilação ou dependências
     - `ci`: Alterações na configuração de CI/CD
     - `chore`: Tarefas de manutenção
   - Detecte alterações significativas procurando por:
     - APIs públicas, funções, classes ou exportações removidas ou renomeadas
     - Assinaturas de função alteradas (parâmetros adicionados/removidos/reordenados)
     - Tipos de retorno ou estruturas de dados alterados
     - Opções de configuração ou variáveis de ambiente removidas
     - Comportamento padrão alterado

5. **Gerar mensagem de commit**
   - Determine uma mensagem de commit seguindo o formato:
     ```
     <type>[escopo opcional]: <description>

     [corpo opcional]

     [rodapé opcional]
     ```
   - Regras:
     - O tipo é um dos tipos permitidos
     - Omitir o escopo, a menos que a área afetada seja óbvia a partir dos caminhos dos arquivos
     - A descrição está presente e no modo imperativo
     - A descrição começa com letra minúscula
     - A descrição não termina com um ponto final
     - Se forem detectadas alterações significativas, acrescente `!` após o tipo e inclua o rodapé `BREAKING CHANGE:`

6. **Executar commit**
   - Prepare todas as alterações: `git add -A`
   - Execute: `git commit -m "<commit-message>"`
   - Confirme se o commit foi bem-sucedido

7. **Enviar para o remoto**
   - Detecte o branch de rastreamento upstream: `git rev-parse --abbrev-ref --symbolic-full-name @{u}`
   - Se o branch de rastreamento existir, envie para ele; caso contrário, envie para `origin` com o nome do branch atual
   - Execute: `git push`

8. **Resumo pós-confirmação**
   - Mostre o hash da confirmação, a mensagem e o destino do envio
