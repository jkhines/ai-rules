---
comando: /spawn
descrição: Gera agentes de modelo paralelos estritos, grava arquivos de resultados e, opcionalmente, aplica correções
alwaysApply: false
---
Execute uma tarefa em vários modelos em paralelo, exija que cada modelo mantenha os resultados em um arquivo markdown local e, opcionalmente, implemente correções a partir dos resultados combinados.

## Entradas

Todas as entradas têm padrões e só precisam ser especificadas quando substituídas.

- `task` -- instrução delegada (por exemplo, `o comando /code-review`)
- `models` -- modelos de destino. Padrão: `["opus-4.6","gpt-5.3-codex","gemini-3.1-pro"]`
- `output_dir` -- diretório para arquivos de resultados. Padrão: diretório de trabalho atual
- `timestamp` -- carimbo de data/hora de execução compartilhado. Padrão: UTC atual `AAAA-MM-DD-HHmmss`
- `poll_interval_sec` -- intervalo de pesquisa de arquivos. Padrão: `2`
- `timeout_sec` -- tempo máximo de espera para todas as saídas do modelo. Padrão: `900`
- `strict` -- quando `true`, falha se algum arquivo esperado estiver faltando. Padrão: `true`
- `apply_severity` -- gravidades a serem implementadas após a síntese. Padrão: `[]` (sem implementação automática)
- `max_parallel` -- número máximo de agentes gerados simultaneamente. Padrão: `3`

## Comportamento

1. Analise a solicitação em:
   - tarefa delegada (por exemplo, execute `/code-review`)
   - modelos de destino
   - instrução de correção opcional (por exemplo, implemente descobertas críticas e altas)
2. Normalize nomes de modelos amigáveis para IDs de modelos Cursor:
   - `Opus 4.6` -&gt; `opus-4.6`
   - `Codex 5.3` -&gt; `gpt-5.3-codex`
   - `Gemini 3.1 Pro` -&gt; `gemini-3.1-pro`
3. Calcule um `timestamp` compartilhado e o arquivo esperado por modelo:
   - `cursor-<model-id>-<timestamp>.md`
   - caminho de saída: `output_dir/cursor-<model-id>-<timestamp>.md`
4. Gere um subagente em segundo plano por modelo (até `max_parallel`) com as instruções necessárias:
   - execute a `tarefa` delegada
   - grave as conclusões finais exatamente em `output_dir/cursor-<model-id>-<timestamp>.md`
   - finalize relatando o caminho exato do arquivo local criado
5. Verifique `output_dir` até que todos os arquivos esperados existam ou `timeout_sec` seja atingido.
6. Imponha a conclusão estrita por padrão:
   - se todos os arquivos existirem, continue
   - se algum arquivo estiver faltando e `strict=true`, falhe na execução e relate os arquivos ausentes
   - se algum arquivo estiver faltando e `strict=false`, continue com os arquivos disponíveis e marque a conclusão parcial
7. Leia os arquivos de resultados produzidos e sintetize:
   - lista consolidada de problemas críticos/altos/médios/baixos
   - sobreposição e discordância por modelo
   - plano de implementação ordenado
8. Se o usuário solicitou a implementação ou `apply_severity` não estiver vazio:
   - mapeie “Implementar todas as correções de bugs críticos e altos” para `apply_severity=["Critical","High"]`
   - implemente as correções em ordem de gravidade
   - execute a verificação após cada grupo de correções e repita até ser aprovado
9. Retorne:
   - modelos gerados
   - caminhos de arquivos criados
   - resultado estrito de aprovação/reprovação
   - melhorias sintetizadas
   - resultados da implementação (se solicitado)

## Modelo de instrução do subagente necessário

Use esta estrutura exata para cada modelo gerado:

1. Execute: `<delegated task>`.
2. Salve sua saída final em: `<output_dir>/cursor-<model-id>-<timestamp>.md`.
3. Termine com: `CREATED_FILE: <absolute-local-path>`.

## Exemplos de prompts

- `/spawn o comando /code-review para Opus 4.6, Codex 5.3 e Gemini 3.1 Pro`
- `/spawn o comando /code-review para Opus 4.6, Codex 5.3 e Gemini 3.1 Pro. Implemente todas as correções de bugs críticos e graves sugeridas pelos agentes.`
