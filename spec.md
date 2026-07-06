# Self-Referential Repository Meta-Specification: dintc

This meta-specification describes the design, architecture, rules, and operational workflows of the `design-code-2` repository. This repository acts as a self-referential engine where the specifications serve as both documentation and the active definition of system compilation targets.

---

## 1. Directory Structure & Map

The repository is organized into distinct namespaces under `/usr/local/google/home/sanchitalekh/Code/design-code-2/`:

```
/usr/local/google/home/sanchitalekh/Code/design-code-2/
├── spec.md (This file)                  # Root repository meta-specification
├── content/
│   ├── checklists.md                    # Monday-Morning developer & agent checklists
│   ├── sections/                        # Narrative sections §0 to §15
│   │   ├── 00.md
│   │   ├── ...
│   │   └── 15.md
│   ├── prompts/                         # Agent API prompt templates
│   │   ├── interrogate.txt
│   │   └── goldfish.txt
│   └── magenta-tv/                      # MagentaTV "Continue Watching" spec thread
│       ├── prd.md                       # Product requirements, user stories, metrics
│       ├── design.md                    # ASCII wireframes and API payloads
│       ├── plan.md                      # 6-phase RPI implementation roadmap
│       ├── GEMINI.md                    # House style, banned libraries, sandboxing
│       ├── runbook.md                   # Oncall incident triage and remediations
│       ├── spec.md                      # MagentaTV master specification
│       └── skills/                      # Executable playbooks/skills
│           ├── deploy-recs-service.md   # Deployment orchestration playbook
│           └── query-watch-history.md   # BigQuery SQL templates and dry-runs
```

---

## 2. Core Repository Concepts

### A. The scrollytelling Narratives (Sections)
The `content/sections/` directory contains 16 markdown documents (§0 to §15) that outline the philosophical transition from compiler-focused human programming to specification-driven agentic synthesis:
- **§0 to §3:** The Shift, Fallacy of the Human Compiler, Specifications as SSoT, and the Agentic Loop.
- **§4 to §7:** Runbooks and Skills, Code as a Search Problem, Specification Engineering, and Blast Radius Mitigation.
- **§8 to §11:** Test-Driven Spec, Continuous Regeneration, Death of the Mainframe, and Self-Healing Architectures.
- **§12 to §15:** Humans as Architects/Auditors, Multi-agent Orchestration, the Self-Referential Engine, and the Epilogue.

### B. The Specification Threads (MagentaTV)
Under `content/magenta-tv/`, we maintain the spec thread for a real-world recommendation service. This thread showcases:
- **The product demand (`prd.md`):** Defining exactly what needs to be built with explicit user stories and numeric targets.
- **The technical design (`design.md`):** Providing the precise visual structure and serialization contracts.
- **The implementation roadmap (`plan.md`):** Outlining the timeline in 6 phases (Research, Plan, Implement sequence).
- **Security controls (`GEMINI.md`):** Prohibiting dangerous libraries, ensuring strict typing, and defining the containment blast radius.

### C. Prompt Templates
The `content/prompts/` directory stores templates for codebase interaction:
- **`interrogate.txt`:** Executed to check source files against design rules and report structured issues.
- **`goldfish.txt`:** Used for low-overhead, stateless code modifications.

---

## 3. Development Workflows & Execution

All repository updates are governed by the **Agentic Loop**:
1. **Interrogation:** Check target paths for spec drift using the `interrogate` route.
2. **Planning:** Verify steps against the 6-phase plan mapping.
3. **Execution:** Execute changes in isolated containers using pre-defined **Skills** (e.g., `query-watch-history`, `deploy-recs-service`).
4. **Validation:** Run target unit and integration tests. No code is merged unless all targets in the spec pass validation.

---

## 4. Monday-Morning Checklist Integration

To maintain codebase hygiene, both humans and agents must execute the checklists defined in [checklists.md](file:///usr/local/google/home/sanchitalekh/Code/design-code-2/content/checklists.md) every Monday morning:
- **Humans:** Pull code, verify branch synchronization, check weekend oncall tickets, and review design proposals.
- **Agents:** Perform static analysis sweeps, execute dry-run SQL validations, run latency load tests, and compile a compliance report.
