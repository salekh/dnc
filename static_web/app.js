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
        if (id === 'section-1-1') {
          displayStr = '01.1 / 18';
        } else if (id === 'section-1-2') {
          displayStr = '01.2 / 18';
        } else if (id === 'section-13-5') {
          displayStr = '13.5 / 18';
        } else if (id === 'section-3-5') {
          displayStr = '03.5 / 18';
        } else {
          const index = parseInt(id.split('-')[1]);
          displayStr = `${index.toString().padStart(2, '0')} / 18`;
        }
        slideIndicator.innerText = displayStr;
        currentFocusedIndex = idxInList;
        
        let activeChapterIdx = 0;
        if (idxInList >= 7 && idxInList < 11) activeChapterIdx = 1;       // AHA MOMENTS (Indices 7..10)
        else if (idxInList >= 11 && idxInList < 18) activeChapterIdx = 2; // EXECUTION (Indices 11..17)
        else if (idxInList >= 18 && idxInList < 20) activeChapterIdx = 3; // ORCHESTRATION (Indices 18..19)
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

  // --- 7. Interactive Latency Trigger (Slide 16) ---
  const pipelineBtn = document.querySelector('#section-16 .bg-primary');
  const latencyTimer = document.querySelector('#section-16 .text-primary');

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
  let cachedSpecs = {};

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
      console.error('Studio generation error:', err);
      if (studioStreamStatus) studioStreamStatus.classList.add('hidden');
      if (studioSynthBadge) studioSynthBadge.classList.add('hidden');
      if (studioWriteStatus) studioWriteStatus.innerHTML = '<span class="text-red-400">⚠️ Generation error - Reverting to Golden Fallback</span>';
      if (studioAppIframe) {
        studioAppIframe.src = `/demo/ruby/index.html?session=default&t=${Date.now()}`;
      }
    }
  }
});
