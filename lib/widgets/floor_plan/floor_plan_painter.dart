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
  });

  final List<PlanRoom> rooms;
  final List<List<Offset>> lines;

  /// Stroke width in plan pixels (the widget keeps it ~constant on screen).
  final double lineWidth;
  final double pinRadius;
  final String? selectedId;

  /// roomId -> isOccupied
  final Map<String, bool> occupancy;

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
      ..color = Colors.white.withOpacity(0.92);

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
        tint = selected.withOpacity(0.25);
      } else if (isOccupied != null) {
        tint = (isOccupied ? occupied : free).withOpacity(0.28);
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

    // 3) Labels (+ 4) pins, which sit just above the label)
    for (final room in rooms) {
      if (room.label.isEmpty) continue;

      final tp = TextPainter(
        text: TextSpan(
          text: room.label,
          style: TextStyle(
            color: Colors.white,
            fontSize: room.fontSize,
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
      if (isOccupied != null) {
        final d = tp.height / 2 + pinRadius + 6;
        final pinCenter = room.labelAt +
            Offset(d * math.sin(radians), -d * math.cos(radians));
        _paintPin(canvas, pinCenter, isOccupied ? occupied : free);
      }
    }
  }

  void _paintPin(Canvas canvas, Offset c, Color color) {
    canvas.drawCircle(
      c,
      pinRadius * 1.8,
      Paint()
        ..color = color.withOpacity(0.35)
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
      !mapEquals(old.occupancy, occupancy);
}
