#!/bin/bash
# Visual Eyes - Compare helper
# Uso: ./compare.sh before.png after.png [diff.png] [threshold]
#
# Threshold: 0.0 (exato) a 1.0 (ignora tudo). Padrao: 0.1
#
# Exemplos:
#   ./compare.sh /tmp/visual-eyes-baseline.png /tmp/visual-eyes-after.png
#   ./compare.sh antes.png depois.png /tmp/diff.png 0.05

BEFORE="$1"
AFTER="$2"
DIFF="${3:-/tmp/visual-eyes-diff.png}"
THRESHOLD="${4:-0.1}"

if [ -z "$BEFORE" ] || [ -z "$AFTER" ]; then
  echo "Uso: $0 <antes.png> <depois.png> [diff.png] [threshold]"
  echo ""
  echo "Exemplo:"
  echo "  $0 /tmp/visual-eyes-baseline.png /tmp/visual-eyes-after.png"
  exit 1
fi

if [ ! -f "$BEFORE" ]; then
  echo "ERRO: Arquivo nao encontrado: $BEFORE"
  exit 1
fi

if [ ! -f "$AFTER" ]; then
  echo "ERRO: Arquivo nao encontrado: $AFTER"
  exit 1
fi

if [ "$BEFORE" = "$AFTER" ]; then
  echo "ERRO: Os arquivos de entrada sao o mesmo arquivo."
  exit 1
fi

echo "Comparando:"
echo "  Antes:     $BEFORE"
echo "  Depois:    $AFTER"
echo "  Threshold: $THRESHOLD"
echo "  Diff:      $DIFF"
echo ""

# Use a small Node.js script with the pixelmatch + pngjs packages.
# These packages are installed on demand into a temporary location.
DEPS_DIR="/tmp/visual-eyes-deps"
if [ ! -d "$DEPS_DIR/node_modules/pixelmatch" ] || [ ! -d "$DEPS_DIR/node_modules/pngjs" ]; then
  echo "Instalando dependencias (pngjs, pixelmatch)..."
  mkdir -p "$DEPS_DIR"
  npm install --prefix "$DEPS_DIR" pngjs pixelmatch --save=false --loglevel=error
  if [ $? -ne 0 ]; then
    echo "ERRO: Falha ao instalar dependencias. Verifique sua conexao com a internet."
    exit 1
  fi
fi

node - "$BEFORE" "$AFTER" "$DIFF" "$THRESHOLD" "$DEPS_DIR" <<'NODEJS'
const fs = require("fs");
const path = require("path");

const [, , before, after, diff, threshold, depsDir] = process.argv;
const { PNG } = require(path.join(depsDir, "node_modules", "pngjs"));
const pixelmatch = require(path.join(depsDir, "node_modules", "pixelmatch"));

const img1 = PNG.sync.read(fs.readFileSync(before));
const img2 = PNG.sync.read(fs.readFileSync(after));

if (img1.width !== img2.width || img1.height !== img2.height) {
  console.error(
    "ERRO: As imagens tem tamanhos diferentes. Antes: " + img1.width + "x" + img1.height +
    ", Depois: " + img2.width + "x" + img2.height
  );
  process.exit(1);
}

const { width, height } = img1;
const diffPng = new PNG({ width, height });

const numDiffPixels = pixelmatch(img1.data, img2.data, diffPng.data, width, height, {
  threshold: parseFloat(threshold),
  includeAA: false,
});

fs.writeFileSync(diff, PNG.sync.write(diffPng));

const totalPixels = width * height;
const pctChanged = ((numDiffPixels / totalPixels) * 100).toFixed(2);
console.log("Pixels alterados: " + numDiffPixels + " / " + totalPixels + " (" + pctChanged + "%)");
if (numDiffPixels === 0) {
  console.log("Imagens identicas - nenhuma diferenca encontrada.");
} else {
  console.log("Pixels vermelhos = areas modificadas.");
}
NODEJS

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ] && [ -f "$DIFF" ]; then
  echo ""
  echo "Diff salvo: $DIFF"
  echo "Use a ferramenta Read no arquivo diff para visualizar as diferencas."
else
  echo ""
  echo "ERRO: Falha ao gerar diff. Verifique se os arquivos sao imagens PNG validas."
  exit 1
fi
