# Red Hat Presentation Style Guide

Reference for creating brand-compliant presentations following Red Hat standards.

**Source:** https://www.redhat.com/en/about/brand/standards

---

## Color Palette

### Primary Colors

**Red Hat Red (red-50)** - Primary brand color
- Hex: `#ee0000`
- RGB: 238, 0, 0
- Use for: Headlines, accents, emphasis (use sparingly - "pops of red")

**Red Shades:**
- `#fef0f0` (red-05) - Lightest tint
- `#fce3e3` (red-10)
- `#fbc5c5` (red-20)
- `#f9a8a8` (red-30)
- `#f56e6e` (red-40)
- `#ee0000` (red-50) - **Primary Red**
- `#a60000` (red-60)
- `#5f0000` (red-70)
- `#3f0000` (red-80) - Darkest shade

**Neutrals:**
- `#ffffff` (white) - Backgrounds, text on dark
- `#000000` (black) - Body text, headings
- `#f2f2f2` (gray-10) - Light backgrounds
- `#151515` (gray-95) - Dark backgrounds

### Secondary Colors (Use for Accents)

- `#f5921b` (orange-40) - Orange accent
- `#ffcc17` (yellow-30) - Yellow accent
- `#37a3a3` (teal-50) - Teal accent
- `#5e40be` (purple-50) - Purple accent

**Design Principle:** Use "pops of red-50" rather than flooding compositions. Balance saturated colors with lighter tints and generous white space.

---

## Typography

### Font Families

**1. Red Hat Display** (Headings, large text)
- Download: https://fonts.google.com/specimen/Red+Hat+Display
- Use: Headings, slide titles, emphasis
- Characteristics: Bold, attention-grabbing

**2. Red Hat Text** (Body text)
- Download: https://fonts.google.com/specimen/Red+Hat+Text
- Use: Paragraphs, small text, body content
- Characteristics: Optimized for readability

**3. Red Hat Mono** (Code only)
- Download: https://fonts.google.com/specimen/Red+Hat+Mono
- Use: Code snippets, technical content only
- Characteristics: Monospaced

### Heading Rules

✅ **DO:**
- Use sentence case ("This is a heading")
- Make it big (large font size)
- Make it bold (font-weight: 700)
- Use Red Hat red (#ee0000) for impact
- Break into 2-3 lines max
- Line height: 110% (1.1x) for text over 150pt

❌ **DON'T:**
- Never use Title Case
- Never use ALL CAPS
- Avoid spanning full width
- Don't use more than 3 lines

### Body Text Rules

✅ **DO:**
- Use Red Hat Text font
- Color: Black (#000000) or white (#ffffff)
- Line height: 120-150% (1.2x-1.5x)
- Line length: 20-100 characters
- Align flush left (or centered with narrow elements)
- Use auto tracking (never adjust letter spacing)

❌ **DON'T:**
- Don't use red for paragraphs
- Never justify text
- Don't increase/decrease letter spacing
- Avoid decorative fonts

### Emphasis

- Use **bold** OR color change (not both)
- Hyperlinks: Blue with underline

### Accessibility

- **Contrast ratio:** Must meet WCAG 2.1 AA (4.5:1 minimum)
- Red Hat red on white: ✅ Passes
- White on Red Hat red: ✅ Passes
- Red Hat red on black: ✅ Passes

---

## Layout Principles

### White Space

✅ **DO:**
- Use generous margins
- Let content breathe
- Embrace negative space
- Balance saturated colors with white space

❌ **DON'T:**
- Never fill entire slide
- Avoid cluttered layouts
- Don't cram content

### Brand Personality

Presentations should reflect Red Hat's brand personality:
- **Open** - Transparent, honest communication
- **Authentic** - Genuine, credible
- **Helpful** - Supportive, educational
- **Brave** - Bold, innovative

---

## Slide Design Patterns

### Title Slide

```
[Large Red Hat Display Bold]
Presentation Title
[Red Hat red #ee0000]

[Smaller Red Hat Text]
Subtitle or context
[Black #000000]

[Bottom]
Presenter Name | Date
```

### Section Divider

```
[Full-width, generous white space]
[Red Hat Display Bold, large size]
Section Title
[Red Hat red #ee0000 or black]

[Optional: Thin accent line in secondary color]
```

### Content Slide

```
[Top-left, Red Hat Display Bold]
Slide Title
[Black or Red Hat red]

[Left-aligned, Red Hat Text]
• Bullet point 1
• Bullet point 2
• Bullet point 3

[Generous margins, plenty of white space]
```

### Code Slide

```
[Top, Red Hat Display Bold]
Code Example
[Black]

[Code block, Red Hat Mono]
const example = "code";
[Dark background with syntax highlighting]
```

---

## reveal.js Implementation

### Custom Theme CSS

```css
/* Import Red Hat fonts */
@import url('https://fonts.googleapis.com/css2?family=Red+Hat+Display:wght@400;700;900&family=Red+Hat+Text:wght@400;500;700&family=Red+Hat+Mono:wght@400;500&display=swap');

/* Color variables */
:root {
  --redhat-red: #ee0000;
  --redhat-black: #000000;
  --redhat-white: #ffffff;
  --redhat-gray-10: #f2f2f2;
  --redhat-red-20: #fbc5c5;
  --redhat-red-60: #a60000;
}

/* Base settings */
.reveal {
  font-family: 'Red Hat Text', sans-serif;
  font-size: 32px;
  color: var(--redhat-black);
  background-color: var(--redhat-white);
}

/* Headings */
.reveal h1, .reveal h2, .reveal h3 {
  font-family: 'Red Hat Display', sans-serif;
  font-weight: 700;
  text-transform: none; /* Sentence case only */
  line-height: 1.1;
  color: var(--redhat-red);
}

.reveal h1 {
  font-size: 3em;
  font-weight: 900;
}

.reveal h2 {
  font-size: 2em;
}

/* Code blocks */
.reveal pre code {
  font-family: 'Red Hat Mono', monospace;
  font-size: 0.7em;
  line-height: 1.3;
}

/* Emphasis */
.reveal strong {
  color: var(--redhat-red);
  font-weight: 700;
}

/* Links */
.reveal a {
  color: var(--redhat-red);
  text-decoration: underline;
}

/* Lists */
.reveal ul, .reveal ol {
  line-height: 1.5;
}

/* Tables */
.reveal table {
  font-size: 0.8em;
  line-height: 1.3;
}
```

### Theme Selection

Use `white` base theme and override with Red Hat custom CSS for closest match to brand standards.

---

## Content Guidelines

### Slide Structure

1. **Title slide** - Set context, introduce topic
2. **Agenda** - Brief outline (3-6 items max)
3. **Content slides** - One key point per slide
4. **Section dividers** - Break presentation into clear sections
5. **Summary/Takeaways** - Reinforce key messages
6. **Q&A** - Invite questions
7. **Thank you** - End with contact info or next steps

### Text Density

- **Maximum 6 bullets per slide**
- **Maximum 8 words per bullet** (ideal)
- Use visuals (diagrams, charts) over text when possible
- One key idea per slide

### Accessibility

- Use high contrast (black on white, white on red)
- Minimum font size: 24pt for body text
- Avoid red/green only distinctions (colorblind-friendly)
- Provide alt text for images (in speaker notes)

---

## Resources

### Fonts

- Red Hat Display: https://fonts.google.com/specimen/Red+Hat+Display
- Red Hat Text: https://fonts.google.com/specimen/Red+Hat+Text
- Red Hat Mono: https://fonts.google.com/specimen/Red+Hat+Mono

### Official Brand Standards

- Main page: https://www.redhat.com/en/about/brand/standards
- Color: https://www.redhat.com/en/about/brand/standards/color
- Typography: https://www.redhat.com/en/about/brand/standards/typography

### Tools

- Color contrast checker: https://webaim.org/resources/contrastchecker/
- WCAG compliance: https://www.w3.org/WAI/WCAG21/quickref/

---

## Quick Checklist

Before presenting:

- [ ] All headings use sentence case (not Title Case or ALL CAPS)
- [ ] Fonts: Red Hat Display for headings, Red Hat Text for body
- [ ] Color: Red Hat red (#ee0000) used sparingly for accents
- [ ] White space: Generous margins, not cluttered
- [ ] Contrast: Meets WCAG 2.1 AA (4.5:1 ratio)
- [ ] Line height: 110% for headings, 120-150% for body
- [ ] No justified text, no adjusted letter spacing
- [ ] Code uses Red Hat Mono (if applicable)
- [ ] Brand personality: Open, authentic, helpful, brave

---

**Last Updated:** 2026-06-17
