# Contribuir

## Como ajudar

- **Issues**: [github.com/nikolasdehor/visual-eyes/issues](https://github.com/nikolasdehor/visual-eyes/issues)
- **Pull requests**: fork, branch, PR
- **Casos de uso**: compartilhe como você usa a skill
- **Skills novas**: ideias que se beneficiem do Playwright + IA

## Estrutura do repo

```
visual-eyes/
├── skills/visual-eyes/SKILL.md   # a skill em si (markdown)
├── install.sh                    # instala em ~/.claude/skills/
├── uninstall.sh                  # remove
├── tests/
│   ├── sanity.sh                 # smoke test pos-install
│   └── validate.sh               # valida estrutura da skill
├── docs/                         # site mkdocs
└── assets/                       # banner, gifs
```

## Setup dev

```bash
git clone https://github.com/nikolasdehor/visual-eyes
cd visual-eyes
./install.sh --scope=project
```

## Testar

```bash
./tests/sanity.sh
./tests/validate.sh
```

## Adicionar comando à skill

Edite `skills/visual-eyes/SKILL.md`, descreva o novo comportamento na seção apropriada, dê exemplo. A skill é puramente declarativa: você documenta como o Claude deve usar Playwright, e ele segue.

## Padrões

- Markdown limpo
- Bash POSIX em scripts
- Sem dependências runtime extras (Playwright já é o suficiente)
- Mensagens de commit em imperativo, sem AI footers
- Português pt-BR com acentos corretos em docs
