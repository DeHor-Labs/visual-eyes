# Comparing PNGs in CI

The default remains informational: a completed comparison exits 0 even when pixels differ. Existing positional calls still work:

```bash
bash skills/visual-eyes/scripts/compare.sh before.png after.png diff.png 0.1
```

Opt into a regression gate:

```bash
bash skills/visual-eyes/scripts/compare.sh before.png after.png diff.png --fail-on-diff --max-diff-percent 2
```

`--fail-on-diff` defaults to zero allowed changed pixels. `--max-diff-percent` accepts a finite decimal from 0 through 100 and only gates when `--fail-on-diff` is enabled. A percentage exactly equal to the limit passes; a greater percentage fails. The comparison uses unrounded counts, even though the displayed percentage has two decimal places.

The optional positional `threshold` remains pixelmatch's perceptual sensitivity (0 through 1, default 0.1). It determines which pixels count as changed. It is **not** the tolerated percentage of changed pixels. Anti-aliased differences remain excluded (`includeAA: false`). This gate measures pixelmatch differences, not every differing byte or human judgment of layout correctness.

Flags may appear before or after positional arguments. Use `--` before paths beginning with a dash. `--help` / `-h` exits 0 without installing dependencies. Missing/extra positional arguments, unknown options, invalid values, missing files, same input file (including aliases), invalid PNGs, mismatched dimensions, output aliases of inputs and unwritable destinations are errors. The diff directory must already exist.

Exit codes:

| Code | Meaning |
| --- | --- |
| 0 | Informational comparison completed, or CI gate passed |
| 1 | CI gate detected a regression |
| 2 | Invalid arguments, PNG/input/dimension/output/dependency/runtime error |

For a completed comparison, the PNG diff, changed/total pixel counts, displayed percentage and output path are produced **before** exit 1. Upload the PNG and captured stdout from CI even on failure. On errors no new usable diff is promised; an old output may still exist, so trust the exit code rather than file existence. The default path is `/tmp/visual-eyes-diff.png`; supply a unique path for concurrent runs.

Requires Node.js 18+ and npm. The helper installs `pngjs@7.0.0` and `pixelmatch@5.3.0` in `/tmp/visual-eyes-deps` when missing. Prime dependencies before an offline CI run:

```bash
npm install --prefix /tmp/visual-eyes-deps pngjs@7.0.0 pixelmatch@5.3.0 --save=false
node tests/compare.cjs
```

The tests generate deterministic PNGs and exercise equal images, one changed pixel, limits below/above/exactly equal, perceptual sensitivity, default compatibility, dimensions, bad inputs, arguments and help. No browser or screenshots of a live application are needed.
