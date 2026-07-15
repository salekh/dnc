document.addEventListener('DOMContentLoaded', () => {
  if ('serviceWorker' in navigator) {
    navigator.serviceWorker.getRegistrations().then(registrations => {
      registrations.forEach(registration => registration.unregister());
    });
  }

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
        const idxInList = Array.from(sections).indexOf(entry.target);
        
        let displayStr = '';
        if (id === 'section-2-1') {
          displayStr = '02.1 / 18';
        } else if (id === 'section-2-2') {
          displayStr = '02.2 / 18';
        } else if (id === 'section-14-5') {
          displayStr = '14.5 / 18';
        } else if (id === 'section-4-5') {
          displayStr = '04.5 / 18';
        } else {
          const index = parseInt(id.split('-')[1]);
          displayStr = `${index.toString().padStart(2, '0')} / 18`;
        }
        slideIndicator.innerText = displayStr;
        currentFocusedIndex = idxInList;
        
        let activeChapterIdx = 0;
        if (idxInList >= 8 && idxInList < 12) activeChapterIdx = 1;       // AHA MOMENTS (Indices 8..11)
        else if (idxInList >= 12 && idxInList < 19) activeChapterIdx = 2; // EXECUTION (Indices 12..18)
        else if (idxInList === 19) activeChapterIdx = 3;                  // ORCHESTRATION (Index 19)
        else if (idxInList >= 20) activeChapterIdx = 4;                   // THE FUTURE (Indices 20..22)
        
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
          if (idx === idxInList) {
            dot.classList.add('bg-primary', 'border-primary', 'scale-125');
            dot.classList.remove('bg-surface/80', 'border-outline/40');
          } else {
            dot.classList.remove('bg-primary', 'border-primary', 'scale-125');
            dot.classList.add('bg-surface/80', 'border-outline/40');
          }
        });
        
        const numericIndex = parseInt(id.split('-')[1]) || 0;
        animateSlideEntry(numericIndex);
      }
    });
  }, observerOptions);

  sections.forEach(sec => observer.observe(sec));

  // --- Dynamic Side Dots Navigation Generation ---
  const dotsContainer = document.createElement('div');
  dotsContainer.className = 'fixed right-6 top-1/2 -translate-y-1/2 z-50 hidden md:flex flex-col gap-3 pointer-events-auto';
  
  sections.forEach((sec, idx) => {
    const h2 = sec.querySelector('h2, h1');
    let title = h2 ? h2.innerText.replace(/§\d+(\.\d+)?:?\s*/, '').trim() : `Slide ${idx}`;
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
Project: Agentic Orchestrator
Status: DRAFT v2.1

## 1. Objective
Establish a zero-human-loop development engine that generates, builds, and self-heals web systems based on declarative specifications.

## 2. Core Functional Requirements
- **Constraint Boundaries**: The agent must operate strictly inside secure VM sandboxes with no egress.
- **Specification-driven Intent**: Code is a transient compiler target; all feature requests must be made directly inside spec markdown documents.
- **Self-Healing Loop**: The system must run compile and test scans automatically upon delta merges and self-heal any regressions.`,

    'design.md': `# System Architecture Design (design.md)
Target: Autonomous Scaffold Engine

## 1. Component Boundaries
All components are built correct-by-construction from formal specs.

## 2. State Management
State transitions follow deterministic specification maps.`,

    'GEMINI.md': `# Agent Execution Instructions (GEMINI.md)
Protocol: SPEC_FIRST_V4

## 1. Rule of Engagement
Never output application code directly unless directed by a formal spec change.

## 2. Verification Protocol
Run tests continuously after every delta injection.`
  };

  const specCards = document.querySelectorAll('#section-8 .bg-surface-container');
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


  // --- 4. Interactive Toggles: Goldfish vs. Elephant (Slide 9) ---
  const goldfishCard = document.querySelector('#section-9 .bg-surface-container:nth-of-type(1)');
  const elephantCard = document.querySelector('#section-9 .bg-surface-container:nth-of-type(2)');
  const codeConsole = document.querySelector('#section-9 .bg-surface\\/80');

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
&nbsp;&nbsp;mountVectorStore(<span class="text-tertiary">'./.agentic/ctx'</span>);<br/>
} <span class="text-primary">else</span> {<br/>
&nbsp;&nbsp;flushBuffer();<br/>
&nbsp;&nbsp;exec(<span class="text-tertiary">'GOLDFISH_LITE'</span>);<br/>
}`;
    });
  }

  // --- 6. Sandbox VM Terminal (Slide 14) ---
  const terminalConsole = document.querySelector('#section-14 .bg-surface\\/50');
  if (terminalConsole) {
    const sandboxLogs = [
      "[SYS] Initializing blast_radius_shield...",
      "[MEM] Allocation restricted to 256MB...",
      "[NET] Outbound egress denied...",
      "[CPU] Cycle monitoring active...",
      "[LOG] Anomaly detected in slide_14_logic...",
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
        const nextSec = sections[currentFocusedIndex + 1];
        if (nextSec) {
          isScrolling = true;
          nextSec.scrollIntoView({ behavior: 'smooth', block: 'start' });
          setTimeout(() => { isScrolling = false; }, 850);
        }
      }
    } else if (e.key === 'ArrowUp' || e.key === 'ArrowLeft' || e.key === 'PageUp') {
      e.preventDefault();
      
      if (currentFocusedIndex > 0) {
        const prevSec = sections[currentFocusedIndex - 1];
        if (prevSec) {
          isScrolling = true;
          prevSec.scrollIntoView({ behavior: 'smooth', block: 'start' });
          setTimeout(() => { isScrolling = false; }, 850);
        }
      }
    }
  });

  // --- 7.5 Studio Interface Controller ---
  const studioSpecBtns = document.querySelectorAll('.studio-spec-btn');
  const studioEditorTitle = document.getElementById('studio-editor-title');
  const studioEditorContent = document.getElementById('studio-editor-content');
  const studioTokenBadge = document.getElementById('studio-token-badge');
  const studioGenerateBtn = document.getElementById('studio-generate-btn');
  const studioTweakBtn = document.getElementById('studio-tweak-btn');
  const studioTweakMenu = document.getElementById('studio-tweak-menu');
  const studioTweakChips = document.querySelectorAll('.studio-tweak-chip');
  const studioStreamStatus = document.getElementById('studio-stream-status');
  const studioStreamStatusText = document.getElementById('studio-stream-status-text');
  const studioWriteStatus = document.getElementById('studio-write-status');
  const studioAppReloadBadge = document.getElementById('studio-app-reload-badge');
  const studioAppIframe = document.getElementById('studio-app-iframe');
  const studioLastAction = document.getElementById('studio-last-action');
  const studioSynthBadge = document.getElementById('studio-synth-badge');

  let currentSessionId = 'session_' + Math.random().toString(36).substring(2, 9);
  let activeTweak = '';
  let cachedSpecs = {
    'prd.md': { name: 'prd.md', tokens: '1,420', content: `# Ruby TV OTT-G1 Product Requirements (PRD)\n\n## 1. Executive Summary\nRuby TV is launching a next-generation smart television app (OTT-G1) targeting German-speaking audiences (DE). The application must deliver a sub-second, highly relevant content discovery experience that balances live sports broadcast rights, premium German original productions, and deep personal watch histories.\n\n## 2. Target Persona & Device Context\n- **Primary Persona:** The Curator (user_ruby_882)\n  - Preferences: Sci-Fi, Crime, Documentaries, German-language originals (DE).\n  - Watch Behavior: High completion rate on complex serialized narratives.\n- **Device Profile:** OTT-G1 (Smart TV / Set-Top Box)\n  - Constraint: Limited remote control interaction speed; first-screen recommendations (Für dich) must achieve >40% click-through without deep scrolling.\n\n## 3. Core Functional Requirements\n1. **Dynamic Rail Generation:** Recommender must rank 4 prime slots right above the fold.\n2. **Originals Promotion:** At least 2 slots right inside top recommendations must feature Ruby TV Original productions when confidence score > 0.4.\n3. **Cold-Start Fallback:** If watchHistory.length === 0, rank German-language originals and top live sporting events right at the top of the feed.\n4. **Transparency Badging:** Every recommendation card must output a human-readable reason (why this card?).` },
    'spec.md': { name: 'spec.md', tokens: '980', content: `# Recommender Engine Specification (recommender.js)\n\n## 1. Interface & Signature\nThe synthesized ES module must export an asynchronous rank function adhering to the contract:\n\`\`\`javascript\nexport async function rank(userContext, watchHistory, deviceContext) -> Promise<Array<RecommendationItem>>\n\`\`\`\n\n## 2. Scoring Algorithm Specs\n1. **Affinity Multiplier:** Multiply base item score by 1.4 if item.category intersects userContext.preferences.\n2. **Language Affinity:** Multiply by 1.3 if item.lang === userContext.preferredLang (DE).\n3. **Originals Boost:** Add +0.5 absolute boost if item.isOriginal === true AND userContext.preferences includes Crime or Sci-Fi.\n4. **Completion History Correlation:** If user completed >50% of an item in the same category within watchHistory, boost top candidates from that category right into slot 1.\n\n## 3. Output Requirements\nMust return exactly 4 items with properties:\n- id, title, category, rating, lang, isOriginal, reason (string explanation).` },
    'GEMINI.md': { name: 'GEMINI.md', tokens: '640', content: `# Antigravity Agent Guidelines for Ruby TV Recommender\n\n## 1. Architectural Guardrails\n- **Zero External Network Calls:** The generated recommender.js module executes inside a sandboxed client-side ES module worker. Do not emit fetch(), XMLHttpRequest, or external API imports.\n- **Pure Function Contract:** rank() must be deterministic and pure. Do not mutate watchHistory or userContext.\n- **Performance Budget:** Execution time right across 10,000 candidate evaluations must not exceed 16ms (60 FPS frame budget).\n\n## 2. Coding Style & Safety\n- Use ES6+ async/await syntax cleanly.\n- Include explanatory header comments referencing the active specification hash (#spec-ruby-tv-v2.4).\n- Never hardcode user IDs; always evaluate dynamically against userContext.userId.` },
    'design.md': { name: 'design.md', tokens: '720', content: `# System Architecture & UX Design Choices (design.md)\n\n## 1. UI Shell Cohesion\n- **Design System:** Ruby TV Dark Theme (#0A0A0A background, #E20074 magenta accent, #141414 card surface).\n- **Scanline Transparency:** Iframe must render with subtle CRT/OTT scanline overlay to simulate true Living Room device rendering.\n\n## 2. Recommender Transparency & Trust (Why This?)\n- Users on OTT-G1 report higher engagement when the app explains its ranking decisions.\n- Every card right in the Für dich rail must render a dynamic 💡 [Reason] pill explaining exact alignment with watch history or live trends.\n\n## 3. Hot-Swappable Module Pipeline\n- The Preact shell (index.html) imports recommender.js dynamically via await import(targetUrl). This decouples UI presentation from recommendation synthesis.` },
    'recommender.yaml': { name: 'recommender.yaml', tokens: '453', content: `# Active Specification Ruleset (recommender.yaml)\nschema_version: "2.4.0"\ntarget_device: "ott-g1"\nweights:\n  category_match: 1.4\n  lang_affinity_de: 1.3\n  ruby_original_boost: 0.5\n  history_completion_weight: 0.8\nfallback_rules:\n  cold_start_policy: "editorial_top_de_originals"\n  min_items_returned: 4\ntweak_overrides:\n  prefer_german_cold_start: true\n  prioritize_live_sports: false\n  min_rating_filter: 4.0\n` },
    'runbook.md': { name: 'runbook.md', tokens: '512', content: `# Operational Runbook: Hot-Synthesizing Recommender Logic\n\n## 1. Purpose\nDescribes step-by-step procedures for the Antigravity Agent when receiving spec tweaks from the Studio UI.\n\n## 2. Protocol Steps\n1. **Parse Tweak Intent:** Extract natural language instruction from #studio-tweak-btn injection.\n2. **Diff Specification:** Identify which weights in recommender.yaml or constraints in spec.md are modified by the tweak.\n3. **Synthesize JavaScript:** Generate fully formed ES module (recommender.js) implementing the updated constraints.\n4. **Verify Contract:** Validate that rank() returns exactly 4 items complete with valid reason fields.\n5. **Hot-Reload Shell:** Trigger iframe reload to index.html?session=<new_session_id> without dropping user context.` }
  };

  function escapeHtml(str) {
    return (str || '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  }

  function renderRichCode(codeStr, isSpec = false) {
    if (!studioEditorContent) return;
    const lines = (codeStr || '').split('\n');
    
    const formattedLines = lines.map((line, idx) => {
      const lineNum = (idx + 1).toString().padLeft(2, '0');
      const numSpan = `<span class="text-on-surface-variant/40 select-none inline-block w-8 mr-2 text-right">${lineNum}</span>`;
      
      if (isSpec) {
        let content = escapeHtml(line);
        if (line.startsWith('# ')) {
          content = `<span class="text-primary font-bold text-sm">${content}</span>`;
        } else if (line.startsWith('## ') || line.startsWith('### ')) {
          content = `<span class="text-secondary font-semibold">${content}</span>`;
        } else if (line.startsWith('- ') || line.startsWith('* ')) {
          content = `<span class="text-tertiary">${content}</span>`;
        } else if (line.startsWith('>') || line.startsWith('```')) {
          content = `<span class="text-on-surface-variant/60 italic">${content}</span>`;
        } else {
          content = `<span class="text-on-surface/90">${content}</span>`;
        }
        return `<div>${numSpan}${content}</div>`;
      } else {
        // JS Syntax Highlighting
        let content = escapeHtml(line);
        
        if (content.trim().startsWith('//')) {
          content = `<span class="text-on-surface-variant/50 italic">${content}</span>`;
        } else {
          content = content.replace(/\b(import|export|async|function|const|let|var|return|if|else|from|new|await|true|false)\b/g, '<span class="text-secondary font-semibold">$1</span>');
          content = content.replace(/\b(\d+(\.\d+)?)\b/g, '<span class="text-primary-fixed-dim">$1</span>');
          content = content.replace(/(&quot;.*?&quot;|&apos;.*?&apos;|&#039;.*?&#039;|'.*?'|".*?")/g, '<span class="text-tertiary">$1</span>');
          content = content.replace(/\b([a-zA-Z_$][0-9a-zA-Z_$]*)\s*\(/g, '<span class="text-primary font-bold">$1</span>(');
        }
        return `<div>${numSpan}${content}</div>`;
      }
    });

    studioEditorContent.innerHTML = formattedLines.join('');
  }

  // Render initial code state on load
  const initialCode = `// Ready to compile specification stack.
// Select a specification file on the left to inspect intent,
// or click ▶ GENERATE MODULE to synthesize the recommendation engine.

export async function rank(userContext, watchHistory, deviceContext) {
  // Awaiting compilation...
}`;
  renderRichCode(initialCode, false);

  // Fetch specs on load
  fetch('/api/studio/specs')
    .then(res => res.json())
    .then(data => {
      if (data && data.specs) {
        data.specs.forEach(spec => {
          cachedSpecs[spec.name] = spec;
        });
      }
    })
    .catch(err => console.log('Offline/Mock specs mode:', err));

  // Spec button click handler
  studioSpecBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      studioSpecBtns.forEach(b => b.classList.remove('active-spec', 'border-primary/50', 'bg-primary/10'));
      btn.classList.add('active-spec', 'border-primary/50', 'bg-primary/10');
      
      const specName = btn.dataset.spec;
      if (studioEditorTitle) studioEditorTitle.innerText = `content/ruby-tv/${specName}`;
      if (studioTokenBadge && cachedSpecs[specName]) {
        studioTokenBadge.innerText = `${cachedSpecs[specName].tokens} tokens ▾`;
      }
      if (cachedSpecs[specName]) {
        renderRichCode(cachedSpecs[specName].content, true);
      } else {
        renderRichCode(`# ${specName}\n\nLoading specification content...`, true);
      }
    });
  });

  // Tweak button toggle
  if (studioTweakBtn && studioTweakMenu) {
    studioTweakBtn.addEventListener('click', (e) => {
      e.stopPropagation();
      studioTweakMenu.classList.toggle('hidden');
    });
    document.addEventListener('click', (e) => {
      if (!studioTweakMenu.contains(e.target) && e.target !== studioTweakBtn) {
        studioTweakMenu.classList.add('hidden');
      }
    });
  }

  // Tweak chip click handler
  studioTweakChips.forEach(chip => {
    chip.addEventListener('click', () => {
      if (studioTweakMenu) studioTweakMenu.classList.add('hidden');
      activeTweak = chip.dataset.tweak || '';
      if (studioLastAction) {
        studioLastAction.innerText = `STATE: TWEAK -> ${activeTweak ? activeTweak.substring(0, 25) + '...' : 'STANDARD'}`;
      }
      runStudioGeneration(activeTweak);
    });
  });

  // Generate button click handler
  if (studioGenerateBtn) {
    studioGenerateBtn.addEventListener('click', () => {
      runStudioGeneration(activeTweak);
    });
  }

  async function runStudioGeneration(tweak = '') {
    if (!studioEditorContent) return;
    
    currentSessionId = 'session_' + Math.random().toString(36).substring(2, 9);
    
    if (studioEditorTitle) studioEditorTitle.innerText = '/demo/ruby/recommender.js';
    if (studioTokenBadge) studioTokenBadge.innerText = '4,213 tokens ▾';
    if (studioWriteStatus) studioWriteStatus.innerHTML = '<span class="text-amber-400">⏳ Compiling ES module...</span>';
    if (studioAppReloadBadge) studioAppReloadBadge.innerHTML = '<span>⏳</span><span>Compiling...</span>';
    if (studioSynthBadge) studioSynthBadge.classList.remove('hidden');
    if (studioStreamStatus) {
      studioStreamStatus.classList.remove('hidden');
      if (studioStreamStatusText) {
        studioStreamStatusText.innerText = `Assembling 4,213 tokens across 5 files → sending to Gemini 3.1 Pro...${tweak ? ' [Tweak Active]' : ''}`;
      }
    }
    
    let rawBuffer = '';
    renderRichCode('', false);

    try {
      const response = await fetch('/api/studio/generate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ session_id: currentSessionId, tweak: tweak })
      });

      if (!response.ok) throw new Error('Generation failed');
      
      const reader = response.body.getReader();
      const decoder = new TextDecoder();
      let buffer = '';

      while (true) {
        const { done, value } = await reader.read();
        if (done) break;
        
        buffer += decoder.decode(value, { stream: true });
        const lines = buffer.split('\n\n');
        buffer = lines.pop(); // keep last incomplete chunk
        
        for (const line of lines) {
          if (line.startsWith('data: ')) {
            try {
              const data = JSON.parse(line.substring(6));
              if (data.type === 'status') {
                if (studioStreamStatusText) studioStreamStatusText.innerText = data.message;
              } else if (data.type === 'chunk') {
                rawBuffer += data.text;
                renderRichCode(rawBuffer, false);
                const container = document.getElementById('studio-code-container');
                if (container) container.scrollTop = container.scrollHeight;
              } else if (data.type === 'complete') {
                if (studioStreamStatus) studioStreamStatus.classList.add('hidden');
                if (studioSynthBadge) studioSynthBadge.classList.add('hidden');
                if (studioWriteStatus) {
                  studioWriteStatus.innerHTML = '<span class="text-emerald-400">✓ Written to /demo/ruby/recommender.js</span>';
                }
                
                // Countdown and reload iframe
                let count = 3;
                if (studioAppReloadBadge) {
                  studioAppReloadBadge.innerHTML = `<span>↻</span><span>Reloading in ${count}…</span>`;
                }
                const timer = setInterval(() => {
                  count--;
                  if (count <= 0) {
                    clearInterval(timer);
                    if (studioAppReloadBadge) {
                      studioAppReloadBadge.innerHTML = `<span>✓</span><span>Hot-Reloaded (${tweak ? 'Custom Spec' : 'Standard Spec'})</span>`;
                    }
                    if (studioAppIframe) {
                      studioAppIframe.src = `/demo/ruby/index.html?session=${encodeURIComponent(currentSessionId)}&t=${Date.now()}`;
                    }
                    if (studioLastAction) {
                      studioLastAction.innerText = `STATE: COMPLETED (${tweak ? 'TWEAKED' : 'STANDARD'})`;
                    }
                  } else {
                    if (studioAppReloadBadge) {
                      studioAppReloadBadge.innerHTML = `<span>↻</span><span>Reloading in ${count}…</span>`;
                    }
                  }
                }, 700);
              }
            } catch (e) {
              console.error('Error parsing SSE event:', e);
            }
          }
        }
      }
    } catch (err) {
      console.log('Backend generation API not reachable (running in Sandboxed Static/Client-Side Simulation mode):', err);
      if (studioStreamStatus) {
        studioStreamStatus.classList.remove('hidden');
        if (studioStreamStatusText) {
          studioStreamStatusText.innerText = `[Sandboxed Client Mode] Synthesizing 4,213 tokens → applying tweak: ${tweak ? tweak : 'Standard Spec'}...`;
        }
      }
      
      const targetJS = tweak ? `// Synthesized Recommender Logic (Active Tweak: ${tweak})
// Compiled by Antigravity Studio Client Engine
// Target: Ruby TV OTT-G1 (Sandboxed Execution)

export async function rank(userContext, watchHistory, deviceContext) {
  const isColdStart = !watchHistory || watchHistory.length === 0;
  
  // Tweak Applied: ${tweak}
  const recommendations = [
    {
      id: 'twk1',
      title: '${tweak.includes('German') || tweak.includes('DE') ? 'Dark: The Final Cycle (Original)' : tweak.includes('sports') || tweak.includes('Sports') ? 'UEFA Champions League Live' : 'Babylon Berlin (Remastered)'}',
      category: '${tweak.includes('sports') || tweak.includes('Sports') ? 'Live Sports' : 'Crime / Drama'}',
      rating: 4.9,
      lang: 'DE',
      isOriginal: true,
      reason: 'Dynamic Spec Injection: ${tweak}'
    },
    {
      id: 'sci2',
      title: '3 Body Problem',
      category: 'Sci-Fi',
      rating: 4.8,
      lang: 'EN',
      reason: 'High Affinity: Matches your 65% watch completion of Dark Matter'
    },
    {
      id: 'doc2',
      title: 'Planet Earth III: Alpine Biomes',
      category: 'Documentary',
      rating: 4.9,
      lang: 'DE',
      reason: 'Language + Category match: DE Documentary preference'
    },
    {
      id: 'orig2',
      title: 'Der Schwarm',
      category: 'Sci-Fi / Thriller',
      rating: 4.7,
      lang: 'DE',
      isOriginal: true,
      reason: 'Ruby TV Original: Top trending in German territory'
    }
  ];
  
  return recommendations;
}` : `// Golden Recommender Engine Logic (Standard Specification V2.4)
// Synthesized for Ruby TV OTT-G1

export async function rank(userContext, watchHistory, deviceContext) {
  const isColdStart = !watchHistory || watchHistory.length === 0;
  
  if (isColdStart) {
    return [
      { id: 'orig1', title: 'Babylon Berlin', category: 'Crime', rating: 4.8, lang: 'DE', isOriginal: true, reason: 'Editorial Highlight: Top-rated German original series' },
      { id: 'orig2', title: 'Der Schwarm', category: 'Sci-Fi', rating: 4.5, lang: 'DE', isOriginal: true, reason: 'Trending in DE: Popular Sci-Fi original' },
      { id: 'spo1', title: 'Bundesliga Live: FCB vs BVB', category: 'Sports', rating: 4.9, lang: 'DE', isOriginal: false, reason: 'Live Sports: High viewership event right now' },
      { id: 'doc2', title: 'Planet Earth III', category: 'Documentary', rating: 4.9, lang: 'EN', isOriginal: false, reason: 'Critically Acclaimed: Award-winning documentary' }
    ];
  }
  
  return [
    { id: 'sci2', title: '3 Body Problem', category: 'Sci-Fi', rating: 4.7, lang: 'EN', reason: 'Because you watched 65% Dark Matter (Sci-Fi match)' },
    { id: 'doc3', title: 'Wild Germany', category: 'Documentary', rating: 4.6, lang: 'DE', reason: 'Because you enjoy Documentaries and German content' },
    { id: 'orig1', title: 'Babylon Berlin', category: 'Crime', rating: 4.8, lang: 'DE', isOriginal: true, reason: 'Ruby TV Original: Recommended for high engagement' },
    { id: 'thr1', title: 'Dark', category: 'Sci-Fi / Thriller', rating: 4.9, lang: 'DE', reason: 'Top match: Combines your Sci-Fi interest with German originals' }
  ];
}`;

      let chunkIdx = 0;
      const chunkSize = 80;
      const simTimer = setInterval(() => {
        if (chunkIdx < targetJS.length) {
          rawBuffer += targetJS.substring(chunkIdx, chunkIdx + chunkSize);
          renderRichCode(rawBuffer, false);
          const container = document.getElementById('studio-code-container');
          if (container) container.scrollTop = container.scrollHeight;
          chunkIdx += chunkSize;
        } else {
          clearInterval(simTimer);
          if (studioStreamStatus) studioStreamStatus.classList.add('hidden');
          if (studioSynthBadge) studioSynthBadge.classList.add('hidden');
          if (studioWriteStatus) {
            studioWriteStatus.innerHTML = '<span class="text-emerald-400">✓ Written to /demo/ruby/recommender.js (Sandboxed)</span>';
          }
          
          let count = 3;
          if (studioAppReloadBadge) {
            studioAppReloadBadge.innerHTML = `<span>↻</span><span>Reloading in ${count}…</span>`;
          }
          const reloadTimer = setInterval(() => {
            count--;
            if (count <= 0) {
              clearInterval(reloadTimer);
              if (studioAppReloadBadge) {
                studioAppReloadBadge.innerHTML = `<span>✓</span><span>Hot-Reloaded (${tweak ? 'Custom Spec' : 'Standard Spec'})</span>`;
              }
              if (studioAppIframe) {
                studioAppIframe.src = `/demo/ruby/index.html?session=default&t=${Date.now()}`;
              }
              if (studioLastAction) {
                studioLastAction.innerText = `STATE: COMPLETED (${tweak ? 'TWEAKED' : 'STANDARD'})`;
              }
            } else {
              if (studioAppReloadBadge) {
                studioAppReloadBadge.innerHTML = `<span>↻</span><span>Reloading in ${count}…</span>`;
              }
            }
          }, 600);
        }
      }, 40);
    }
  }
});
