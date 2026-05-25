# claire.zone — Brand spec (extracted from live site)

## Overview
Personal website of Claire Raud — self-taught software engineer in Chicago. Dark, moody aesthetic with playful coral accent, cursive display headlines, and a personal/confessional writing voice. The site balances technical depth with self-deprecating humor.

## Color tokens (reconciled with Elegant design system)

The original site uses deep-dark backgrounds with coral accents. Elegant provides structural refinement (spacing, radius, component polish). The reconciled palette:

```css
:root {
  --bg:      #111110;   /* near-black page background */
  --surface: rgba(20, 8, 12, 0.96);  /* dark card surface (slightly warm) */
  --fg:      oklch(90% 0.012 30);    /* warm light text */
  --muted:   oklch(60% 0.025 30);    /* muted warm grey */
  --border:  oklch(35% 0.04 28);     /* subtle dark border */
  --accent:  oklch(68% 0.17 28);     /* coral signature (#ff6f65 equivalent) */

  --font-display: 'Comfortaa', 'Iowan Old Style', Georgia, serif;
  --font-body:    -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
  --font-mono:    ui-monospace, 'JetBrains Mono', 'SF Mono', Menlo, monospace;
}
```

**Rationale:** Clay.zone's signature coral (#ff6f65) is the one true accent. The dark background with fixed bg.jpeg creates the moody canvas. Comfortaa (cursive) is the non-negotiable display font — it defines the site's playful personality. Elegant contributes: spacing discipline, radius refinement, component polish, and a cleaner body font stack.

## Typography patterns

| Element | Font | Size | Notes |
|---------|------|------|-------|
| h1 (name/title) | Comfortaa | 4em → 3em mobile | Text on bg image, kenBurns animation |
| h2 (section titles) | Comfortaa | 1.8em / 2.2em | Uppercase or sentence case |
| h3 (skill category) | Comfortaa | 1.4em | Normal case |
| Body text | Segoe UI / system | 17px | Warm light color on dark |
| Post dates | mono | 13px | Accent-tinted |
| Blog post headlines | Comfortaa | 1.8em | On post detail pages |

## Layout patterns

- **Header**: Photo + name + social links. Sticky on scroll, shrinks to mini-bar.
- **Hero**: Full-width gradient overlay with personal bio text. White text, text-shadow.
- **Content sections**: Dark card sections at max-width ~700px, centered. Box shadow for depth.
- **Blog list**: Chronological with date + title, compact.
- **Skills**: Two-level nested lists in grid layout.
- **Background**: Fixed full-bleed background image (bg.jpeg) with parallax feel.

## Interactive patterns to preserve

1. **Scroll header shrink** — photo + name collapse into mini-nav bar on scroll
2. **Email obfuscation** — JS-injected mailto:href
3. **Social icon hover** — circle pulse effect on GitHub/envelope icons
4. **Background image** — fixed attachment for parallax feel
5. **Emoji section headers** — playful use of emoji as section markers (📰, 📚, 🎉)

## Voice & copy tone

- First-person, confessional but confident
- Self-deprecating humor ("I'm very funny", "not even close to done yet")
- Technical depth without jargon overload
- Personal details (city, spouse, cat) for human connection
- Direct, no corporate filler

## Reconciliation notes — Elegant system

Elegant provides structural tokens that improve the site without changing its character:
- `--radius-sm: 10px` / `--radius-md: 16px` — replaces no-radius on cards
- `--space-*` scale — systematic vertical rhythm
- `--motion-base: 240ms` — consistent transition timing
- `--ease-standard` — smooth easing curve
- Container max-width pattern — cleaner content centering

Elegant's color palette (#fbf6ee bg, #9b5b32 accent) is NOT used — it conflicts with the dark/coral brand identity. claire.zone's extracted palette takes priority.
