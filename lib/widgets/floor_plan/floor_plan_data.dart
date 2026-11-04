import 'package:flutter/material.dart';

/// Size of the reference First Floor plan image, in "plan pixels".
/// Every coordinate in this file is in this space (origin = top-left).
/// Because the map is drawn with CustomPaint and scaled to fit the screen,
/// the layout is identical to the plan on every phone size.
const double kPlanWidth = 2478;
const double kPlanHeight = 1484;

/// One shape on the plan: a room, lift, staircase, washroom, etc.
class PlanRoom {
  PlanRoom({
    required this.id,
    required this.label,
    required this.points,
    required this.labelAt,
    this.angle = 0,
    this.fontSize = 13.5,
    this.lineHeight = 1.8,
    this.tappable = true,
  });

  /// Stable id used to connect a venue (from your API/DB) to this shape.
  final String id;

  /// Text drawn on the plan ('\n' = new line). Empty = unlabelled shape.
  final String label;

  /// Corner points of the shape, in plan pixels.
  final List<Offset> points;

  /// Centre of the label, in plan pixels.
  final Offset labelAt;

  /// Label rotation in degrees (the angled rooms are rotated +/-30).
  final double angle;
  final double fontSize;
  final double lineHeight;

  /// Whether tapping this shape selects it (rooms yes, lifts/stairs no).
  final bool tappable;

  late final Path path = Path()..addPolygon(points, true);

  String get displayName => label.replaceAll('\n', ' ');
}

List<Offset> _rect(double l, double t, double r, double b) =>
    [Offset(l, t), Offset(r, t), Offset(r, b), Offset(l, b)];

/// All shapes of the First Floor, traced from the floor plan image.
final List<PlanRoom> kFirstFloorRooms = [
  PlanRoom(id: 'cr113', label: 'Classroom 113', points: _rect(750, 0, 1030, 148), labelAt: Offset(889, 74)),
  PlanRoom(id: 'cr114', label: 'Classroom 114', points: _rect(1030, 0, 1217, 148), labelAt: Offset(1123, 74)),
  PlanRoom(id: 'cr115', label: 'Classroom 115', points: _rect(1217, 0, 1381, 148), labelAt: Offset(1298, 74)),
  PlanRoom(id: 'cr116', label: 'Classroom 116', points: _rect(1381, 0, 1535, 148), labelAt: Offset(1458, 74)),
  PlanRoom(id: 'cr117', label: 'Classroom 117', points: _rect(1535, 0, 1815, 148), labelAt: Offset(1675, 74)),
  PlanRoom(id: 'stair2', label: 'Stair 2', points: _rect(1815, 55, 1892, 148), labelAt: Offset(1856, 74), fontSize: 11, tappable: false),
  PlanRoom(id: 'room112', label: 'WashRoom Boys\nRoom 112', points: _rect(667, 241, 788, 357), labelAt: Offset(727, 299), fontSize: 11),
  PlanRoom(id: 'room111', label: 'Faculty Washroom\nRoom 111', points: _rect(788, 241, 909, 299), labelAt: Offset(848, 270), fontSize: 10.5, lineHeight: 2),
  PlanRoom(id: 'room110', label: 'Faculty Room\nRoom 110', points: _rect(909, 241, 1030, 299), labelAt: Offset(969, 270), fontSize: 10.5, lineHeight: 2),
  PlanRoom(id: 'room109', label: 'Computer Lab 2\nRoom 109', points: _rect(788, 299, 1030, 450), labelAt: Offset(909, 374), lineHeight: 1.9),
  PlanRoom(id: 'wifi', label: 'Wifi Zone', points: _rect(1110, 241, 1451, 450), labelAt: Offset(1280, 346), tappable: false),
  PlanRoom(id: 'central_stair', label: 'Central Staircase', points: _rect(1228, 362, 1336, 450), labelAt: Offset(1282, 406), fontSize: 11, tappable: false),
  PlanRoom(id: 'male_lift', label: 'Male Lift', points: _rect(1190, 404, 1228, 450), labelAt: Offset(1208, 427), fontSize: 7.5, tappable: false),
  PlanRoom(id: 'female_lift', label: 'Female Lift', points: _rect(1336, 404, 1373, 450), labelAt: Offset(1354, 427), fontSize: 7.5, tappable: false),
  PlanRoom(id: 'room120', label: 'ERP Cell\nRoom 120', points: _rect(1529, 241, 1650, 299), labelAt: Offset(1590, 270), fontSize: 10.5, lineHeight: 2),
  PlanRoom(id: 'room119', label: 'Room 119', points: _rect(1650, 241, 1771, 299), labelAt: Offset(1711, 270), fontSize: 10.5),
  PlanRoom(id: 'room118', label: 'WashRoom Girls\nRoom 118', points: _rect(1771, 241, 1892, 357), labelAt: Offset(1831, 299), fontSize: 11),
  PlanRoom(id: 'room121', label: 'Computer Lab 9\nRoom 121', points: _rect(1529, 299, 1771, 450), labelAt: Offset(1650, 374), lineHeight: 1.9),
  PlanRoom(id: 'room108', label: 'Room 108\nServer Room', points: _rect(1074, 517, 1228, 725), labelAt: Offset(1150, 620), lineHeight: 1.9),
  PlanRoom(id: 'room122', label: 'Room 122', points: _rect(1336, 517, 1490, 725), labelAt: Offset(1413, 620)),
  PlanRoom(id: 'cr107', label: 'Classroom\n107', points: [Offset(874, 672), Offset(1003, 599), Offset(1074, 723), Offset(944, 796)], labelAt: Offset(974, 697), angle: -30, fontSize: 12, lineHeight: 1.5),
  PlanRoom(id: 'lt106', label: '106 (LT)\nLecture Theatre 106', points: [Offset(537, 714), Offset(775, 577), Offset(912, 814), Offset(674, 951)], labelAt: Offset(724, 764), angle: -30, lineHeight: 2),
  PlanRoom(id: 'cr123', label: 'Classroom\n123', points: [Offset(1562, 599), Offset(1690, 672), Offset(1620, 797), Offset(1490, 723)], labelAt: Offset(1590, 698), angle: 30, fontSize: 12, lineHeight: 1.5),
  PlanRoom(id: 'lt124', label: '124 (LT)\nLecture Theatre 124', points: [Offset(1784, 576), Offset(2022, 713), Offset(1885, 950), Offset(1648, 813)], labelAt: Offset(1835, 763), angle: 30, lineHeight: 2),
  PlanRoom(id: 'wash_male', label: 'Washroom Male', points: _rect(511, 972, 637, 1092), labelAt: Offset(574, 1032)),
  PlanRoom(id: 'wash_female', label: 'Washroom Female', points: _rect(1917, 966, 2043, 1087), labelAt: Offset(1980, 1026)),
  PlanRoom(id: 'lab102', label: '102 LAB A/B\nTCL 1, TCL 2', points: _rect(0, 1037, 407, 1389), labelAt: Offset(203, 1212), lineHeight: 2.6),
  PlanRoom(id: 'library', label: 'Library Upper Floor', points: _rect(2137, 1037, 2478, 1373), labelAt: Offset(2306, 1205)),
  PlanRoom(id: 'cr101', label: 'Classroom 101', points: [Offset(475, 1308), Offset(570, 1342), Offset(545, 1409), Offset(452, 1376)], labelAt: Offset(510, 1359), angle: 20, fontSize: 12.5),
  PlanRoom(id: 'vc_office', label: 'Vice Chancellor\'s\nOffice', points: _rect(665, 1372, 758, 1482), labelAt: Offset(711, 1427), fontSize: 11.5, lineHeight: 1.5),
  PlanRoom(id: 'stair_l', label: 'StairCase', points: _rect(758, 1372, 857, 1482), labelAt: Offset(807, 1427), fontSize: 12, tappable: false),
  PlanRoom(id: 'stair_r', label: 'StairCase', points: _rect(1708, 1367, 1807, 1477), labelAt: Offset(1757, 1422), fontSize: 12, tappable: false),
  PlanRoom(id: 'chairman', label: 'Chairman Sir Office', points: _rect(1807, 1367, 2005, 1477), labelAt: Offset(1905, 1422)),
  PlanRoom(id: 'staff_lift_l', label: 'Staff Lift', points: _rect(917, 1236, 972, 1296), labelAt: Offset(944, 1265), fontSize: 11, tappable: false),
  PlanRoom(id: 'staff_lift_r', label: 'Staff Lift', points: _rect(1587, 1236, 1642, 1296), labelAt: Offset(1615, 1265), fontSize: 11, tappable: false),
  PlanRoom(id: 'deco_atrium', label: '', points: [Offset(1087, 829), Offset(1478, 829), Offset(1829, 1032), Offset(1829, 1242), Offset(1642, 1296), Offset(917, 1296), Offset(730, 1242), Offset(730, 1032)], labelAt: Offset(1280, 1060), tappable: false),
  PlanRoom(id: 'deco_cub_l1', label: '', points: _rect(511, 1142, 577, 1208), labelAt: Offset(0, 0), tappable: false),
  PlanRoom(id: 'deco_cub_l2', label: '', points: _rect(577, 1142, 637, 1224), labelAt: Offset(0, 0), tappable: false),
  PlanRoom(id: 'deco_cub_r1', label: '', points: _rect(1917, 1136, 1983, 1224), labelAt: Offset(0, 0), tappable: false),
  PlanRoom(id: 'deco_cub_r2', label: '', points: _rect(1983, 1136, 2043, 1208), labelAt: Offset(0, 0), tappable: false),
  PlanRoom(id: 'deco_sq_l', label: '', points: _rect(761, 241, 788, 274), labelAt: Offset(0, 0), tappable: false),
  PlanRoom(id: 'deco_sq_r', label: '', points: _rect(1771, 241, 1799, 274), labelAt: Offset(0, 0), tappable: false),
];

/// Walls, corridor edges and small details drawn as open lines.
final List<List<Offset>> kFirstFloorLines = [
  [Offset(750, 55), Offset(667, 55), Offset(667, 241)],
  [Offset(1815, 55), Offset(1892, 55), Offset(1892, 241)],
  [Offset(705, 83), Offset(705, 138)],
  [Offset(1853, 88), Offset(1853, 142)],
  [Offset(1282, 384), Offset(1282, 440)],
  [Offset(1030, 450), Offset(1030, 489), Offset(1057, 527), Offset(1074, 517)],
  [Offset(1529, 450), Offset(1529, 489), Offset(1502, 527), Offset(1491, 517)],
  [Offset(898, 787), Offset(913, 780), Offset(922, 785), Offset(935, 802)],
  [Offset(1627, 799), Offset(1637, 781), Offset(1650, 776), Offset(1662, 785)],
  [Offset(648, 907), Offset(611, 928), Offset(637, 972)],
  [Offset(1911, 906), Offset(1944, 922), Offset(1917, 966)],
  [Offset(511, 1092), Offset(511, 1208), Offset(637, 1240), Offset(637, 1092)],
  [Offset(2043, 1087), Offset(2043, 1208), Offset(1917, 1240), Offset(1917, 1224)],
  [Offset(2043, 1208), Offset(2137, 1175)],
  [Offset(2137, 1282), Offset(1895, 1367)],
  [Offset(417, 1181), Offset(511, 1208)],
  [Offset(417, 1181), Offset(412, 1291), Offset(475, 1309)],
  [Offset(570, 1342), Offset(665, 1372)],
  [Offset(857, 1372), Offset(1708, 1368)],
  [Offset(808, 1372), Offset(808, 1482)],
  [Offset(1758, 1367), Offset(1758, 1477)],
];
