import '../domain/boss.dart';
import 'boss_model.dart';

class BossMapper {
  static Boss? fromModel(BossModel model) {
    if (model.spawns.isEmpty) return null;

    BossSpawn bossSpawn = model.spawns.first;

    if (bossSpawn.pos.isEmpty) return null;

    return Boss(
      id: model.id,
      name: model.name,
      level: model.spawns.first.npc.level,
      respawn: Respawn(
        deadAt: DateTime.now(),
        endTime: DateTime.now(),
        startTime: DateTime.now(),
      ),
      pos: Position(
        x: bossSpawn.pos.first.x,
        y: bossSpawn.pos.first.y,
      ),
    );
  }
}
