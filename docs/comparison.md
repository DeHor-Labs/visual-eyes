# Comparativo

Como o Visual Eyes se compara a outras soluções.

## Visual Eyes vs ferramentas de testing visual tradicionais

| Aspecto | Visual Eyes | Percy / Chromatic / Loki |
|---------|------------|---------------------------|
| Foco | Iteração com IA durante desenvolvimento | Regressão visual em CI |
| Custo | $0 (local) | SaaS pago |
| Comparação | IA analisa contextualmente | Pixel-diff matemático |
| Decisão | "esse layout faz sentido?" | "essa imagem mudou X pixels?" |
| Quando usar | Quando você tá codando e quer ver | Quando você quer detectar regressões em PR |

**Não são substitutos, são complementares.** Use Visual Eyes para desenvolvimento iterativo, Percy/Chromatic para CI de regressão.

## Visual Eyes vs DOM inspection (acessibilidade ferramentas)

| Aspecto | Visual Eyes | axe-core / Lighthouse |
|---------|------------|----------------------|
| Granularidade | Aspecto visual + contexto | Específico (WCAG checks) |
| Velocidade | Lento (screenshot + análise) | Rápido (~segundos) |
| Cobertura | Casos não automatizáveis | WCAG bem definido |
| Iteração | Ótima (loop natural com IA) | Ruim (precisa de outro fix manual) |

Use ambos: axe-core em CI para o que é determinístico, Visual Eyes em dev para o resto.

## Visual Eyes vs MCP Playwright

A Anthropic publicou um MCP server oficial de Playwright. Diferenças:

| Aspecto | Visual Eyes (skill) | MCP Playwright |
|---------|--------------------|-----------------| 
| Setup | `npx visual-eyes-install` | Editar JSON do config |
| Filosofia | Skill markdown reutilizável | Tools MCP genéricas |
| Curva de aprendizado | Baixa (prompts em PT-BR) | Média (tools individuais) |
| Cobertura | Foco em testing/auto-fix | Generic browser automation |

Se você quer **só dar olhos ao Claude**, use Visual Eyes. Se quer **automação de browser completa via MCP**, use o MCP server da Anthropic.

## Por que skill em vez de MCP server?

Skills são markdown — leves, versionáveis, fáceis de modificar. Não exigem processo separado rodando. Quando o Claude precisa, lê o arquivo e age. Funciona perfeitamente para casos como visual testing onde o "comportamento" é mais sobre **quando usar Playwright** do que sobre **operações novas**.
