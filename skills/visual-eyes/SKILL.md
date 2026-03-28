---
name: visual-eyes
description: >
  Give Claude Code eyes to see and analyze running web applications.
  Use when: user asks for a screenshot, mentions a visual bug, broken layout,
  "how does it look", "take a screenshot", "visual regression", "compare before
  and after", "test the UI", "show me the screen", or any reference to the
  visual appearance of a running app.
---

# Visual Eyes - Eyes for Web Applications

This skill lets Claude see locally running web applications, identify visual
problems, and fix the code automatically.

**Available tools in `scripts/`:**
- `scripts/screenshot.sh` - Capture a screenshot of a URL
- `scripts/compare.sh` - Compare two screenshots and generate a visual diff

The scripts live inside the skill directory. Resolve the path at runtime:

```bash
SKILL_DIR="$HOME/.claude/skills/visual-eyes"
```

**ALWAYS run scripts with the correct arguments.** See the usage sections below.

---

## Main Flow: See -> Analyze -> Fix -> Verify

```
1. Capture a screenshot of the application
2. Read the PNG file with the Read tool (multimodal vision)
3. Identify visual problems
4. Fix the code
5. Capture a new screenshot
6. Compare visually - is it correct now?
7. Iterate until it looks right
```

---

## CAPTURE MODE - Taking Screenshots

### Basic screenshot (desktop 1280x800)

```bash
bash "$HOME/.claude/skills/visual-eyes/scripts/screenshot.sh" \
  "http://localhost:3000" \
  "/tmp/visual-eyes-capture.png"
```

### Mobile screenshot (iPhone)

```bash
npx playwright screenshot "http://localhost:3000" "/tmp/visual-eyes-mobile.png" \
  --viewport-size "390,844" \
  --wait-for-timeout 2000
```

### Full-page screenshot (full scroll)

```bash
npx playwright screenshot "http://localhost:3000" "/tmp/visual-eyes-full.png" \
  --viewport-size "1280,800" \
  --full-page \
  --wait-for-timeout 2000
```

### Screenshot of a specific route

Replace the URL with `$ARGUMENTS` when the user provides a custom route or URL.
Examples: `/dashboard`, `http://localhost:5173/settings`, `http://localhost:8000`

Default URL: `http://localhost:3000` when the user does not specify one.

### Sweep multiple routes at once

```bash
for ROUTE in "/" "/dashboard" "/settings" "/profile"; do
  SLUG=$(echo "$ROUTE" | tr '/' '-')
  npx playwright screenshot "http://localhost:3000${ROUTE}" \
    "/tmp/visual-eyes${SLUG}.png" \
    --viewport-size "1280,800" \
    --wait-for-timeout 2000
  echo "Captured: /tmp/visual-eyes${SLUG}.png"
done
```

Then use the Read tool on each PNG file to analyze it visually.

---

## ANALYSIS MODE - What to check when viewing a screenshot

When you read a PNG with the Read tool, check the following:

### Layout and structure
- Overlapping elements or elements out of position
- Broken grids/flexbox (misaligned columns, items outside container)
- Inconsistent margins and paddings
- Elements clipped by the viewport

### Typography
- Text truncated with unexpected ellipsis
- Text overflowing the container
- Font size inappropriate for the context
- Inconsistent visual hierarchy (h1 smaller than h2, etc.)

### Colors and contrast
- Low-contrast text on background (hard to read)
- Wrong colors (primary button with secondary color)
- Elements missing color when they should have it

### Responsiveness
- Elements going off-screen on mobile
- Buttons too small for touch (< 44px)
- Unreadable text on small screens

### Loading state
- Blank areas where content should be
- Stuck spinners/skeletons
- Visible error messages
- Mock data still appearing in production

### Alignment and spacing
- Inconsistent spacing between similar sections
- Elements misaligned with each other
- Accidentally zeroed padding/margin

---

## FIX MODE - Automatic fix loop

When you identify a visual problem:

1. Note the specific issue (e.g., "header overlapping main content by 20px")
2. Locate the responsible component or CSS file
3. Apply the fix
4. Capture a new screenshot with a different name:

```bash
bash "$HOME/.claude/skills/visual-eyes/scripts/screenshot.sh" \
  "http://localhost:3000" \
  "/tmp/visual-eyes-after-fix.png"
```

5. Read the new PNG with Read and verify visually
6. If there is still a problem, repeat the cycle
7. Show before and after to the user

---

## COMPARE MODE - Visual regression

Use when the user wants to compare the state before and after a change.

### Save baseline before modifying

```bash
cp /tmp/visual-eyes-capture.png /tmp/visual-eyes-baseline.png
```

### Take screenshot after changes

```bash
bash "$HOME/.claude/skills/visual-eyes/scripts/screenshot.sh" \
  "http://localhost:3000" \
  "/tmp/visual-eyes-after.png"
```

### Generate diff image (red pixels = differences)

```bash
bash "$HOME/.claude/skills/visual-eyes/scripts/compare.sh" \
  "/tmp/visual-eyes-baseline.png" \
  "/tmp/visual-eyes-after.png" \
  "/tmp/visual-eyes-diff.png"
```

Then use Read on `/tmp/visual-eyes-diff.png` to see exactly what changed.
Red pixels indicate modified areas. More red means bigger difference.

---

## RESPONSIVE MODE - Desktop and Mobile side by side

To check full responsive behavior:

```bash
# Desktop
npx playwright screenshot "http://localhost:3000" "/tmp/visual-eyes-desktop.png" \
  --viewport-size "1280,800" --wait-for-timeout 2000

# Tablet
npx playwright screenshot "http://localhost:3000" "/tmp/visual-eyes-tablet.png" \
  --viewport-size "768,1024" --wait-for-timeout 2000

# Mobile
npx playwright screenshot "http://localhost:3000" "/tmp/visual-eyes-mobile.png" \
  --viewport-size "390,844" --wait-for-timeout 2000
```

Read all three PNGs with Read and compare the layout at each size.

---

## Error handling

### Server is not running

If the screenshot fails with a connection error, inform the user:
"The server is not running at localhost:3000. Please start the server first."

Suggestions for how to start it (try to identify from the project):
- React/Vite: `npm run dev`
- Next.js: `npm run dev`
- FastAPI: `uvicorn main:app --reload`
- Django: `python manage.py runserver`

### Playwright browsers not installed

If the error is about missing browsers:

```bash
npx playwright install chromium
```

Wait for installation and try the screenshot again.

### Page loading async data

If the page appears blank or shows a loading spinner, increase the timeout:

```bash
npx playwright screenshot "http://localhost:3000" "/tmp/visual-eyes-capture.png" \
  --viewport-size "1280,800" \
  --wait-for-timeout 5000
```

For pages with authentication or complex state, use Python with Playwright:

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
    print("Screenshot saved: /tmp/visual-eyes-capture.png")
```

---

## File naming conventions

All temporary files live in `/tmp/visual-eyes-*` to avoid polluting the project.

| File | Use |
|---|---|
| `/tmp/visual-eyes-capture.png` | Current main screenshot |
| `/tmp/visual-eyes-baseline.png` | Baseline for comparison |
| `/tmp/visual-eyes-after.png` | After modifications |
| `/tmp/visual-eyes-diff.png` | Visual regression diff |
| `/tmp/visual-eyes-desktop.png` | Desktop 1280x800 |
| `/tmp/visual-eyes-tablet.png` | Tablet 768x1024 |
| `/tmp/visual-eyes-mobile.png` | Mobile iPhone |
| `/tmp/visual-eyes-full.png` | Full page (scroll) |
| `/tmp/visual-eyes-{route}.png` | Specific routes |

---

## Example phrases that activate this skill

- "screenshot the homepage"
- "how does the dashboard look?"
- "there's a visual bug in the header"
- "the layout is broken on mobile"
- "screenshot localhost"
- "compare before and after my change"
- "run a visual regression test"
- "the sidebar is overlapping the content"
- "show me how the screen looks"
- "capture the app screen"
- "test the component visually"
