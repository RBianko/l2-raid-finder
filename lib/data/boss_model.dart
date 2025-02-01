int mapRatioDivider = 200;

class BossModel {
  int id;
  String name;
  List<BossSpawn> spawns;
  bool isDead;
  bool highlight;

  BossModel({
    required this.id,
    required this.name,
    required this.spawns,
    this.isDead = false,
    this.highlight = false,
  });

  BossModel copyWith({bool? isDead, bool? highlight}) => BossModel(
        id: id,
        name: name,
        spawns: spawns,
        isDead: isDead ?? this.isDead,
        highlight: highlight ?? this.highlight,
      );

  factory BossModel.fromJson(Map<String, dynamic> json) {
    return BossModel(
      id: json['id'],
      name: json['name'],
      spawns: json['spawns'] == null
          ? []
          : (json['spawns'] as List).map((spawn) => BossSpawn.fromJson(spawn)).toList(),
    );
  }
}

class BossSpawn {
  BossNpc npc;
  List<BossPos> pos;

  BossSpawn({
    required this.npc,
    required this.pos,
  });

  factory BossSpawn.fromJson(Map<String, dynamic> json) {
    return BossSpawn(
      npc: json['npc'] == null ? BossNpc.empty() : BossNpc.fromJson(json['npc']),
      pos: json['pos'] == null
          ? []
          : (json['pos'] as List).map((pos) => BossPos.fromJson(pos)).toList(),
    );
  }

  @override
  String toString() {
    return 'BossSpawn{npc: $npc, pos: $pos}';
  }
}

class BossNpc {
  String npcName;
  int level;

  BossNpc({
    required this.npcName,
    required this.level,
  });

  factory BossNpc.empty() => BossNpc(npcName: '', level: 0);

  factory BossNpc.fromJson(Map<String, dynamic> json) {
    return BossNpc(
      npcName: json['name'] ?? '',
      level: json['level'] ?? 0,
    );
  }

  @override
  String toString() {
    return 'BossNpc{npcName: $npcName, level: $level}';
  }
}

class BossPos {
  double x;
  double y;

  BossPos({
    required this.x,
    required this.y,
  });

  factory BossPos.fromJson(Map<String, dynamic> json) {
    int x = json['x'] ?? 0;
    int y = json['y'] ?? 0;

    double realX = x / mapRatioDivider;
    double realY = y / mapRatioDivider;

    return BossPos(
      x: realX,
      y: realY,
    );
  }

  @override
  String toString() {
    return 'BossPos{x: $x, y: $y}';
  }
}
