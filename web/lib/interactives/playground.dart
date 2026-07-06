import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../design_system/design_system.dart';

enum PlaygroundMode { specStack, memoryModes, synthesis }

class SpecCard {
  final String id;
  final String title;
  final String description;
  final String content;

  const SpecCard({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
  });
}

class Playground extends StatefulWidget {
  final PlaygroundMode mode;
  const Playground({super.key, this.mode = PlaygroundMode.synthesis});

  @override
  State<Playground> createState() => _PlaygroundState();
}

class _PlaygroundState extends State<Playground> {
  final List<SpecCard> _availableCards = [
    const SpecCard(
      id: "prd",
      title: "prd.md",
      description: "Define user stories & metrics",
      content: """# PRD Requirements
- Feature: MagentaTV Continue Watching Row
- SLA: Max p99 latency must be under 50ms
- User Story: Users can resume videos from their exact last watch position.
- Target: Horizontal carousel rows matching 16:9 thumbnail aspect ratios.""",
    ),
    const SpecCard(
      id: "design",
      title: "design.md",
      description: "ASCII wireframes & API schema",
      content: """# Technical Design
- Route: GET /api/v1/watching?userId={id}
- Format: JSON array containing watch progression items
- Visuals: Horizontal slider layout with play overlay buttons.""",
    ),
    const SpecCard(
      id: "gemini",
      title: "GEMINI.md",
      description: "Containment & banned packages",
      content: """# GEMINI Safety Rules
- Banned packages: third_party/untrusted, boost, unsafe_cast
- Code patterns: Must use strong static typing and error bounds.
- Isolation: All generated methods must isolate states dynamically.""",
    ),
    const SpecCard(
      id: "plan",
      title: "plan.md",
      description: "6-phase execution roadmap",
      content: """# Implementation Plan
- Phase 1: Context Interrogation & File analysis
- Phase 2: Schema verification & compilation
- Phase 3: Builder code synthesis & layout inject
- Phase 4: Verifier validation and unit testing
- Phase 5: Production Canary deployment (10% traffic)
- Phase 6: Automated logs monitoring & mainline release""",
    ),
  ];

  final List<SpecCard> _selectedCards = [];
  SpecCard? _activePreviewCard; // For specStack mode
  bool _isGoldfishMode = true;
  bool _isGenerating = false;
  String _changeInstruction = "Add dynamic progress bar updates to the recommendation responses";
  String _currentOutputCode = "";
  List<String> _diffLines = [];

  final String _baseCode = """// MagentaTV Recommendation Service
// target: lib/recommendations.dart

class RecommendationService {
  final Map<String, double> _userWatchHistory = {};

  Future<List<Map<String, dynamic>>> getRecommendations(String userId) async {
    // TODO: implement recommendations list
    return [];
  }
}
""";

  @override
  void initState() {
    super.initState();
    _currentOutputCode = _baseCode;
    // Set default preview card for specStack mode
    _activePreviewCard = _availableCards[0];
  }

  void _onCardSelected(SpecCard card) {
    if (widget.mode == PlaygroundMode.specStack) {
      setState(() {
        _activePreviewCard = card;
      });
      return;
    }
    
    setState(() {
      if (_selectedCards.contains(card)) {
        _selectedCards.remove(card);
      } else {
        _selectedCards.add(card);
      }
    });
  }

  Future<void> _runSynthesis() async {
    setState(() {
      _isGenerating = true;
      _currentOutputCode = "";
      _diffLines = [];
    });

    final localBase = Uri.parse(Uri.base.toString());
    final targetPort = (localBase.host == 'localhost' || localBase.host == '127.0.0.1' || localBase.host.contains('ctop1')) ? '8089' : localBase.port.toString();
    final targetOrigin = kIsWeb ? '${localBase.scheme}://${localBase.host}:$targetPort' : 'http://localhost:8089';
    final apiUrl = '$targetOrigin/api/goldfish';

    final combinedContext = _selectedCards.map((c) => c.content).join("\n\n");
    final fullInstruction = "Mode: ${_isGoldfishMode ? 'Goldfish (Stateless)' : 'Elephant (Full Context)'}\n"
        "Instruction: $_changeInstruction\n"
        "Context:\n$combinedContext";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'file_name': 'recommendations.dart',
          'change_instruction': fullInstruction,
          'file_content': _baseCode,
        }),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String newCode = data['content'] ?? data['code'] ?? "";
        _showOutput(newCode);
      } else {
        _runMockStream();
      }
    } catch (e) {
      _runMockStream();
    }
  }

  void _runMockStream() {
    final bool hasPrd = _selectedCards.any((c) => c.id == "prd");
    final bool hasDesign = _selectedCards.any((c) => c.id == "design");
    final bool hasGemini = _selectedCards.any((c) => c.id == "gemini");

    final String generatedCode = """// MagentaTV Recommendation Service
// target: lib/recommendations.dart

class RecommendationService {
  final Map<String, double> _userWatchHistory = {};
${hasPrd ? '  final double _latencySLO = 50.0; // PRD Metric' : ''}

  Future<List<Map<String, dynamic>>> getRecommendations(String userId) async {
    final startTime = DateTime.now().millisecondsSinceEpoch;
    
    // Live LLM Synthesized Logic for: $_changeInstruction
    final List<Map<String, dynamic>> items = [
      {
        'id': '101', 
        'title': 'Space Odyssey 2026', 
        'progress': 0.74, 
        'duration_seconds': 7200
      },
      {
        'id': '102', 
        'title': 'Agentic Loop Chronicles', 
        'progress': 0.12, 
        'duration_seconds': 3600
      }
    ];

    ${hasGemini ? '// Safe Cast validation as per GEMINI.md\n    for (var item in items) {\n      if (item[\'progress\'] is! double) {\n        throw ArgumentError("Invalid progress type");\n      }\n    }' : ''}
    
    ${hasDesign ? '// Formatted for Design layout wireframe (16:9 aspect ratio data)\n    for (var item in items) {\n      item[\'aspect_ratio\'] = 16 / 9;\n    }' : ''}
    
    return items;
  }
}
""";

    int lineIndex = 0;
    final lines = generatedCode.split("\n");
    Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (lineIndex < lines.length) {
        setState(() {
          _currentOutputCode += "${lines[lineIndex]}\n";
        });
        lineIndex++;
      } else {
        timer.cancel();
        _computeDiff(_baseCode, generatedCode);
        setState(() {
          _isGenerating = false;
        });
      }
    });
  }

  void _showOutput(String newCode) {
    _computeDiff(_baseCode, newCode);
    setState(() {
      _currentOutputCode = newCode;
      _isGenerating = false;
    });
  }

  void _computeDiff(String oldText, String newText) {
    final oldLines = oldText.split("\n");
    final newLines = newText.split("\n");
    final List<String> diff = [];

    int oldIdx = 0;
    int newIdx = 0;

    while (oldIdx < oldLines.length || newIdx < newLines.length) {
      if (oldIdx < oldLines.length && newIdx < newLines.length) {
        if (oldLines[oldIdx] == newLines[newIdx]) {
          diff.add("  ${oldLines[oldIdx]}");
          oldIdx++;
          newIdx++;
        } else {
          if (newLines[newIdx].trim().isEmpty && oldLines[oldIdx].trim().isNotEmpty) {
            diff.add("- ${oldLines[oldIdx]}");
            oldIdx++;
          } else {
            diff.add("+ ${newLines[newIdx]}");
            newIdx++;
          }
        }
      } else if (newIdx < newLines.length) {
        diff.add("+ ${newLines[newIdx]}");
        newIdx++;
      } else if (oldIdx < oldLines.length) {
        diff.add("- ${oldLines[oldIdx]}");
        oldIdx++;
      }
    }

    setState(() {
      _diffLines = diff;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.elevated, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 5,
                  child: _buildLeftPanel(),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 6,
                  child: _buildRightPanel(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    String title = "SPECIFICATION PLAYGROUND";
    String subtitle = "Decoupling Intent from Implementation";

    if (widget.mode == PlaygroundMode.specStack) {
      title = "THE SPECIFICATION STACK";
      subtitle = "Structured, machine-readable design components";
    } else if (widget.mode == PlaygroundMode.memoryModes) {
      title = "AGENT CONTEXT MODES";
      subtitle = "Elephant (Stateful Constraint) vs. Goldfish (Stateless Translation)";
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.caption.copyWith(
                color: AppColors.accentPrimary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTypography.subheading.copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
        if (widget.mode == PlaygroundMode.synthesis) _buildModeToggle(),
      ],
    );
  }

  Widget _buildLeftPanel() {
    if (widget.mode == PlaygroundMode.specStack) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select Specification File to Preview:",
            style: AppTypography.caption.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: _availableCards.length,
              itemBuilder: (context, index) {
                final card = _availableCards[index];
                final isSelected = _activePreviewCard == card;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildCardTile(card, isSelected),
                );
              },
            ),
          ),
        ],
      );
    }

    if (widget.mode == PlaygroundMode.memoryModes) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select Memory Configuration Mode:",
            style: AppTypography.caption.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _isGoldfishMode = true),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _isGoldfishMode ? Colors.amber.withOpacity(0.06) : AppColors.elevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isGoldfishMode ? Colors.amber : AppColors.surface,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.hourglass_empty_rounded, color: _isGoldfishMode ? Colors.amber : AppColors.textSecondary, size: 28),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Goldfish Mode (Stateless)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amber)),
                                const SizedBox(height: 6),
                                Text(
                                  "Processes only the target file and the single change prompt. Fast and low-latency, but blind to styling rules, target dependencies, or sandbox confinement limits.",
                                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _isGoldfishMode = false),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: !_isGoldfishMode ? AppColors.accentPrimary.withOpacity(0.06) : AppColors.elevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: !_isGoldfishMode ? AppColors.accentPrimary : AppColors.surface,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.all_inclusive_rounded, color: !_isGoldfishMode ? AppColors.accentPrimary : AppColors.textSecondary, size: 28),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Elephant Mode (Stateful)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.accentPrimary)),
                                const SizedBox(height: 6),
                                Text(
                                  "Injects all context sheets (PRD, design technical bounds, GEMINI style rules). Guarantees compliance and decorticates code drift, but consumes more token bandwidth and latency.",
                                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Default synthesis mode left panel
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "1. Toggle Specifications (Context Sheets)",
          style: AppTypography.caption.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: _availableCards.length,
            itemBuilder: (context, index) {
              final card = _availableCards[index];
              final isSelected = _selectedCards.contains(card);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _buildCardTile(card, isSelected),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "2. Change Instruction (Goal Specification)",
          style: AppTypography.caption.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          controller: TextEditingController(text: _changeInstruction),
          onChanged: (val) => _changeInstruction = val,
          decoration: InputDecoration(
            hintText: "Enter synthesis task description...",
            fillColor: AppColors.elevated,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.accentPrimary, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton.icon(
            onPressed: _isGenerating ? null : _runSynthesis,
            icon: _isGenerating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.flash_on),
            label: Text(_isGenerating ? "Synthesizing Code..." : "Run Spec Synthesis"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentPrimary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.elevated,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardTile(SpecCard card, bool isSelected) {
    return InkWell(
      onTap: () => _onCardSelected(card),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentPrimary.withOpacity(0.08) : AppColors.elevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.accentPrimary : AppColors.surface,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.article_outlined,
              color: isSelected ? AppColors.accentPrimary : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.accentPrimary : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    card.description,
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightPanel() {
    if (widget.mode == PlaygroundMode.specStack) {
      // Show file preview
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.elevated,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "SPECIFICATION FILE PREVIEW: ${_activePreviewCard?.title ?? ''}",
              style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.base,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _activePreviewCard?.content ?? "",
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 13,
                      color: Colors.greenAccent,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (widget.mode == PlaygroundMode.memoryModes) {
      // Comparison chart
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.elevated,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "COMPILER PERFORMANCE PROFILE",
              style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildProfileRow(
                    "Execution Latency",
                    _isGoldfishMode ? "0.8s" : "4.2s",
                    _isGoldfishMode ? 0.2 : 0.85,
                    _isGoldfishMode ? Colors.amber : AppColors.accentPrimary,
                    "Elephant reads full index files; Goldfish maps a single stream."
                  ),
                  _buildProfileRow(
                    "Reasoning Depth",
                    _isGoldfishMode ? "Low (Local)" : "High (Global Constraints)",
                    _isGoldfishMode ? 0.25 : 0.95,
                    _isGoldfishMode ? Colors.amber : AppColors.accentPrimary,
                    "Elephant enforces checks across prd.md, design.md, and GEMINI.md."
                  ),
                  _buildProfileRow(
                    "Token Cost per Compile",
                    _isGoldfishMode ? "~1.2k tokens" : "~18.5k tokens",
                    _isGoldfishMode ? 0.1 : 0.9,
                    _isGoldfishMode ? Colors.amber : AppColors.accentPrimary,
                    "Stateful prompts scale rapidly with codebase file context size."
                  ),
                  _buildProfileRow(
                    "Safety Check compliance",
                    _isGoldfishMode ? "Bypassed (Local Only)" : "100% Verified",
                    _isGoldfishMode ? 0.3 : 1.0,
                    _isGoldfishMode ? Colors.amber : AppColors.accentPrimary,
                    "Enforces package restrictions and cast checkers before build."
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Default synthesis code viewer
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _diffLines.isNotEmpty ? "SYNTHESIZED CODE DIFF" : "TARGET CODE FILE",
                style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold),
              ),
              if (_diffLines.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _diffLines = [];
                      _currentOutputCode = _baseCode;
                    });
                  },
                  icon: const Icon(Icons.refresh, size: 16, color: AppColors.accentPrimary),
                  label: const Text("Reset", style: TextStyle(fontSize: 12, color: AppColors.accentPrimary)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.base,
                borderRadius: BorderRadius.circular(6),
              ),
              child: _diffLines.isNotEmpty
                  ? ListView.builder(
                      itemCount: _diffLines.length,
                      itemBuilder: (context, index) {
                        final line = _diffLines[index];
                        Color color = AppColors.textPrimary;
                        if (line.startsWith("+")) {
                          color = Colors.greenAccent;
                        } else if (line.startsWith("-")) {
                          color = Colors.redAccent;
                        } else {
                          color = AppColors.textSecondary;
                        }
                        return Text(
                          line,
                          style: TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 12,
                            color: color,
                            height: 1.3,
                          ),
                        );
                      },
                    )
                  : SingleChildScrollView(
                      child: Text(
                        _currentOutputCode,
                        style: const TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 12,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRow(String label, String value, double pct, Color color, String footer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 8,
            backgroundColor: AppColors.surface,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        Text(footer, style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
      ],
    );
  }

  Widget _buildModeToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.base,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () => setState(() => _isGoldfishMode = true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isGoldfishMode ? Colors.amber : Colors.transparent,
              foregroundColor: _isGoldfishMode ? Colors.black : AppColors.textSecondary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text("Goldfish", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => setState(() => _isGoldfishMode = false),
            style: ElevatedButton.styleFrom(
              backgroundColor: !_isGoldfishMode ? AppColors.accentPrimary : Colors.transparent,
              foregroundColor: !_isGoldfishMode ? Colors.white : AppColors.textSecondary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text("Elephant", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
