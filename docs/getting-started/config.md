# Configuração

A skill funciona com defaults razoáveis. Para customizar, edite a configuração local.

## Localização

- Skill instalada globalmente: `~/.claude/skills/visual-eyes/`
- Skill instalada no projeto: `.claude/skills/visual-eyes/`

## Variáveis de ambiente

| Variável | Default | Descrição |
|----------|---------|-----------|
| `VISUAL_EYES_BROWSER` | `chromium` | `chromium`, `firefox` ou `webkit` |
| `VISUAL_EYES_HEADLESS` | `true` | `false` para mostrar a janela |
| `VISUAL_EYES_TIMEOUT` | `30000` | Timeout em ms para load |
| `VISUAL_EYES_VIEWPORT` | `1280x720` | Viewport default |
| `VISUAL_EYES_USER_AGENT` | (Playwright default) | UA customizado |
| `VISUAL_EYES_SCREENSHOTS_DIR` | `./screenshots` | Onde salvar |

Exemplo `.env`:

```bash
VISUAL_EYES_BROWSER=firefox
VISUAL_EYES_HEADLESS=false
VISUAL_EYES_VIEWPORT=375x812
```

## Viewports comuns

| Nome | Dimensão | Uso |
|------|----------|-----|
| iPhone SE | 375x667 | Mobile pequeno |
| iPhone 12 | 390x844 | Mobile padrão |
| iPad | 768x1024 | Tablet portrait |
| Desktop HD | 1280x720 | Desktop padrão |
| Desktop FHD | 1920x1080 | Desktop grande |
| Ultrawide | 2560x1080 | Monitor ultrawide |

Use no prompt:

> "Tira screenshot em viewport iPhone SE"

## Dependências

A primeira execução baixa o Chromium do Playwright (~150 MB). Após isso, fica em cache em `~/.cache/ms-playwright/`.

## Browser alternativo

Se preferir Firefox ou WebKit:

```bash
VISUAL_EYES_BROWSER=firefox npx playwright install firefox
```

E configure a variável.

## Em CI

Para usar em GitHub Actions, instale dependências do Playwright:

```yaml
- name: Setup Playwright
  run: npx playwright install --with-deps chromium
```
