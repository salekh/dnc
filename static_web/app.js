document.addEventListener('DOMContentLoaded', () => {
  // --- 1. Scroll Observer for Active Chapter & Slide Counter ---
  const sections = document.querySelectorAll('section');
  const navLinks = document.querySelectorAll('header nav a');
  const slideIndicator = document.getElementById('slide-index-indicator');
  
  let currentFocusedIndex = 0;

  const observerOptions = {
    root: null,
    rootMargin: '-30% 0px -30% 0px',
    threshold: 0
  };

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        const id = entry.target.id;
        const index = parseInt(id.split('-')[1]);
        
        slideIndicator.innerText = `${index.toString().padLeft(2, '0')} / 20`;
        currentFocusedIndex = index;
        

        
        let activeChapterIdx = 0;
        if (index >= 4 && index < 8) activeChapterIdx = 1;
        else if (index >= 8 && index < 12) activeChapterIdx = 2;
        else if (index >= 12 && index < 16) activeChapterIdx = 3;
        else if (index >= 16) activeChapterIdx = 4;
        
        navLinks.forEach((link, idx) => {
          if (idx === activeChapterIdx) {
            link.classList.add('active-nav');
          } else {
            link.classList.remove('active-nav');
          }
        });
        
        // Highlight active side dot
        const dots = document.querySelectorAll('.fixed.right-6 a');
        dots.forEach((dot, idx) => {
          if (idx === index) {
            dot.classList.add('bg-primary', 'border-primary', 'scale-125');
            dot.classList.remove('bg-surface/80', 'border-outline/40');
          } else {
            dot.classList.remove('bg-primary', 'border-primary', 'scale-125');
            dot.classList.add('bg-surface/80', 'border-outline/40');
          }
        });
        
        animateSlideEntry(index);
      }
    });
  }, observerOptions);

  sections.forEach(sec => observer.observe(sec));

  // --- Dynamic Side Dots Navigation Generation ---
  const dotsContainer = document.createElement('div');
  dotsContainer.className = 'fixed right-6 top-1/2 -translate-y-1/2 z-50 flex flex-col gap-3 pointer-events-auto';
  
  sections.forEach((sec, idx) => {
    const h2 = sec.querySelector('h2, h1');
    let title = h2 ? h2.innerText.replace(/§\d+:\s*/, '').trim() : `Slide ${idx}`;
    // Strip nested html tags from text if any
    title = title.replace(/<[^>]*>/g, '');
    
    const dot = document.createElement('a');
    dot.href = `#${sec.id}`;
    dot.className = 'w-2.5 h-2.5 rounded-full border border-outline/40 bg-surface/80 hover:bg-primary hover:border-primary transition-all duration-300 relative group flex items-center justify-center';
    dot.dataset.idx = idx;
    
    dot.innerHTML = `<span class="absolute right-8 bg-surface-container/95 border border-outline-variant/60 px-3 py-1 text-[11px] text-on-surface-variant font-label-mono whitespace-nowrap rounded opacity-0 group-hover:opacity-100 pointer-events-none transition-opacity duration-200">${title.toUpperCase()}</span>`;
    
    dotsContainer.appendChild(dot);
  });
  
  document.body.appendChild(dotsContainer);

  String.prototype.padLeft = function(length, character) {
    return this.length >= length ? this : (new Array(length - this.length + 1).join(character || ' ') + this);
  };

  function animateSlideEntry(index) {
    if (index === 1) {
      const volumeBar = document.querySelector('#section-1 [style*="width: 95%"]');
      const visibilityBar = document.querySelector('#section-1 [style*="width: 38%"]');
      if (volumeBar && visibilityBar) {
        volumeBar.style.width = '0%';
        visibilityBar.style.width = '0%';
        setTimeout(() => {
          volumeBar.style.width = '95%';
          visibilityBar.style.width = '38%';
        }, 100);
      }
    }
  }

  // --- 2. Interactive Spec Preview Modal (Slide 7) ---
  const specModal = document.getElementById('spec-modal');
  const modalTitle = document.getElementById('modal-title');
  const modalContent = document.getElementById('modal-content');
  const closeModalBtn = document.getElementById('close-modal-btn');

  const specContentMap = {
    'prd.md': `# Product Requirements Document (PRD)
Project: DINTC Orchestrator
Status: DRAFT v2.1

## 1. Objective
Establish a zero-human-loop development engine that generates, builds, and self-heals web systems based on declarative specifications.

## 2. Core Functional Requirements
- **Constraint Boundaries**: The agent must operate strictly inside secure VM sandboxes with no egress.
- **Specification-driven Intent**: Code is a transient compiler target; all feature requests must be made directly inside spec markdown documents.
- **Self-Healing Loop**: The system must run compile and test scans automatically upon delta merges and self-heal any regressions.`,

    'design.md': `# System Architecture Design (design.md)
Target: Autonomous Scaffold Engine

## 1. Modular Architecture
- **Builder Agent**: Performs code synthesis by applying atomic changes to the repository file tree.
- **Verifier Agent**: Orchestrates hermetic build and test environments, generating detailed triage logs on compile failures.
- **Orchestrator**: Coordinates tasks, updates specifications, and records history logs.

## 2. State Mapping Schema
- Layer 01: Product requirements (prd.md)
- Layer 02: API & Architecture Schemas (design.md)
- Layer 03: Integration bindings (GEMINI.md)`,

    'GEMINI.md': `# Gemini Execution Instructions (GEMINI.md)
Role: Expert AI Software Engineer

## 1. Guiding Principles
- **Conciseness**: Avoid diagnostic warnings, apologies, or verbose summaries. Speak directly via code and specifications.
- **Autonomy**: Proactively write scratch scripts to compile and test code. Do not halt loops for minor decisions.

## 2. Sandbox Constraints
- NEVER attempt to modify or query files outside the configured workspace directory.
- DO NOT execute non-hermetic shell commands (such as curl, wget, or ssh) without sandboxing flags.`
  };

  const specCards = document.querySelectorAll('#section-7 .bg-surface-container');
  specCards.forEach(card => {
    const h3 = card.querySelector('h3');
    if (h3) {
      const title = h3.innerText.trim();
      if (specContentMap[title]) {
        card.style.cursor = 'pointer';
        card.style.transition = 'all 0.3s cubic-bezier(0.22, 1, 0.36, 1)';
        card.addEventListener('mouseenter', () => {
          card.style.borderColor = '#ffb1c6';
          card.style.transform = 'translateY(-4px)';
        });
        card.addEventListener('mouseleave', () => {
          card.style.borderColor = 'rgba(91, 63, 70, 0.3)';
          card.style.transform = 'translateY(0)';
        });
        card.addEventListener('click', () => {
          openSpecModal(title);
        });
      }
    }
  });

  function openSpecModal(title) {
    modalTitle.innerText = title;
    modalContent.innerText = specContentMap[title];
    specModal.classList.remove('hidden');
    setTimeout(() => {
      specModal.classList.remove('opacity-0');
      specModal.querySelector('.transform').classList.remove('scale-95');
    }, 10);
  }

  function closeSpecModal() {
    specModal.classList.add('opacity-0');
    specModal.querySelector('.transform').classList.add('scale-95');
    setTimeout(() => {
      specModal.classList.add('hidden');
    }, 300);
  }

  closeModalBtn.addEventListener('click', closeSpecModal);
  specModal.addEventListener('click', (e) => {
    if (e.target === specModal) closeSpecModal();
  });

  // --- 3. Fullscreen art viewer removed (illustrations integrated directly into slide panels) ---


  // --- 4. Interactive Toggles: Goldfish vs. Elephant (Slide 8) ---
  const goldfishCard = document.querySelector('#section-8 .bg-surface-container:nth-of-type(1)');
  const elephantCard = document.querySelector('#section-8 .bg-surface-container:nth-of-type(2)');
  const codeConsole = document.querySelector('#section-8 .bg-surface\\/80');

  if (goldfishCard && elephantCard && codeConsole) {
    goldfishCard.style.cursor = 'pointer';
    elephantCard.style.cursor = 'pointer';
    goldfishCard.style.transition = 'all 0.3s ease';
    elephantCard.style.transition = 'all 0.3s ease';

    goldfishCard.addEventListener('click', () => {
      goldfishCard.style.border = '2px solid #e8c352';
      elephantCard.style.border = 'none';
      codeConsole.innerHTML = `<span class="text-primary">function</span> getRecs(userId) {<br/>
&nbsp;&nbsp;<span class="text-secondary">// Goldfish Mode: stateless & fast</span><br/>
&nbsp;&nbsp;<span class="text-primary">return</span> fetchLegacyRecs(userId);<br/>
}`;
    });

    elephantCard.addEventListener('click', () => {
      elephantCard.style.border = '2px solid #e20074';
      goldfishCard.style.border = 'none';
      codeConsole.innerHTML = `<span class="text-primary">if</span> (intent.depth &gt; threshold) {<br/>
&nbsp;&nbsp;switchMode(<span class="text-tertiary">'ELEPHANT'</span>);<br/>
&nbsp;&nbsp;mountVectorStore(<span class="text-tertiary">'./.dnc/ctx'</span>);<br/>
} <span class="text-primary">else</span> {<br/>
&nbsp;&nbsp;flushBuffer();<br/>
&nbsp;&nbsp;exec(<span class="text-tertiary">'GOLDFISH_LITE'</span>);<br/>
}`;
    });
  }

  // --- 5. Interactive Spec Synthesis (Slide 9) ---
  const diffOutput = document.querySelector('#section-9 .grid-cols-1');
  const slide9TextCol = document.querySelector('#section-9 .col-span-4');

  if (diffOutput && slide9TextCol) {
    const btnContainer = document.createElement('div');
    btnContainer.className = 'mt-6';
    btnContainer.innerHTML = `<button id="synthesis-trigger-btn" class="bg-primary text-on-primary font-label-mono text-xs px-6 py-3 rounded hover:bg-primary-container transition-colors uppercase tracking-wider cursor-pointer">Run Spec Synthesis</button>`;
    slide9TextCol.appendChild(btnContainer);

    const triggerBtn = document.getElementById('synthesis-trigger-btn');
    const baseDiffLines = [
      '<div class="text-on-surface-variant opacity-40">@@ -124,6 +124,24 @@</div>',
      '<div class="bg-primary/10 text-primary py-1 px-2">+ // FEATURE_DELTA: Implement dynamic context synthesis</div>',
      '<div class="bg-primary/10 text-primary py-1 px-2">+ export const synthesize = (specs: Spec[]) =&gt; {</div>',
      '<div class="bg-primary/10 text-primary py-1 px-2">+ &nbsp;&nbsp;return specs.reduce((acc, curr) =&gt; ({{ ...acc, ...curr.delta }}), {{}});</div>',
      '<div class="bg-primary/10 text-primary py-1 px-2">+ };</div>',
      '<div class="text-on-surface-variant opacity-40 mt-4">@@ -210,4 +228,8 @@</div>',
      '<div class="bg-error/10 text-error py-1 px-2">- const legacy_delta = old_synthesis_logic();</div>',
      '<div class="bg-primary/10 text-primary py-1 px-2">+ const modern_delta = await agent.synthesis(raw_stream);</div>'
    ];

    triggerBtn.addEventListener('click', () => {
      triggerBtn.disabled = true;
      triggerBtn.innerText = "SYNTHESIZING...";
      diffOutput.innerHTML = "";
      
      let lineIdx = 0;
      const interval = setInterval(() => {
        if (lineIdx < baseDiffLines.length) {
          diffOutput.innerHTML += baseDiffLines[lineIdx];
          lineIdx++;
        } else {
          clearInterval(interval);
          triggerBtn.disabled = false;
          triggerBtn.innerText = "RUN SPEC SYNTHESIS";
        }
      }, 350);
    });
  }

  // --- 6. Sandbox VM Terminal (Slide 15) ---
  const terminalConsole = document.querySelector('#section-15 .bg-surface\\/50');
  if (terminalConsole) {
    const sandboxLogs = [
      "[SYS] Initializing blast_radius_shield...",
      "[MEM] Allocation restricted to 256MB...",
      "[NET] Outbound egress denied...",
      "[CPU] Cycle monitoring active...",
      "[LOG] Anomaly detected in slide_13_logic...",
      "[SEC] Isolating process context VM_04...",
      "[SYS] Executing adversarial build checks...",
      "[ERR] Invalid package import 'third_party/boost' blocked...",
      "[SYS] Terminating process thread...",
      "[LOG] Confinement containment intact."
    ];
    
    let logIdx = 5;
    setInterval(() => {
      if (logIdx < sandboxLogs.length) {
        terminalConsole.innerHTML += `<br/>${sandboxLogs[logIdx]}`;
        logIdx++;
      } else {
        terminalConsole.innerHTML = sandboxLogs.slice(0, 5).join('<br/>');
        logIdx = 5;
      }
      terminalConsole.scrollTop = terminalConsole.scrollHeight;
    }, 1800);
  }

  // --- 7. Interactive Latency Trigger (Slide 17) ---
  const pipelineBtn = document.querySelector('#section-17 .bg-primary');
  const latencyTimer = document.querySelector('#section-17 .text-primary');

  if (pipelineBtn && latencyTimer) {
    pipelineBtn.style.cursor = 'pointer';
    pipelineBtn.addEventListener('click', () => {
      latencyTimer.innerText = "---";
      pipelineBtn.style.opacity = '0.5';
      
      setTimeout(() => {
        const randLatency = (Math.random() * 0.15 + 0.01).toFixed(2);
        latencyTimer.innerText = `${randLatency}s`;
        pipelineBtn.style.opacity = '1.0';
      }, 800);
    });
  }

  // --- 8. Keyboard Navigation Event Handlers ---
  let isScrolling = false;

  window.addEventListener('keydown', (e) => {
    // Check if modal dialog overlay is currently open
    const modal = document.getElementById('spec-modal');
    if (modal && !modal.classList.contains('hidden')) {
      // If modal is active, let ESC key close it and prevent arrow scrolling inside the deck
      if (e.key === 'Escape') {
        modal.classList.add('hidden');
      }
      return; 
    }

    if (isScrolling) {
      // Ignore key events while scrolling transition is active
      return;
    }

    if (e.key === 'ArrowDown' || e.key === 'ArrowRight' || e.key === 'PageDown' || e.key === ' ') {
      // Prevent default page scrolling jump
      e.preventDefault();
      
      if (currentFocusedIndex < sections.length - 1) {
        const nextSec = document.getElementById(`section-${currentFocusedIndex + 1}`);
        if (nextSec) {
          isScrolling = true;
          nextSec.scrollIntoView({ behavior: 'smooth', block: 'start' });
          setTimeout(() => { isScrolling = false; }, 850);
        }
      }
    } else if (e.key === 'ArrowUp' || e.key === 'ArrowLeft' || e.key === 'PageUp') {
      e.preventDefault();
      
      if (currentFocusedIndex > 0) {
        const prevSec = document.getElementById(`section-${currentFocusedIndex - 1}`);
        if (prevSec) {
          isScrolling = true;
          prevSec.scrollIntoView({ behavior: 'smooth', block: 'start' });
          setTimeout(() => { isScrolling = false; }, 850);
        }
      }
    }
  });
});
