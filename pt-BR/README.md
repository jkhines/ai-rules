# Regras de IA

Regras e comandos personalizados para assistentes de codificação de IA, incluindo Claude Code, Cursor e ChatGPT.

## Conteúdo

### Regras globais
- **CLAUDE.md** - Regras globais de comportamento, geração e formatação para Claude Code. Aplicadas automaticamente a todas as interações.
  - Observação: essas configurações também podem ser copiadas e coladas no Cursor IDE para serem aplicadas globalmente.
- **CHATGPT.md** - Regras concisas para o ChatGPT, enfatizando respostas diretas e breves.

### Comandos
- **commands/ask-questions.md** - `/ask-questions`: Análise sistemática de problemas e otimização do caminho para a solução.
- **commands/code-review.md** - `/code-review`: Analisa as alterações entre dois ramos com feedback priorizado.
- **commands/commit-push.md** - `/commit-push`: Confirma e envia alterações seguindo o Conventional Commits v1.0.0.
- **commands/feature-branch.md** - `/feature-branch`: Cria e verifica um branch de recurso Git a partir do título de um ticket.
- **commands/pull-request.md** - `/pull-request`: Cria um PR com resumo, plano de teste e contexto vinculado.
- **commands/spawn.md** - `/spawn`: Executa tarefas delegadas paralelas ao modelo com saídas de arquivo rígidas e implementação de correção opcional.

---

## Instruções de configuração

### Claude Code

O [Claude Code](https://docs.anthropic.com/en/docs/claude-code) lê a configuração do diretório `~/.claude/`. Use links simbólicos para manter as regras sincronizadas com este repositório.

```bash
# Clone o repositório
git clone https://github.com/jkhines/ai-rules.git ~/src/ai-rules

# Crie o diretório de configuração do Claude, se ele não existir
mkdir -p ~/.claude

# Link simbólico para regras globais
ln -s ~/src/ai-rules/CLAUDE.md ~/.claude/CLAUDE.md

# Link simbólico para o diretório de comandos
ln -s ~/src/ai-rules/commands ~/.claude/commands
```

Após a configuração, o Claude Code carrega automaticamente o `CLAUDE.md` em todas as conversas e disponibiliza os comandos através de `/ask-questions`, `/code-review`, `/commit-push`, `/feature-branch`, `/pull-request` e `/spawn`.

### Cursor

O [Cursor](https://cursor.com/) utiliza uma estrutura semelhante à do Claude Code:
- **As regras globais** são definidas no IDE: `Configurações do Cursor &gt; Geral &gt; Regras para IA`
- **As regras do projeto** ficam em `.cursor/rules/` dentro de cada projeto (formato `.mdc`)
- **Os comandos de barra** ficam em `.cursor/commands/` dentro de cada projeto (formato `.md`)

Para usar essas regras no Cursor:

1. **Para regras globais**: abra `Configurações do Cursor &gt; Geral &gt; Regras para IA` e cole o conteúdo de `CLAUDE.md`

2. **Para comandos de barra**: se o link simbólico ~/.cursor/commands tiver sido definido, os comandos de barra serão importados para o IDE do Cursor e o cursor-agent.

```bash
# Comandos symlink para suporte a comandos de barra (/ask-questions, /code-review, /commit-push, /feature-branch, /pull-request, /spawn)
ln -s ~/src/ai-rules/commands ~/.cursor/commands
```

Após a configuração, invoque os comandos no chat do Cursor com `/ask-questions`, `/code-review`, `/commit-push`, `/feature-branch`, `/pull-request` ou `/spawn`.

### ChatGPT

O [ChatGPT](https://chat.openai.com/) não suporta configuração baseada em arquivo. Em vez disso, copie as regras para a configuração Custom Instructions (Instruções personalizadas):

1. Abra o ChatGPT e vá para `Configurações &gt; Personalização &gt; Personalizar ChatGPT`
2. Certifique-se de que a opção “Habilitar personalização” esteja ativada
3. Cole o conteúdo de `CHATGPT.md` no campo Instruções personalizadas
4. As instruções se aplicam a todas as novas conversas (limite de 1.500 caracteres)

---

## Mantendo as regras atualizadas

Com links simbólicos, baixar atualizações deste repositório atualiza automaticamente suas configurações do Claude Code e do Cursor:

```bash
cd ~/src/ai-rules
git pull
```

---

## Licença

Este trabalho é dedicado ao domínio público sob CC0 1.0 Universal.

