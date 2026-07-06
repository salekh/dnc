import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../design_system/design_system.dart';

class MondayChecklists extends StatefulWidget {
  const MondayChecklists({super.key});

  @override
  State<MondayChecklists> createState() => _MondayChecklistsState();
}

class _MondayChecklistsState extends State<MondayChecklists> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  SharedPreferences? _prefs;

  final List<String> _humanItems = [
    "Workspace Sync: Sync local Git/Citc workspace and resolve divergent branches.",
    "Spec Drift Inspection: Review content/magenta-tv/spec.md proposals & comments.",
    "Static Quality Check: Verify compile states and run local static checkers.",
    "Alerts & Oncall Handovers: Review Buganizer queue and check weekend oncall logs."
  ];

  final List<String> _agentItems = [
    "Step 1: Codebase Interrogation - Trigger /interrogate template to check spec drift.",
    "Step 2: Dry-run Query Verification - Run query-watch-history dry-runs on BigQuery.",
    "Step 3: Execute Load/Regression Tests - Validate latency targets under load.",
    "Step 4: Report Status - Output weekly compliance report to JSON logs."
  ];

  Map<String, bool> _states = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStates() async {
    _prefs = await SharedPreferences.getInstance();
    if (_prefs != null) {
      final Map<String, bool> loaded = {};
      for (final item in _humanItems) {
        loaded['human_$item'] = _prefs!.getBool('human_$item') ?? false;
      }
      for (final item in _agentItems) {
        loaded['agent_$item'] = _prefs!.getBool('agent_$item') ?? false;
      }
      setState(() {
        _states = loaded;
      });
    }
  }

  Future<void> _toggleItem(String key) async {
    final newValue = !(_states[key] ?? false);
    setState(() {
      _states[key] = newValue;
    });
    if (_prefs != null) {
      await _prefs!.setBool(key, newValue);
    }
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "WEEKLY COMPLIANCE CHECKLISTS",
            style: AppTypography.caption.copyWith(
              color: AppColors.accentPrimary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Monday Morning Hygiene Playbooks",
            style: AppTypography.subheading.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),

          // Tab Bar
          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.accentPrimary,
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: const [
              Tab(text: "Human Developer"),
              Tab(text: "Automated Agent"),
            ],
          ),
          const SizedBox(height: 16),

          // Tab Contents
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChecklistList(_humanItems, "human"),
                _buildChecklistList(_agentItems, "agent"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistList(List<String> items, String prefix) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final key = '${prefix}_$item';
        final isChecked = _states[key] ?? false;

        return Card(
          color: AppColors.elevated,
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isChecked ? AppColors.accentPrimary.withOpacity(0.4) : Colors.transparent,
              width: 1,
            ),
          ),
          child: ListTile(
            leading: Checkbox(
              activeColor: AppColors.accentPrimary,
              value: isChecked,
              onChanged: (_) => _toggleItem(key),
            ),
            title: Text(
              item.split(" - ").first,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                decoration: isChecked ? TextDecoration.lineThrough : null,
                color: isChecked ? AppColors.textSecondary : AppColors.textPrimary,
              ),
            ),
            subtitle: item.contains(" - ")
                ? Text(
                    item.substring(item.indexOf(" - ") + 3),
                    style: TextStyle(
                      fontSize: 12,
                      decoration: isChecked ? TextDecoration.lineThrough : null,
                    ),
                  )
                : null,
            onTap: () => _toggleItem(key),
          ),
        );
      },
    );
  }
}
