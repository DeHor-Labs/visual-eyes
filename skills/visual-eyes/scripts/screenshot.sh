#!/bin/bash
# Visual Eyes - Screenshot helper
# Uso: ./screenshot.sh [url] [output] [viewport] [timeout]
#
# Exemplos:
#   ./screenshot.sh
#   ./screenshot.sh http://localhost:5173
#   ./screenshot.sh http://localhost:3000 /tmp/minha-tela.png
#   ./screenshot.sh http://localhost:3000 /tmp/minha-tela.png "1920,1080" 3000

URL="${1:-http://localhost:3000}"
OUTPUT="${2:-/tmp/visual-eyes-$(date +%s).png}"
VIEWPORT="${3:-1280,800}"
TIMEOUT="${4:-2000}"

echo "Capturando: $URL"
echo "Viewport:   $VIEWPORT"
echo "Timeout:    ${TIMEOUT}ms"
echo "Saida:      $OUTPUT"

npx playwright screenshot "$URL" "$OUTPUT" \
  --viewport-size "$VIEWPORT" \
  --wait-for-timeout "$TIMEOUT"

if [ $? -eq 0 ]; then
  echo "Screenshot salvo: $OUTPUT"
else
  echo "ERRO: Falha ao capturar screenshot."
  echo ""
  echo "Possiveis causas:"
  echo "  1. Servidor nao esta rodando em $URL"
  echo "  2. Browsers do Playwright nao instalados"
  echo ""
  echo "Para instalar os browsers:"
  echo "  npx playwright install chromium"
  exit 1
fi
