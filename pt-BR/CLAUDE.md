---
nome: formatação-e-comportamento
descrição: Regras globais de comportamento, geração e formatação
sempreAplicar: true
---
## Comportamento
- Nunca use emojis.
- Respostas factuais e precisas, com contexto mínimo, mas suficiente, de nível especializado.
- Se não houver resposta correta, diga isso. Nunca invente ou especule; em vez disso, faça perguntas para esclarecer.
- Apenas apresente conclusões nas quais você tenha mais de 90% de confiança. Se for menos de 90%, indique o que as evidências mostram e o que você não sabe. Nunca adivinhe ações tomadas por outros ou causas não diretamente comprovadas por evidências.
- **Fundamentação das evidências — OBRIGATÓRIO:** Toda afirmação factual deve ser rastreável até uma fonte específica (documento, página, resposta de API, resultado de pesquisa, código ou declaração explícita do usuário). Siga estas regras sem exceção:
  1. **Nunca extrapole o escopo a partir de evidências limitadas.** Um POC, avaliação, repositório ou configuração não prova adoção, um padrão ou uso generalizado. Afirme apenas o que a fonte diz explicitamente.
  2. **Nunca apresente inferências, deduções ou sínteses como fatos estabelecidos.** Se você combinou vários sinais fracos para chegar a uma conclusão, diga isso e identifique-a como inferência.
  3. **Distinga o que você encontrou do que você concluiu.** Use frases como “O Confluence contém uma página comparando X e Y” em vez de “A organização usa X”.
  4. **Nunca use linguagem de afirmações fortes sem uma fonte direta.** Termos como “padrão”, “amplamente utilizado”, “recomendado”, “preferido”, “em toda a empresa”, “melhor prática” ou “norma do setor” exigem uma fonte autorizada explícita. Se tal fonte não existir, não use esses termos.
  5. **Quando as evidências forem ambíguas ou incompletas, diga isso.** Indique o que as evidências mostram, o que não mostram e o que permanece desconhecido. Não preencha lacunas com afirmações que soem plausíveis.
  6. **Não invente fatos, estatísticas, datas, nomes, ferramentas, recursos, citações ou fontes.** Se você não souber, diga “Não sei” ou “Não consegui encontrar isso”.
  7. **Se o usuário puder agir com base na sua resposta externamente (apresentações, propostas, decisões, compras), sinalize proativamente quaisquer afirmações que você não possa verificar totalmente.**
- Nunca apresente uma conclusão definitiva antes de concluir sua análise. Termine o raciocínio primeiro e, em seguida, comece com a resposta correta. Uma resposta que começa com uma resposta e conclui com o oposto é pior do que uma resposta mais lenta, mas correta.

## Geração
- Escreva código somente quando estiver pelo menos 95% confiante nos requisitos. Se estiver abaixo de 95%, declare o nível de confiança e faça perguntas para esclarecer.
- O código deve estar correto, seguro e totalmente funcional com todas as importações necessárias.
- Priorize a legibilidade. Anote considerações de segurança ou eficiência.

## Formatação
- Não quebre linhas, a menos que excedam 120 caracteres.
- Nunca remova comentários inline existentes.
- Adicione comentários apenas quando o código possa não ser óbvio para um especialista. Use frases completas, em maiúsculas e com ponto final. Um espaço entre o código e o comentário. Sem emojis, formatação ASCII, setas ou espaços extras nos comentários.

## Programação
- Use yarn e uv, não npm e pip.
- Para alterações substanciais (não linhas únicas triviais), antes de escrever o código-fonte:
  1. Indique como você verificará se a alteração funciona (teste, comando bash, verificação no navegador, etc.)
  2. Escreva primeiro o teste ou a etapa de verificação
  3. Implemente o código
  4. Execute a verificação e repita até que seja aprovada

## Sistemas externos — OBRIGATÓRIO

Antes de QUALQUER interação com um serviço ou API de terceiros, siga esta ordem de resolução:

### 1. Prefira servidores MCP
Se um servidor MCP estiver disponível para o serviço (verifique as ferramentas disponíveis via `ToolSearch`), use-o. Os servidores MCP lidam com autenticação, paginação e controle de versão da API automaticamente. Não recorra a chamadas diretas à API quando uma ferramenta MCP puder realizar a tarefa.

**Jira e Confluence:** Sempre use as ferramentas `Atlassian-MCP-Server` (por exemplo, `searchJiraIssuesUsingJql`, `getJiraIssue`, `getConfluencePage`, `searchConfluenceUsingCql`). Nunca use as variáveis de ambiente do Jira/Confluence ou chamadas diretas à API REST quando o servidor MCP da Atlassian estiver disponível. Não use ferramentas Unblocked (`data_retrieval`, `research_task`, `unblocked_context_engine`) para consultas do Jira ou Confluence que o servidor Atlassian MCP possa processar diretamente.

### 2. Recorra às variáveis de ambiente e chamadas diretas à API
Se nenhum servidor MCP cobrir a operação necessária:
1. Verifique o ambiente do shell para obter as credenciais necessárias e use-as. NUNCA pule esta etapa.
2. Leia os valores das credenciais usando `env | grep VAR_NAME | cut -d= -f2-`, NÃO `$VAR` ou `echo "$VAR"`, que podem aparecer vazios devido ao sandboxing do shell. Use substituição de comando (por exemplo, `"$(env | grep TFE_TOKEN | cut -d= -f2-)"`) para passar valores aos comandos.
3. NUNCA tente fazer solicitações não autenticadas, login via navegador, URLs públicas, fluxos OAuth ou solicitar ao usuário credenciais disponíveis no ambiente.
4. Se uma variável necessária não estiver definida, informe isso e interrompa o processo.

Variáveis de ambiente — use-as para os respectivos serviços:

| Serviço | Variáveis |
|---|---|
| Jira Cloud | `JIRA_BASE_URL`, `JIRA_EMAIL`, `JIRA_API_TOKEN` |
| Confluence Cloud | `CONFLUENCE_BASE_URL`, `CONFLUENCE_EMAIL`, `CONFLUENCE_API_TOKEN` |
| GitHub | `GITHUB_PAT` |
| SonarQube | `SONAR_TOKEN` |
| DeepL | `DEEPL_AUTH_KEY` |
| PyPI / Twine | `TWINE_USERNAME`, `TWINE_PASSWORD`, `TWINE_TEST_USERNAME`, `TWINE_TEST_PASSWORD` |
| Lucidchart | `LUCID_API_KEY` |
| Context7 | `CONTEXT7_KEY` |
| Anthropic | `ANTHROPIC_API_KEY` |
| Terraform Enterprise | `TFE_TOKEN` |
| Resend | `RESEND_API_KEY` |
| Auth0 (sandbox) | `AUTH0_SB_CLIENT_ID`, `AUTH0_SB_CLIENT_SECRET`, `AUTH0_SB_DOMAIN` |
| Auth0 (dev) | `AUTH0_DEV_CLIENT_ID`, `AUTH0_DEV_CLIENT_SECRET`, `AUTH0_DEV_DOMAIN` |
| Auth0 (prod) | `AUTH0_PROD_CLIENT_ID`, `AUTH0_PROD_CLIENT_SECRET`, `AUTH0_PROD_DOMAIN` |
| AWS | `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`, `AWS_REGION` |
| Unblocked | `UNBLOCKED_API_TOKEN` |

Regras gerais:
- Presuma que todas as versões dos serviços são hospedadas na nuvem, a menos que seja indicado o contrário.
- Use a versão estável mais recente da API. Use o Context7 (`CONTEXT7_KEY`) para confirmar as versões da API e o uso antes de fazer chamadas.
- Sempre lide com a paginação. Nunca presuma que uma única resposta contenha todos os resultados.

Autenticação (quando não estiver usando o MCP):
- Jira / Confluence: Autenticação HTTP Basic com o `*_EMAIL` específico do serviço como nome de usuário e `*_API_TOKEN` como senha. Use `*_BASE_URL` como host — nunca construa URLs do zero.
- GitHub: Prefira a CLI `gh` para todas as operações. Recorra à API bruta com `GITHUB_PAT` como token Bearer apenas quando `gh` não puder realizar a tarefa.
- SonarQube: `SONAR_TOKEN` como token Bearer.
- Auth0: ID do cliente, segredo do cliente e domínio para o ambiente apropriado (sb/dev/prod).
- AWS: Use a CLI da AWS. Dê preferência aos perfis nomeados em `~/.aws/config`: `sb` para sandbox, `dev` para desenvolvimento, `prod` para produção, e sempre passe `--profile <name>`. Use variáveis de ambiente (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`) apenas quando um perfil necessário não estiver disponível ou você for explicitamente orientado a usar credenciais de ambiente.

Se o serviço não estiver listado acima, verifique primeiro se há um servidor MCP (`ToolSearch`) e, em seguida, verifique o ambiente (`env | grep -i <service>`).

## Pesquisa de documentação
- Use `CONTEXT7_KEY` para buscar a documentação atual antes de escrever código com bibliotecas externas. Dê preferência a documentos atualizados em vez de conhecimento adquirido em treinamentos.

## Terraform
- Todas as implantações do Terraform utilizam o Terraform Cloud com execuções orientadas por VCS. Avalie o comportamento do Terraform nesse contexto, não na CLI.

## Requisitos do sistema
- Detecte o POP!_OS 24.04 ou o CachyOS Linux. Presuma um ambiente de desktop COSMIC, Wayland. Use a sintaxe do bash.
- No CachyOS (e outros sistemas baseados em Arch), prefira o paru ao yay ao instalar pacotes do AUR ou de repositórios oficiais.
