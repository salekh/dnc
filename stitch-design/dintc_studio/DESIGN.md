---
name: DINTC Editorial System
colors:
  surface: '#1e0f13'
  surface-dim: '#1e0f13'
  surface-bright: '#473439'
  surface-container-lowest: '#180a0e'
  surface-container-low: '#27171b'
  surface-container: '#2c1b1f'
  surface-container-high: '#37252a'
  surface-container-highest: '#433034'
  on-surface: '#f9dbe1'
  on-surface-variant: '#e3bdc5'
  inverse-surface: '#f9dbe1'
  inverse-on-surface: '#3e2b30'
  outline: '#aa8890'
  outline-variant: '#5b3f46'
  surface-tint: '#ffb1c6'
  primary: '#ffb1c6'
  on-primary: '#650030'
  primary-container: '#e20074'
  on-primary-container: '#fffbfa'
  inverse-primary: '#ba005e'
  secondary: '#a8c8ff'
  on-secondary: '#003061'
  secondary-container: '#114784'
  on-secondary-container: '#8cb6fb'
  tertiary: '#e8c352'
  on-tertiary: '#3d2f00'
  tertiary-container: '#caa739'
  on-tertiary-container: '#4e3d00'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#ffd9e1'
  primary-fixed-dim: '#ffb1c6'
  on-primary-fixed: '#3f001c'
  on-primary-fixed-variant: '#8e0047'
  secondary-fixed: '#d5e3ff'
  secondary-fixed-dim: '#a8c8ff'
  on-secondary-fixed: '#001b3c'
  on-secondary-fixed-variant: '#114784'
  tertiary-fixed: '#ffe08a'
  tertiary-fixed-dim: '#e8c352'
  on-tertiary-fixed: '#241a00'
  on-tertiary-fixed-variant: '#574400'
  background: '#1e0f13'
  on-background: '#f9dbe1'
  surface-variant: '#433034'
typography:
  display-xl:
    fontFamily: Google Sans Display
    fontSize: 128px
    fontWeight: '700'
    lineHeight: 110%
    letterSpacing: -0.04em
  display-lg:
    fontFamily: Google Sans Display
    fontSize: 96px
    fontWeight: '700'
    lineHeight: 110%
    letterSpacing: -0.03em
  display-md:
    fontFamily: Google Sans Display
    fontSize: 72px
    fontWeight: '500'
    lineHeight: 110%
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Google Sans Display
    fontSize: 48px
    fontWeight: '500'
    lineHeight: 120%
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Google Sans Display
    fontSize: 32px
    fontWeight: '500'
    lineHeight: 120%
    letterSpacing: '0'
  headline-sm:
    fontFamily: Google Sans Display
    fontSize: 24px
    fontWeight: '500'
    lineHeight: 130%
    letterSpacing: '0'
  body-lg:
    fontFamily: Google Sans Text
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 160%
    letterSpacing: '0'
  body-md:
    fontFamily: Google Sans Text
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 150%
    letterSpacing: '0'
  label-mono:
    fontFamily: Google Sans Mono
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 140%
    letterSpacing: 0.05em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  max_width: 1440px
  columns: '12'
  gutter: 24px
  margin: 48px
  unit: 4px
  motion_curve: cubic-bezier(0.22, 1, 0.36, 1)
---

## Brand & Style

This design system embodies a "High-Density Editorial" aesthetic, merging the authoritative weight of traditional prestige journalism with the precision of modern technical environments. It is designed for an audience that values information density, rapid scanning, and expert-level tooling.

The style is characterized by a "The Economist on a Widescreen" philosophy: high information throughput, razor-sharp hierarchy, and a sophisticated dark-mode environment. It utilizes a **Minimalist-Technical** approach—leveraging vast amounts of structured data while maintaining a premium, cinematic feel through high-contrast accents and expansive typography.

The emotional response is one of controlled power, intellectual rigor, and architectural clarity.

## Colors

The palette is rooted in deep blacks and cool grays to prioritize legibility and reduce eye strain in high-density data environments. 

- **Primary (Magenta):** Used sparingly for critical action points, brand markers, and high-priority status indicators.
- **Secondary (Blue):** Applied to interactive elements, links, and technical data visualizations.
- **Tertiary (Yellow):** Reserved for warnings, highlights, and editorial call-outs.
- **Neutrals:** A three-tier depth system (Base, Surface, Elevated) provides the structural foundation without relying on heavy borders or shadows.

## Typography

The typographic system uses the Google Sans family to bridge the gap between geometric friendliness and technical precision. 

- **Display & Headlines:** Use Google Sans Display for high-impact editorial sections. Large sizes should utilize tight letter spacing and aggressive line heights for a "masthead" appearance.
- **Body:** Google Sans Text is used for all long-form content and UI labels to ensure maximum legibility at high densities.
- **Technical/Metadata:** Google Sans Mono is used for data points, code snippets, and small utility labels, reinforcing the "Technical Editorial" narrative.
- **Mobile Scaling:** For mobile devices, `display-xl` and `display-lg` scale down to `headline-lg` (48px) to maintain readability within the viewport.

## Layout & Spacing

This design system utilizes a rigid **12-column fixed-width grid** centered on the screen, maximizing at 1440px. The layout philosophy is built on an 8px rhythmic scale with a 4px sub-grid for high-density components.

- **Desktop (1440px+):** 12 columns, 24px gutters, 48px outer margins. Content should be dense but vertically rhythmically balanced.
- **Tablet:** 8 columns, 16px gutters, 32px margins. Reflow sidebars into collapsible drawers.
- **Mobile:** 4 columns, 16px gutters, 16px margins. 
- **Motion:** All transitions (hover states, drawer entries) must use the "Silk Curve" (`cubic-bezier(0.22, 1, 0.36, 1)`) for a smooth, high-end feel that avoids the "bounciness" of consumer apps.

## Elevation & Depth

In this system, depth is communicated through **Tonal Layering** rather than traditional drop shadows. This maintains the clean, flat-editorial look while providing clear object hierarchy.

- **Level 0 (Base):** #0A0A0A – Used for the primary background and canvas.
- **Level 1 (Surface):** #141414 – Used for cards, sections, and navigation bars.
- **Level 2 (Elevated):** #1E1E1E – Used for floating menus, tooltips, and active modal surfaces.
- **Outlines:** Use 1px solid borders in #1E1E1E to define boundaries between Level 1 elements without adding visual weight. Shadows are only permitted on the highest z-index elements (modals) and must be extremely diffused: `0 20px 40px rgba(0,0,0,0.4)`.

## Shapes

The shape language is "Soft-Technical." Elements use subtle rounding to feel modern and accessible, but remain sharp enough to convey precision.

- **Small elements (Buttons, Inputs, Chips):** 4px (0.25rem) corner radius.
- **Medium elements (Cards, Modals):** 8px (0.5rem) corner radius.
- **Large elements (Containers):** 12px (0.75rem) corner radius.
- **Interactive States:** Hovering over a list item or button should trigger a subtle background color shift to `#1E1E1E` using the Silk Curve.

## Components

- **Buttons:** Primary buttons use a solid Magenta (#E20074) background with White (#FFFFFF) text. Secondary buttons are ghost-style with Blue (#8AB4F8) outlines. Interaction should feel immediate and crisp.
- **Inputs:** Dark-filled surfaces (#141414) with a subtle bottom-border only (#9AA0A6). On focus, the border transitions to Primary Magenta.
- **Cards:** No shadows. Use Tonal Layering (Surface #141414) with a thin #1E1E1E border. Card headers should use `label-mono` for categories.
- **Lists:** High-density rows (48px height) with 1px dividers. Use `body-md` for primary text and `label-mono` for technical metadata on the right.
- **Chips/Badges:** Small, rectangular with 2px radius. Monospaced text only. Color-coded based on status using the accent palette.
- **Editorial Callouts:** Large-scale quotes or insights should use `headline-md` with a Primary Magenta vertical accent bar on the left.