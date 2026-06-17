# Demo Presentation

Interactive reveal.js presentation for the Container Build Pipeline Demo (UBI vs RHHI).

## Quick Start

**IMPORTANT:** Due to browser CORS restrictions, you MUST use a web server (not just open the HTML file directly).

**Three presentation versions:**
- `index.html` - Full presentation (30 slides, ~60 min, black theme)
- `index-short.html` - Short version (18 slides, 30-45 min, black theme)
- `index-redhat.html` - Red Hat branded (18 slides, 30-45 min, Red Hat theme)

**Method 1: Use the provided script (easiest)**
```bash
cd demo/slides/
./serve.sh          # Start on port 8080
# Then open: http://localhost:8080/index.html (full, black theme)
#        or: http://localhost:8080/index-short.html (short, black theme)
#        or: http://localhost:8080/index-redhat.html (Red Hat branded)
# Press Ctrl+C to stop
```

**Method 2: Python HTTP server**
```bash
cd demo/slides/
python3 -m http.server 8080
# Open: http://localhost:8080
```

**Method 3: Node.js http-server (if installed)**
```bash
cd demo/slides/
npx http-server -p 8080
```

⚠️ **Note:** Opening `index.html` directly (double-click or `open`) will show a blank screen due to CORS blocking the markdown file load.

## Navigation Controls

### Keyboard Shortcuts

| Key | Action |
|-----|--------|
| **→** or **Space** | Next slide |
| **←** | Previous slide |
| **↓** | Down (vertical slides) |
| **↑** | Up (vertical slides) |
| **Home** | First slide |
| **End** | Last slide |
| **Esc** or **O** | Overview mode (see all slides) |
| **S** | Speaker notes (presenter mode) |
| **F** | Fullscreen |
| **?** | Show keyboard shortcuts |

### Mouse Controls

- **Click** arrows in bottom-right corner to navigate
- **Scroll** to move between slides (if enabled)

## Presenter Mode

Press **S** to open speaker notes in a separate window:
- Shows current slide and next slide preview
- Displays speaker notes for each slide
- Shows elapsed time and current time
- Useful for practicing or presenting

## Overview Mode

Press **Esc** or **O** to see all slides at once:
- Navigate by clicking on any slide
- Useful for jumping to specific sections
- Press Esc again to return to presentation mode

## PDF Export

To create a PDF of the presentation:

1. Add `?print-pdf` to the URL: `index.html?print-pdf`
2. Open in Chrome/Chromium
3. Print (Cmd+P)
4. Destination: Save as PDF
5. Layout: Landscape
6. Margins: None
7. Save

## Hosting for Remote Presentations

**Option 1: Local server**
```bash
# From demo/slides/ directory
python3 -m http.server 8080
# Then open: http://localhost:8080
```

**Option 2: GitHub Pages**
```bash
# Already committed to git
# Access via: https://jkirklan.github.io/homelab/demo/slides/
```

**Option 3: Share via Traefik**
- Copy to web server on kvm151
- Add Traefik route
- Access via: https://demo-slides.lab.kubelet.org

## Red Hat Branded Version

**index-redhat.html** uses a custom theme following Red Hat brand standards:

**Features:**
- Red Hat Display font (headings)
- Red Hat Text font (body)
- Red Hat Mono font (code)
- Red Hat color palette (#ee0000 red, black, white)
- Sentence case headings (never Title Case or ALL CAPS)
- Generous white space
- High contrast (WCAG 2.1 AA compliant)

**Style guide:** See `redhat-style-guide.md` for complete brand standards

**Customize:** Edit `redhat-theme.css` to adjust colors, fonts, spacing

## Customization

**Theme:** Edit `index.html` or `index-short.html`:
```html
<!-- Change from black to: white, league, beige, sky, night, serif, simple, solarized -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/reveal.js@5.0.4/dist/theme/black.css">
```

**Transition:** Edit `index.html` transition setting:
```javascript
transition: 'slide',  // none, fade, slide, convex, concave, zoom
```

## Editing Content

The presentation content is in **demo-presentation.md**:
- Markdown format with reveal.js extensions
- Slides separated by `---`
- Vertical slides separated by `--`
- Speaker notes after `Note:`

After editing, refresh the browser to see changes.

## Technical Details

- **Framework:** reveal.js 5.0.4
- **Markdown:** Supports GitHub-flavored markdown
- **Syntax Highlighting:** Monokai theme for code blocks
- **CDN:** All dependencies loaded from jsdelivr CDN (no npm install needed)

## Troubleshooting

**Slides not rendering:**
- Open browser console (F12 or Cmd+Option+I)
- Check for JavaScript errors
- Ensure `demo-presentation.md` is in the same directory as `index.html`

**Images not showing:**
- Check relative paths in markdown (e.g., `architecture/diagram.png`)
- Ensure PNG files exist in the architecture directory

**Presenter mode not working:**
- Allow pop-ups in your browser
- Try opening in a different browser (Chrome/Firefox work best)
