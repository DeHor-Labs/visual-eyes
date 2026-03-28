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

echo "Comparando:"
echo "  Antes:     $BEFORE"
echo "  Depois:    $AFTER"
echo "  Threshold: $THRESHOLD"
echo "  Diff:      $DIFF"
echo ""

RESULT=$(npx pixelmatch "$BEFORE" "$AFTER" "$DIFF" "$THRESHOLD" 2>&1)
EXIT_CODE=$?

echo "$RESULT"

if [ $EXIT_CODE -eq 0 ] || [ -f "$DIFF" ]; then
  echo ""
  echo "Diff salvo: $DIFF"
  echo "Pixels vermelhos = areas modificadas"
  echo "Use a ferramenta Read no arquivo diff para visualizar as diferencas."
else
  echo ""
  echo "ERRO: Falha ao gerar diff. Verifique se os arquivos sao imagens PNG validas."
  exit 1
fi
