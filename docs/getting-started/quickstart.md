# Quickstart

## 1. Rode sua app

```bash
cd ~/projects/meu-app
npm run dev  # ou pnpm, yarn, qualquer servidor local
```

App escutando em `http://localhost:3000` (porta padrão).

## 2. Abra Claude Code no mesmo terminal

```bash
claude
```

## 3. Peça pro Claude usar a skill

> "Use a skill visual-eyes pra ver minha app em http://localhost:3000 e me diz o que melhorar no layout"

O Claude vai:

1. Ler `~/.claude/skills/visual-eyes/SKILL.md`
2. Spawnar Playwright (Chromium em modo headless)
3. Navegar para a URL
4. Tirar screenshot
5. Analisar visualmente
6. Sugerir mudanças

## 4. Aceitar mudanças e iterar

> "Ok, faz isso e tira outra screenshot pra comparar"

Claude aplica, recarrega, screenshota de novo, mostra antes/depois.

## Comandos úteis

Sintaxes naturais que funcionam:

- "Mostra o estado atual"
- "Tira screenshot em viewport mobile (375x812)"
- "Compara antes e depois dessa mudança"
- "Tem algum erro de console na página?"
- "O botão X está visível em scroll?"

## Próximos passos

- [Configuração](config.md) — viewports, timeouts, browser
- [Testing visual](../use-cases/visual-testing.md) — regressão visual em CI
- [Auto-fix de UI](../use-cases/auto-fix.md) — corrigir bugs visuais com 1 prompt
