import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'design_system/design_system.dart';
import 'presenter/presenter_mode.dart';
import 'content/sections.g.dart';

// Import all 12 interactives
import 'interactives/slop_simulator.dart';
import 'interactives/snr_oscilloscope.dart';
import 'interactives/vanishing_layer.dart';
import 'interactives/playground.dart';
import 'interactives/loop.dart';
import 'interactives/interrogate_replay.dart';
import 'interactives/repo_tree.dart';
import 'interactives/adversarial_matrix.dart';
import 'interactives/blast_radius_explorer.dart';
import 'interactives/fleet_view.dart';
import 'interactives/focus_timer.dart';
import 'interactives/monday_checklists.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'dintc - Design Is The New Code',
      theme: getDarkTheme(),
      debugShowCheckedModeBanner: false,
      home: const PresenterMode(
        child: ScrollytellingContainer(),
      ),
    );
  }
}

class ScrollytellingContainer extends StatefulWidget {
  const ScrollytellingContainer({super.key});

  @override
  State<ScrollytellingContainer> createState() => _ScrollytellingContainerState();
}

class _ScrollytellingContainerState extends State<ScrollytellingContainer> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final page = _pageController.page ?? 0.0;
      final roundedPage = page.round();
      if (roundedPage != _currentIndex) {
        setState(() {
          _currentIndex = roundedPage;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _getInteractiveWidget(int index) {
    switch (index) {
      case 0:
        return const WelcomeWidget(
          title: 'THE EVOLUTION OF INTENT',
        );
      case 1:
        return const WelcomeWidget(
          title: 'THE ILLUSION OF SPEED',
        );
      case 2:
        return const SlopSimulator();
      case 3:
        return const WelcomeWidget(
          title: 'THE BLANK SLATE',
        );
      case 4:
        return const WelcomeWidget(
          title: 'THE EAGER RUNAWAY',
        );
      case 5:
        return const IllustratedInteractive(
          imagePath: 'assets/illustrations/spec_ssot.jpg',
          title: 'SPECIFICATIONS AS SSoT',
          interactiveWidget: SnrOscilloscope(),
        );
      case 6:
        return const IllustratedInteractive(
          imagePath: 'assets/illustrations/agentic_loop.jpg',
          title: 'THE SELF-HEALING AGENTIC LOOP',
          interactiveWidget: Loop(),
        );
      case 7:
        return const Playground(mode: PlaygroundMode.specStack);
      case 8:
        return const Playground(mode: PlaygroundMode.memoryModes);
      case 9:
        return const Playground(mode: PlaygroundMode.synthesis);
      case 10:
        return const RepoTree();
      case 11:
        return const WelcomeWidget(
          title: 'SHIFT LEFT OF DESIGN',
        );
      case 12:
        return const IllustratedInteractive(
          imagePath: 'assets/illustrations/vanishing_layer.jpg',
          title: 'THE VANISHING LAYER',
          interactiveWidget: VanishingLayer(),
        );
      case 13:
        return const InterrogateReplay();
      case 14:
        return const WelcomeWidget(
          imagePath: 'assets/illustrations/shift_hero.jpg',
          title: 'DESIGN IS THE NEW CODE',
        );
      case 15:
        return const BlastRadiusExplorer();
      case 16:
        return const IllustratedInteractive(
          imagePath: 'assets/illustrations/adversarial_verification.jpg',
          title: 'ADVERSARIAL VERIFICATION MATRIX',
          interactiveWidget: AdversarialMatrix(),
        );
      case 17:
        return const WelcomeWidget(
          imagePath: 'assets/illustrations/continuous_regeneration.jpg',
          title: 'CONTINUOUS REGENERATION',
        );
      case 18:
        return const FleetView();
      case 19:
        return const WelcomeWidget(
          title: 'SELF-HEALING ARCHITECTURES',
        );
      case 20:
        return const WelcomeWidget(
          imagePath: 'assets/illustrations/self_referential.jpg',
          title: 'THE SELF-REFERENTIAL ENGINE',
        );
      default:
        return const WelcomeWidget();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 950;

    return Scaffold(
      body: SafeArea(
        child: isDesktop ? _buildDesktopLayout(size) : _buildMobileLayout(size),
      ),
    );
  }

  // Desktop Split Layout with High-Density Grid elements
  Widget _buildDesktopLayout(Size size) {
    return Column(
      children: [
        // Responsive High-Density Navigation Header
        _buildTopNavigationHeader(),
        
        Expanded(
          child: Row(
            children: [
              // Left Column: Scrollable Markdown Prose
              Expanded(
                flex: 9,
                child: Container(
                  color: AppColors.surfaceLowest,
                  child: Column(
                    children: [
                      // Scrollable prose content
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          scrollDirection: Axis.vertical,
                          itemCount: sections.length,
                          itemBuilder: (context, index) {
                            final section = sections[index];
                            return Stack(
                              children: [
                                // Huge Watermark index number overlay in the background
                                Positioned(
                                  top: 16,
                                  right: 48,
                                  child: Opacity(
                                    opacity: 0.08,
                                    child: Text(
                                      section.index.toString().padLeft(2, '0'),
                                      style: AppTypography.displayXL.copyWith(
                                        fontSize: 220,
                                        fontStyle: FontStyle.italic,
                                        color: AppColors.primary,
                                        height: 0.9,
                                      ),
                                    ),
                                  ),
                                ),
                                // Editorial text content
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(48, 64, 48, 32),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "§${section.index}: ${section.title.toUpperCase()}",
                                        style: AppTypography.headlineMD.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Expanded(
                                        child: Markdown(
                                          data: section.content,
                                          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                                            p: AppTypography.bodyLG.copyWith(height: 1.7, color: AppColors.onSurfaceVariant),
                                            listBullet: const TextStyle(color: AppColors.primaryContainer, fontWeight: FontWeight.bold),
                                            code: const TextStyle(
                                              fontFamily: AppTypography.fontMono,
                                              fontSize: 13,
                                              color: Colors.greenAccent,
                                              backgroundColor: Colors.transparent,
                                            ),
                                            codeblockDecoration: BoxDecoration(
                                              color: AppColors.surfaceContainer,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: AppColors.outlineVariant, width: 1.0),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      
                      // Bottom decoration editorial accent bar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceContainer,
                          border: Border(
                            top: BorderSide(color: AppColors.outlineVariant, width: 1.0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "DINTC // DECK_V2_FINAL",
                              style: AppTypography.labelMono.copyWith(
                                fontSize: 11,
                                color: AppColors.onSurfaceVariant.withOpacity(0.4),
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 2,
                                  color: AppColors.primaryContainer,
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 48,
                                  height: 2,
                                  color: AppColors.outlineVariant.withOpacity(0.3),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 48,
                                  height: 2,
                                  color: AppColors.outlineVariant.withOpacity(0.3),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Vertical divider line
              Container(
                width: 1,
                color: AppColors.outlineVariant,
              ),

              // Right Column: Dynamic Interactive Widget / Cover Image
              Expanded(
                flex: 11,
                child: Container(
                  color: AppColors.surfaceLowest,
                  padding: const EdgeInsets.all(32),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.96, end: 1.0).animate(
                            CurvedAnimation(parent: animation, curve: AppMotion.silkCurve),
                          ),
                          child: child,
                        ),
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey<int>(_currentIndex),
                      child: _getInteractiveWidget(_currentIndex),
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

  // Mobile / Tablet Stack Layout
  Widget _buildMobileLayout(Size size) {
    return Column(
      children: [
        _buildTopNavigationHeader(),
        
        // Upper section: Interactive Widget
        Expanded(
          flex: 4,
          child: Container(
            color: AppColors.surfaceLowest,
            padding: const EdgeInsets.all(12),
            child: KeyedSubtree(
              key: ValueKey<int>(_currentIndex),
              child: _getInteractiveWidget(_currentIndex),
            ),
          ),
        ),

        const Divider(color: AppColors.outlineVariant, height: 1),

        // Lower section: Markdown Prose PageView
        Expanded(
          flex: 5,
          child: PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: sections.length,
            itemBuilder: (context, index) {
              final section = sections[index];
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "§${section.index}: ${section.title.toUpperCase()}",
                      style: AppTypography.subheading.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Markdown(
                        data: section.content,
                        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                          p: AppTypography.body.copyWith(fontSize: 14),
                          code: const TextStyle(
                            fontFamily: AppTypography.fontMono,
                            fontSize: 11,
                            color: Colors.greenAccent,
                          ),
                          codeblockDecoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopNavigationHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainer,
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant, width: 1.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo text with left border accent
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Design is the New Code".toUpperCase(),
                style: const TextStyle(
                  fontFamily: AppTypography.fontDisplay,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: -0.5,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          
          // Navigation tabs mapping to chapters
          Row(
            children: [
              _buildNavTab("THE SHIFT", 0, _currentIndex >= 0 && _currentIndex < 4),
              const SizedBox(width: 24),
              _buildNavTab("AHA MOMENTS", 4, _currentIndex >= 4 && _currentIndex < 8),
              const SizedBox(width: 24),
              _buildNavTab("EXECUTION", 8, _currentIndex >= 8 && _currentIndex < 12),
              const SizedBox(width: 24),
              _buildNavTab("THE FUTURE", 12, _currentIndex >= 12 && _currentIndex < 16),
              const SizedBox(width: 24),
              _buildNavTab("ORCHESTRATION", 16, _currentIndex >= 16 && _currentIndex < 21),
            ],
          ),

          // Slide counter controls
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_up, size: 20, color: AppColors.onSurface),
                onPressed: _currentIndex > 0
                    ? () {
                        _pageController.animateToPage(
                          _currentIndex - 1,
                          duration: const Duration(milliseconds: 500),
                          curve: AppMotion.silkCurve,
                        );
                      }
                    : null,
              ),
              Text(
                "${_currentIndex.toString().padLeft(2, '0')} / ${(sections.length - 1).toString().padLeft(2, '0')}",
                style: AppTypography.labelMono.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: AppColors.onSurface),
                onPressed: _currentIndex < sections.length - 1
                    ? () {
                        _pageController.animateToPage(
                          _currentIndex + 1,
                          duration: const Duration(milliseconds: 500),
                          curve: AppMotion.silkCurve,
                        );
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavTab(String label, int targetIndex, bool isActive) {
    return InkWell(
      onTap: () {
        _pageController.animateToPage(
          targetIndex,
          duration: const Duration(milliseconds: 600),
          curve: AppMotion.silkCurve,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? AppColors.primaryContainer : Colors.transparent,
              width: 2.0,
            ),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelMono.copyWith(
            fontWeight: FontWeight.bold,
            color: isActive ? AppColors.onSurface : AppColors.onSurfaceVariant.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}

// Welcome / Default Idle Interactive Widget
class WelcomeWidget extends StatefulWidget {
  final String? imagePath;
  final String? title;

  const WelcomeWidget({
    super.key,
    this.imagePath,
    this.title,
  });

  @override
  State<WelcomeWidget> createState() => _WelcomeWidgetState();
}

class _WelcomeWidgetState extends State<WelcomeWidget> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget graphic;
    if (widget.imagePath != null && widget.imagePath!.isNotEmpty) {
      graphic = Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              widget.imagePath!,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Center(child: _buildWireframe());
              },
            ),
          ),
        ),
      );
    } else {
      graphic = Padding(
        padding: const EdgeInsets.all(24.0),
        child: _buildWireframe(),
      );
    }

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant, width: 1.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          graphic,
          const SizedBox(height: 24),
          Text(
            (widget.title ?? "DESIGN IS THE NEW CODE").toUpperCase(),
            style: AppTypography.headlineSM.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "SCROLL SECTIONS TO ACTIVATE SIMULATORS",
            style: AppTypography.labelMono.copyWith(
              fontSize: 11,
              color: AppColors.onSurfaceVariant.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildWireframe() {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationController.value * 2 * math.pi,
          child: CustomPaint(
            size: const Size(180, 180),
            painter: _GeometricWireframePainter(),
          ),
        );
      },
    );
  }
}

class _GeometricWireframePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryContainer.withOpacity(0.4)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw concentric wireframe circles & polygons
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(center, radius * 0.6, paint);
    canvas.drawCircle(center, radius * 0.2, paint);

    // Draw octagram lines
    const int nodes = 8;
    final List<Offset> points = [];
    for (int i = 0; i < nodes; i++) {
      final angle = (i * 45) * math.pi / 180;
      points.add(Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      ));
    }

    for (int i = 0; i < nodes; i++) {
      canvas.drawLine(center, points[i], paint);
      // Connect alternate nodes to form a star
      canvas.drawLine(points[i], points[(i + 2) % nodes], paint);
      canvas.drawLine(points[i], points[(i + 3) % nodes], paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GeometricWireframePainter oldDelegate) => false;
}

class IllustratedInteractive extends StatefulWidget {
  final String imagePath;
  final Widget interactiveWidget;
  final String title;

  const IllustratedInteractive({
    super.key,
    required this.imagePath,
    required this.interactiveWidget,
    required this.title,
  });

  @override
  State<IllustratedInteractive> createState() => _IllustratedInteractiveState();
}

class _IllustratedInteractiveState extends State<IllustratedInteractive> {
  bool _showInteractive = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: _showInteractive
          ? widget.interactiveWidget
          : Container(
              key: const ValueKey('illustration'),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant, width: 1.0),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        widget.imagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return widget.interactiveWidget;
                        },
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 24,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _showInteractive = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryContainer,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, size: 20),
                      label: Text(
                        "LAUNCH WIDGET: ${widget.title}",
                        style: AppTypography.labelMono.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
