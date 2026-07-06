import 'package:flutter/material.dart';
import '../design_system/design_system.dart';

class RepoTree extends StatefulWidget {
  const RepoTree({super.key});

  @override
  State<RepoTree> createState() => _RepoTreeState();
}

class _RepoTreeState extends State<RepoTree> {
  String? _selectedFileName;
  String _selectedFileContent = "Select a file from the repository tree to view its contents.";

  // Mock database of files in spec.md
  final Map<String, String> _filesData = {
    "spec.md": """# dintc Meta-Specification
- Root blueprint of the repository.
- Defines rules, pathways, and sandbox targets.
- All code generation must respect this root spec.""",

    "checklists.md": """# Monday-Morning Checklists
- Workspace sync commands
- Spec drift interrogation routines
- Dry-run query check lists
- Log reporting paths""",

    "interrogate.txt": """# Prompt Template: Interrogate
Check target directory paths for specification alignment.
Find illegal libraries, un-typed functions, and drift.""",

    "goldfish.txt": """# Prompt Template: Goldfish
Stateless translation mode. No memory retention.
Accepts single file inputs and returns direct change updates.""",

    "prd.md": """# PRD: Continue Watching Row
- Target: user watch history resumption
- SLA: <50ms P99 latency
- Story: carousel cards with 16:9 aspect ratios""",

    "design.md": """# Technical Design: Continue Watching
- Route: GET /api/v1/watching
- Format: JSON array
- Wireframe: horizontal scroll layout""",

    "plan.md": """# 6-Phase Implementation Roadmap
- Phase 1: Context Interrogation
- Phase 2: Schema generation
- Phase 3: Builder code synthesis
- Phase 4: Verifier validation""",

    "GEMINI.md": """# GEMINI Containment Rules
- NO unsafe pointers
- NO third_party/untrusted libraries
- Sandbox memory limit: 512MB""",

    "runbook.md": """# Oncall Incident Triage Runbook
- Alert: RecommendationsServiceHighLatency
- Steps: check logs, query DB, adjust throttle, redeploy.""",

    "deploy-recs-service.md": """# Skill: Deploy Recs Service
Playbook to deploy recommendations app:
1. Run verifier
2. Deploy Canary (10%)
3. Monitor logs for 120s
4. Rollout 100%""",

    "query-watch-history.md": """# Skill: Query Watch History
SQL dry-run query validator:
SELECT user_id, video_id, timestamp_seconds
FROM `magenta-tv.prod.watch_history`
WHERE user_id = @userId;"""
  };

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Text(
            "CONTAINMENT SANDBOX REPOSITORY TREE",
            style: AppTypography.caption.copyWith(
              color: AppColors.accentPrimary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Repository Layout & Mock File Viewer",
            style: AppTypography.subheading.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Panel: Collapsible File Tree
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.elevated,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFolderNode("dnc/", [
                            _buildFileNode("spec.md"),
                            _buildFolderNode("content/", [
                              _buildFileNode("checklists.md"),
                              _buildFolderNode("prompts/", [
                                _buildFileNode("interrogate.txt"),
                                _buildFileNode("goldfish.txt"),
                              ]),
                              _buildFolderNode("magenta-tv/", [
                                _buildFileNode("prd.md"),
                                _buildFileNode("design.md"),
                                _buildFileNode("plan.md"),
                                _buildFileNode("GEMINI.md"),
                                _buildFileNode("runbook.md"),
                                _buildFolderNode("skills/", [
                                  _buildFileNode("deploy-recs-service.md"),
                                  _buildFileNode("query-watch-history.md"),
                                ]),
                              ]),
                            ]),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Right Panel: Mock File Viewer Panel
                Expanded(
                  flex: 6,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.base,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.elevated, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedFileName ?? "NO FILE SELECTED",
                          style: TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _selectedFileName != null ? AppColors.accentPrimary : AppColors.textSecondary,
                          ),
                        ),
                        const Divider(color: AppColors.elevated, height: 20),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              _selectedFileContent,
                              style: const TextStyle(
                                fontFamily: 'Courier',
                                fontSize: 12,
                                height: 1.5,
                                color: Colors.greenAccent,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFolderNode(String name, List<Widget> children) {
    return Theme(
      data: ThemeData.dark().copyWith(
        dividerColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: const Icon(Icons.folder, color: Colors.amber, size: 18),
        title: Text(
          name,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(left: 16),
        children: children,
      ),
    );
  }

  Widget _buildFileNode(String name) {
    final isSelected = _selectedFileName == name;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFileName = name;
          _selectedFileContent = _filesData[name] ?? "Empty file.";
        });
      },
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentPrimary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(
              name.endsWith(".md") ? Icons.article : Icons.text_snippet_outlined,
              color: isSelected ? AppColors.accentPrimary : AppColors.textSecondary,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.accentPrimary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
