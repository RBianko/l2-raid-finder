class Boss {
  final int id;
  final String name;
  final int level;
  final Respawn respawn;
  final Position pos;

  bool get isDead => DateTime.now().isBefore(respawn.startTime);

  bool get isRespawning =>
      DateTime.now().isAfter(respawn.startTime) && DateTime.now().isBefore(respawn.endTime);

  Boss({
    required this.id,
    required this.name,
    required this.level,
    required this.respawn,
    required this.pos,
  });

  Boss copyWith({
    int? id,
    String? name,
    int? level,
    Respawn? respawn,
    Position? pos,
  }) {
    return Boss(
      id: id ?? this.id,
      name: name ?? this.name,
      level: level ?? this.level,
      respawn: respawn ?? this.respawn,
      pos: pos ?? this.pos,
    );
  }

  static Boss empty() => Boss(
        id: -1,
        name: '',
        level: 0,
        respawn: Respawn(
          deadAt: DateTime.now(),
          endTime: DateTime.now(),
          startTime: DateTime.now(),
        ),
        pos: Position(
          x: 0,
          y: 0,
        ),
      );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'respawn': respawn.toJson(),
      'pos': pos.toJson(),
    };
  }

  factory Boss.fromJson(Map<String, dynamic> json) => Boss(
        id: json['id'],
        name: json['name'],
        level: json['level'],
        respawn: Respawn.fromJson(json['respawn']),
        pos: Position.fromJson(json['pos']),
      );

  @override
  String toString() {
    return 'Boss{id: $id, name: $name, level: $level, respawn: $respawn}';
  }
}

class Position {
  final double x;
  final double y;

  Position({
    required this.x,
    required this.y,
  });

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
    };
  }

  factory Position.fromJson(Map<String, dynamic> json) => Position(
        x: json['x'],
        y: json['y'],
      );
}

class Respawn {
  final DateTime deadAt;
  final DateTime startTime;
  final DateTime endTime;

  Respawn({
    required this.deadAt,
    required this.startTime,
    required this.endTime,
  });

  @override
  String toString() {
    return 'Respawn{deadAt: ${deadAt.toLocal()}, respawnStart: ${startTime.toLocal()}, respawnEnd: ${endTime.toLocal()}}';
  }

  Map<String, dynamic> toJson() {
    return {
      'deadAt': deadAt.toIso8601String(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String()
    };
  }

  factory Respawn.fromJson(Map<String, dynamic> json) => Respawn(
        deadAt: DateTime.parse(json['deadAt']),
        startTime: DateTime.parse(json['startTime']),
        endTime: DateTime.parse(json['endTime']),
      );
}
