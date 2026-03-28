---
name: visual-eyes
description: >
  Dar olhos ao Claude Code para ver e analisar aplicacoes web rodando.
  Use quando: usuario pedir screenshot, mencionar bug visual, layout quebrado,
  "como esta ficando", "olha a tela", "tem algo errado no UI", "visual regression",
  "compara antes e depois", "testa visual", "como ta o design", "screenshot",
  "captura a tela", "mostra como ta", ou qualquer referencia a aparencia visual.
---

# Visual Eyes - Olhos para Aplicacoes Web

Esta skill permite que o Claude veja aplicacoes web rodando localmente, identifique
problemas visuais e corrija o codigo automaticamente.

**Ferramentas disponiveis em `scripts/`:**
- `scripts/screenshot.sh` - Captura screenshot de uma URL
- `scripts/compare.sh` - Compara dois screenshots e gera diff visual

**SEMPRE execute scripts com os argumentos corretos.** Leia a secao de uso abaixo.

---

## Fluxo Principal: Ver -> Analisar -> Corrigir -> Verificar

```
1. Captura screenshot da aplicacao
2. Le o arquivo PNG com a ferramenta Read (visao multimodal)
3. Identifica problemas visuais
4. Corrige o codigo
5. Captura novo screenshot
6. Compara visualmente - esta correto?
7. Itera ate ficar certo
```

---

## MODO CAPTURA - Tirar Screenshots

### Screenshot basico (desktop 1280x800)

```bash
bash /Users/nikolas/.claude/skills/visual-eyes/scripts/screenshot.sh \
  "http://localhost:3000" \
  "/tmp/visual-eyes-capture.png"
```

### Screenshot mobile (iPhone)

```bash
# Usa viewport manual (funciona com Chromium, sem precisar instalar WebKit)
npx playwright screenshot "http://localhost:3000" "/tmp/visual-eyes-mobile.png" \
  --viewport-size "390,844" \
  --wait-for-timeout 2000
```

### Screenshot pagina completa (scroll inteiro)

```bash
npx playwright screenshot "http://localhost:3000" "/tmp/visual-eyes-full.png" \
  --viewport-size "1280,800" \
  --full-page \
  --wait-for-timeout 2000
```

### Screenshot de rota especifica

Substitua a URL pelo $ARGUMENTS se o usuario passar uma rota ou URL personalizada.
Exemplos de $ARGUMENTS: `/dashboard`, `http://localhost:5173/settings`, `http://localhost:8000`

URL padrao: `http://localhost:3000` se o usuario nao especificar nada.

### Varrer multiplas rotas de uma vez

```bash
for ROUTE in "/" "/dashboard" "/settings" "/profile"; do
  SLUG=$(echo "$ROUTE" | tr '/' '-')
  npx playwright screenshot "http://localhost:3000${ROUTE}" \
    "/tmp/visual-eyes${SLUG}.png" \
    --viewport-size "1280,800" \
    --wait-for-timeout 2000
  echo "Capturado: /tmp/visual-eyes${SLUG}.png"
done
```

Depois use a ferramenta Read em cada arquivo PNG para analisar visualmente.

---

## MODO ANALISE - O que verificar ao ver o screenshot

Quando voce le um PNG com a ferramenta Read, analise os seguintes aspectos:

### Layout e estrutura
- Elementos sobrepostos ou fora de posicao
- Grids/flexbox quebrados (colunas desalinhadas, itens fora do container)
- Margens e paddings inconsistentes
- Elementos cortados pelo viewport

### Tipografia
- Texto truncado com ellipsis inesperado
- Overflow de texto saindo do container
- Tamanho de fonte inadequado para o contexto
- Hierarquia visual inconsistente (h1 menor que h2, etc.)

### Cores e contraste
- Texto com baixo contraste sobre fundo (dificulta leitura)
- Cores erradas (botao primario com cor secundaria)
- Elementos sem cor quando deveriam ter

### Responsividade
- Elementos saindo da tela em mobile
- Botoes pequenos demais para toque (< 44px)
- Texto ilegivel em tela pequena

### Estado de carregamento
- Areas em branco onde deveria haver conteudo
- Spinners/skeletons travados
- Mensagens de erro visiveis
- Dados mockados ainda aparecendo em producao

### Alinhamento e espacamento
- Inconsistencia de espacamento entre secoes similares
- Elementos desalinhados entre si
- Padding/margin zerado acidentalmente

---

## MODO CORRECAO - Loop automatico de correcao

Quando identificar um problema visual:

1. Anote o problema especifico (ex: "header sobrepondo o conteudo principal em 20px")
2. Localize o componente ou arquivo CSS responsavel
3. Aplique a correcao
4. Capture novo screenshot com nome diferente:

```bash
bash /Users/nikolas/.claude/skills/visual-eyes/scripts/screenshot.sh \
  "http://localhost:3000" \
  "/tmp/visual-eyes-after-fix.png"
```

5. Leia o novo PNG com Read e verifique visualmente
6. Se ainda houver problema, repita o ciclo
7. Mostre antes e depois para o usuario

---

## MODO COMPARACAO - Regressao visual

Usar quando o usuario quiser comparar o estado antes e depois de uma mudanca.

### Salvar baseline antes de modificar

```bash
cp /tmp/visual-eyes-capture.png /tmp/visual-eyes-baseline.png
```

### Tirar screenshot depois das mudancas

```bash
bash /Users/nikolas/.claude/skills/visual-eyes/scripts/screenshot.sh \
  "http://localhost:3000" \
  "/tmp/visual-eyes-after.png"
```

### Gerar imagem de diff (pixels vermelhos = diferencas)

```bash
bash /Users/nikolas/.claude/skills/visual-eyes/scripts/compare.sh \
  "/tmp/visual-eyes-baseline.png" \
  "/tmp/visual-eyes-after.png" \
  "/tmp/visual-eyes-diff.png"
```

Depois use Read em `/tmp/visual-eyes-diff.png` para ver exatamente o que mudou.
Pixels vermelhos indicam areas modificadas. Quanto mais vermelho, maior a diferenca.

---

## MODO RESPONSIVO - Desktop e Mobile lado a lado

Para verificar comportamento responsivo completo:

```bash
# Desktop
npx playwright screenshot "http://localhost:3000" "/tmp/visual-eyes-desktop.png" \
  --viewport-size "1280,800" --wait-for-timeout 2000

# Tablet
npx playwright screenshot "http://localhost:3000" "/tmp/visual-eyes-tablet.png" \
  --viewport-size "768,1024" --wait-for-timeout 2000

# Mobile (viewport manual, funciona com Chromium)
npx playwright screenshot "http://localhost:3000" "/tmp/visual-eyes-mobile.png" \
  --viewport-size "390,844" --wait-for-timeout 2000
```

Leia os tres PNGs com Read e compare o layout em cada tamanho.

---

## Tratamento de erros

### Servidor nao esta rodando

Se o screenshot falhar com erro de conexao, informe o usuario:
"O servidor nao esta rodando em localhost:3000. Inicie o servidor primeiro."

Sugestoes de como iniciar (tente identificar pelo projeto):
- React/Vite: `npm run dev`
- Next.js: `npm run dev`
- FastAPI: `uvicorn main:app --reload`
- Django: `python manage.py runserver`

### Browsers do Playwright nao instalados

Se o erro for sobre browsers ausentes:

```bash
npx playwright install chromium
```

Aguarde a instalacao e tente o screenshot novamente.

### Pagina carregando dados assincronos

Se a pagina aparecer em branco ou com loading spinner, aumente o timeout:

```bash
npx playwright screenshot "http://localhost:3000" "/tmp/visual-eyes-capture.png" \
  --viewport-size "1280,800" \
  --wait-for-timeout 5000
```

Para paginas com autenticacao ou estado complexo, use Python com Playwright:

```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page(viewport={"width": 1280, "height": 800})
    page.goto("http://localhost:3000")
    page.wait_for_load_state("networkidle")
    page.wait_for_timeout(2000)
    page.screenshot(path="/tmp/visual-eyes-capture.png", full_page=False)
    browser.close()
    print("Screenshot salvo: /tmp/visual-eyes-capture.png")
```

---

## Convencoes de nomes de arquivo

Todos os arquivos temporarios ficam em `/tmp/visual-eyes-*` para nao poluir o projeto.

| Arquivo | Uso |
|---|---|
| `/tmp/visual-eyes-capture.png` | Screenshot principal atual |
| `/tmp/visual-eyes-baseline.png` | Baseline para comparacao |
| `/tmp/visual-eyes-after.png` | Apos modificacoes |
| `/tmp/visual-eyes-diff.png` | Diff de regressao visual |
| `/tmp/visual-eyes-desktop.png` | Desktop 1280x800 |
| `/tmp/visual-eyes-tablet.png` | Tablet 768x1024 |
| `/tmp/visual-eyes-mobile.png` | Mobile iPhone |
| `/tmp/visual-eyes-full.png` | Pagina completa (scroll) |
| `/tmp/visual-eyes-{rota}.png` | Rotas especificas |

---

## Exemplos de frases que ativam esta skill

- "olha como ta ficando o dashboard"
- "tem um bug visual no header"
- "o layout ta quebrado em mobile"
- "screenshot do localhost"
- "como ta o design da pagina de login"
- "compara antes e depois da minha mudanca"
- "faz um visual regression test"
- "a sidebar ta sobrepondoo conteudo"
- "mostra como ta a tela"
- "captura a tela do app"
- "testa o visual do componente"
