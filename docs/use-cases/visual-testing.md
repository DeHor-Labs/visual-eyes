# Testing visual

Use o Visual Eyes para testes visuais automatizados, especialmente para detectar regressões em UI.

## Cenário típico

Você fez um refactor de CSS. Quer garantir que nada quebrou visualmente em 5 páginas-chave do app.

## Fluxo manual (em conversa com Claude)

> "Tira screenshot das seguintes URLs em http://localhost:3000:
> - /
> - /pricing
> - /docs
> - /login
> - /dashboard
> 
> Em viewports mobile (375x812), tablet (768x1024) e desktop (1280x720).
> 
> Salva tudo em screenshots/baseline/"

Claude executa, salva 15 imagens.

Depois do refactor:

> "Tira novamente, salva em screenshots/after/. Compara com baseline/ e me diz o que mudou visualmente."

Claude compara, lista diferenças com severidade (cosmética, layout quebrado, conteúdo cortado).

## Em CI

Crie um teste E2E que dispara o Claude com o prompt acima quando necessário, ou faça a comparação direta com Playwright + pixel-match.

Veja `tests/sanity.sh` no repo para um exemplo simples.

## Antipadrões

- **Não use** Visual Eyes pra testes determinísticos que você executa em todo CI (muito caro em latência)
- **Use** para investigação manual de bugs visuais ou validação pontual antes de release

Para testes determinísticos contínuos, prefira ferramentas dedicadas como Percy, Chromatic ou loki.
