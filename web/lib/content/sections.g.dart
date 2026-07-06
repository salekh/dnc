// Generated file. Do not edit manually.
import 'section.dart';

const List<Section> sections = [
  Section(
    index: 0,
    title: "The Shift",
    content: r'''
The transition from manual code construction to specification-driven intent.

- **The Evolution:** From binary switches to compilers, and now to automated code engines.
- **The Core Premise:** Source files are merely ephemeral build targets generated from specifications.
- **The Shift:** Elevating software engineers from syntax writers to system architects.
''',
  ),
  Section(
    index: 1,
    title: "The Illusion of Speed",
    content: r'''
For decades, the holy grail of software development has been speed: higher-level languages, frameworks, and pipelines.

- **The LLM Promise:** Generative AI spits out 1,000 lines of complex boilerplate in seconds.
- **The Illusion:** It feels like magic. It feels like we finally won the speed war.
- **The Reality:** Underneath the surface, rapid syntax output mask a critical decline in system visibility.
''',
  ),
  Section(
    index: 2,
    title: "Auto-scaling Our Mistakes",
    content: r'''
When teams begin using AI to write code, the primary realization is immediate and terrifying.

- **Mistake Scaling:** We aren't just writing code faster; we are auto-scaling our architectural mistakes.
- **The Slop Limit:** If the rate of generated slop exceeds the rate of human reviews, the project collapses.
- **Noise vs. Signal:** Productivity decays when AI generates complex boilerplate that humans cannot maintain.
''',
  ),
  Section(
    index: 3,
    title: "The Blank Slate",
    content: r'''
A single hour of deep debugging with an LLM can vanish instantly when the context window resets.

- **The Lost Session:** A model crash wipes the slate clean, leaving no memory of the previous work.
- **The Re-bootstrap Drag:** Feeding thousands of lines of raw code back into the prompt is tedious and token-heavy.
- **The Solution:** A concise 30-second document describing intent and state gets the agent up to speed immediately.
''',
  ),
  Section(
    index: 4,
    title: "The Eager Runaway",
    content: r'''
AI models are eager to please, which means they will happily sprint off a cliff without strict boundaries.

- **The Drift:** Left to their own devices, agents hallucinate APIs and construct bizarre architectures.
- **Strict Guardrails:** Without explicit rules defining what *not* to write, code decays instantly.
- **The Necessity:** We must prescribe constraints, blocklists, and safety frameworks at compile time.
''',
  ),
  Section(
    index: 5,
    title: "The Mathematical Certainty",
    content: r'''
It is a mathematical certainty that managing design documents is cheaper than managing codebases.

- **Mathematical Proof:** `sizeof(docs) <<< sizeof(code)`
- **Context Bandwidth:** Reading a 20-line design file is faster for an LLM than digesting a 10,000-line repository.
- **The Leverage:** Plain English design specifications are the highest-leverage representation of a system.
''',
  ),
  Section(
    index: 6,
    title: "The Limits of Precision",
    content: r'''
Human language is imprecise and verbose when complete precision is required. But complete precision is not the goal.

- **Boswell's Observation:** Precise manuals are verbose, but design documents will never be perfect.
- **Statistical Confidence:** We build statistical confidence in a specification, minimizing ambiguous interpretations.
- **The Framework:** Elephant-Goldfish Model improves precision while minimizing ambiguities caused by concision.
''',
  ),
  Section(
    index: 7,
    title: "Decoupling Intent — The Specification Stack",
    content: r'''
A spec-driven repository is built on a stack of structured, modular files that define the business and technical logic.

- **PRD (`prd.md`):** Formulates target customer stories, latency bounds, and success metrics.
- **Technical Design (`design.md`):** Defines REST API schemas, data contracts, and visual wireframe outlines.
- **Containment Rules (`GEMINI.md`):** Establishes explicit safety checks, memory boundaries, and dependency blocklists.
''',
  ),
  Section(
    index: 8,
    title: "Agent Context Memory Modes",
    content: r'''
An agent can translate intent under two different memory strategies, balancing speed against safety.

- **Goldfish Mode (Stateless):** Operates on a single file delta without context history. Extremely fast and low-latency.
- **Elephant Mode (Stateful):** Injects the full specification stack and repository files. Enforces global styling and security.
- **Tradeoffs:** Goldfish saves token bandwidth; Elephant blocks code drift by validating all constraints.
''',
  ),
  Section(
    index: 9,
    title: "Specification Synthesis in Confinement",
    content: r'''
Once context sheets and memory modes are active, the agentic engine compiles instructions directly into verified code.

- **Goal Specs:** Humans input the feature delta instructions (e.g., adding dynamic progress updates).
- **Automated Traversal:** The agent parses selected specs, constructs plans, and writes code.
- **Diff Streams:** The right pane simulates streaming code modifications in real time.
''',
  ),
  Section(
    index: 10,
    title: "Runbooks and Execution Skills",
    content: r'''
We decouple the system's architecture (specifications) from its environment-specific deployment actions (skills).

- **The Spec:** Declares *what* the system is and *what* it must accomplish.
- **The Skill:** An encapsulated, playbook declaring *how* to interact with the environment.
- **Repeatable Vocabulary:** Standardizes actions like database querying, cloud deployment, and rollbacks.
''',
  ),
  Section(
    index: 11,
    title: "The Shift Left of Design Judgments",
    content: r'''
Historically, design judgments sit in two places: in the design docs, and in the code itself.

- **Micro-decisions:** When a human writes code, they leave a trail of micro-decisions behind in the logic.
- **The AI Dilemma:** If an AI is writing the code, the human is no longer making those micro-decisions.
- **Shift Left:** We must force all design judgments into the design documents *before* the code is written.
''',
  ),
  Section(
    index: 12,
    title: "The Vanishing Code",
    content: r'''
We still need code because we still need rigor. But code is a vanishing intermediate step.

- **The Analog:** When you ask an AI for a picture of a cat, it doesn't write a python script to paint it.
- **The Future:** In the near future, LLMs will produce executable binaries directly from specifications.
- **The Opaque Step:** Code will become as opaque to developers as machine code is today.
''',
  ),
  Section(
    index: 13,
    title: "The Opaque Avalanche",
    content: r'''
With LLMs producing code at 10x or 100x speed, the sheer volume makes human code review impossible.

- **Avalanche:** Human review of every line of generated code becomes a physical impossibility.
- **The Opaque Horizon:** The code becomes an unreadable blizzard, serving only the compilers.
- **The Only Artifact:** When the code becomes opaque, the only artifact that matters is the design.
''',
  ),
  Section(
    index: 14,
    title: "DESIGN IS THE NEW CODE",
    content: r'''
The climax of software evolution: specifications are the software.

- **The Core Truth:** When code vanishes or becomes opaque, the design document is the codebase.
- **The Architect's Epoch:** Developers are elevated to design authors; machines are the compilers.
- **Design is the New Code:** We prompt the compiler through structured design, not programming syntax.
''',
  ),
  Section(
    index: 15,
    title: "Containment and the Blast Radius",
    content: r'''
Running untrusted agentic compilations requires robust containment to prevent system destruction.

- **The Blast Radius:** Define precise boundaries where the agent can create or modify files.
- **Sandbox Execution:** Code is compiled and run in strict isolation to capture compile errors safely.
- **Resource Monitoring:** CPU, memory, and API tokens are metered to prevent loops or resource drain.
''',
  ),
  Section(
    index: 16,
    title: "Test-Driven Spec & Confinement",
    content: r'''
We ensure codebase integrity through an adversarial loop containing two distinct agent instances.

- **Builder Agent:** Focuses on writing and editing code to meet the specification requirements.
- **Verifier Agent:** An adversarial validator running tests and static analysis in confinement.
- **Zero Human Trust:** No code is written directly to the codebase without verifier checkmarks.
''',
  ),
  Section(
    index: 17,
    title: "Continuous Regeneration Pipeline",
    content: r'''
Traditional software pipelines require human pull requests and reviews. The new pipeline compiles specs.

- **Spec Mainline:** Changes are committed to design documents, not to source files.
- **Automated Compile:** The agentic engine intercepts commits, regenerates source code, and runs tests.
- **Instant Deployment:** Green builds are instantly pushed to production, bypassing manual code approvals.
''',
  ),
  Section(
    index: 18,
    title: "Multi-agent Orchestration & Fleet",
    content: r'''
Complex features cannot be built by a single agent. We orchestrate a fleet of micro-agents.

- **Decomposition:** A manager agent splits the specification task into parallel sub-tasks.
- **Specialized Workers:** Independent agents (frontend, backend, database) edit code in isolated branches.
- **Integration:** Code changes are merged and validated as a cohesive unit.
''',
  ),
  Section(
    index: 19,
    title: "Self-Healing Architectures",
    content: r'''
When live systems encounter exceptions, the architecture resolves issues autonomously.

- **Triage:** Monitoring agents capture exceptions and trace back to the offending lines of code.
- **Diagnostic Loop:** The agent checks compiler rules, generates diagnostic scripts, and isolates bugs.
- **Self-Healing:** The agent modifies the specification, regenerates code, runs tests, and redeploys.
''',
  ),
  Section(
    index: 20,
    title: "The Self-Referential Engine",
    content: r'''
The ultimate state: the agentic engine is itself specified and compiled by the specification it runs.

- **Recursion:** The codebase contains specifications for the compiler and the agents themselves.
- **Self-Compiling:** Modifying the agent specs regenerates the core compiler logic dynamically.
- **The Loop:** An infinite, self-referential loop of software engineering evolution.
''',
  ),
];
