# Acessibilidade

Use o Visual Eyes para auditoria visual de acessibilidade.

## Verificações comuns

### Contraste

> "Verifica o contraste de cores das partes principais e me lista o que não atinge WCAG AA"

Claude tira screenshot, identifica regiões de texto e fundo, calcula contraste.

### Focus indicators

> "Aperta Tab nos elementos focáveis e me mostra onde o foco fica invisível"

Claude navega via teclado, screenshota cada estado focado.

### Tamanhos de touch target

> "No mobile, marca todos os botões e links com menos de 44x44px"

Útil para iOS Human Interface Guidelines e Material Design.

### Reading order

> "Mostra a ordem de navegação por teclado da página inteira em mobile"

Verifica que faz sentido lógico.

## Limitações

Visual Eyes não substitui ferramentas dedicadas como **axe-core** ou **Lighthouse Accessibility**. Use ele para:

- ✅ Validação visual rápida
- ✅ Iteração em correções
- ✅ Casos onde axe não detecta (exemplo: contraste em imagens de fundo)

Para auditoria completa, combine com axe-core em CI.

## Exemplo de loop

> "Faz uma auditoria de acessibilidade visual do header.
> Liste 3 problemas em ordem de impacto.
> Para cada um, proponha fix e aplique.
> Após aplicar todos, screenshote pra confirmar."
