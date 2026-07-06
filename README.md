# Design is the New Code (DNC)

> "When the 'how' is automated, the 'what' is the only remaining lever. Structure, intent, and interface become the absolute source of truth."

![DNC Core Paradigm](static_web/assets/illustrations/shift_hero.jpg)

## What is this Repository?
**DNC** is a high-density, interactive editorial exploration of the paradigm shift in software engineering. We are moving from the manual assembly of syntax (code) to the declarative specification of intent. 

When LLMs can generate 1,000 lines of boilerplate instantly, human speed is no longer bounded by typing speed, but by **design precision**. If you auto-scale code without rigorous specifications, you merely **auto-scale technical debt**. 

This repository serves as a slide presentation deck and live interactive playground demonstrating these principles in action.

---

## 🛠️ Repository Architecture

| Directory | Purpose | Tech Stack |
| :--- | :--- | :--- |
| [`static_web/`](file:///usr/local/google/home/sanchitalekh/Code/dnc/static_web) | The primary visual presentation deck. | HTML5, TailwindCSS, Vanilla JS |
| [`content/`](file:///usr/local/google/home/sanchitalekh/Code/dnc/content) | Source content files and prompt templates. | Markdown, Plain Text |
| [`api/`](file:///usr/local/google/home/sanchitalekh/Code/dnc/api) | Mock agent services simulating memory modes. | FastAPI, Uvicorn, Python |
| [`web/`](file:///usr/local/google/home/sanchitalekh/Code/dnc/web) | Legacy Flutter web presentation framework (for reference). | Dart, Flutter Web |
| [`scripts/`](file:///usr/local/google/home/sanchitalekh/Code/dnc/scripts) | Compiler tools and workspace cache management. | Python |

---

## 🚀 Quickstart & Deployment

### 1. Serve the Presentation Deck
Start a static web server from the `static_web` directory:
```bash
python3 -m http.server 8000 --directory static_web
```
Access the deck at: **`http://localhost:8000/`**

### 2. Launch the Mock Agent Backend
The interactive slides query a local python microservice to simulate Goldfish/Elephant memory state evaluations. To spin it up:
```bash
cd api
# Create virtual environment and install requirements
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# Run shebang server module
python3 -m uvicorn api.main:app --port 8089 --host 127.0.0.1
```
The API serves health check status on port `8089`.

---

## 🎨 Visual System Integration
This repository integrates premium, high-contrast AI-generated illustrations directly inside the slide deck cards to visual progress. These are located in:
`static_web/assets/illustrations/`
