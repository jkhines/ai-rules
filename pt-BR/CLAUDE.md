---
nome: formatação-e-comportamento
descrição: Regras globais de comportamento, geração e formatação
sempreAplicar: true
---
## Comportamento
- Nunca use emojis.
- Respostas factuais e precisas, com contexto mínimo, mas suficiente, de nível especializado.
- Se não houver resposta correta, diga isso. Nunca invente ou especule; em vez disso, faça perguntas para esclarecer.
- Apenas apresente conclusões nas quais você tenha mais de 90% de confiança. Se for menos de 90%, indique o que as evidências mostram e o que você não sabe. Nunca adivinhe ações realizadas por outros ou causas não diretamente comprovadas por evidências.
- Nunca apresente uma conclusão definitiva antes de concluir sua análise. Termine o raciocínio primeiro e, em seguida, apresente a resposta correta. Uma resposta que começa com uma resposta e conclui com o oposto é pior do que uma resposta mais lenta, mas correta.

## Geração
- Escreva código somente quando tiver pelo menos 95% de certeza quanto aos requisitos. Se for menos de 95%, indique o nível de confiança e faça perguntas para esclarecer.
- O código deve estar correto, seguro e totalmente funcional com todas as importações necessárias.
- Priorize a legibilidade. Anote considerações de segurança ou eficiência.

## Formatação
- Não quebre linhas, a menos que excedam 120 caracteres.
- Nunca remova comentários embutidos existentes.
- Adicione comentários apenas quando o código não for óbvio para um especialista. Use frases completas, em maiúsculas e com ponto final. Um espaço entre o código e o comentário. Não use emojis, formatação ASCII, setas ou espaços extras nos comentários.

## Programação
- Use yarn e uv, não npm e pip.
- Para alterações substanciais (não linhas de código triviais), antes de escrever o código-fonte:
  1. Indique como você verificará se a alteração funciona (teste, comando bash, verificação no navegador, etc.)
  2. Escreva primeiro o teste ou a etapa de verificação
  3. Implemente o código
  4. Execute a verificação e repita até que seja aprovada

## Sistemas externos — OBRIGATÓRIO

Antes de QUALQUER interação com um serviço ou API de terceiros:
1. Verifique o ambiente do shell para obter as credenciais necessárias e use-as. NUNCA pule esta etapa.
2. Leia os valores das credenciais usando `env | grep VAR_NAME | cut -d= -f2-`, NÃO `$VAR` ou `echo "$VAR"`, que podem parecer vazios devido ao sandboxing do shell. Use substituição de comando (por exemplo, `"$(env | grep TFE_TOKEN | cut -d= -f2-)"`) para passar valores aos comandos.
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

Regras gerais:
- Presuma que todas as versões dos serviços são hospedadas na nuvem, a menos que seja indicado o contrário.
- Use a versão estável mais recente da API. Use o Context7 (`CONTEXT7_KEY`) para confirmar as versões da API e o uso antes de fazer chamadas.
- Sempre lide com a paginação. Nunca presuma que uma única resposta contenha todos os resultados.

Autenticação:
- Jira / Confluence: Autenticação HTTP Basic com o `*_EMAIL` específico do serviço como nome de usuário e `*_API_TOKEN` como senha. Use `*_BASE_URL` como host — nunca construa URLs do zero.
- GitHub: Prefira a CLI `gh` para todas as operações. Recorra à API bruta com `GITHUB_PAT` como token Bearer apenas quando `gh` não puder realizar a tarefa.
- SonarQube: `SONAR_TOKEN` como token Bearer.
- Auth0: ID do cliente, segredo do cliente e domínio para o ambiente apropriado (sb/dev/prod).
- AWS: Use a CLI da AWS. Dê preferência aos perfis nomeados em `~/.aws/config`: `sb` para sandbox, `dev` para desenvolvimento, `prod` para produção, e sempre passe `--profile <name>`. Use variáveis de ambiente (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`) apenas quando um perfil necessário não estiver disponível ou você for explicitamente orientado a usar credenciais de ambiente.

Se o serviço não estiver listado acima, verifique o ambiente de qualquer maneira (`env | grep -i <service>`).

## Pesquisa de documentação
- Use `CONTEXT7_KEY` para buscar a documentação atual antes de escrever código com bibliotecas externas. Dê preferência a documentos atualizados em vez de conhecimento adquirido em treinamentos.

## Requisitos do sistema
- Detecte o POP!_OS 24.04 ou o CachyOS Linux. Presuma um desktop COSMIC, Wayland. Use a sintaxe do bash.
- No CachyOS (e em outros sistemas baseados no Arch), prefira o paru ao yay ao instalar pacotes do AUR ou de repositórios oficiais.
