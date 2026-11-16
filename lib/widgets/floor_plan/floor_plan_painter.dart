import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'floor_plan_data.dart';

/// Draws the First Floor plan exactly like the reference image:
/// near-black background, thin white outlines, white labels.
/// Rooms listed in [occupancy] also get a green (free) / red (occupied)
/// tint and a status pin; [selectedId] is highlighted in cyan.
class FloorPlanPainter extends CustomPainter {
  FloorPlanPainter({
    required this.rooms,
    required this.lines,
    required this.lineWidth,
    required this.pinRadius,
    this.selectedId,
    this.occupancy = const {},
    this.routePoints,
    this.progress = 0.0,
    this.pulse = 0.0,
    this.isNavigating = false,
    this.isArrived = false,
  });

  final List<PlanRoom> rooms;
  final List<List<Offset>> lines;

  /// Stroke width in plan pixels (the widget keeps it ~constant on screen).
  final double lineWidth;
  final double pinRadius;
  final String? selectedId;

  /// roomId -> isOccupied
  final Map<String, bool> occupancy;

  /// Navigation parameters for drawing live routes & user location on the floor plan
  final List<Offset>? routePoints;
  final double progress; // 0.0 to 1.0
  final double pulse;    // 0.0 to 1.0
  final bool isNavigating;
  final bool isArrived;

  static const Color background = Color(0xFF111111);
  static const Color free = Color(0xFF00E676);
  static const Color occupied = Color(0xFFFF3B30);
  static const Color selected = Color(0xFF00E5FF);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.white.withValues(alpha: 0.92);

    final selectedStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth * 1.8
      ..strokeJoin = StrokeJoin.round
      ..color = selected;

    // 1) Room fills (status tint / selection) + outlines
    for (final room in rooms) {
      final isSelected = room.id == selectedId;
      final isOccupied = occupancy[room.id];

      Color? tint;
      if (isSelected) {
        tint = selected.withValues(alpha: 0.25 + (pulse * 0.15));
      } else if (isOccupied != null) {
        tint = (isOccupied ? occupied : free).withValues(alpha: 0.28);
      }
      if (tint != null) {
        canvas.drawPath(room.path, Paint()..color = tint);
      }
      canvas.drawPath(room.path, isSelected ? selectedStroke : stroke);
    }

    // 2) Walls / corridor edges
    for (final line in lines) {
      canvas.drawPath(Path()..addPolygon(line, false), stroke);
    }

    // 3) Draw Navigation Route & Moving Location Marker on the Floor Plan
    if (isNavigating && routePoints != null && routePoints!.length >= 2) {
      _paintNavigationRoute(canvas);
    }

    // 4) Labels (+ pins, which sit just above the label)
    for (final room in rooms) {
      if (room.label.isEmpty) continue;

      final isSelected = room.id == selectedId;

      final tp = TextPainter(
        text: TextSpan(
          text: room.label,
          style: TextStyle(
            color: isSelected ? selected : Colors.white,
            fontSize: room.fontSize,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            height: room.lineHeight,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      final radians = room.angle * math.pi / 180;

      canvas.save();
      canvas.translate(room.labelAt.dx, room.labelAt.dy);
      canvas.rotate(radians);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();

      final isOccupied = occupancy[room.id];
      if (isOccupied != null && !isSelected) {
        final d = tp.height / 2 + pinRadius + 6;
        final pinCenter = room.labelAt +
            Offset(d * math.sin(radians), -d * math.cos(radians));
        _paintPin(canvas, pinCenter, isOccupied ? occupied : free);
      }
    }
  }

  void _paintNavigationRoute(Canvas canvas) {
    final pts = routePoints!;

    // A) Draw full planned route path line
    final fullPath = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < pts.length; i++) {
      fullPath.lineTo(pts[i].dx, pts[i].dy);
    }

    final fullPathPaint = Paint()
      ..color = selected.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth * 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(fullPath, fullPathPaint);

    // B) Calculate total path length and compute user current position
    double totalLength = 0;
    final segmentLengths = <double>[];
    for (int i = 0; i < pts.length - 1; i++) {
      final len = (pts[i + 1] - pts[i]).distance;
      segmentLengths.add(len);
      totalLength += len;
    }

    final targetDist = totalLength * progress.clamp(0.0, 1.0);
    double accumulated = 0;
    Offset userPos = pts.first;

    final walkedPath = Path()..moveTo(pts[0].dx, pts[0].dy);

    for (int i = 0; i < segmentLengths.length; i++) {
      final segLen = segmentLengths[i];
      if (accumulated + segLen >= targetDist) {
        final remaining = targetDist - accumulated;
        final ratio = segLen > 0 ? remaining / segLen : 0.0;
        userPos = Offset.lerp(pts[i], pts[i + 1], ratio)!;
        walkedPath.lineTo(userPos.dx, userPos.dy);
        break;
      } else {
        accumulated += segLen;
        walkedPath.lineTo(pts[i + 1].dx, pts[i + 1].dy);
      }
    }

    // C) Draw walked route line in vibrant cyan
    final walkedPaint = Paint()
      ..color = selected
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth * 4.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(walkedPath, walkedPaint);

    // D) Destination Pin at final waypoint
    final destPt = pts.last;
    final destColor = isArrived ? free : const Color(0xFFD500F9);
    canvas.drawCircle(
      destPt,
      pinRadius * 2.2 + (pulse * 6),
      Paint()..color = destColor.withValues(alpha: 0.35 - (pulse * 0.2)),
    );
    canvas.drawCircle(destPt, pinRadius * 1.4, Paint()..color = destColor);
    canvas.drawCircle(destPt, pinRadius * 0.6, Paint()..color = Colors.white);

    // E) Current User Location Kinematic Marker
    final pulseRadius = (pinRadius * 2.0) + (pulse * 12.0);
    canvas.drawCircle(
      userPos,
      pulseRadius,
      Paint()..color = selected.withValues(alpha: 0.4 - (pulse * 0.25)),
    );
    canvas.drawCircle(userPos, pinRadius * 1.5, Paint()..color = selected);
    canvas.drawCircle(userPos, pinRadius * 0.6, Paint()..color = Colors.white);
  }

  void _paintPin(Canvas canvas, Offset c, Color color) {
    canvas.drawCircle(
      c,
      pinRadius * 1.8,
      Paint()
        ..color = color.withValues(alpha: 0.35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, pinRadius * 0.8),
    );
    canvas.drawCircle(c, pinRadius, Paint()..color = color);
    canvas.drawCircle(
      c,
      pinRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = pinRadius * 0.25
        ..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant FloorPlanPainter old) =>
      old.lineWidth != lineWidth ||
      old.pinRadius != pinRadius ||
      old.selectedId != selectedId ||
      old.progress != progress ||
      old.pulse != pulse ||
      old.isNavigating != isNavigating ||
      old.isArrived != isArrived ||
      !mapEquals(old.occupancy, occupancy);
}
