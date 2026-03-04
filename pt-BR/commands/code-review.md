---
command: /code-review
description: Revê dois ramos e fornece feedback
alwaysApply: false
---
Revê as alterações de código entre dois ramos especificados pelo usuário. O usuário fornece os nomes dos dois ramos (por exemplo, `feature/auth` e `main`).

## Processo

### 1. Obter e definir o escopo da diferença
```bash
git fetch origin
git diff --name-only origin/<base>...origin/<feature>
```
Para cada arquivo, verifique se as alterações reais existem com `git diff --quiet`. Ignore arquivos sem diferenças.

**Importante**: use comandos Git para ler o conteúdo do branch, não ferramentas do sistema de arquivos. O diretório de trabalho pode ser um branch diferente.
- Verifique a existência do arquivo: `git ls-tree -r --name-only origin/<branch> -- <path>`
- Leia o conteúdo do arquivo: `git show origin/<branch>:<path>`

### 2. Avalie cada alteração
Para cada trecho alterado, entenda como o código modificado interage com a lógica ao redor: como as entradas são derivadas, como as saídas são consumidas e se a alteração introduz efeitos colaterais.

Avalie com base nestes critérios (marque N/A se não for aplicável a esta alteração):

| Categoria | Verificar |
|----------|-------|
| Design | Se encaixa nos padrões arquitetônicos, evita acoplamento, separação clara de interesses |
| Complexidade | Fluxo de controle plano, baixa complexidade ciclomática, DRY, sem código morto |
| Correção | Lida com entradas válidas/inválidas, casos extremos, caminhos de erro, idempotência |
| Legibilidade | Nomes claros, comentários explicam o porquê e não o quê, ordenação lógica |
| Padrões | Expressões idiomáticas da linguagem, princípios SOLID, limpeza de recursos, registro em log |
| Testes | Cobertura de unidade + integração, asserções significativas, nomes descritivos |
| Estilo | Em conformidade com o guia de estilo, sem novos avisos do linter |
| Documentação | APIs públicas documentadas, README/CHANGELOG atualizados se necessário |
| Segurança | Validação de entrada, codificação de saída, gerenciamento de segredos, authZ/authN |
| Desempenho | Sem consultas N+1, E/S eficiente, cache/loteamento apropriado |
| Observabilidade | Métricas/rastreamento para eventos importantes, níveis de log apropriados, sem dados confidenciais registrados |
| Acessibilidade | HTML semântico, atributos ARIA, navegação por teclado, strings i18n externalizadas |
| CI/CD | Integridade do pipeline, declarações de dependência, estratégia de implantação |
| Qualidade do código | Estilo consistente, sem dependências ocultas, testes e documentos incluídos |

### 3. Problemas de formato
Para cada problema:
```
- Arquivo: `<path>:<line-range>`
  - Problema: [Problema principal em uma linha]
  - Correção: [Alteração sugerida ou trecho de código]
```

## Formato de saída

### Resumo de alto nível
2-3 frases cobrindo:
- **Impacto no produto**: O que isso oferece para usuários/clientes
- **Abordagem de engenharia**: Padrões ou estruturas principais usados

### Problemas priorizados
Agrupe todos os problemas por gravidade. Inclua todas as quatro seções, mesmo que estejam vazias.

#### Crítico
- ...

#### Grave
- ...

#### Leve
- ...

#### Aprimoramento
- ...

### Destaques
Lista com marcadores de descobertas positivas ou padrões bem implementados.
