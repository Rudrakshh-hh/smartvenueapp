import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'floor_plan_data.dart';
import 'floor_plan_painter.dart';

/// Pinch-to-zoom, pan and tap-a-room First Floor plan.
///
/// Usage:
/// ```dart
/// final _mapKey = GlobalKey<FloorPlanMapState>();
/// FloorPlanMap(
///   key: _mapKey,
///   occupancy: {'cr117': false, 'room109': true}, // roomId -> isOccupied
///   selectedRoomId: 'cr117',
///   onRoomTap: (room) => print(room.displayName),
/// );
/// _mapKey.currentState?.resetView(); // back to full view
/// ```
class FloorPlanMap extends StatefulWidget {
  const FloorPlanMap({
    super.key,
    this.occupancy = const {},
    this.selectedRoomId,
    this.onRoomTap,
    this.height,
  });

  /// roomId -> isOccupied. Rooms in this map get a status tint + pin.
  final Map<String, bool> occupancy;
  final String? selectedRoomId;
  final ValueChanged<PlanRoom>? onRoomTap;

  /// Fixed height. If null the map takes the plan's natural aspect ratio.
  final double? height;

  @override
  State<FloorPlanMap> createState() => FloorPlanMapState();
}

class FloorPlanMapState extends State<FloorPlanMap> {
  final TransformationController _controller = TransformationController();

  /// Zoom back out to show the whole floor.
  void resetView() => _controller.value = Matrix4.identity();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap(Offset p) {
    // Check top-most shapes first.
    for (final room in kFirstFloorRooms.reversed) {
      if (room.tappable && room.path.contains(p)) {
        widget.onRoomTap?.call(room);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final map = LayoutBuilder(
      builder: (context, constraints) {
        // How much the plan is scaled down to fit this box.
        final fitScale = math.min(
          constraints.maxWidth / kPlanWidth,
          constraints.maxHeight / kPlanHeight,
        );

        return ColoredBox(
          color: FloorPlanPainter.background,
          child: InteractiveViewer(
            transformationController: _controller,
            minScale: 1,
            maxScale: 10,
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: kPlanWidth,
                height: kPlanHeight,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (d) => _handleTap(d.localPosition),
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      // Keep lines/pins a constant size on screen while zooming.
                      final screenScale =
                          fitScale * _controller.value.getMaxScaleOnAxis();
                      return CustomPaint(
                        size: const Size(kPlanWidth, kPlanHeight),
                        painter: FloorPlanPainter(
                          rooms: kFirstFloorRooms,
                          lines: kFirstFloorLines,
                          lineWidth: (1.4 / screenScale).clamp(1.5, 8.0).toDouble(),
                          pinRadius: (6 / screenScale).clamp(7.0, 16.0).toDouble(),
                          selectedId: widget.selectedRoomId,
                          occupancy: widget.occupancy,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (widget.height != null) {
      return SizedBox(height: widget.height, child: map);
    }
    return AspectRatio(aspectRatio: kPlanWidth / kPlanHeight, child: map);
  }
}

/// Full-screen, landscape view of the plan (much easier to read on a phone).
class FloorPlanFullScreen extends StatefulWidget {
  const FloorPlanFullScreen({
    super.key,
    this.occupancy = const {},
    this.initialSelectedId,
    this.onRoomTap,
  });

  final Map<String, bool> occupancy;
  final String? initialSelectedId;
  final ValueChanged<PlanRoom>? onRoomTap;

  static Future<void> open(
    BuildContext context, {
    Map<String, bool> occupancy = const {},
    String? selectedRoomId,
    ValueChanged<PlanRoom>? onRoomTap,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => FloorPlanFullScreen(
          occupancy: occupancy,
          initialSelectedId: selectedRoomId,
          onRoomTap: onRoomTap,
        ),
      ),
    );
  }

  @override
  State<FloorPlanFullScreen> createState() => _FloorPlanFullScreenState();
}

class _FloorPlanFullScreenState extends State<FloorPlanFullScreen> {
  final _mapKey = GlobalKey<FloorPlanMapState>();
  String? _selectedId;
  String? _selectedName;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.initialSelectedId;
    for (final r in kFirstFloorRooms) {
      if (r.id == _selectedId) _selectedName = r.displayName;
    }
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(_selectedName ?? 'First Floor Plan'),
        actions: [
          IconButton(
            tooltip: 'Reset zoom',
            icon: const Icon(Icons.center_focus_strong_outlined),
            onPressed: () => _mapKey.currentState?.resetView(),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: FloorPlanMap(
            key: _mapKey,
            occupancy: widget.occupancy,
            selectedRoomId: _selectedId,
            onRoomTap: (room) {
              setState(() {
                _selectedId = room.id;
                _selectedName = room.displayName;
              });
              widget.onRoomTap?.call(room);
            },
          ),
        ),
      ),
    );
  }
}
