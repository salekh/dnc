import 'package:flutter/material.dart';
import '../design_system/design_system.dart';

class VanishingLayer extends StatefulWidget {
  const VanishingLayer({super.key});

  @override
  State<VanishingLayer> createState() => _VanishingLayerState();
}

class _VanishingLayerState extends State<VanishingLayer> {
  double _year = 1980; // 1950 to 2026

  // Define layers and their lifespan
  final List<Map<String, dynamic>> _layers = [
    {
      "name": "Design & Intent Specification",
      "color": AppColors.accentPrimary,
      "desc": "Human defines system bounds, constraints, and business rules.",
      "startYear": 2020,
      "endYear": 2026,
    },
    {
      "name": "Manual Developer Coding / Translation",
      "color": Colors.amber,
      "desc": "Human translates designs into syntax, satisfying package managers, compilers, and linters.",
      "startYear": 1960,
      "endYear": 2022,
    },
    {
      "name": "Frameworks & Standard Libraries",
      "color": Colors.indigoAccent,
      "desc": "Standardizing abstractions (e.g. databases, HTTP routers, UI kits) to hide boilerplate.",
      "startYear": 1990,
      "endYear": 2025,
    },
    {
      "name": "Compilers & Virtual Machines",
      "color": Colors.teal,
      "desc": "Translates high-level code (C, Java) into hardware-native machine instructions.",
      "startYear": 1955,
      "endYear": 2026,
    },
    {
      "name": "Physical Hardware / CPU Silicon",
      "color": Colors.blueGrey,
      "desc": "Executes raw binary machine instructions in logic gates.",
      "startYear": 1950,
      "endYear": 2026,
    },
  ];

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ABSTRACTION STACK TRANSITION",
                    style: AppTypography.caption.copyWith(
                      color: AppColors.accentPrimary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "The Vanishing Translation Layer",
                    style: AppTypography.subheading.copyWith(color: AppColors.textPrimary),
                  ),
                ],
              ),
              Text(
                "YEAR: ${_year.toInt()}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentPrimary,
                  fontFamily: 'Courier',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stacked Layers Visualization
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _layers.map((layer) {
                // Calculate height and visibility factors based on selected year
                final double startYear = layer["startYear"].toDouble();
                final double endYear = layer["endYear"].toDouble();

                double visibility = 0.0;
                if (_year >= startYear && _year <= endYear) {
                  visibility = 1.0;
                } else if (_year > endYear) {
                  // Fade out / vanish
                  visibility = (1.0 - (_year - endYear) / 6.0).clamp(0.0, 1.0);
                } else {
                  // Not yet introduced
                  visibility = (1.0 - (startYear - _year) / 10.0).clamp(0.0, 1.0);
                }

                final name = layer["name"] as String;
                final color = layer["color"] as Color;
                final desc = layer["desc"] as String;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: visibility > 0 ? 55 * visibility : 0,
                  margin: EdgeInsets.symmetric(vertical: 4 * visibility),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: visibility,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        border: Border.all(color: color.withOpacity(0.8), width: 1.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.layers, color: color),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  desc,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.caption.copyWith(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Year Slider Control
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("1950 (Assembly)", style: AppTypography.caption),
                  const Text("2026 (dintc Spec Synthesis)", style: AppTypography.caption),
                ],
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.accentPrimary,
                  thumbColor: AppColors.accentPrimary,
                  trackHeight: 4,
                ),
                child: Slider(
                  value: _year,
                  min: 1950.0,
                  max: 2026.0,
                  onChanged: (val) {
                    setState(() {
                      _year = val;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
