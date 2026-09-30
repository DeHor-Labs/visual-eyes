const assert = require('assert');
const fs = require('fs');
const os = require('os');
const path = require('path');
const {spawnSync} = require('child_process');
const {PNG} = require('/tmp/visual-eyes-deps/node_modules/pngjs');
const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'visual-eyes-test-'));
const script = process.env.COMPARE_SCRIPT || path.resolve(__dirname, '../skills/visual-eyes/scripts/compare.sh');
/** Write an opaque white PNG fixture with the requested number of black pixels.
 * @returns {string} Path to the generated input image.
 */
function png(name, changed=0, width=10) {
  const p = new PNG({width, height:10});
  p.data.fill(255);
  for(let i=0;i<changed;i++) {p.data[i*4]=0;p.data[i*4+1]=0;p.data[i*4+2]=0;}
  const file = path.join(dir,name);fs.writeFileSync(file,PNG.sync.write(p));return file;
}
const before = png('before.png');
const equal = png('equal.png');
const one = png('one.png',1);
const two = png('two.png',2);
const three = png('three.png',3);
let failures = 0;
/** Run a named assertion group and record failures without stopping later cases. */
function test(name, fn) {try {fn(); console.log('PASS '+name);}catch(e){failures++;console.log('FAIL '+name+': '+e.message);}}
/** Compare a fixture against the baseline and assert the expected exit code.
 * Removes any previous diff so artifact assertions reflect only this invocation.
 * @returns {{r: object, diff: string}} Process result and expected diff path.
 */
function run(after, options=[], code=0) {
  const diff = path.join(dir,'diff.png');fs.rmSync(diff,{force:true});
  const r = spawnSync('bash',[script,before,after,diff,...options],{encoding:'utf8'});
  assert.equal(r.status,code,r.stdout+r.stderr);return {r,diff};
}
test('equal CI',()=>run(equal,['--fail-on-diff']));
test('one pixel default remains informational',()=>run(one));
test('one pixel CI regression creates PNG and metrics',()=>{const {r,diff}=run(one,['--fail-on-diff'],1);assert(fs.existsSync(diff));assert(r.stdout.includes('1 / 100'));assert(r.stdout.includes('Diff salvo:'));});
test('below 2 percent',()=>run(one,['--fail-on-diff','--max-diff-percent','2']));
test('exact 2 percent',()=>run(two,['--fail-on-diff','--max-diff-percent','2']));
test('above 2 percent',()=>run(three,['--fail-on-diff','--max-diff-percent','2'],1));
test('perceptual threshold distinct',()=>{
  run(one,['1','--fail-on-diff','--max-diff-percent','0']);
  run(one,['0.1','--fail-on-diff','--max-diff-percent','0'],1);
});
test('dimension mismatch',()=>run(png('size.png',0,11),[],2));
test('invalid PNG',()=>{const f=path.join(dir,'bad.png');fs.writeFileSync(f,'bad');run(f,[],2);});
test('missing input',()=>run(path.join(dir,'missing'),[],2));
test('same file',()=>run(before,[],2));
for(const options of [['--bogus'],['--max-diff-percent'],['--max-diff-percent','NaN'],['--max-diff-percent','101'],['--max-diff-percent','-1'],['NaN'],['1.1'],['0.1','extra']]) test('invalid arguments '+options.join(' '),()=>run(equal,options,2));
test('percentage alone stays informational',()=>run(three,['--max-diff-percent','0']));
test('unrounded percentage gates',()=>run(one,['--fail-on-diff','--max-diff-percent','0.999'],1));
test('diff cannot overwrite input',()=>{const r=spawnSync('bash',[script,before,equal,before],{encoding:'utf8'});assert.equal(r.status,2);assert(PNG.sync.read(fs.readFileSync(before)));});
test('flags before positional inputs',()=>{const r=spawnSync('bash',[script,'--fail-on-diff',before,one,path.join(dir,'early.png')],{encoding:'utf8'});assert.equal(r.status,1);});
test('legacy four positional args',()=>run(one,['0.05']));
test('exact fractional percent avoids floating point error',()=>{
  const r=spawnSync('bash',[script,png('large-before.png',0,1000),png('fraction.png',57,1000),path.join(dir,'fraction-diff.png'),'--fail-on-diff','--max-diff-percent','0.57'],{encoding:'utf8'});
  assert.equal(r.status,0,r.stdout+r.stderr);
});
test('help without dependencies',()=>{const r=spawnSync('bash',[script,'--help'],{encoding:'utf8'});assert.equal(r.status,0);assert(r.stdout.includes('--fail-on-diff'));assert(r.stdout.includes('--max-diff-percent'));});
fs.rmSync(dir,{recursive:true,force:true});process.exitCode=failures?1:0;
