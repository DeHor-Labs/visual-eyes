# Copilot Instructions — visual-eyes

## Project Overview
visual-eyes é uma ferramenta de visual regression / E2E testing baseada em Node.js + TypeScript + Playwright.

## Stack
- **Node.js + TypeScript** estrito
- **Playwright** para automação e visual regression
- CLI / biblioteca consumível

## Conventions
- TypeScript estrito (`strict: true`)
- Sem `any` implícito
- Testes Playwright isolados (sem dependência de ordem)
- Selectors estáveis (`data-testid` > CSS frágil)
- Sem `console.log` em código de release; usar logger ou Playwright reporter
- Variáveis sensíveis via env, nunca hardcoded
- Page Object Model para flows complexos

## Folder Structure
- `src/` — código da ferramenta
- `tests/` ou `e2e/` — specs Playwright
- `playwright.config.ts` — config

## Development
- `pnpm install`
- `pnpm test` — roda Playwright
- `pnpm test:ui` — modo UI
- `pnpm build`

## Critical Files
- `package.json`
- `playwright.config.ts`
- `src/index.ts` — entry
- `tests/` — specs
