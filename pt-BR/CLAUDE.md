---
name: formatação-e-comportamento
description: Regras globais de comportamento, geração e formatação
alwaysApply: true
---
## Comportamento
- Nunca use emojis.
- Respostas factuais e precisas, com contexto mínimo, mas suficiente, de nível especializado.
- Se não houver resposta correta, diga isso. Nunca invente ou especule; em vez disso, faça perguntas para esclarecer.

## Geração
- Escreva código apenas quando tiver pelo menos 95% de confiança nos requisitos. Se estiver abaixo de 95%, indique o nível de confiança e faça perguntas esclarecedoras.
- O código deve estar correto, seguro e totalmente funcional com todas as importações necessárias.
- Priorize a legibilidade. Observe as considerações de segurança ou eficiência.

## Formatação
- Não quebre linhas, a menos que excedam 120 caracteres.
- Nunca remova comentários embutidos existentes.
- Adicione comentários apenas quando o código não for óbvio para um especialista. Use frases completas, em maiúsculas e com ponto final. Um espaço entre o código e o comentário. Não use emojis, formatação ASCII, setas ou espaços extras nos comentários.

## Programação
- Use yarn e uv, não npm e pip.
- Para alterações substanciais (não linhas únicas triviais), antes de escrever o código-fonte:
  1. Declare como você verificará se a alteração funciona (teste, comando bash, verificação do navegador, etc.)
  2. Escreva primeiro a etapa de teste ou verificação
  3. Implemente o código
  4. Execute a verificação e repita até que ela seja aprovada

## Sistemas externos — OBRIGATÓRIO

Antes de QUALQUER interação com um serviço ou API de terceiros:
1. Verifique o ambiente do shell para obter as credenciais necessárias e use-as. NUNCA pule esta etapa.
2. NUNCA tente solicitações não autenticadas, login baseado em navegador, URLs públicas, fluxos OAuth ou solicite ao usuário credenciais disponíveis no ambiente.
3. Se uma variável necessária não estiver definida, informe isso e pare.

Variáveis de ambiente — use-as para seus respectivos serviços:

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

Regras gerais:
- Presuma que todas as versões dos serviços são hospedadas na nuvem, a menos que seja informado o contrário.
- Use a versão mais recente e estável da API. Use o Context7 (`CONTEXT7_KEY`) para confirmar as versões e o uso da API antes de fazer chamadas.
- Sempre lide com a paginação. Nunca presuma que uma única resposta contém todos os resultados.

Autenticação:
- Jira / Confluence: Autenticação HTTP básica com o `*_EMAIL` específico do serviço como nome de usuário e `*_API_TOKEN` como senha. Use `*_BASE_URL` como host — nunca construa URLs do zero.
- GitHub: prefira `gh` CLI para todas as operações. Recorra à API bruta com `GITHUB_PAT` como token Bearer somente quando `gh` não puder realizar a tarefa.
- SonarQube: `SONAR_TOKEN` como token Bearer.
- Auth0: ID do cliente, segredo do cliente e domínio para o ambiente apropriado (sb/dev/prod).

Se o serviço não estiver listado acima, verifique o ambiente de qualquer maneira (`env | grep -i <service>`).

## Pesquisa de documentação
- Use `CONTEXT7_KEY` para obter a documentação atual antes de escrever código com bibliotecas externas. Dê preferência a documentos atualizados em vez de conhecimento de treinamento.

## Requisitos do sistema
- POP!_OS 24.04 Linux, desktop COSMIC, Wayland. Use sintaxe bash.
