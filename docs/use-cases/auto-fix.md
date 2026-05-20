# Auto-fix de UI

Use o Visual Eyes para o Claude detectar bugs visuais e propor fixes automaticamente.

## Cenário

> "Tem algo estranho com o cabeçalho no mobile, ele está sobreposto ao conteúdo"

Sem Visual Eyes, o Claude leria o CSS e tentaria adivinhar. Com Visual Eyes:

1. Claude abre o app em viewport mobile
2. Screenshot
3. Analisa: header com `position: fixed` mas conteúdo sem `padding-top` correspondente
4. Edita CSS adicionando padding adequado
5. Screenshot de novo
6. Confirma fix
7. Reporta

## Exemplos de fixes comuns

### Conteúdo cortado em mobile

Causa típica: `overflow: hidden` em container, conteúdo maior que viewport.

> "O texto do banner está cortado no iPhone, conserta"

### Botões empilhados desalinhados

Causa típica: `flex-wrap: wrap` sem gap.

> "Os botões do hero estão saindo um sobre o outro no mobile"

### Imagens distorcidas

Causa típica: ausência de `object-fit: cover`.

> "A foto de perfil tá esticada"

### Z-index conflitando

Causa típica: modais por baixo do header.

> "O modal de login está sumindo atrás do header"

## Loop de iteração

Para casos mais complexos, peça loops:

> "Quero centralizar o card vertical e horizontalmente.
> Itera até ficar certo: faz mudança, screenshot, avalia, se não ficou bom, ajusta."

Claude vai iterar 3-5 vezes até convergir.

## Limitações

- **Não funciona** para apps que exigem login (a menos que você dê credentials no prompt)
- **Sensível a animações**: screenshots durante transições podem ser inconsistentes
- **Custo**: cada iteração consome tokens (load page + screenshot + análise)

Para casos extremos, considere fazer manualmente.
