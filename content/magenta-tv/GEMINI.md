# GEMINI Agent Guidelines & Linting Policies (GEMINI.md)

This document defines the agent execution constraints, coding standards, and sandbox boundaries for all autonomous agents executing changes within the `magenta-tv` service.

---

## 1. Banned Libraries & Patterns

To prevent bloated binaries, security vulnerabilities, and licensing issues, the following libraries and coding practices are strictly banned. The Verifier agent must reject any CL containing them:

- **Banned C++ Dependencies:** 
  - `boost` (Use standard library `<algorithm>`, `<thread>`, and `<chrono>` instead).
  - Raw pointer management with `new`/`delete` (Use `std::unique_ptr` or `std::shared_ptr`).
- **Banned Go/Python Dependencies:**
  - `pandas` in runtime microservices (Allowed only in offline analysis scripts; too heavy for serving path).
  - External HTTP libraries like Python `requests` or Go `gorilla/mux` (Use standard Go `net/http` or fast, pre-approved internal gRPC frameworks).
- **Concurrency Warnings:**
  - Avoid spawning unmonitored goroutines or threads. All background tasks must run within a standard context manager with explicit timeouts.

---

## 2. Coding House Style (dintc Standards)

- **Strict Type Checking:** All Python code must include type hints (`typing` or Python 3.10 native types) and must pass `mypy --strict`.
- **Formatting:** Code must be formatted using system defaults: `clang-format` for C++, `gofmt` for Go, and `black` for Python. Do not submit unformatted code.
- **Error Handling:** Never swallow errors. All errors must be logged with appropriate context-tracing IDs (Sherlog/Stubby) and returned up the call stack. Do not use generic `except Exception:` without logging.

---

## 3. Blast Radius & Sandbox Constraints

To ensure safety, agents must respect the following security zones:

```
+-----------------------------------------------------------------+
|                         Production Network                      |
|                                                                 |
|   +---------------------------------------------------------+   |
|   |                       Staging Network                   |   |
|   |                                                         |   |
|   |   +-------------------------------------------------+   |   |
|   |   |            Agent Sandbox (Capsule)              |   |   |
|   |   |                                                 |   |   |
|   |   |   - No access to production databases.          |   |   |
|   |   |   - Interrogate & Goldfish API routes mocked.   |   |   |
|   |   |   - Output code limited to:                     |   |   |
|   |   |     /content/magenta-tv/                        |   |   |
|   |   +-------------------------------------------------+   |   |
|   +---------------------------------------------------------+   |
+-----------------------------------------------------------------+
```

- **Write Boundaries:** Agents are only permitted to modify files under `/usr/local/google/home/sanchitalekh/Code/design-code-2/content/magenta-tv/`. Attempts to edit files in `infra/` or other root directories without explicit approval will trigger a security kill-switch.
- **Network Isolation:** Sandbox containers do not have outbound internet access. All dependency installations must use internal pre-mirrored package sources.
- **Execution Log:** Every terminal command proposed by the agent must run with a timeout limit of 60 seconds and must be logged to `/var/log/agent-execution.log`.
