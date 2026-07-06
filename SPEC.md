# Project Specification: From Idea to Scaffold Implementation

> "When intent is decoupled from implementation, the cost of change approaches the speed of thought."

![SSoT Telemetry Feedback](static_web/assets/illustrations/spec_ssot.jpg)

## 01. Idea: The Drift Threshold
The inception of DNC arose from a core problem in generative software development: **Code Drift**. Without rigorous spec boundaries, agent-driven refactoring introduces syntax entropy at machine speed. 

We set out to build a highly interactive slide deck and playground that teaches developers how to transition from traditional compilers to Spec-driven intent.

---

## 02. Phased Implementation Log

### Phase 1: Interactive Prototypes (Flutter Web)
* Built a split-screen workspace in Flutter Web.
* Implemented live custom paints for Slop Simulator dials and SNR Oscilloscopes.
* Coded interactive vector state charts to visually demonstrate memory depletion.

### Phase 2: Mockup Editorial Design (Tailwind CSS)
* Realized Flutter Web could not cleanly match the tight text layout, letter-spacing, outline borders, and backdrop blurs of a high-end corporate Google presentation.
* Overhauled the visual layouts using Tailwind CSS across 5 slide folders.
* Replaced heavy compiled visuals with custom, high-fidelity AI-generated illustrations.

### Phase 3: The Native Scroll Integration
* Merged the 5 static mockup folders into a single unified `static_web/index.html` scrollytelling web page.
* Translated the complex Flutter simulators into lightweight client-side JavaScript controllers in `app.js`.
* Discarded legacy compilers to decrease loading weights.

---

## 03. Design System Visual Tokens

To maintain a consistent corporate editorial theme, we enforce the following tokens:

* **Backgrounds**: `#1E0F13` (Base plum), `#2C1B1F` (Surface container), `#180A0E` (Surface container lowest).
* **Accents**: `#E20074` (Neon Magenta container highlights), `#FFB1C6` (Soft primary rose).
* **Typography**: Google Sans Display for huge italic index watermarks, Google Sans Mono for shebang code logs.
