# Generate PDF or PPTX from Reveal.js Presentation

The presentation is served at: http://kvm152.lab.kubelet.org:8888/

## Method 1: Marp CLI (Recommended - PDF or PPTX)

**Fastest and most reliable method** - converts markdown directly to PDF or PowerPoint.

```bash
cd demo/slides

# Install marp-cli (one-time)
brew install marp-cli
# or: npm install -g @marp-team/marp-cli

# Generate PDF
marp demo-presentation.md --pdf --allow-local-files -o demo-presentation.pdf

# Generate PowerPoint
marp demo-presentation.md --pptx --allow-local-files -o demo-presentation.pptx
```

**Output:**
- PDF: ~456KB, high quality, single file
- PPTX: Editable PowerPoint format

**Note:** Marp works offline, no web server needed.

## Method 2: Browser Print to PDF

1. Open the presentation in Chrome/Edge/Safari:
   ```
   http://kvm152.lab.kubelet.org:8888/
   ```

2. Add `?print-pdf` to the URL:
   ```
   http://kvm152.lab.kubelet.org:8888/?print-pdf
   ```

3. Press **Cmd+P** (or File > Print)

4. Select "Save as PDF" as destination

5. Enable "Background graphics" in print options

6. Save to `demo/slides/demo-presentation.pdf`

## Method 3: Use decktape (if Chrome is properly installed)

```bash
cd demo/slides
npm install -g decktape
decktape reveal http://kvm152.lab.kubelet.org:8888/ demo-presentation.pdf --size 1920x1080
```

Note: Requires Chrome/Chromium to be installed for Puppeteer.

## Alternative: Local Server

If kvm152 is not accessible:

```bash
cd demo/slides
python3 -m http.server 8000
# Then open http://localhost:8000/?print-pdf
```
