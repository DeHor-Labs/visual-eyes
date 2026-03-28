# Changelog

## [1.0.0] - 2026-03-28

### Added
- Screenshot capture (desktop, mobile, full-page, multi-route)
- Visual analysis via Claude multimodal vision
- Auto-fix loop (capture -> analyze -> fix -> verify)
- Pixel-level visual regression testing via pixelmatch
- Responsive testing (desktop + mobile viewports)
- One-liner install script (macOS + Linux)
- Plugin manifest for Claude Code marketplace
- Professional landing page at GitHub Pages

### Fixed
- compare.sh rewritten with real Node.js pixelmatch implementation
- screenshot.sh removed invalid --wait-for-selector flag
- SKILL.md translated to English for global marketplace
- Mobile screenshots use viewport size instead of WebKit device
