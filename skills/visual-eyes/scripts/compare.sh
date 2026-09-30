#!/bin/bash
# Informational by default; opt into a CI regression gate with --fail-on-diff.
# Print command syntax, defaults, output behavior, and exit-code semantics.
usage() {
  cat <<'HELP'
Uso: compare.sh [opcoes] <antes.png> <depois.png> [diff.png] [threshold]
  --fail-on-diff             Exit 1 when changed percentage exceeds the limit
  --max-diff-percent NUMBER  Allowed changed pixels, 0..100 percent (default 0)
  -h, --help                Show help
threshold: pixelmatch perceptual sensitivity, 0..1 (default 0.1), NOT a percent.
Default diff: /tmp/visual-eyes-diff.png. Equal to the limit passes.
Exit: 0 comparison passed/informational, 1 CI regression, 2 invalid input/runtime error.
PNG and pixel counts are written before a regression exit. Anti-aliasing is excluded.
Use -- before positional paths beginning with '-'. Requires Node.js and npm.
HELP
}
# Report an argument or runtime error on stderr and terminate with exit code 2.
error() { echo "ERRO: $*" >&2; exit 2; }
FAIL_ON_DIFF=0
MAX_DIFF_PERCENT=0
POSITIONAL=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --fail-on-diff) FAIL_ON_DIFF=1; shift ;;
    --max-diff-percent)
      [ "$#" -ge 2 ] || error "--max-diff-percent exige um valor"
      MAX_DIFF_PERCENT="$2"; shift 2 ;;
    --) shift; POSITIONAL+=("$@"); break ;;
    -*) error "Opcao desconhecida: $1" ;;
    *) POSITIONAL+=("$1"); shift ;;
  esac
done
[ "${#POSITIONAL[@]}" -ge 2 ] && [ "${#POSITIONAL[@]}" -le 4 ] || { usage >&2; exit 2; }
BEFORE="${POSITIONAL[0]}"
AFTER="${POSITIONAL[1]}"
DIFF="${POSITIONAL[2]:-/tmp/visual-eyes-diff.png}"
THRESHOLD="${POSITIONAL[3]:-0.1}"
command -v node >/dev/null || error "Node.js nao encontrado"
# Validate before installing dependencies or writing an artifact.
node - "$BEFORE" "$AFTER" "$DIFF" "$THRESHOLD" "$MAX_DIFF_PERCENT" <<'JS'
const fs = require('fs');
const path = require('path');
const [before,after,diff,threshold,percent] = process.argv.slice(2);
try {
  for (const [value,max,label] of [[threshold,1,'threshold'],[percent,100,'max-diff-percent']]) {
    if (!/^(?:\d+(?:\.\d*)?|\.\d+)$/.test(value) || !Number.isFinite(Number(value)) || Number(value)>max)
      throw new Error(label+' deve ser um numero entre 0 e '+max);
  }
  const identities = [before,after].map(f=>{if(!fs.statSync(f).isFile()) throw new Error('Entrada nao e arquivo: '+f);return fs.statSync(f);});
  if(identities[0].dev===identities[1].dev && identities[0].ino===identities[1].ino) throw new Error('Entradas sao o mesmo arquivo');
  const output = fs.existsSync(diff) ? fs.realpathSync(diff) : path.join(fs.realpathSync(path.dirname(diff)),path.basename(diff));
  if([before,after].some(f=>fs.realpathSync(f)===output)) throw new Error('Diff nao pode sobrescrever uma entrada');
  if(fs.existsSync(diff)) {
    const s=fs.statSync(diff);
    if(identities.some(i=>i.dev===s.dev && i.ino===s.ino)) throw new Error('Diff aponta para uma entrada');
  }
} catch(e) {console.error('ERRO: '+e.message);process.exit(2);}
JS
[ "$?" -eq 0 ] || exit 2
DEPS_DIR="/tmp/visual-eyes-deps"
if [ ! -d "$DEPS_DIR/node_modules/pixelmatch" ] || [ ! -d "$DEPS_DIR/node_modules/pngjs" ]; then
  mkdir -p "$DEPS_DIR" || error "Falha ao criar diretorio de dependencias"
  npm install --prefix "$DEPS_DIR" pngjs@7.0.0 pixelmatch@5.3.0 --save=false --loglevel=error || error "Falha ao instalar dependencias"
fi
node - "$BEFORE" "$AFTER" "$DIFF" "$THRESHOLD" "$DEPS_DIR" "$FAIL_ON_DIFF" "$MAX_DIFF_PERCENT" <<'JS'
const fs = require('fs');
const path = require('path');
const [before,after,diff,threshold,depsDir,fail,limit] = process.argv.slice(2);
try {
  const {PNG} = require(path.join(depsDir,'node_modules','pngjs'));
  const pixelmatch = require(path.join(depsDir,'node_modules','pixelmatch'));
  const a=PNG.sync.read(fs.readFileSync(before)), b=PNG.sync.read(fs.readFileSync(after));
  if(a.width!==b.width || a.height!==b.height) throw new Error('Dimensoes diferentes: '+a.width+'x'+a.height+' / '+b.width+'x'+b.height);
  const output=new PNG({width:a.width,height:a.height});
  const changed=pixelmatch(a.data,b.data,output.data,a.width,a.height,{threshold:Number(threshold),includeAA:false});
  const total=a.width*a.height, percent=changed/total*100;
  fs.writeFileSync(diff,PNG.sync.write(output));
  console.log('Pixels alterados: '+changed+' / '+total+' ('+percent.toFixed(2)+'%)');
  console.log('Threshold perceptual: '+threshold+'; limite percentual: '+limit+'%');
  console.log('Diff salvo: '+diff);
  // Compare unrounded counts; exact equality passes (avoid rounded display decisions).
  // Treat the user-supplied decimal as an exact rational, not binary float.
  const [whole,fraction='']=limit.split('.');
  const scale=10n**BigInt(fraction.length);
  const allowed=BigInt((whole || '0')+fraction);
  const regression=fail==='1' && BigInt(changed)*100n*scale>allowed*BigInt(total);
  console.log(regression ? 'Regressao visual: limite excedido.' : 'Comparacao concluida.');
  process.exitCode=regression?1:0;
} catch(e) {console.error('ERRO: '+e.message);process.exitCode=2;}
JS
exit "$?"
