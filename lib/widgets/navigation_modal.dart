import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import 'glass_container.dart';

class NavigationModal extends StatefulWidget {
  const NavigationModal({super.key});

  @override
  State<NavigationModal> createState() => _NavigationModalState();
}

class _NavigationModalState extends State<NavigationModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final venue = appState.navigationTargetVenue;
    final isDark = appState.isDarkMode;

    if (venue == null) return const SizedBox.shrink();

    final isArrived = appState.navDistanceRemaining == 0;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkBg : AppTheme.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textMuted(isDark).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Banner
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: AppTheme.neonGlowDecoration(
                    color: isArrived
                        ? AppTheme.emeraldSuccess
                        : AppTheme.cyanPrimary,
                    borderRadius: 14,
                    isDark: isDark,
                  ),
                  child: Icon(
                    isArrived
                        ? Icons.check_circle_rounded
                        : Icons.navigation_rounded,
                    color: isArrived
                        ? AppTheme.emeraldSuccess
                        : AppTheme.cyanPrimary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArrived
                            ? 'ARRIVED AT DESTINATION'
                            : 'LIVE IPS INDOOR ROUTING',
                        style: TextStyle(
                          color: isArrived
                              ? AppTheme.emeraldSuccess
                              : AppTheme.cyanPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        '${venue.code} • ${venue.name}',
                        style: TextStyle(
                          color: AppTheme.textPrimary(isDark),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${venue.building} (Level ${venue.level})',
                        style: TextStyle(
                          color: AppTheme.textSecondary(isDark),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppTheme.textMuted(isDark),
                  ),
                  onPressed: () => appState.stopNavigation(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Simulated Interactive Indoor Map Blueprint Canvas
            GlassContainer(
              borderRadius: 20,
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: _IndoorRouteCanvasPainter(
                            progress:
                                1.0 -
                                (appState.navDistanceRemaining /
                                        (venue.distanceMeters > 0
                                            ? venue.distanceMeters
                                            : 1.0))
                                    .clamp(0.0, 1.0),
                            pulse: _pulseController.value,
                            isArrived: isArrived,
                            isDark: isDark,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.bluetooth_audio_rounded,
                              size: 14,
                              color: AppTheme.cyanPrimary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                appState.activeBleAnchor,
                                style: TextStyle(
                                  color: AppTheme.textMuted(isDark),
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.directions_walk_rounded,
                            size: 14,
                            color: AppTheme.purpleAccent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'PDR Step: ${appState.pdrStepCounter}',
                            style: TextStyle(
                              color: AppTheme.textMuted(isDark),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Distance & ETA Stats
            Row(
              children: [
                Expanded(
                  child: GlassContainer(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.straighten_rounded,
                          color: AppTheme.cyanPrimary,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Distance Left',
                              style: TextStyle(
                                color: AppTheme.textMuted(isDark),
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              '${appState.navDistanceRemaining.toInt()} m',
                              style: TextStyle(
                                color: AppTheme.textPrimary(isDark),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassContainer(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          color: AppTheme.purpleAccent,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Est. Arrival',
                              style: TextStyle(
                                color: AppTheme.textMuted(isDark),
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              '~${appState.navEstMinutesRemaining} min',
                              style: TextStyle(
                                color: AppTheme.textPrimary(isDark),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Step-by-Step Directions Guidance Card
            GlassContainer(
              borderColor: AppTheme.cyanPrimary.withValues(alpha: 0.3),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.cyanPrimary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isArrived
                          ? Icons.pin_drop_rounded
                          : appState.navCurrentStepIndex == 1
                          ? Icons.turn_right_rounded
                          : Icons.stairs_rounded,
                      color: AppTheme.cyanPrimary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArrived
                              ? 'Destination Reached'
                              : 'Step ${appState.navCurrentStepIndex} of 3',
                          style: const TextStyle(
                            color: AppTheme.cyanPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isArrived
                              ? 'You have arrived in front of ${venue.code} (${venue.name}).'
                              : appState.navCurrentStepIndex == 1
                              ? 'Walk straight 25 meters, then turn right toward West Stairwell.'
                              : 'Ascend to Level ${venue.level}. Room ${venue.code} is third door on the left.',
                          style: TextStyle(
                            color: AppTheme.textPrimary(isDark),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      appState.triggerArUcoRecalibration();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'ArUco Camera Vision Scan Completed! Position Rectified.',
                          ),
                          backgroundColor: AppTheme.cyanPrimary,
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.qr_code_scanner_rounded,
                      size: 18,
                      color: AppTheme.cyanPrimary,
                    ),
                    label: const Text(
                      'ArUco Recalibrate',
                      style: TextStyle(
                        color: AppTheme.cyanPrimary,
                        fontSize: 13,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppTheme.cyanPrimary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => appState.stopNavigation(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isArrived
                          ? AppTheme.emeraldSuccess
                          : AppTheme.roseAlert.withValues(alpha: 0.85),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      isArrived ? 'Finish Navigation' : 'Cancel Route',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _IndoorRouteCanvasPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final double pulse;
  final bool isArrived;
  final bool isDark;

  _IndoorRouteCanvasPainter({
    required this.progress,
    required this.pulse,
    required this.isArrived,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background Grid
    final gridPaint = Paint()
      ..color = AppTheme.cyanPrimary.withValues(alpha: 0.08)
      ..strokeWidth = 1.0;

    for (double x = 0; x < size.width; x += 25) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 25) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Corridor & Room Rectangles Mock (IMDF Geometry)
    final roomPaint = Paint()
      ..color = (isDark ? AppTheme.darkCard : AppTheme.lightSurface).withValues(
        alpha: 0.85,
      )
      ..style = PaintingStyle.fill;
    final roomBorderPaint = Paint()
      ..color = AppTheme.blueGlow.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Room A
    canvas.drawRRect(
      RRect.fromLTRBR(20, 20, 110, 80, const Radius.circular(8)),
      roomPaint,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(20, 20, 110, 80, const Radius.circular(8)),
      roomBorderPaint,
    );

    // Room B
    canvas.drawRRect(
      RRect.fromLTRBR(150, 20, 260, 80, const Radius.circular(8)),
      roomPaint,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(150, 20, 260, 80, const Radius.circular(8)),
      roomBorderPaint,
    );

    // Target Room (Destination)
    final targetRect = RRect.fromLTRBR(
      200,
      110,
      310,
      165,
      const Radius.circular(8),
    );
    final targetFill = Paint()
      ..color = AppTheme.cyanPrimary.withValues(alpha: 0.15);
    final targetBorder = Paint()
      ..color = AppTheme.cyanPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawRRect(targetRect, targetFill);
    canvas.drawRRect(targetRect, targetBorder);

    // D* Lite Path Line
    final path = Path();
    const startPt = Offset(50, 140);
    const turnPt1 = Offset(130, 140);
    const turnPt2 = Offset(130, 95);
    const endPt = Offset(200, 135);

    path.moveTo(startPt.dx, startPt.dy);
    path.lineTo(turnPt1.dx, turnPt1.dy);
    path.lineTo(turnPt2.dx, turnPt2.dy);
    path.lineTo(endPt.dx, endPt.dy);

    final pathPaint = Paint()
      ..color = AppTheme.cyanPrimary.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawPath(path, pathPaint);

    // Current Walked Path glowing cyan
    final currentOffset = _computePointOnPath(
      progress,
      startPt,
      turnPt1,
      turnPt2,
      endPt,
    );

    final walkedPaint = Paint()
      ..color = AppTheme.cyanPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final walkedPath = Path();
    walkedPath.moveTo(startPt.dx, startPt.dy);

    double segment = progress * 3.0; // 3 segments
    if (segment >= 1.0) {
      walkedPath.lineTo(turnPt1.dx, turnPt1.dy);
    } else {
      walkedPath.lineTo(
        startPt.dx + (turnPt1.dx - startPt.dx) * segment,
        startPt.dy,
      );
    }

    if (segment >= 2.0) {
      walkedPath.lineTo(turnPt2.dx, turnPt2.dy);
      double rest = segment - 2.0;
      walkedPath.lineTo(
        turnPt2.dx + (endPt.dx - turnPt2.dx) * rest,
        turnPt2.dy + (endPt.dy - turnPt2.dy) * rest,
      );
    } else if (segment > 1.0) {
      double rest = segment - 1.0;
      walkedPath.lineTo(
        turnPt1.dx,
        turnPt1.dy + (turnPt2.dy - turnPt1.dy) * rest,
      );
    }

    canvas.drawPath(walkedPath, walkedPaint);

    // Destination Pin
    canvas.drawCircle(endPt, 8, Paint()..color = AppTheme.purpleAccent);
    canvas.drawCircle(endPt, 4, Paint()..color = Colors.white);

    // Current User Kinematic Position Marker
    final userPos = currentOffset;
    final pulseRadius = 8.0 + (pulse * 8.0);

    canvas.drawCircle(
      userPos,
      pulseRadius,
      Paint()
        ..color = AppTheme.cyanPrimary.withValues(alpha: 0.3 - (pulse * 0.2)),
    );
    canvas.drawCircle(userPos, 7, Paint()..color = AppTheme.cyanPrimary);
    canvas.drawCircle(userPos, 3, Paint()..color = Colors.white);
  }

  Offset _computePointOnPath(
    double t,
    Offset p0,
    Offset p1,
    Offset p2,
    Offset p3,
  ) {
    if (t <= 0.33) {
      double sub = t / 0.33;
      return Offset(
        p0.dx + (p1.dx - p0.dx) * sub,
        p0.dy + (p1.dy - p0.dy) * sub,
      );
    } else if (t <= 0.66) {
      double sub = (t - 0.33) / 0.33;
      return Offset(
        p1.dx + (p2.dx - p1.dx) * sub,
        p1.dy + (p2.dy - p1.dy) * sub,
      );
    } else {
      double sub = (t - 0.66) / 0.34;
      return Offset(
        p2.dx + (p3.dx - p2.dx) * sub,
        p2.dy + (p3.dy - p2.dy) * sub,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _IndoorRouteCanvasPainter oldDelegate) => true;
}
