# Instalação

## Pré-requisitos

- **Claude Code** instalado ([docs](https://docs.claude.com/en/docs/claude-code))
- **Node.js 18+** (para o helper `visual-eyes-install`)
- **Playwright** (instala automaticamente na primeira execução)

## Métodos

=== "npm / npx (recomendado)"

    ```bash
    # Instala globalmente no Claude Code (todos os projetos)
    npx visual-eyes-install --scope=user

    # Ou apenas no projeto atual
    npx visual-eyes-install --scope=project
    ```

=== "Clone manual"

    ```bash
    git clone https://github.com/nikolasdehor/visual-eyes
    cd visual-eyes
    ./install.sh --scope=user      # ou --scope=project
    ```

=== "Direto do repo"

    Adicione `~/.claude/skills/visual-eyes/SKILL.md` apontando para o conteúdo da skill.

## Verificar instalação

No Claude Code:

```
/skills
```

Você deve ver `visual-eyes` listada.

Ou pergunte direto ao Claude:

> "Você tem a skill visual-eyes disponível?"

## Desinstalar

```bash
./uninstall.sh --scope=user
# ou
./uninstall.sh --scope=project
```

## Próximos passos

- [Quickstart](quickstart.md)
- [Configuração](config.md)
